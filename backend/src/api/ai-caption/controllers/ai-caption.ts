const ALLOWED_STYLES = ['cute', 'funny', 'sassy', 'short'] as const;

function pickImageFile(files: any) {
  if (!files) return null;
  const raw = files.image ?? files.files;
  if (!raw) return null;
  return Array.isArray(raw) ? raw[0] : raw;
}

export default {
  async generate(ctx: any) {
    const user = ctx.state.user;
    if (!user) {
      return ctx.unauthorized('Authentication required');
    }

    const styleRaw =
      typeof ctx.request.body?.style === 'string'
        ? ctx.request.body.style.trim().toLowerCase()
        : 'cute';
    const style = (ALLOWED_STYLES as readonly string[]).includes(styleRaw)
      ? styleRaw
      : 'cute';

    const imageFile = pickImageFile(ctx.request.files);
    if (!imageFile) {
      return ctx.badRequest('กรุณาแนบรูปภาพ');
    }

    const filepath = imageFile.filepath || imageFile.path;
    const mimeType = imageFile.mimetype || imageFile.type || 'image/jpeg';
    if (!filepath) {
      return ctx.badRequest('กรุณาแนบรูปภาพ');
    }

    try {
      const result = await strapi
        .service('api::ai-caption.ai-caption')
        .generateCaptions({
          filepath,
          mimeType,
          style,
          userId: user.id,
        });

      if (result.error === 'rate_limit') {
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

      ctx.body = {
        data: {
          captions: result.captions,
          style: result.style,
        },
      };
    } catch (err: any) {
      strapi.log.error('AI caption generation failed', err);
      const status = err?.status;
      if (status === 503 || status === 429) {
        ctx.status = 503;
        ctx.body = {
          error: {
            status: 503,
            name: 'ServiceUnavailableError',
            message: 'AI กำลังหนาแน่นอยู่ กรุณาลองใหม่สักครู่',
          },
        };
        return;
      }
      return ctx.internalServerError('สร้าง caption ไม่สำเร็จ กรุณาลองใหม่');
    }
  },
};
