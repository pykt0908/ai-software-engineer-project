import { BaseAIProvider } from './base.provider';
import { EditImageInput, EditImageResult, GeneratePromptInput, GeneratePromptResult } from '../ai.types';

export class OpenRouterProvider extends BaseAIProvider {
  readonly name = 'openrouter';

  private get apiKey(): string {
    const key = process.env.OPENROUTER_API_KEY;
    if (!key) {
      throw new Error('OPENROUTER_API_KEY is not configured');
    }
    return key.trim();
  }

  private get imageModel(): string {
    return process.env.OPENROUTER_IMAGE_MODEL || 'google/gemini-2.5-flash-image';
  }

  private get promptModel(): string {
    return process.env.OPENROUTER_PROMPT_MODEL || 'google/gemini-2.5-flash';
  }

  async generateEditPrompt(input: GeneratePromptInput): Promise<GeneratePromptResult> {
    const userIntent = input.userIntent?.trim() || '';
    const style = input.style || 'natural';

    const systemInstruction = `You are an expert AI photo editor for cat photos.
Analyze the provided cat photo and create a clear, natural-language editing instruction for an image-to-image AI model.
Guidelines:
1. Focus on editing, enhancing, lighting, mood, atmosphere, and stylistic improvements for THIS SPECIFIC CAT PHOTO.
2. ALWAYS enforce guardrails: Preserve the cat's physical identity, fur color/pattern, pose, and original composition unless explicitly asked.
3. If user intent is provided, honor it: "${userIntent || 'Enhance photo nicely'}".
4. Style requested: "${style}".
5. Return ONLY a single concise, effective editing prompt (2-4 sentences in English, with optional Thai summary if user wrote in Thai). Do not include disclaimers or markdown formatting.`;

    const dataUrl = `data:${input.mimeType.startsWith('image/') ? input.mimeType : 'image/jpeg'};base64,${input.imageBase64}`;

    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://instacat.app',
        'X-Title': 'InstaCat AI Photo Studio',
      },
      body: JSON.stringify({
        model: this.promptModel,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: systemInstruction },
              { type: 'image_url', image_url: { url: dataUrl } },
            ],
          },
        ],
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`OpenRouter prompt generation failed (${response.status}): ${errText}`);
    }

    const data = await response.json() as any;
    const content = data?.choices?.[0]?.message?.content?.trim() || '';

    return {
      prompt: content || `Enhance the cat photo with ${style} lighting and clear textures while preserving the original cat's appearance and composition.`,
      style,
      suggestedGuardrails: [
        'Preserve original cat subject',
        'Keep fur pattern and markings',
        'Maintain original composition',
      ],
    };
  }

  async editImage(input: EditImageInput): Promise<EditImageResult> {
    const mimeType = input.mimeType.startsWith('image/') ? input.mimeType : 'image/jpeg';
    const dataUrl = `data:${mimeType};base64,${input.imageBase64}`;

    const promptWithGuardrails = `${input.prompt}. Ensure the cat's core features, fur pattern and pose are preserved with high fidelity.`;

    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://instacat.app',
        'X-Title': 'InstaCat AI Photo Studio',
      },
      body: JSON.stringify({
        model: this.imageModel,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: promptWithGuardrails },
              { type: 'image_url', image_url: { url: dataUrl } },
            ],
          },
        ],
        modalities: ['image'],
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`OpenRouter image editing failed (${response.status}): ${errText}`);
    }

    const data = await response.json() as any;
    const images = data?.choices?.[0]?.message?.images;

    if (!Array.isArray(images) || images.length === 0) {
      // Check if image data is embedded in message content as base64 or markdown
      const content = data?.choices?.[0]?.message?.content || '';
      const b64Match = content.match(/data:image\/(png|jpeg|jpg|webp);base64,([A-Za-z0-9+/=]+)/);
      if (b64Match) {
        const format = b64Match[1] === 'jpg' ? 'jpeg' : b64Match[1];
        const buffer = Buffer.from(b64Match[2], 'base64');
        return {
          imageBuffer: buffer,
          mimeType: `image/${format}`,
          format,
          provider: this.name,
        };
      }
      throw new Error('OpenRouter did not return image data in the response');
    }

    const firstImage = images[0];
    const imageUrl = firstImage?.image_url?.url || '';
    if (!imageUrl.startsWith('data:image/')) {
      throw new Error('Unexpected image URL format from OpenRouter');
    }

    const matches = imageUrl.match(/^data:image\/([a-zA-Z0-9]+);base64,(.+)$/);
    if (!matches) {
      throw new Error('Failed to parse base64 image data from OpenRouter');
    }

    const format = matches[1].toLowerCase() === 'jpg' ? 'jpeg' : matches[1].toLowerCase();
    const buffer = Buffer.from(matches[2], 'base64');

    return {
      imageBuffer: buffer,
      mimeType: `image/${format}`,
      format,
      provider: this.name,
    };
  }
}
