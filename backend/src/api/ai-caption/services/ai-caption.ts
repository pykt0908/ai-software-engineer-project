import fs from 'fs/promises';

const DAILY_LIMIT = 20;

const STYLE_PROMPTS: Record<string, string> = {
  cute: 'เขียน caption ภาษาไทยแนวน่ารักฟรุ้งฟริ้ง ใส่ emoji ที่เกี่ยวข้อง',
  funny: 'เขียน caption ภาษาไทยแนวตลก มีมุก ใส่ emoji',
  sassy: 'เขียน caption ภาษาไทยแนวกวนๆ แสบๆ นิดหน่อย ใส่ emoji',
  short: 'เขียน caption ภาษาไทยสั้นกระชับ ไม่เกิน 10 คำ ใส่ emoji 1 ตัว',
};

type GenerateInput = {
  filepath: string;
  mimeType: string;
  style: string;
  userId: number;
};

function startOfUtcDay(): Date {
  const d = new Date();
  d.setUTCHours(0, 0, 0, 0);
  return d;
}

function normalizeCaptionList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value
    .map((item) => {
      if (typeof item === 'string') return item.trim();
      if (item && typeof item === 'object' && typeof (item as any).caption === 'string') {
        return String((item as any).caption).trim();
      }
      if (item && typeof item === 'object' && typeof (item as any).text === 'string') {
        return String((item as any).text).trim();
      }
      return '';
    })
    .filter((item) => item.length > 0)
    .slice(0, 3);
}

function parseCaptions(text: string): string[] {
  const cleaned = text.replace(/```json|```/gi, '').trim();

  try {
    const parsed = JSON.parse(cleaned);
    if (Array.isArray(parsed)) {
      return normalizeCaptionList(parsed);
    }
    if (parsed && typeof parsed === 'object') {
      const fromKeys =
        (parsed as any).captions ?? (parsed as any).data ?? (parsed as any).items;
      const normalized = normalizeCaptionList(fromKeys);
      if (normalized.length > 0) return normalized;
    }
  } catch {
    // fall through
  }

  const arrayMatch = cleaned.match(/\[[\s\S]*\]/);
  if (arrayMatch) {
    try {
      const parsed = JSON.parse(arrayMatch[0]);
      const normalized = normalizeCaptionList(parsed);
      if (normalized.length > 0) return normalized;
    } catch {
      // fall through
    }
  }

  const lines = cleaned
    .split('\n')
    .map((line) =>
      line
        .replace(/^[\d\-\*\.]+\s*/, '')
        .replace(/^["']|["',]$/g, '')
        .trim(),
    )
    .filter((line) => line.length > 0 && !line.startsWith('[') && !line.startsWith('{'));

  return lines.slice(0, 3);
}

function extractTextFromGemini(data: any): string {
  const parts = data?.candidates?.[0]?.content?.parts;
  if (!Array.isArray(parts)) return '';

  return parts
    .map((part: any) => (typeof part?.text === 'string' ? part.text : ''))
    .filter(Boolean)
    .join('\n')
    .trim();
}

const GEMINI_MODELS = [
  'gemini-flash-lite-latest',
  'gemini-3.1-flash-lite',
  'gemini-3.5-flash-lite',
  'gemini-3.6-flash',
  'gemini-3.5-flash',
];

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function callGeminiOnce(
  model: string,
  apiKey: string,
  imageBase64: string,
  mimeType: string,
  instruction: string,
): Promise<string[]> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [
        {
          parts: [
            {
              inlineData: {
                mimeType: mimeType.startsWith('image/') ? mimeType : 'image/jpeg',
                data: imageBase64,
              },
            },
            { text: instruction },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.9,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
        responseSchema: {
          type: 'OBJECT',
          properties: {
            captions: {
              type: 'ARRAY',
              items: { type: 'STRING' },
              minItems: 3,
              maxItems: 3,
            },
          },
          required: ['captions'],
        },
      },
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    const error = new Error(`Gemini API failed with status ${response.status}`) as Error & {
      status?: number;
      body?: string;
    };
    error.status = response.status;
    error.body = errText;
    throw error;
  }

  const data = (await response.json()) as any;
  const finishReason = data?.candidates?.[0]?.finishReason;
  const text = extractTextFromGemini(data);
  const captions = parseCaptions(text);

  if (captions.length < 2) {
    console.error('Gemini invalid caption payload', {
      model,
      finishReason,
      textPreview: text.slice(0, 500),
    });
    throw new Error('Gemini returned invalid caption payload');
  }

  return captions;
}

async function callGemini(imageBase64: string, mimeType: string, style: string): Promise<string[]> {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is not configured');
  }

  const promptInstruction = STYLE_PROMPTS[style] || STYLE_PROMPTS.cute;
  const instruction = `มองรูปสัตว์เลี้ยงนี้ แล้ว${promptInstruction}
สร้าง caption ภาษาไทย 3 แบบ
ตอบเป็น JSON object เท่านั้น ในรูปแบบ {"captions":["...","...","..."]}
ห้ามมีข้อความอื่นนอก JSON`;

  let lastError: unknown;

  for (const model of GEMINI_MODELS) {
    for (let attempt = 0; attempt < 2; attempt += 1) {
      try {
        const captions = await callGeminiOnce(
          model,
          apiKey,
          imageBase64,
          mimeType,
          instruction,
        );
        if (model !== GEMINI_MODELS[0] || attempt > 0) {
          console.info(`Gemini caption succeeded with model=${model} attempt=${attempt + 1}`);
        }
        return captions;
      } catch (err: any) {
        lastError = err;
        const status = err?.status;
        console.error(
          `Gemini API error model=${model} attempt=${attempt + 1} status=${status ?? 'n/a'}: ${err?.body || err?.message}`,
        );

        // Retry same model once on transient overload / rate limit.
        if ((status === 503 || status === 429) && attempt === 0) {
          await sleep(800);
          continue;
        }

        // Try next model on overload / not found / unavailable.
        if (status === 503 || status === 429 || status === 404) {
          break;
        }

        // Non-retryable for this request.
        throw err;
      }
    }
  }

  throw lastError instanceof Error
    ? lastError
    : new Error('Gemini API failed after retries');
}

export default ({ strapi }: { strapi: any }) => ({
  async generateCaptions({ filepath, mimeType, style, userId }: GenerateInput) {
    const since = startOfUtcDay();
    const usedToday = await strapi.documents('api::ai-caption-log.ai-caption-log').count({
      filters: {
        user: { id: userId },
        createdAt: { $gte: since.toISOString() },
      },
    });

    if (usedToday >= DAILY_LIMIT) {
      return {
        error: 'rate_limit' as const,
        message: `วันนี้ใช้ AI สร้าง caption ครบ ${DAILY_LIMIT} ครั้งแล้ว ลองใหม่พรุ่งนี้`,
      };
    }

    const buffer = await fs.readFile(filepath);
    const imageBase64 = buffer.toString('base64');
    const captions = await callGemini(imageBase64, mimeType, style);

    await strapi.documents('api::ai-caption-log.ai-caption-log').create({
      data: {
        user: userId,
        style,
        resultCount: captions.length,
      },
    });

    return { captions, style };
  },
});
