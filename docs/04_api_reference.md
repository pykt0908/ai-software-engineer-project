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
| `POST` | `/api/posts` | สร้างโพสต์ใหม่พร้อมรูปภาพ 1-10 รูป และระบุ Location | ✅ Yes |
| `PUT` | `/api/posts/:documentId` | แก้ไขคำบรรยายโพสต์ของตนเอง | ✅ Yes |
| `DELETE` | `/api/posts/:documentId` | ลบโพสต์ของตนเอง | ✅ Yes |
| `POST` | `/api/posts/:documentId/like` | กดถูกใจโพสต์ | ✅ Yes |
| `DELETE` | `/api/posts/:documentId/like` | ยกเลิกการถูกใจโพสต์ | ✅ Yes |
| `GET` | `/api/comments` | ดึงรายการความคิดเห็นของโพสต์ (`?postId=:id`) | ❌ No / Optional |
| `POST` | `/api/comments` | ส่งความคิดเห็นใหม่ในโพสต์ | ✅ Yes |
| `DELETE` | `/api/comments/:id` | ลบความคิดเห็นของตนเอง | ✅ Yes |
| `GET` | `/api/notifications` | ดึงรายการแจ้งเตือนของผู้ใช้ปัจจุบัน | ✅ Yes |
| `PUT` | `/api/notifications/:id/read` | ทำเครื่องหมายว่าอ่านการแจ้งเตือนแล้ว | ✅ Yes |
| `POST` | `/api/ai-caption/generate` | สร้างแคปชันด้วย Google Gemini AI ตามสไตล์ที่เลือก | ✅ Yes |
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

## 4.3 ระบบโพสต์และฟีด (Posts & Feeds Endpoints)

### 1. สร้างโพสต์ใหม่ (Create Post)
* **Method**: `POST`
* **URL**: `/api/posts`
* **Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Request Body**:
```json
{
  "data": {
    "caption": "วันนี้มาเที่ยวคาเฟ่แมว น่ารักมากก 🐾",
    "location": "Cat Cafe Siam, Bangkok",
    "images": [12, 13]
  }
}
```

### 2. ดึงฟีดสาธารณะ (Public Feed)
* **Method**: `GET`
* **URL**: `/api/feed/public?page=1&pageSize=10`
* **Headers**: `Authorization: Bearer <token>` (Optional)
* **Response (200 OK)**:
```json
{
  "data": [
    {
      "id": 1,
      "documentId": "post_doc_01",
      "caption": "น้องเหมียวขี้เซา",
      "location": "Bangkok, Thailand",
      "createdAt": "2026-09-20T10:00:00.000Z",
      "likesCount": 15,
      "commentsCount": 3,
      "isLiked": true,
      "author": {
        "id": 2,
        "username": "mochicat",
        "displayName": "Mochi The Cat",
        "avatar": { "url": "/uploads/mochi.jpg" }
      },
      "images": [
        { "id": 10, "url": "/uploads/cat1.jpg" }
      ]
    }
  ],
  "meta": {
    "pagination": { "page": 1, "pageSize": 10, "total": 25, "pageCount": 3 }
  }
}
```

---

## 4.4 ระบบความคิดเห็นและการแจ้งเตือน (Comments & Notifications)

### 1. ดึงความคิดเห็นของโพสต์ (Get Comments)
* **Method**: `GET`
* **URL**: `/api/comments?postId=1`
* **Response (200 OK)**:
```json
{
  "data": [
    {
      "id": 1,
      "content": "น้องน่ารักจังเลยยย!",
      "createdAt": "2026-09-20T11:00:00.000Z",
      "author": {
        "id": 3,
        "username": "catlover99",
        "displayName": "Cat Lover",
        "avatar": { "url": "/uploads/avatar.jpg" }
      }
    }
  ]
}
```

### 2. ส่งความคิดเห็น (Create Comment)
* **Method**: `POST`
* **URL**: `/api/comments`
* **Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Request Body**:
```json
{
  "data": {
    "content": "มุมกล้องสวยมากครับ",
    "post": 1
  }
}
```

### 3. ดึงรายการแจ้งเตือน (Get Notifications)
* **Method**: `GET`
* **URL**: `/api/notifications`
* **Headers**: `Authorization: Bearer <token>`
* **Response (200 OK)**:
```json
{
  "data": [
    {
      "id": 1,
      "type": "like",
      "isRead": false,
      "createdAt": "2026-09-20T11:15:00.000Z",
      "sender": {
        "id": 2,
        "username": "mochicat",
        "displayName": "Mochi The Cat"
      },
      "post": {
        "id": 1,
        "caption": "วันนี้มาเที่ยวคาเฟ่แมว"
      }
    }
  ]
}
```

---

## 4.5 ระบบผู้ช่วยสร้างแคปชันอัจฉริยะ (AI Caption Generator)

### 1. สร้างแคปชันด้วย AI (Generate AI Caption)
* **Method**: `POST`
* **URL**: `/api/ai-caption/generate`
* **Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Request Body**:
```json
{
  "tone": "funny",
  "prompt": "แมวส้มนอนหงายพุงอ้วนกลางบ้าน",
  "imageUrl": "/uploads/cat_orange.jpg"
}
```
* **Response (200 OK)**:
```json
{
  "captions": [
    "บ้านนี้ใครใหญ่ไม่รู้ แต่ที่รู้ๆ ข้าคือเจ้าของโซฟา 🛋️😼 #แมวส้ม #ทาสแมว",
    "นอนกินบ้านกินเมืองของแทร่ พุงนี้ไม่ได้มาเพราะโชคช่วย 🍗😹 #แมวอ้วน",
    "อย่าเพิ่งปลุก กำลังฝันว่าได้กินปลาทูทอด 🐟💤 #OrangeCat"
  ]
}
```

---

## 4.6 รูปแบบข้อผิดพลาดมาตรฐาน (Error Responses)

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
Client มี `ApiClient` และ `AppSnackBar` ที่จะดึงข้อความจาก `error.message` มาแสดงเป็นแจ้งเตือนให้ผู้ใช้ทราบโดยอัตโนมัติ
