import { Client } from 'pg';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.resolve(__dirname, '../.env');

const port = parseInt(process.env.DB_PORT || process.argv[2] || '5432', 10);
const password = process.env.DB_PASSWORD || process.argv[3] || '';
const user = process.env.DB_USER || process.argv[4] || 'postgres';
const host = process.env.DB_HOST || process.argv[5] || '127.0.0.1';
const targetDb = process.env.DB_NAME || process.argv[6] || 'strapi_db';

async function main() {
  console.log(`Connecting to PostgreSQL on ${host}:${port} as ${user}...`);
  const client = new Client({
    host,
    port,
    user,
    password,
    database: 'postgres',
  });

  try {
    await client.connect();
    console.log('Connected to PostgreSQL successfully!');

    const checkRes = await client.query(
      `SELECT 1 FROM pg_database WHERE datname = $1`,
      [targetDb]
    );

    if (checkRes.rowCount === 0) {
      console.log(`Database "${targetDb}" does not exist. Creating it now...`);
      await client.query(`CREATE DATABASE "${targetDb}"`);
      console.log(`Database "${targetDb}" created successfully!`);
    } else {
      console.log(`Database "${targetDb}" already exists.`);
    }

    await client.end();

    if (fs.existsSync(envPath)) {
      let content = fs.readFileSync(envPath, 'utf8');
      content = content.replace(/^DATABASE_HOST=.*/m, `DATABASE_HOST=${host}`);
      content = content.replace(/^DATABASE_PORT=.*/m, `DATABASE_PORT=${port}`);
      content = content.replace(/^DATABASE_NAME=.*/m, `DATABASE_NAME=${targetDb}`);
      content = content.replace(/^DATABASE_USERNAME=.*/m, `DATABASE_USERNAME=${user}`);
      content = content.replace(/^DATABASE_PASSWORD=.*/m, `DATABASE_PASSWORD=${password}`);
      fs.writeFileSync(envPath, content, 'utf8');
      console.log(`.env updated with database credentials.`);
    }

    console.log('Setup finished successfully!');
    process.exit(0);
  } catch (err) {
    console.error('Connection failed:', err.message);
    process.exit(1);
  }
}

main();
