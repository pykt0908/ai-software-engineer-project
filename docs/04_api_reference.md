# 4. ข้อมูลอ้างอิง API (API Reference Specification) 📡

เอกสารนี้ระบุรายละเอียดของ REST API Endpoints ทั้งหมดที่เปิดให้บริการโดย **Strapi 5 Backend** พร้อมตัวอย่าง Request Body และ Response JSON

---

## 4.1 ตารางสรุปภาพรวม Endpoints

| Method | Endpoint Path | รายละเอียด | Auth Required |
| :--- | :--- | :--- | :---: |
| `POST` | `/api/auth/local` | เข้าสู่ระบบด้วย Username/Email และ Password | ❌ No |
| `POST` | `/api/auth/local/register` | สมัครสมาชิกใหม่ในระบบ | ❌ No |
| `POST` | `/api/auth/refresh` | ขอรับ Access Token ชุดใหม่ด้วย Refresh Token | ❌ No |
| `POST` | `/api/auth/change-password`| เปลี่ยนรหัสผ่านของบัญชี | ✅ Yes |
| `POST` | `/api/auth/logout` | ออกจากระบบและยกเลิก Session | ✅ Yes |
| `GET` | `/api/feed/public` | ดึงฟีดสาธารณะเรียงจากใหม่ไปเก่า | ❌ No / Optional |
| `GET` | `/api/feed/following` | ดึงฟีดเฉพาะผู้ที่กำลังติดตาม | ✅ Yes |
| `POST` | `/api/posts` | สร้างโพสต์ใหม่พร้อมรูปภาพ 1-10 รูป | ✅ Yes |
| `PUT` | `/api/posts/:documentId` | แก้ไขคำบรรยายโพสต์ของตนเอง | ✅ Yes |
| `DELETE` | `/api/posts/:documentId` | ลบโพสต์ของตนเอง | ✅ Yes |
| `POST` | `/api/posts/:documentId/like` | กดถูกใจโพสต์ | ✅ Yes |
| `DELETE` | `/api/posts/:documentId/like` | ยกเลิกการถูกใจโพสต์ | ✅ Yes |
| `GET` | `/api/me` | ดึงข้อมูลโปรไฟล์ของตนเองและยอดสถิติ | ✅ Yes |
| `PUT` | `/api/me` | แก้ไขโปรไฟล์ (รวมถึง Username และ Avatar) | ✅ Yes |
| `GET` | `/api/profiles/search` | ค้นหาบัญชีผู้ใช้ด้วยคำค้นหา (Query string `?q=...`) | ❌ No / Optional |
| `GET` | `/api/profiles/:username` | ดูข้อมูลโปรไฟล์สาธารณะของผู้ใช้อื่น | ❌ No / Optional |
| `GET` | `/api/profiles/:username/posts` | ดูรายการโพสต์ทั้งหมดของบัญชีผู้ใช้ | ❌ No / Optional |
| `POST` | `/api/users/:documentId/follow` | ติดตามผู้ใช้อื่น | ✅ Yes |
| `DELETE` | `/api/users/:documentId/follow` | ยกเลิกการติดตามผู้ใช้ | ✅ Yes |
| `POST` | `/api/upload` | อัปโหลดไฟล์รูปภาพ (Multipart Form) | ✅ Yes |

---

## 4.2 ระบบยืนยันตัวตน (Authentication Endpoints)

### 1. เข้าสู่ระบบ (Login)
* **Method**: `POST`
* **URL**: `/api/auth/local`
* **Headers**: `Content-Type: application/json`
* **Request Body**:
```json
{
  "identifier": "testcat",
  "password": "password123"
}
```
* **Response (200 OK)**:
```json
{
  "jwt": "eyJhbGciOiJIUzI1NiIsIn...",
  "refreshToken": "d8f3a9e2...",
  "user": {
    "id": 1,
    "documentId": "usr_testcat_01",
    "username": "testcat",
    "email": "testcat@example.com",
    "displayName": "Test Cat",
    "bio": "Official Test Cat account"
  }
}
```

---

### 2. สมัครสมาชิก (Register)
* **Method**: `POST`
* **URL**: `/api/auth/local/register`
* **Headers**: `Content-Type: application/json`
* **Request Body**:
```json
{
  "username": "fluffy_cat",
  "email": "fluffy@example.com",
  "password": "password123"
}
```
* **Response (200 OK)**:
```json
{
  "jwt": "eyJhbGciOiJIUzI1NiIsIn...",
  "user": {
    "id": 2,
    "documentId": "usr_fluffy_02",
    "username": "fluffy_cat",
    "email": "fluffy@example.com"
  }
}
```

---

## 4.3 ระบบฟีดและโพสต์ (Feed & Posts Endpoints)

