# 5. คู่มือการติดตั้งและรันระบบ (Setup & Deployment Guide) 🚀

คู่มือนี้แนะนำขั้นตอนการติดตั้ง ตั้งค่าสภาพแวดล้อม และเริ่มรันโปรเจกต์ **InstaCat** ทั้งในส่วนของ Database, Backend (Strapi 5) และ Frontend (Flutter) ตั้งแต่เริ่มต้นจนพร้อมใช้งาน

---

## 5.1 ข้อกำหนดของระบบ (Prerequisites)

ก่อนเริ่มการติดตั้ง กรุณาตรวจสอบว่าเครื่องของท่านมีซอฟต์แวร์ดังต่อไปนี้ติดตั้งอยู่:
* **Node.js**: เวอร์ชั่น `18.x` หรือ `20.x` (LTS แนะนำ)
* **npm**: เวอร์ชั่น `9.x` ขึ้นไป
* **PostgreSQL**: เวอร์ชั่น `14.x` ขึ้นไป
* **Flutter SDK**: เวอร์ชั่น `^3.10.7` หรือใหม่กว่า
* **Xcode** (สำหรับ macOS เพื่อรัน iOS Simulator) และ **CocoaPods** (`pod --version`)
* **Android Studio** (สำหรับรัน Android Emulator)

---

## 5.2 ขั้นตอนที่ 1: การตั้งค่าฐานข้อมูล PostgreSQL (Database Setup)

1. เริ่มรันเซิร์ฟเวอร์ PostgreSQL ในเครื่องของคุณ
2. สร้างฐานข้อมูลสำหรับโปรเจกต์ (Database Name: `ai-software-project-db`):
```sql
CREATE DATABASE "ai-software-project-db";
```
3. กำหนดสิทธิ์และรหัสผ่านสำหรับ User ของฐานข้อมูล (ตัวอย่าง: User `postgres` บน Port `5433` หรือ `5432` ตามคอนฟิกเครื่องของคุณ)

---

## 5.3 ขั้นตอนที่ 2: การติดตั้งและรัน Strapi Backend

1. เข้าไปยังไดเรกทอรี `backend/`:
```bash
cd backend
```

2. ติดตั้ง Dependencies:
```bash
npm install
```

3. ตรวจสอบและกำหนดค่าตัวแปรในไฟล์ `.env` ([backend/.env](file:///Users/panya/Documents/ai-engineer-course/backend/.env)):
```ini
HOST=0.0.0.0
PORT=1337
APP_KEYS=yourAppKeys1,yourAppKeys2
API_TOKEN_SALT=yourApiTokenSalt
ADMIN_JWT_SECRET=yourAdminJwtSecret
TRANSFER_TOKEN_SALT=yourTransferTokenSalt
JWT_SECRET=yourJwtSecret

# Database Configuration (PostgreSQL)
DATABASE_CLIENT=postgres
DATABASE_HOST=127.0.0.1
DATABASE_PORT=5433
DATABASE_NAME=ai-software-project-db
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password
DATABASE_SSL=false
```

4. สั่ง Compile และเริ่มเซิร์ฟเวอร์ในโหมด Development:
```bash
npm run build
npm run dev
```
เมื่อเซิร์ฟเวอร์เริ่มทำงานเสร็จสมบูรณ์ จะมีข้อความแสดงว่า Strapi พร้อมให้บริการที่:
`http://localhost:1337` หรือ `http://127.0.0.1:1337`

> [!NOTE]
> ระบบมีฟังก์ชัน `bootstrap()` อัตโนมัติใน `backend/src/index.ts` ที่จะทำการกำหนดสิทธิ์ Public และ Authenticated Roles ให้โดยอัตโนมัติ จึงไม่จำเป็นต้องเข้าไปกดตั้งค่าสิทธิ์เองในหน้า Admin UI

---

## 5.4 ขั้นตอนที่ 3: การติดตั้งและรัน Flutter Frontend

1. เข้าไปยังไดเรกทอรี `frontend/`:
```bash
cd frontend
```

2. ดึง Dependencies ทั้งหมดของ Flutter:
```bash
flutter pub get
```

3. ตรวจสอบการเชื่อมต่อของ Simulator หรืออุปกรณ์:
```bash
flutter devices
```

4. รันแอปพลิเคชัน:
```bash
flutter run
```
* หากรันบน **iOS Simulator**: ระบบจะเชื่อมต่อกับ Backend ที่ `http://127.0.0.1:1337`
* หากรันบน **Android Emulator**: ระบบจะเชื่อมต่อผ่าน Loopback Alias ที่ `http://10.0.2.2:1337` โดยอัตโนมัติ

---

## 5.5 บัญชีสำหรับทดสอบระบบทันที (Pre-configured Test Accounts)

คุณสามารถทดสอบเข้าสู่ระบบได้ทันทีด้วยบัญชีที่มีอยู่ในฐานข้อมูล:

| Username / Identifier | Password | สิทธิ์และข้อมูล |
| :--- | :--- | :--- |
| `testcat` | `password123` | บัญชีแมวตัวแรก มีโพสต์และรูปภาพพร้อมทดสอบ |
| `testregister1` | `password123` | บัญชีสำรองสำหรับทดสอบการกด Follow และ Like |

หรือสามารถกด **"Sign up."** บนหน้าจอเพื่อสร้างบัญชีแมวตัวใหม่ของคุณเองได้ทันที

---

## 5.6 การแก้ไขปัญหาที่พบบ่อย (Troubleshooting Guide)

### 1. ปัญหา: `HTTP 403 Forbidden` ตอน Login หรือโหลดข้อมูล
* **สาเหตุ**: อาจเกิดจากการที่ Strapi เปิดระบบ Email Confirmation ไว้ หรือ Token ไม่ได้ถูกแนบใน Header
* **วิธีแก้ไข**: ตรวจสอบว่าใน `backend/src/index.ts` ได้รันคำสั่งปิด `email_confirmation = false` หรือไม่ และตรวจสอบว่าใช้รหัสผ่านที่เป็นตัวพิมพ์เล็กทั้งหมด (`password123`) ถูกต้องตามฐานข้อมูล

### 2. ปัญหา: `Connection refused` หรือเน็ตเวิร์กไม่เชื่อมต่อใน Android Emulator
* **สาเหตุ**: Android Emulator ไม่สามารถเข้าถึง `localhost` ของเครื่องโฮสต์ได้โดยตรง
* **วิธีแก้ไข**: ตรวจสอบว่าใช้ `http://10.0.2.2:1337` ใน `api_config.dart` หรือไม่

### 3. ปัญหา: พอร์ตชนกัน (`EADDRINUSE: address already in use :::1337`)
* **สาเหตุ**: มี Strapi หรือ Process อื่นรันค้างอยู่บนพอร์ต 1337
* **วิธีแก้ไข**: ค้นหา PID แล้วปิดโปรเซสเดิม:
```bash
lsof -i :1337
kill -9 <PID>
```

### 4. ปัญหา: Keychain Error บน iOS Simulator (`-34018`)
* **สาเหตุ**: เป็นข้อจำกัดด้านความปลอดภัยของ iOS Simulator บางเวอร์ชันเมื่อเข้าถึง Keychain แบบ Unlocked
* **วิธีแก้ไข**: ในโค้ด [api_client.dart](file:///Users/panya/Documents/ai-engineer-course/frontend/lib/services/api_client.dart) ได้ตั้งค่า `KeychainAccessibility.first_unlock` และครอบ `try-catch` พร้อม In-memory Cache สำรองไว้เรียบร้อยแล้ว
