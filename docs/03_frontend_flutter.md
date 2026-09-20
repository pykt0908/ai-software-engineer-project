# 3. ระบบ Frontend (Flutter Mobile Application) 📱

ส่วนติดต่อผู้ใช้งาน (Mobile Client) ของ **InstaCat** ถูกพัฒนาขึ้นด้วย **Flutter** โดยเน้นความสวยงาม ทันสมัยตามหลัก Instagram Design System รองรับการตอบสนองแบบ Reactive และมีระบบสถาปัตยกรรมโค้ดที่แยกส่วนชัดเจน

---

## 3.1 โครงสร้างโฟลเดอร์ของโปรเจกต์ (Directory Structure)

```
frontend/lib/
├── main.dart                      # จุดเริ่มต้นของแอปพลิเคชันและการตรวจสอบ Session
├── models/
│   └── models.dart                # Data Models: CatUser, Post, Comment, NotificationItem, PlaceSuggestion
├── services/
│   ├── api_config.dart            # Network URLs, Google Maps API Key, & Image Resolution
│   ├── api_client.dart            # Dio HTTP Client, Secure Storage & Interceptors
│   ├── auth_service.dart          # Authentication & Multi-Account Switcher Persistence
│   ├── post_service.dart          # Post creation, Feeds, Likes, and Compression
│   ├── profile_service.dart       # Profile Management, Following, and Avatar Upload
│   ├── ai_caption_service.dart    # Google Gemini AI Caption Generator Service
│   ├── comment_service.dart       # Real-time Comments Management Service
│   ├── location_service.dart      # GPS, Google Places Text Search, & Nominatim Geocoding
│   └── notification_service.dart  # In-App Notifications Service
├── theme/
│   ├── app_colors.dart            # InstaCat Brand Colors (Vibrant Orange, Gradients)
│   ├── app_typography.dart        # LINESeedSansTH & Inter Typography Tokens
│   └── app_theme.dart             # Material 3 Theme Definition
├── screens/
│   ├── switch_account_screen.dart # สลับบัญชีผู้ใช้ (Multi-Account Switcher & Quick Login)
│   ├── login_screen.dart          # หน้า Login ปกติ (สะอาด ไม่มี predata พร้อมปุ่มย้อนกลับ)
│   ├── register_screen.dart       # หน้าสมัครสมาชิกใหม่พร้อมการตรวจสอบฟิลด์
│   ├── main_shell.dart            # Shell ครอบ Bottom Navigation Bar 5 แท็บ
│   ├── feed_screen.dart           # หน้า Feed ข่าวสาร (Infinite Scroll & Pull-to-refresh)
│   ├── explore_screen.dart        # หน้าค้นหาผู้ใช้ ค้นหาโพสต์ และสำรวจรูปภาพ
│   ├── create_post_screen.dart    # หน้าสร้างโพสต์ (พร้อม AI Caption, Tag Friends, Location)
│   ├── gallery_picker_screen.dart # ตัวเลือกรูปภาพจากเครื่องสไตล์ Instagram (Multi-select, Zoom)
│   ├── location_picker_screen.dart# ตัวเลือกสถานที่ค้นหาแบบ Full-Screen รองรับ Google Places / OSM
│   ├── edit_post_screen.dart      # หน้าแก้ไขคำบรรยายโพสต์และสถานที่
│   ├── comment_screen.dart        # หน้าต่างความคิดเห็นและส่งคอมเมนต์
│   ├── notifications_screen.dart  # หน้ารายการแจ้งเตือน (Likes, Comments, Follows)
│   ├── in_app_browser_screen.dart # เบราว์เซอร์ภายในแอปสำหรับเปิดลิงก์ภายนอก
│   ├── profile_screen.dart        # หน้าโปรไฟล์พร้อมตารางโพสต์รูปภาพและตัวนับสถิติ
│   └── edit_profile_screen.dart   # หน้าแก้ไขข้อมูลโปรไฟล์ รูป Avatar และ Username
├── utils/                         # Helper utilities (image formatting, debounce)
└── widgets/                       # Reusable UI Components:
    ├── post_card.dart             # การ์ดแสดงโพสต์ (Carousel, Like, Comment, Location, Time)
    ├── ai_caption_widgets.dart    # BottomSheet ผู้ช่วยเขียนแคปชัน AI และเลือกโทนอารมณ์
    ├── post_composer_extras.dart  # แถบเลือกสถานที่ แท็กเพื่อน และฟังก์ชันเสริมในการโพสต์
    ├── app_dialog.dart            # Confirm & Alert Dialogs สไตล์พรีเมียม
    └── app_snackbar.dart          # แจ้งเตือนข้อความ Success / Error ที่สวยงาม
```

