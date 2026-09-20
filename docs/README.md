# InstaCat Documentation (คู่มือและเอกสารประกอบโปรเจกต์) 🐾

ยินดีต้อนรับสู่ศูนย์รวมเอกสารทางเทคนิคของโปรเจกต์ **InstaCat** ซึ่งเป็นโซเชียลมีเดียสำหรับคนรักแมว (Cat Social Network Application) ที่ถูกพัฒนาขึ้นอย่างสมบูรณ์แบบตามข้อกำหนดใน [spec.md](../spec/spec.md)

ระบบได้รับการออกแบบและพัฒนาด้วยสถาปัตยกรรมแบบ **3-Tier Architecture** โดยเชื่อมต่อระหว่าง Mobile Application (Flutter), Headless CMS Backend (Strapi 5), และ Relational Database (PostgreSQL)

---

## 📸 ภาพรวมหน้าจอหลักของแอปพลิเคชัน

| 1. One-Tap Quick Login | 2. Clean Login Screen | 3. Register Screen | 4. Profile & Posts Grid |
| :---: | :---: | :---: | :---: |
| ![One-Tap Login](images/01_one_tap_login.png) | ![Login Screen](images/02_login_screen.png) | ![Register Screen](images/03_register_screen.png) | ![Profile Posts](images/04_profile_posts.png) |

---

## 📚 สารบัญเอกสาร (Table of Contents)

เอกสารในโฟลเดอร์นี้ถูกแบ่งออกเป็นหมวดหมู่ตามหัวข้อทางเทคนิคอย่างละเอียด ดังนี้:

### [1. สถาปัตยกรรมระบบ (System Architecture)](01_architecture.md)
- ภาพรวมสถาปัตยกรรม 3-Tier Model (Flutter ↔ Strapi 5 ↔ PostgreSQL)
- ไดอะแกรมลำดับการทำงาน (Sequence & Data Flow Diagram)
- ระบบความปลอดภัยและการจัดการ Token (JWT, Refresh Token, Secure Storage)
- การจัดการ Network IP Configuration ระหว่าง iOS Simulator, Android Emulator, และ Localhost

### [2. ระบบ Backend (Strapi 5 & PostgreSQL)](02_backend_strapi.md)
- การตั้งค่าและการขยาย User Schema ใน Strapi
- Content-Types และโมเดลความสัมพันธ์ (Post, PostLike, Follow, User)
- Custom Controllers และ Routers ที่พัฒนาขึ้นเพิ่มเติม
- Automated Permissions Bootstrap Lifecycle (`src/index.ts`)
- การจัดการไฟล์มัลติมีเดีย (Media Library & Uploads)

### [3. ระบบ Frontend (Flutter Mobile Application)](03_frontend_flutter.md)
- โครงสร้างโค้ดและการจัดระเบียบไดเรกทอรี (`frontend/lib/`)
- การจัดการ State ด้วย `ValueNotifier` และ Reactive UI
- Service Layer Architecture (`ApiClient`, `AuthService`, `PostService`, `ProfileService`)
- หน้าจอและการทำงานของ UI Flow ทั้งหมด
- ระบบจดจำบัญชีล่าสุดที่ใช้งานบนเครื่อง (Last Logged-in User Persistence)
- การบีบอัดภาพก่อนอัปโหลด (Image Compression Pipeline)

### [4. ข้อมูลอ้างอิง API (API Reference Specification)](04_api_reference.md)
- เอกสาร REST API ทุก Endpoint อย่างละเอียด
- Endpoints สำหรับ Authentication (`/api/auth/*`)
- Endpoints สำหรับ Feed (`/api/feed/*`)
- Endpoints สำหรับ Posts และ Likes (`/api/posts/*`)
- Endpoints สำหรับ Profile และ Follows (`/api/profiles/*`, `/api/me`, `/api/users/*`)
- โครงสร้าง Request Body, Response JSON และ Error Codes

### [5. คู่มือการติดตั้งและรันระบบ (Setup & Deployment Guide)](05_setup_guide.md)
- สิ่งที่ต้องติดตั้งล่วงหน้า (Prerequisites)
- ขั้นตอนการตั้งค่า PostgreSQL Database
- ขั้นตอนการติดตั้งและรัน Strapi Backend
- ขั้นตอนการติดตั้งและรัน Flutter Frontend บน iOS Simulator / Android
- บันทึกการแก้ไขปัญหาที่พบบ่อย (Troubleshooting FAQ)

