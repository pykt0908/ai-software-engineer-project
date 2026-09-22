import { AIImageProvider, EditImageInput, EditImageResult, GeneratePromptInput, GeneratePromptResult } from '../ai.types';

export abstract class BaseAIProvider implements AIImageProvider {
  abstract readonly name: string;

  abstract generateEditPrompt(input: GeneratePromptInput): Promise<GeneratePromptResult>;
  abstract editImage(input: EditImageInput): Promise<EditImageResult>;
}