### 1. ฟีดสาธารณะ (Public Feed)
* **Method**: `GET`
* **URL**: `/api/feed/public?page=1&pageSize=10`
* **Headers**: `Authorization: Bearer <token>` (ใส่หรือไม่ใส่ก็ได้)
* **Response (200 OK)**:
```json
{
  "data": [
    {
      "id": 10,
      "documentId": "post_doc_001",
      "caption": "Enjoying the sunny afternoon! ☀️🐾",
      "createdAt": "2026-09-20T12:00:00.000Z",
      "likeCount": 15,
      "isLiked": false,
      "author": {
        "id": 1,
        "username": "testcat",
        "displayName": "Test Cat",
        "avatarUrl": "/uploads/avatar_1.jpg"
      },
      "images": [
        {
          "id": 101,
          "url": "/uploads/cat_pic_1.jpg"
        }
      ]
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "pageSize": 10,
      "pageCount": 1,
      "total": 1
    }
  }
}
```

---

### 2. สร้างโพสต์ใหม่ (Create Post)
* **Method**: `POST`
* **URL**: `/api/posts`
* **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
* **Request Body**:
```json
{
  "data": {
    "caption": "Look at my new toy! 🎾",
    "images": [101, 102]
  }
}
```
* **Response (201 Created)**: ส่งคืนข้อมูลของโพสต์ที่สร้างใหม่พร้อม `documentId`

---

### 3. กดถูกใจ / ยกเลิกถูกใจ (Like / Unlike)
* **Like**: `POST /api/posts/:documentId/like`
* **Unlike**: `DELETE /api/posts/:documentId/like`
* **Headers**: `Authorization: Bearer <token>`
* **Response (200 OK)**:
```json
{
  "success": true,
  "liked": true,
  "likeCount": 16
}
```

---

## 4.4 ระบบโปรไฟล์ผู้ใช้งาน (Profile Endpoints)

### 1. ดึงข้อมูลผู้ใช้ปัจจุบัน (Get Current User)
* **Method**: `GET`
* **URL**: `/api/me`
* **Headers**: `Authorization: Bearer <token>`
* **Response (200 OK)**:
```json
{
  "data": {
    "id": 1,
    "documentId": "usr_testcat_01",
    "username": "testcat",
    "email": "testcat@example.com",
    "displayName": "Test Cat",
    "bio": "Official Test Cat account",
    "isPublic": true,
    "postsCount": 5,
    "followersCount": 42,
    "followingCount": 18,
    "avatar": {
      "id": 5,
      "url": "/uploads/avatar_testcat.jpg"
    }
  }
}
```

---

### 2. อัปเดตข้อมูลผู้ใช้ (Update Profile & Username)
* **Method**: `PUT`
* **URL**: `/api/me`
* **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
* **Request Body**:
```json
{
  "username": "super_cat",
  "displayName": "Super Kitty",
  "bio": "Cat superhero fighting crime",
  "isPublic": true
}
```
* **Response (200 OK)**: ส่งคืนข้อมูลที่อัปเดตแล้วสำเร็จ

---

### 3. ค้นหาผู้ใช้งาน (Search Users)
* **Method**: `GET`
* **URL**: `/api/profiles/search?q=test`
* **Headers**: `Authorization: Bearer <token>` (Optional)
* **Response (200 OK)**:
```json
{
  "data": [
    {
      "id": 1,
      "documentId": "usr_testcat_01",
      "username": "testcat",
      "displayName": "Test Cat",
      "bio": "Official Test Cat account",
      "isPublic": true,
      "followersCount": 42,
      "postsCount": 5,
      "isFollowing": false,
      "avatar": {
        "id": 5,
        "url": "/uploads/avatar_testcat.jpg"
      }
    }
  ]
}
```

---

### 4. ดึงรายการโพสต์ของผู้ใช้ (Get User Posts)
* **Method**: `GET`
* **URL**: `/api/profiles/:username/posts?page=1&pageSize=12`
* **Headers**: `Authorization: Bearer <token>` (Optional)
* **Response (200 OK)**: ส่งคืน Array ของโพสต์ที่เป็นของ Username นั้นๆ พร้อมรูปภาพ

---

## 4.5 รูปแบบข้อผิดพลาดมาตรฐาน (Error Responses)

เมื่อเกิดข้อผิดพลาด Strapi 5 จะส่งคืนโครงสร้าง JSON ดังนี้:
```json
{
  "data": null,
  "error": {
    "status": 400,
    "name": "ValidationError",
    "message": "Username already taken",
    "details": {}
  }
}
```
Client มี `ApiClient` และ `AuthService` ที่จะดึงข้อความจาก `error.message` มาแสดงเป็น SnackBar หรือ Alert Banner ให้ผู้ใช้ทราบโดยอัตโนมัติ
