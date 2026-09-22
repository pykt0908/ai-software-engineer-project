import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.join(__dirname, '../.env');
if (fs.existsSync(envPath)) {
  const lines = fs.readFileSync(envPath, 'utf8').split('\n');
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed && !trimmed.startsWith('#') && trimmed.includes('=')) {
      const idx = trimmed.indexOf('=');
      const k = trimmed.slice(0, idx).trim();
      const v = trimmed.slice(idx + 1).trim();
      process.env[k] = v;
    }
  }
}

// 1x1 png base64 for testing
const testBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

async function testPrompt() {
  console.log('Testing prompt generation...');
  const { AiPromptService } = await import('../dist/src/services/ai/ai-prompt.service.js');
  const service = new AiPromptService();
  const res = await service.generatePrompt({
    imageBase64: testBase64,
    mimeType: 'image/png',
    userIntent: 'อยากให้ดูอบอุ่นและน่ารัก',
    style: 'warm',
  });
  console.log('Prompt result:', JSON.stringify(res, null, 2));
}

async function testEnhance() {
  console.log('Testing local enhance...');
  const { LocalEnhanceProvider } = await import('../dist/src/services/ai/providers/local-enhance.provider.js');
  const provider = new LocalEnhanceProvider();
  const res = await provider.editImage({
    imageBase64: testBase64,
    mimeType: 'image/png',
    prompt: 'Make it cozy and warm',
    operation: 'enhance',
    preset: 'warm_cozy',
  });
  console.log('Local enhance result format:', res.format, 'buffer bytes:', res.imageBuffer.length);
}

async function run() {
  try {
    await testPrompt();
    await testEnhance();
    console.log('\nAll tests passed successfully!');
  } catch (err) {
    console.error('Test failed:', err);
    process.exit(1);
  }
}

run();