### [6. การทดสอบและการรับประกันคุณภาพ (Testing & QA)](06_testing_and_verification.md)
- กลยุทธ์การทดสอบอัตโนมัติ (Automated Testing Strategy)
- รายละเอียด Unit Tests และ Widget Tests ทั้งหมด 22 ชุด
- ผลการทดสอบจริง (`flutter test`, `flutter analyze`)
- รายละเอียดบัญชีทดสอบในระบบ (Test Accounts & Credentials)

---

## 🛠 เทคโนโลยีที่ใช้ในโปรเจกต์ (Technology Stack)

| ส่วนของระบบ (Layer) | เทคโนโลยีหลัก (Technologies) | รายละเอียด (Details) |
| :--- | :--- | :--- |
| **Frontend** | **Flutter 3.x / Dart** | รองรับ iOS และ Android, Material 3 Design |
| **Networking & HTTP** | **Dio 5.x** | Custom Interceptors, Auto Refresh Token, Multipart Upload |
| **Local Storage** | **Flutter Secure Storage** | บันทึก JWT Tokens, รหัสผ่าน และบัญชีผู้ใช้ล่าสุดอย่างปลอดภัย |
| **Backend Framework** | **Strapi 5 Headless CMS** | TypeScript, Custom REST APIs, Lifecycle Hooks |
| **Database** | **PostgreSQL 14+** | Relational Database, Foreign Keys, Indexing |
| **Image Processing** | **Flutter Image Compress** | ลดขนาดภาพอัตโนมัติ (JPEG 85%, Max 2048px) ก่อนอัปโหลด |
| **Version Control** | **Git / GitHub** | Branch `main`, Semantic Commit Messages |

---

## 💡 สรุปฟังก์ชันการทำงานที่พัฒนาเสร็จสมบูรณ์

1. **Authentication & Session Persistence**:
   - สมัครสมาชิกใหม่ (Register) พร้อม Form Validation และ Error banner แจ้งเตือน
   - ล็อกอินด้วยบัญชีจริง (`testcat` / `password123` หรือบัญชีที่สมัครใหม่)
   - หน้า One-Tap Login จดจำและแสดงข้อมูลโปรไฟล์บัญชีจริงล่าสุด (`lastUser`)
   - ระบบจัดเก็บ Token ลง Keychain/Secure Storage พร้อมการ Refresh Token อัตโนมัติ
   - หน้า Login สวยงาม ช่องกรอกว่างเปล่า (ไม่มี predata) และมีปุ่มย้อนกลับ `<` มาตรฐาน
   - การ Logout ออกจากระบบอย่างปลอดภัย พร้อม Confirm Dialog และล้าง Token

2. **Feed & Exploration**:
   - Public Feed ดึงโพสต์สาธารณะจาก Strapi เรียงจากใหม่ไปเก่า พร้อม Pagination
   - Following Feed แสดงเฉพาะโพสต์ของเพื่อนที่ติดตาม
   - ดึงข้อมูล Like status (`isLiked`) และ Like count แบบ Real-time
   - ระบบ Optimistic UI สำหรับการกดถูกใจ/ยกเลิกถูกใจ (Like / Unlike)
   - ผู้เขียนโพสต์สามารถแก้ไขคำบรรยาย (Edit Caption) หรือลบโพสต์ (Delete Post) ได้

3. **Post Creation**:
   - เลือกภาพได้ 1 ถึง 10 ภาพ พร้อมพรีวิวแบบ Carousel
   - ย่อขนาดภาพอัตโนมัติก่อนส่งขึ้นเซิร์ฟเวอร์เพื่อประหยัด Bandwidth
   - สร้างโพสต์เชื่อมต่อกับ Strapi REST API และบันทึกรูปภาพลง Media Library

4. **Profile & Social**:
   - หน้าโปรไฟล์ดึงข้อมูลสถิติสดจากเซิร์ฟเวอร์ (จำนวน Posts, Followers, Following)
   - แท็บแสดงตารางโพสต์รูปภาพของผู้ใช้ (`GET /api/profiles/:username/posts`) พร้อม Pull-to-Refresh
   - แก้ไขโปรไฟล์ (Display Name, Bio, สถานะบัญชีส่วนตัว/สาธารณะ, และรูป Avatar)
   - เมื่อแก้ไข Username หน้าจอจะอัปเดตและแสดงผลใหม่ทันทีทุกจุดแบบ Real-time
   - ระบบ Follow / Unfollow ระหว่างผู้ใช้งาน พร้อมระบบป้องกันการ Follow ตัวเอง