---

## 3.2 การจัดการ State (State Management)

แอปพลิเคชันใช้แนวทาง **Reactive ValueNotifier** ร่วมกับ **StatefulWidget Lifecycle** ซึ่งมีประสิทธิภาพสูงและกินทรัพยากรน้อย:
* `AuthService().currentUserNotifier`: เป็น `ValueNotifier<CatUser?>` คอยกระจายสถานะผู้ใช้ที่ล็อกอินอยู่
* ใน `main.dart` ใช้ `ValueListenableBuilder` คอยฟังค่า `currentUserNotifier`:
  - หากมีค่า (`user != null`) → แสดงผลหน้า `MainShell` (แอปหลัก)
  - หากเป็นค่าว่าง (`user == null`) → แสดงผลหน้า `SwitchAccountScreen` (หน้าสลับบัญชี/ล็อกอิน)

```dart
ValueListenableBuilder<CatUser?>(
  valueListenable: AuthService.instance.currentUserNotifier,
  builder: (context, user, child) {
    if (user != null) {
      return MainShell(key: ValueKey(user.id));
    }
    return const SwitchAccountScreen();
  },
)
```

---

## 3.3 ฟีเจอร์หลักและการทำงานของ UI Flow

### 1. ระบบสลับบัญชี (Switch Account Screen)
* แสดงรายการบัญชีที่เคยล็อกอินไว้บนเครื่อง พร้อมรูปโปรไฟล์และชื่อแสดงผล
* สามารถแตะเพื่อเข้าใช้งานได้ทันที (Quick Login) ด้วยรหัสผ่านที่บันทึกไว้อย่างปลอดภัย
* มีปุ่ม "Log in to another account" สำหรับเข้าสู่ระบบบัญชีอื่น และ "Create new account" สำหรับสมัครสมาชิกใหม่

### 2. ตัวช่วยสร้างแคปชันอัจฉริยะ (AI Caption Generator)
* ในหน้าสร้างโพสต์ มีปุ่ม **"AI Caption"** เปิด BottomSheet ผู้ช่วยสร้างคำบรรยาย
* เลือกอารมณ์/สไตล์ของแคปชันได้ 5 รูปแบบ:
  - 🐱 **Cute** (น่ารัก มุ้งมิ้ง)
  - 😂 **Funny** (ตลก อารมณ์ดี)
  - 😼 **Sarcastic** (กวนๆ ประชดแบบแมวๆ)
  - ✨ **Poetic** (บทกวี อ่อนโยน)
  - 🔥 **Trendy** (วัยรุ่น ตามเทรนด์)
* สามารถใส่ Prompt พิเศษเพิ่มเติมได้
* สร้างผลลัพธ์เป็นตัวเลือกแคปชันภาษาไทย/อังกฤษ พร้อมแฮชแท็ก เพียง 1 แตะสามารถนำไปใส่ในกล่องข้อความได้ทันที

### 3. ตัวเลือกสถานที่แบบ Full-Screen (Location Picker Screen)
* ระบบเลือกสถานที่รองรับทั้ง **Google Places API** และ **OpenStreetMap Nominatim**
* เมื่อพิมพ์ค้นหา รายการผลลัพธ์จะขยายเต็มหน้าจอ (Full-Screen List) แสดงชื่อสถานที่ชัดเจนพร้อมที่อยู่ย่อย
* มีปุ่มทางลัด `Use "<ชื่อที่พิมพ์>"` สำหรับใช้ชื่อสถานที่ที่กำหนดเองทันที
* รองรับปุ่ม **"Use Current Location"** ดึงพิกัด GPS อัตโนมัติ

### 4. ตัวเลือกรูปภาพจากเครื่องสไตล์ Instagram (Gallery Picker Screen)
* พัฒนาขึ้นโดยใช้ `photo_manager` เข้าถึง Photo Library บนอุปกรณ์โดยตรง
* แสดงภาพขนาดใหญ่ด้านบนพร้อมพรีวิวแบบสลับดูได้ และตาราง Grid แสดงรูปภาพทั้งหมดในอัลบั้ม
* รองรับโหมด Multi-selection เลือกได้สูงสุด 10 รูป พร้อมตัวเลขลำดับ 1, 2, 3...

### 5. ความคิดเห็นและการแจ้งเตือน (Comments & Notifications)
* หน้ารายการความคิดเห็น (`CommentScreen`) เปิดเป็น BottomSheet หรือหน้ารายการสด
* หน้ารายการแจ้งเตือน (`NotificationsScreen`) แยกหมวดหมู่การกดไลก์ คอมเมนต์ และการติดตาม พร้อมสถานะ unread
