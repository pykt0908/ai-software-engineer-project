# Feature Spec: AI Caption Generator 📝

> เอกสารนี้เขียนเพื่อใช้เป็น prompt/บรีฟสำหรับสั่งงาน Cursor ในการ implement ฟีเจอร์ AI สร้าง Caption อัตโนมัติสำหรับรูปสัตว์เลี้ยง (เช่น แมว)
> Stack: **Flutter** (frontend) + **Strapi** (backend/CMS) + **PostgreSQL** (database)

---

## 1. ภาพรวม (Overview)

เมื่อผู้ใช้กำลังจะโพสต์รูปสัตว์เลี้ยง ให้มีปุ่ม `✨ Generate with AI` อยู่ในหน้าสร้างโพสต์ เมื่อกดแล้ว:

1. แอปส่งรูปที่เลือกไปให้ backend
2. Backend เรียก AI Vision Model วิเคราะห์รูป แล้วสร้าง caption แนว "น่ารัก/มีมุกตลก" พร้อม emoji
3. ผู้ใช้เลือก **Style** ของ caption ได้ (เช่น น่ารัก / ตลก / กวนๆ / สั้นกระชับ)
4. ผู้ใช้เลือก caption ที่ชอบ (หรือกดสุ่มใหม่) แล้วนำไปแก้ไขต่อ/โพสต์ได้ทันที

ตัวอย่าง output: `"วันนี้น้องขอเป็นเจ้าของโซฟาทั้งวัน 🐱🛋️"`

---

## 2. User Flow

```
[หน้าสร้างโพสต์] 
   → เลือกรูปภาพ 
   → กดปุ่ม "✨ Generate with AI" 
   → เลือก Style (chip selector) 
   → Loading state (skeleton/shimmer) 
   → แสดงตัวเลือก caption 2-3 แบบ 
   → ผู้ใช้แตะเลือก 1 อัน (หรือกด "สุ่มใหม่") 
   → Caption ถูกใส่ลงใน text field อัตโนมัติ (แก้ไขต่อได้) 
   → กดโพสต์ตามปกติ
```

---

## 3. Frontend (Flutter)

### 3.1 UI Components ที่ต้องเพิ่ม
- `AiCaptionButton` — ปุ่ม `✨ Generate with AI` วางใต้/ข้าง image picker
- `CaptionStyleSelector` — แถว chip เลือกสไตล์ (ดูหัวข้อ 3.2)
- `AiCaptionSuggestionSheet` — bottom sheet แสดงผล caption 2-3 ตัวเลือกให้เลือก พร้อมปุ่ม "สุ่มใหม่" (regenerate)
- Loading/shimmer state ระหว่างรอ AI ตอบกลับ
- Error state (เช่น รูปไม่ชัด, API timeout, rate limit เกิน) พร้อมปุ่ม retry

### 3.2 Style Options (enum)
```dart
enum CaptionStyle {
  cute,      // น่ารักฟรุ้งฟริ้ง
  funny,     // ตลก/มีมุก
  sassy,     // กวนๆ/แสบๆ
  short,     // สั้น กระชับ
}
```

### 3.3 State Management
- ใช้ pattern เดิมของโปรเจกต์ (Provider/Riverpod/Bloc — ระบุใน Cursor ตามที่โปรเจกต์ใช้อยู่จริง)
- เพิ่ม `AiCaptionController` หรือเทียบเท่า รับผิดชอบ:
  - เก็บสถานะ: `idle | loading | success(List<String>) | error(String)`
  - เรียก `AiCaptionRepository.generate(imageFile, style)`
  - เก็บ cache ผลลัพธ์ล่าสุดต่อรูป (กันยิง API ซ้ำถ้าผู้ใช้แค่สลับดู)

### 3.4 API Call (ตัวอย่าง)
```dart
class AiCaptionRepository {
  final Dio dio;

  Future<List<String>> generate({
    required File imageFile,
    required CaptionStyle style,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
      'style': style.name,
    });

    final response = await dio.post(
      '/api/ai-caption/generate',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return List<String>.from(response.data['data']['captions']);
  }
}
```

### 3.5 UX Notes
- Limit ขนาดรูปก่อนอัปโหลด (compress ~1-2MB) เพื่อลด latency/ค่าใช้จ่าย AI API
- แสดง caption แบบ streaming/typewriter effect ถ้า backend รองรับ SSE (ไม่บังคับ, nice-to-have)
- Debounce ปุ่ม generate ป้องกันกดรัว

