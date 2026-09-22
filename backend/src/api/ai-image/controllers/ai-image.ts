import fs from 'fs/promises';

function pickImageFile(files: any) {
  if (!files) return null;
  const raw = files.image ?? files.files;
  if (!raw) return null;
  return Array.isArray(raw) ? raw[0] : raw;
}

export default {
  async generateEditPrompt(ctx: any) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const body = ctx.request.body || {};
    const userIntent = typeof body.userIntent === 'string' ? body.userIntent.trim() : '';
    const style = typeof body.style === 'string' ? body.style.trim().toLowerCase() : 'natural';

    let imageBase64 = '';
    let mimeType = 'image/jpeg';

    const imageFile = pickImageFile(ctx.request.files);
    if (imageFile) {
      const filepath = imageFile.filepath || imageFile.path;
      mimeType = imageFile.mimetype || imageFile.type || 'image/jpeg';
      const buffer = await fs.readFile(filepath);
      imageBase64 = buffer.toString('base64');
    } else if (typeof body.imageBase64 === 'string' && body.imageBase64.length > 0) {
      imageBase64 = body.imageBase64.replace(/^data:image\/[a-zA-Z0-9]+;base64,/, '');
      mimeType = typeof body.mimeType === 'string' ? body.mimeType : 'image/jpeg';
    } else {
      return ctx.badRequest('กรุณาแนบรูปภาพสำหรับวิเคราะห์');
    }

    try {
      const result = await strapi
        .service('api::ai-image.ai-image')
        .generateEditPrompt({
          imageBase64,
          mimeType,
          userIntent,
          style,
        });

      return {
        data: result,
      };
    } catch (err: any) {
      strapi.log.error('AI generate edit prompt failed', err);
      return ctx.internalServerError('สร้าง prompt ไม่สำเร็จ: ' + (err?.message || 'ข้อผิดพลาดภายในระบบ'));
    }
  },

  async editImage(ctx: any) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const body = ctx.request.body || {};
    const prompt = typeof body.prompt === 'string' ? body.prompt.trim() : '';
    const operation = body.operation === 'enhance' ? 'enhance' : 'edit';
    const preset = typeof body.preset === 'string' ? body.preset.trim() : undefined;

    let imageBuffer: Buffer;
    let mimeType = 'image/jpeg';

    const imageFile = pickImageFile(ctx.request.files);
    if (imageFile) {
      const filepath = imageFile.filepath || imageFile.path;
      mimeType = imageFile.mimetype || imageFile.type || 'image/jpeg';
      imageBuffer = await fs.readFile(filepath);
    } else if (typeof body.imageBase64 === 'string' && body.imageBase64.length > 0) {
      const cleanB64 = body.imageBase64.replace(/^data:image\/[a-zA-Z0-9]+;base64,/, '');
      mimeType = typeof body.mimeType === 'string' ? body.mimeType : 'image/jpeg';
      imageBuffer = Buffer.from(cleanB64, 'base64');
    } else {
      return ctx.badRequest('กรุณาแนบรูปภาพที่ต้องการแต่ง');
    }

    try {
      const result = await strapi
        .service('api::ai-image.ai-image')
        .editImage({
          imageBuffer,
          mimeType,
          prompt: prompt || preset || 'Enhance cat photo',
          operation,
          preset,
          userId: user.id,
        });

      if ('error' in result && result.error === 'rate_limit') {
        ctx.status = 429;
        ctx.body = {
          error: {
            status: 429,
            name: 'TooManyRequestsError',
            message: result.message,
          },
        };
        return;
      }

      return {
        data: result,
      };
    } catch (err: any) {
      strapi.log.error('AI edit image failed', err);
      const status = err?.status;
      if (status === 503 || status === 429) {
        ctx.status = 503;
        ctx.body = {
          error: {
            status: 503,
            name: 'ServiceUnavailableError',
            message: 'AI ให้บริการหนาแน่น กรุณาลองใหม่อีกครั้ง',
          },
        };
        return;
      }
      return ctx.internalServerError('แต่งรูปภาพไม่สำเร็จ: ' + (err?.message || 'โปรดลองใหม่อีกครั้ง'));
    }
  },

  async getJob(ctx: any) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const documentId = ctx.params.documentId || ctx.params.id;
    if (!documentId) {
      return ctx.badRequest('Missing job id');
    }

    const jobDoc = strapi.documents('api::ai-image-job.ai-image-job' as any) as any;
    const job = await jobDoc.findOne({
      documentId,
      populate: ['resultMedia', 'user'],
    });

    if (!job) {
      return ctx.notFound('Job not found');
    }

    const jobAny = job as any;
    if (jobAny.user?.id !== user.id && jobAny.user?.documentId !== user.documentId) {
      return ctx.forbidden('Access denied');
    }

    return {
      data: {
        documentId: jobAny.documentId,
        status: jobAny.status,
        operation: jobAny.operation,
        prompt: jobAny.prompt,
        provider: jobAny.provider,
        resultMedia: jobAny.resultMedia
          ? {
              id: jobAny.resultMedia.id,
              url: jobAny.resultMedia.url,
            }
          : null,
        errorMessage: jobAny.errorMessage,
        createdAt: jobAny.createdAt,
      },
    };
  },

  async cancelJob(ctx: any) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const documentId = ctx.params.documentId || ctx.params.id;
    if (!documentId) {
      return ctx.badRequest('Missing job id');
    }

    const jobDoc = strapi.documents('api::ai-image-job.ai-image-job' as any) as any;
    const job = await jobDoc.findOne({
      documentId,
      populate: ['user'],
    });

    if (!job) {
      return ctx.notFound('Job not found');
    }

    const jobAny = job as any;
    if (jobAny.user?.id !== user.id) {
      return ctx.forbidden('Access denied');
    }

    const updated = await jobDoc.update({
      documentId,
      data: {
        status: 'cancelled',
      },
    });

    return {
      data: {
        documentId: updated?.documentId || documentId,
        status: 'cancelled',
      },
    };
  },
};
