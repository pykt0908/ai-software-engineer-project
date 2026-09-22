export interface GeneratePromptInput {
  imageBase64: string;
  mimeType: string;
  userIntent?: string;
  style?: string;
}

export interface GeneratePromptResult {
  prompt: string;
  style?: string;
  suggestedGuardrails?: string[];
}

export interface EditImageInput {
  imageBase64: string;
  mimeType: string;
  prompt: string;
  operation: 'enhance' | 'edit';
  preset?: string;
}

export interface EditImageResult {
  imageBuffer: Buffer;
  mimeType: string;
  format: string;
  provider: string;
}

export interface AIImageProvider {
  readonly name: string;
  generateEditPrompt(input: GeneratePromptInput): Promise<GeneratePromptResult>;
  editImage(input: EditImageInput): Promise<EditImageResult>;
}
