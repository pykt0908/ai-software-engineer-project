import os from 'os';
import path from 'path';
import fs from 'fs/promises';
import { AIImageProvider, EditImageInput, EditImageResult } from './ai.types';
import { OpenRouterProvider } from './providers/openrouter.provider';
import { GeminiProvider } from './providers/gemini.provider';
import { LocalEnhanceProvider } from './providers/local-enhance.provider';

const DAILY_LIMIT = 20;

function startOfUtcDay(): Date {
  const d = new Date();
  d.setUTCHours(0, 0, 0, 0);
  return d;
}

export class AiImageService {
  constructor(private strapi: any) {}

  private getProvider(): AIImageProvider {
    const requested = (process.env.AI_PROVIDER || '').toLowerCase();
    if (requested === 'openrouter') {
      return new OpenRouterProvider();
    }
    if (requested === 'gemini') {
      return new GeminiProvider();
    }
    if (requested === 'local') {
      return new LocalEnhanceProvider();
    }

    if (process.env.OPENROUTER_API_KEY) {
      return new OpenRouterProvider();
    }
    if (process.env.GEMINI_API_KEY) {
      return new GeminiProvider();
    }
    return new LocalEnhanceProvider();
  }

  async editImage({
    imageBuffer,
    mimeType,
    prompt,
    operation,
    preset,
    userId,
  }: {
    imageBuffer: Buffer;
    mimeType: string;
    prompt: string;
    operation: 'enhance' | 'edit';
    preset?: string;
    userId: number;
  }): Promise<
    | { error: 'rate_limit'; message: string }
    | {
        jobId: string;
        status: string;
        prompt: string;
        provider: string;
        resultMedia: {
          id: number;
          url: string;
          width?: number;
          height?: number;
        };
      }
  > {
    // 1. Check daily quota
    const since = startOfUtcDay();
    const usedToday = await (this.strapi.documents('api::ai-image-job.ai-image-job' as any) as any).count({
      filters: {
        user: { id: userId },
        createdAt: { $gte: since.toISOString() },
        status: 'completed',
      },
    });

    if (usedToday >= DAILY_LIMIT) {
      return {
        error: 'rate_limit',
        message: `วันนี้ใช้ AI แต่งภาพครบ ${DAILY_LIMIT} ครั้งแล้ว ลองใหม่พรุ่งนี้`,
      };
    }

    const provider = this.getProvider();
    const imageBase64 = imageBuffer.toString('base64');

    let editResult: EditImageResult;
    try {
      editResult = await provider.editImage({
        imageBase64,
        mimeType,
        prompt,
        operation,
        preset,
      });
    } catch (err: any) {
      // If primary provider fails and it was not local enhance, try local fallback
      if (provider.name !== 'local-enhance') {
        console.warn(`Primary AI provider (${provider.name}) failed, falling back to local-enhance:`, err?.message || err);
        const fallback = new LocalEnhanceProvider();
        editResult = await fallback.editImage({
          imageBase64,
          mimeType,
          prompt,
          operation,
          preset,
        });
      } else {
        throw err;
      }
    }

    // 2. Save result image to temporary file for Strapi upload
    const filename = `ai_edit_${Date.now()}.${editResult.format}`;
    const tmpFilePath = path.join(os.tmpdir(), filename);
    await fs.writeFile(tmpFilePath, editResult.imageBuffer);

    let uploadedMedia: any = null;
    try {
      const stats = await fs.stat(tmpFilePath);
      const fileData = {
        filepath: tmpFilePath,
        originalFilename: filename,
        mimetype: editResult.mimeType,
        size: stats.size,
      };

      const uploadResult = await this.strapi
        .plugin('upload')
        .service('upload')
        .upload({
          data: {},
          files: fileData,
        });

      uploadedMedia = Array.isArray(uploadResult) ? uploadResult[0] : uploadResult;
    } finally {
      // Clean up temp file
      await fs.unlink(tmpFilePath).catch(() => undefined);
    }

    if (!uploadedMedia) {
      throw new Error('Failed to store generated image in Strapi media library');
    }

    // 3. Create AIImageJob record
    const job = await (this.strapi.documents('api::ai-image-job.ai-image-job' as any) as any).create({
      data: {
        status: 'completed',
        operation,
        prompt,
        provider: editResult.provider,
        resultMedia: uploadedMedia.id,
        user: userId,
      },
    });

    return {
      jobId: job.documentId,
      status: 'completed',
      prompt,
      provider: editResult.provider,
      resultMedia: {
        id: uploadedMedia.id,
        url: uploadedMedia.url,
        width: uploadedMedia.width,
        height: uploadedMedia.height,
      },
    };
  }
}
