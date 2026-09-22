import { AIImageProvider, GeneratePromptInput, GeneratePromptResult } from './ai.types';
import { OpenRouterProvider } from './providers/openrouter.provider';
import { GeminiProvider } from './providers/gemini.provider';
import { LocalEnhanceProvider } from './providers/local-enhance.provider';

export class AiPromptService {
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

    // Default auto selection:
    if (process.env.OPENROUTER_API_KEY) {
      return new OpenRouterProvider();
    }
    if (process.env.GEMINI_API_KEY) {
      return new GeminiProvider();
    }
    return new LocalEnhanceProvider();
  }

  async generatePrompt(input: GeneratePromptInput): Promise<GeneratePromptResult> {
    const provider = this.getProvider();
    return await provider.generateEditPrompt(input);
  }
}
