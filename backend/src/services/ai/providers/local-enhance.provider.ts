import sharp from 'sharp';
import { BaseAIProvider } from './base.provider';
import { EditImageInput, EditImageResult, GeneratePromptInput, GeneratePromptResult } from '../ai.types';

export class LocalEnhanceProvider extends BaseAIProvider {
  readonly name = 'local-enhance';

  async generateEditPrompt(input: GeneratePromptInput): Promise<GeneratePromptResult> {
    const style = input.style || 'warm';
    const userIntent = input.userIntent ? ` (${input.userIntent})` : '';
    return {
      prompt: `Enhance the existing cat photo with balanced lighting, clearer fur textures and vibrant natural colors while preserving original subject features and pose.${userIntent}`,
      style,
      suggestedGuardrails: [
        'Preserve original cat subject',
        'Preserve fur pattern and markings',
        'Keep original pose and composition',
      ],
    };
  }

  async editImage(input: EditImageInput): Promise<EditImageResult> {
    const buffer = Buffer.from(input.imageBase64, 'base64');
    let pipeline = sharp(buffer).rotate(); // auto-orient based on EXIF

    const preset = (input.preset || '').toLowerCase();
    const prompt = (input.prompt || '').toLowerCase();

    if (preset === 'improve_lighting' || preset === 'brighter' || prompt.includes('bright') || prompt.includes('สว่าง')) {
      pipeline = pipeline
        .modulate({
          brightness: 1.18,
          saturation: 1.05,
        })
        .gamma(1.1);
    } else if (preset === 'improve_sharpness' || preset === 'sharp' || prompt.includes('sharp') || prompt.includes('คมชัด')) {
      pipeline = pipeline
        .sharpen({
          sigma: 1.5,
          m1: 1.0,
          m2: 2.0,
        })
        .modulate({
          saturation: 1.08,
        });
    } else if (preset === 'vivid_colors' || preset === 'vivid' || prompt.includes('color') || prompt.includes('สดใส')) {
      pipeline = pipeline
        .modulate({
          brightness: 1.05,
          saturation: 1.35,
        })
        .sharpen({ sigma: 1.0 });
    } else if (preset === 'warm_cozy' || preset === 'warm' || prompt.includes('warm') || prompt.includes('อบอุ่น')) {
      pipeline = pipeline
        .modulate({
          brightness: 1.08,
          saturation: 1.15,
          hue: 8, // slight warm shift
        })
        .tint({ r: 255, g: 242, b: 220 });
    } else if (preset === 'vintage_cat' || preset === 'vintage' || prompt.includes('vintage') || prompt.includes('วินเทจ')) {
      pipeline = pipeline
        .modulate({
          brightness: 1.02,
          saturation: 0.85,
        })
        .tint({ r: 245, g: 225, b: 200 });
    } else if (preset === 'soft_purr' || preset === 'soft' || prompt.includes('soft') || prompt.includes('ละมุน')) {
      pipeline = pipeline
        .modulate({
          brightness: 1.12,
          saturation: 1.02,
        })
        .gamma(1.15);
    } else {
      // Default natural enhancement
      pipeline = pipeline
        .modulate({
          brightness: 1.08,
          saturation: 1.12,
        })
        .sharpen({ sigma: 1.2 });
    }

    const outputBuffer = await pipeline.jpeg({ quality: 90 }).toBuffer();

    return {
      imageBuffer: outputBuffer,
      mimeType: 'image/jpeg',
      format: 'jpeg',
      provider: this.name,
    };
  }
}
