import { AiImageService } from '../../../services/ai/ai-image.service';
import { AiPromptService } from '../../../services/ai/ai-prompt.service';

export default ({ strapi }: { strapi: any }) => {
  const imageService = new AiImageService(strapi);
  const promptService = new AiPromptService();

  return {
    async generateEditPrompt(input: {
      imageBase64: string;
      mimeType: string;
      userIntent?: string;
      style?: string;
    }) {
      return await promptService.generatePrompt(input);
    },

    async editImage(input: {
      imageBuffer: Buffer;
      mimeType: string;
      prompt: string;
      operation: 'enhance' | 'edit';
      preset?: string;
      userId: number;
    }) {
      return await imageService.editImage(input);
    },
  };
};
