import { BaseAIProvider } from './base.provider';
import { EditImageInput, EditImageResult, GeneratePromptInput, GeneratePromptResult } from '../ai.types';
import { LocalEnhanceProvider } from './local-enhance.provider';

const GEMINI_MODELS = [
  'gemini-3.6-flash',
  'gemini-flash-lite-latest',
  'gemini-3.1-flash-lite',
  'gemini-3.5-flash',
];

export class GeminiProvider extends BaseAIProvider {
  readonly name = 'gemini';
  private localFallback = new LocalEnhanceProvider();

  private get apiKey(): string {
    const key = process.env.GEMINI_API_KEY;
    if (!key) {
      throw new Error('GEMINI_API_KEY is not configured');
    }
    return key.trim();
  }

  async generateEditPrompt(input: GeneratePromptInput): Promise<GeneratePromptResult> {
    const userIntent = input.userIntent?.trim() || '';
    const style = input.style || 'natural';

    const promptInstruction = `มองรูปแมวนี้ แล้วเขียนคำสั่ง (Editing Prompt) สำหรับนำไปใช้กับ AI แต่งรูปภาพ (Image-to-image)
สิ่งที่ผู้ใช้ต้องการ: "${userIntent || 'แต่งให้สวยขึ้น มีชีวิตชีวา'}"
สไตล์ที่เลือก: "${style}"

ข้อกำหนดสำคัญ (AI Guardrails):
1. ต้องเป็นการปรับปรุงรูปเดิม ไม่ใช่สร้างรูปใหม่ที่ไม่เกี่ยวข้องกัน
2. เน้นการปรับแสง (lighting), บรรยากาศ (mood/ambience), โทนสี (color grading), ความคมชัด และพื้นหลัง
3. ย้ำให้คงเอกลักษณ์ของแมวตัวเดิม (สายพันธุ์, ลวดลายขน, ท่าทาง, จุดเด่นบนใบหน้า) และคงองค์ประกอบหลักของภาพไว้
4. เขียนผลลัพธ์เป็นข้อความภาษาอังกฤษสั้นกระชับ 2-3 ประโยค ที่โมเดลแต่งรูปเข้าใจง่าย พร้อมสรุปสั้นๆ เป็นภาษาไทย 1 ประโยค
5. ตอบเฉพาะตัว prompt โดยตรง ไม่ต้องมีคำนำหรือเครื่องหมายคำพูด`;

    const mime = input.mimeType.startsWith('image/') ? input.mimeType : 'image/jpeg';

    for (const model of GEMINI_MODELS) {
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${this.apiKey}`;
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [
              {
                parts: [
                  {
                    inlineData: {
                      mimeType: mime,
                      data: input.imageBase64,
                    },
                  },
                  { text: promptInstruction },
                ],
              },
            ],
            generationConfig: {
              temperature: 0.7,
              maxOutputTokens: 1024,
            },
          }),
        });

        if (response.ok) {
          const data = await response.json() as any;
          const text = data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || '';
          if (text) {
            return {
              prompt: text,
              style,
              suggestedGuardrails: [
                'Preserve original cat subject',
                'Preserve fur pattern and markings',
                'Keep original pose and composition',
              ],
            };
          }
        }
      } catch (err) {
        console.warn(`Gemini model ${model} failed for prompt generation, trying next:`, err);
      }
    }

    // Fallback to local prompt generator
    return this.localFallback.generateEditPrompt(input);
  }

  async editImage(input: EditImageInput): Promise<EditImageResult> {
    // If OPENROUTER_API_KEY is available, delegate editImage to OpenRouter!
    if (process.env.OPENROUTER_API_KEY) {
      try {
        const { OpenRouterProvider } = await import('./openrouter.provider');
        const openrouter = new OpenRouterProvider();
        return await openrouter.editImage(input);
      } catch (orErr) {
        console.warn('OpenRouter image edit failed, falling back to local enhance:', orErr);
      }
    }

    // Fallback to high quality sharp local enhancement
    return this.localFallback.editImage(input);
  }
}