---

## 4. Backend (Strapi)

### 4.1 Custom API Endpoint
สร้าง custom route ใน Strapi (ไม่ใช้ auto-generated CRUD เพราะ logic นี้เป็น action ไม่ใช่ resource):

```
POST /api/ai-caption/generate
```

**Request (multipart/form-data):**
| field | type | description |
|---|---|---|
| image | file | รูปที่จะวิเคราะห์ |
| style | string | `cute` \| `funny` \| `sassy` \| `short` |

**Response:**
```json
{
  "data": {
    "captions": [
      "วันนี้น้องขอเป็นเจ้าของโซฟาทั้งวัน 🐱🛋️",
      "มองอะไร ที่นี่บ้านของหนูเอง 😼",
      "ขี้เกียจสุดในรอบวัน 💤🐾"
    ],
    "style": "funny"
  }
}
```

### 4.2 โครงสร้างไฟล์ Strapi (v4/v5 style)
```
src/api/ai-caption/
  ├── routes/ai-caption.js
  ├── controllers/ai-caption.js
  └── services/ai-caption.js
```

**routes/ai-caption.js**
```js
module.exports = {
  routes: [
    {
      method: 'POST',
      path: '/ai-caption/generate',
      handler: 'ai-caption.generate',
      config: {
        policies: ['global::is-authenticated'], // ปรับตามระบบ auth จริง
      },
    },
  ],
};
```

**controllers/ai-caption.js**
```js
module.exports = {
  async generate(ctx) {
    const { files, body } = ctx.request;
    const style = body.style || 'cute';
    const imageFile = files.image;

    if (!imageFile) {
      return ctx.badRequest('กรุณาแนบรูปภาพ');
    }

    try {
      const captions = await strapi
        .service('api::ai-caption.ai-caption')
        .generateCaptions(imageFile, style);

      // (optional) log การเรียกใช้เพื่อ rate limit / analytics
      await strapi.entityService.create('api::ai-caption-log.ai-caption-log', {
        data: {
          user: ctx.state.user?.id,
          style,
          resultCount: captions.length,
        },
      });

      ctx.body = { data: { captions, style } };
    } catch (err) {
      strapi.log.error('AI caption generation failed', err);
      ctx.internalServerError('สร้าง caption ไม่สำเร็จ กรุณาลองใหม่');
    }
  },
};
```

**services/ai-caption.js**
```js
const STYLE_PROMPTS = {
  cute: 'เขียน caption ภาษาไทยแนวน่ารักฟรุ้งฟริ้ง ใส่ emoji ที่เกี่ยวข้อง',
  funny: 'เขียน caption ภาษาไทยแนวตลก มีมุก ใส่ emoji',
  sassy: 'เขียน caption ภาษาไทยแนวกวนๆ แสบๆ นิดหน่อย ใส่ emoji',
  short: 'เขียน caption ภาษาไทยสั้นกระชับ ไม่เกิน 10 คำ ใส่ emoji 1 ตัว',
};

module.exports = {
  async generateCaptions(imageFile, style) {
    const base64 = await fileToBase64(imageFile.path);
    const promptInstruction = STYLE_PROMPTS[style] || STYLE_PROMPTS.cute;

    // เรียก AI Vision API (เลือก provider ที่ใช้จริง เช่น OpenAI/Gemini/Claude)
    const captions = await callVisionModel({
      imageBase64: base64,
      mimeType: imageFile.type,
      instruction: `
        มองรูปสัตว์เลี้ยงนี้ แล้ว${promptInstruction}
        ตอบกลับเป็น JSON array ของ caption 3 แบบเท่านั้น ห้ามมีข้อความอื่น
      `,
    });

    return captions; // ["...", "...", "..."]
  },
};

async function fileToBase64(path) {
  const fs = require('fs').promises;
  const buffer = await fs.readFile(path);
  return buffer.toString('base64');
}

async function callVisionModel({ imageBase64, mimeType, instruction }) {
  // ตัวอย่างเรียก Anthropic API — ปรับ endpoint/key ตาม provider จริง
  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': process.env.AI_API_KEY,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-6',
      max_tokens: 500,
      messages: [
        {
          role: 'user',
          content: [
            { type: 'image', source: { type: 'base64', media_type: mimeType, data: imageBase64 } },
            { type: 'text', text: instruction },
          ],
        },
      ],
    }),
  });

  const data = await response.json();
  const text = data.content?.[0]?.text || '[]';
  return JSON.parse(text.replace(/```json|```/g, '').trim());
}
```

> ⚠️ ปรับ `callVisionModel` ให้ตรงกับ provider ที่ใช้จริง (Anthropic / OpenAI GPT-4o Vision / Google Gemini) — เก็บ API key ไว้ใน environment variable เสมอ ห้าม hardcode

### 4.3 Rate Limiting / Cost Control
- เพิ่ม middleware หรือ policy จำกัดจำนวนครั้ง generate ต่อผู้ใช้ต่อวัน (เช่น 20 ครั้ง/วัน) เพื่อคุมค่าใช้จ่าย AI API
- พิจารณา cache ผลลัพธ์ตาม image hash (ถ้ารูปเดียวกัน + style เดียวกัน ไม่ต้องยิง AI ซ้ำ)

---

## 5. Database (PostgreSQL)

### 5.1 ตาราง log การใช้งาน (สำหรับ analytics/rate-limit)
Strapi content-type: `ai-caption-log`

```sql
CREATE TABLE ai_caption_logs (
  id            SERIAL PRIMARY KEY,
  user_id       INTEGER REFERENCES up_users(id),
  style         VARCHAR(20) NOT NULL,
  result_count  INTEGER DEFAULT 0,
  created_at    TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_ai_caption_logs_user_created 
  ON ai_caption_logs (user_id, created_at);
```

### 5.2 (ถ้าต้องการ) เก็บ caption ที่ผู้ใช้เลือกจริง เชื่อมกับโพสต์
เพิ่ม field ในตาราง `posts` (หรือ content-type `post` เดิม):

```sql
ALTER TABLE posts 
  ADD COLUMN caption_source VARCHAR(20) DEFAULT 'manual'; 
  -- ค่า: 'manual' | 'ai-generated' | 'ai-edited'

ALTER TABLE posts 
  ADD COLUMN caption_style VARCHAR(20) NULL; 
  -- เก็บ style ที่ใช้ตอน generate ถ้า caption_source != 'manual'
```

ประโยชน์: ใช้วัด adoption rate ของฟีเจอร์ AI ทีหลังได้ (กี่ % ของโพสต์ใช้ AI caption)

---

## 6. Checklist สำหรับ Cursor

- [ ] สร้าง Strapi content-type `ai-caption-log`
- [ ] สร้าง custom route/controller/service `ai-caption`
- [ ] เพิ่ม env var `AI_API_KEY` ใน `.env` ของ backend
- [ ] เพิ่ม migration เพิ่ม column `caption_source`, `caption_style` ใน posts
- [ ] เพิ่ม policy/middleware จำกัด rate limit ต่อผู้ใช้
- [ ] Flutter: เพิ่ม `AiCaptionRepository` + `AiCaptionController`
- [ ] Flutter: เพิ่ม UI `AiCaptionButton`, `CaptionStyleSelector`, `AiCaptionSuggestionSheet`
- [ ] เพิ่ม loading/error state ทั้งฝั่ง UI
- [ ] Compress รูปก่อนอัปโหลดฝั่ง client
- [ ] ทดสอบ: รูปไม่ชัด / ไม่มีสัตว์ในรูป / API timeout / rate limit เกิน
- [ ] เพิ่ม analytics event เมื่อผู้ใช้กด generate และเมื่อเลือก caption

---

## 7. Open Questions (ต้องตัดสินใจก่อนเริ่ม implement)
1. จะใช้ AI Vision provider ตัวไหน (Anthropic Claude / OpenAI GPT-4o / Gemini) — มีผลต่อ cost และ code ใน `callVisionModel`
2. จำกัดจำนวนครั้ง generate ต่อวันเท่าไหร่ (คุม cost)
3. ต้องรองรับภาษาอื่นนอกจากไทยหรือไม่ (เช่น อังกฤษ)
4. จะเก็บรูปที่ส่งไป generate ไว้ถาวรหรือลบทิ้งหลัง process (privacy/storage cost)
