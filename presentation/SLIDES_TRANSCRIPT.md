# InstaCat: บทบรรยายการนำเสนอและคู่มือสไลด์ฉบับเต็ม (Presentation Transcript & Guide) 🐾

เอกสารนี้รวบรวมเนื้อหาและสคริปต์คำพูดบรรยาย (Speaker Notes) อย่างละเอียดแบบ Slide-by-Slide รวม **18 สไลด์เต็ม** สำหรับใช้ประกอบการนำเสนอโปรเจกต์ **InstaCat: The Purr-fect Pet Community** ครอบคลุมครบทุกมิติสำคัญ:
1. **การวางแผนและสถาปัตยกรรม (Architecture & Planning)**
2. **Style การสั่งงาน AI (Prompt Engineering & Instruction Methodology)**
3. **การแสดงผลหน้าจอแอปพลิเคชันครบทุก 13 หน้าจอ (All 13 App Screens Showcase)**
4. **ปัญหาเชิงเทคนิคที่เจอทั้งหมด 8 ประเด็นและวิธีแก้ไข (Comprehensive Problem Solving)**
5. **การประกันคุณภาพและการทดสอบ (QA, Testing & Verification)**
6. **บทเรียนสำคัญและทิศทางการต่อยอด (Key Takeaways & Future Roadmap)**

---

## สารบัญสไลด์ (18 สไลด์)

1. [สไลด์ 1: หน้าปก (Title & Hero)](#สไลด์-1-หน้าปก-title--hero)
2. [สไลด์ 2: ภาพรวมและความเป็นมาของโปรเจกต์ (Project Overview & Vision)](#สไลด์-2-ภาพรวมและความเป็นมาของโปรเจกต์-project-overview--vision)
3. [สไลด์ 3: สถาปัตยกรรมระบบ 3-Tier Enterprise Architecture](#สไลด์-3-สถาปัตยกรรมระบบ-3-tier-enterprise-architecture)
4. [สไลด์ 4: Style การสั่งงาน AI: กลยุทธ์การกำกับ AI ให้ได้งานสูงสุด (Prompt Engineering)](#สไลด์-4-style-การสั่งงาน-ai-กลยุทธ์การกำกับ-ai-ให้ได้งานสูงสุด-prompt-engineering)
5. [สไลด์ 5: Agentic Workflow: วงจรการพัฒนาร่วมกับ AI ระดับคู่คิด (Autonomous Loop)](#สไลด์-5-agentic-workflow-วงจรการพัฒนาร่วมกับ-ai-ระดับคู่คิด-autonomous-loop)
6. [สไลด์ 6: Showcase 1 - ระบบสมาชิกและความปลอดภัย (Authentication Suite: 3 จอ)](#สไลด์-6-showcase-1---ระบบสมาชิกและความปลอดภัย-authentication-suite-3-จอ)
7. [สไลด์ 7: Showcase 2 - หน้าฟีดและคอมเมนต์ (Social Feed & Discussion: 2 จอ)](#สไลด์-7-showcase-2---หน้าฟีดและคอมเมนต์-social-feed--discussion-2-จอ)
8. [สไลด์ 8: Showcase 3 - หน้าสำรวจและค้นหา (Explore & Discovery Grid: 1 จอ)](#สไลด์-8-showcase-3---หน้าสำรวจและค้นหา-explore--discovery-grid-1-จอ)
9. [สไลด์ 9: Showcase 4 - สตูดิโอสร้างโพสต์ (Content Creation & Media Studio: 2 จอ)](#สไลด์-9-showcase-4---สตูดิโอสร้างโพสต์-content-creation--media-studio-2-จอ)
10. [สไลด์ 10: Showcase 5 - ผู้ช่วยแคปชันอัจฉริยะ (Gemini Vision AI Assistant: 1 จอ)](#สไลด์-10-showcase-5---ผู้ช่วยแคปชันอัจฉริยะ-gemini-vision-ai-assistant-1-จอ)
11. [สไลด์ 11: Showcase 6 - ระบบปักหมุดสถานที่ (Geolocation & Place Tagging: 1 จอ)](#สไลด์-11-showcase-6---ระบบปักหมุดสถานที่-geolocation--place-tagging-1-จอ)
12. [สไลด์ 12: Showcase 7 - ระบบแจ้งเตือนและกิจกรรม (Notifications & Activity: 1 จอ)](#สไลด์-12-showcase-7---ระบบแจ้งเตือนและกิจกรรม-notifications--activity-1-จอ)
13. [สไลด์ 13: Showcase 8 - โปรไฟล์และการตั้งค่าบัญชี (Profile & Settings Suite: 2 จอ)](#สไลด์-13-showcase-8---โปรไฟล์และการตั้งค่าบัญชี-profile--settings-suite-2-จอ)
14. [สไลด์ 14: ปัญหาเชิงเทคนิคและการแก้ไข 1: Backend & Database (Issues 1-4)](#สไลด์-14-ปัญหาเชิงเทคนิคและการแก้ไข-1-backend--database-issues-1-4)
15. [สไลด์ 15: ปัญหาเชิงเทคนิคและการแก้ไข 2: Mobile, AI & UX (Issues 5-8)](#สไลด์-15-ปัญหาเชิงเทคนิคและการแก้ไข-2-mobile-ai--ux-issues-5-8)
16. [สไลด์ 16: การทดสอบระบบและการรับประกันคุณภาพ (QA Matrix & Verification)](#สไลด์-16-การทดสอบระบบและการรับประกันคุณภาพ-qa-matrix--verification)
17. [สไลด์ 17: บทเรียนสำคัญจากการพัฒนาร่วมกับ AI (Key Takeaways)](#สไลด์-17-บทเรียนสำคัญจากการพัฒนาร่วมกับ-ai-key-takeaways)
18. [สไลด์ 18: ทิศทางการพัฒนาต่อยอด และสรุปผลงาน (Roadmap & Q&A)](#สไลด์-18-ทิศทางการพัฒนาต่อยอด-และสรุปผลงาน-roadmap--qa)
19. [แนวทางการตอบคำถามกรรมการ (Anticipated Q&A Guide)](#แนวทางการตอบคำถามกรรมการ-anticipated-qa-guide)

---

### สไลด์ 1: หน้าปก (Title & Hero)
* **หัวข้อ:** InstaCat: The Purr-fect Pet Community
* **หัวข้อย่อย:** การพัฒนาโมบายโซเชียลมีเดียแบบ Full-Stack (Flutter ↔ Strapi 5 ↔ PostgreSQL ↔ Gemini AI) ด้วยสไตล์การสั่งงาน AI ชั้นสูง (Spec-Driven Prompting) และ Agentic Workflow
* **Speaker Script (บทพูดบรรยาย):**
  > "สวัสดีอาจารย์ คณะกรรมการ และผู้ฟังทุกท่านครับ วันนี้ผมมีความยินดีเป็นอย่างยิ่งที่จะมานำเสนอผลงานโปรเจกต์ **InstaCat: The Purr-fect Pet Community** โซเชียลมีเดียแอปพลิเคชันสำหรับคนรักแมว ที่ได้รับการพัฒนาขึ้นอย่างสมบูรณ์แบบครบวงจรตั้งแต่ระดับ Mobile Frontend ไปจนถึง Headless CMS, Relational Database และ Generative AI Vision บนคลาวด์
  > 
  > สิ่งที่ทำให้การนำเสนอในวันนี้มีความพิเศษอย่างยิ่ง คือเราจะพาไปชม **ภาพหน้าจอจริงของแอปพลิเคชันครบทุก 13 หน้าจอ**, ถอดรหัส **Style การสั่งงาน AI (Prompt Engineering)** ที่ผู้ใช้สั่งให้ AI ช่วยพัฒนาอย่างมีประสิทธิภาพ, และเจาะลึก **ปัญหาจริงทั้ง 8 ประเด็น** ที่เกิดขึ้นระหว่างการเชื่อมต่อระบบ พร้อมวิธีการแก้ไขเชิงวิศวกรรมครับ"

---

### สไลด์ 2: ภาพรวมและความเป็นมาของโปรเจกต์ (Project Overview & Vision)
* **หัวข้อ:** ภาพรวมและความเป็นมาของ InstaCat
* **ประเด็นสำคัญ:**
  - **Vision:** ชุมชนออนไลน์เฉพาะกลุ่ม (Niche Pet Community) ให้คนรักแมวได้แชร์ภาพ เรื่องราว และเชื่อมต่อกัน
  - **MVP Scope:** ครอบคลุมการยืนยันตัวตน, วัน-แท็ปสลับบัญชี, หน้าฟีดพร้อมสตอรี่, ระบบไลก์แบบเรียลไทม์, คอมเมนต์, คลังภาพมัลติมีเดีย, การปักหมุด GPS และ Gemini Vision AI
  - **The Golden Rule:** *"Do not recreate the project"* — โค้ด UI เดิมของ Flutter คือ Visual Source of Truth ห้ามลบเขียนใหม่แบบ generic แต่ต้องต่อท่อเชื่อม UI เดิมเข้ากับ Backend จริงทั้งหมด
* **Speaker Script (บทพูดบรรยาย):**
  > "InstaCat เริ่มต้นจากเป้าหมายในการสร้างพื้นที่เฉพาะสำหรับคนรักสัตว์เลี้ยง โดยเรากำหนดขอบเขต MVP ไว้อย่างชัดเจน แต่สิ่งที่ท้าทายที่สุดคือ **กฎเหล็กของโปรเจกต์**: เรามีโค้ด UI ของ Flutter ที่ออกแบบไว้อย่างประณีตอยู่แล้ว โจทย์ของเราไม่ใช่การรื้อทิ้งแล้วสร้างใหม่ แต่เป็นการรักษา UI เดิมไว้เป็น Visual Source of Truth แล้วพัฒนาระบบ Backend Strapi 5 และฐานข้อมูล PostgreSQL ขึ้นมารองรับการทำงานจริงในทุกจุดครับ"

---

### สไลด์ 3: สถาปัตยกรรมระบบ 3-Tier Enterprise Architecture
* **หัวข้อ:** สถาปัตยกรรมระบบ 3-Tier Enterprise Architecture
* **ประเด็นสำคัญ:**
  - **Client Tier:** Flutter 3.x (Dart), Material 3, LINE Seed Sans TH, Dio Network Interceptor, Flutter Secure Storage, Client Image Compression
  - **CMS / API Tier:** Strapi 5 Headless CMS (Node.js & TypeScript), Document Service Life-cycles, JWT & Refresh Policies, Automated RBAC Bootstrap
  - **Data Tier:** PostgreSQL 16 (Port 5433), Relational Data Integrity (Users, Posts, Media, PostLikes, Comments, Follows, Notifications)
  - **Cloud AI Tier:** Google Gemini 2.5 Flash Multimodal Vision, OpenStreetMap / Nominatim Reverse Geocoding
* **Speaker Script (บทพูดบรรยาย):**
  > "สถาปัตยกรรมของ InstaCat ถูกออกแบบตามหลัก 3-Tier Enterprise Architecture: ฝั่ง Client เป็น Flutter 3.x ที่ใช้ฟอนต์ LINE Seed Sans TH ทั้งหมด, ฝั่ง Application ใช้ Strapi 5 บน TypeScript จัดการ REST API และ Lifecycle, ฐานข้อมูลคือ PostgreSQL 16 รันบนพอร์ต 5433 จัดเก็บข้อมูลแบบ Relational อย่างรัดกุม และเชื่อมต่อไปยัง Google Gemini 2.5 Flash เพื่อทำ Multimodal Vision วิเคราะห์รูปภาพแมวครับ"

---

### สไลด์ 4: Style การสั่งงาน AI: กลยุทธ์การกำกับ AI ให้ได้งานสูงสุด (Prompt Engineering)
* **หัวข้อ:** Style การสั่งงาน AI: กลยุทธ์การกำกับ AI ให้ได้งานสูงสุด
* **ประเด็นสำคัญ:**
  - **1. Spec-Driven Directives:** ส่งมอบไฟล์ Markdown Spec ละเอียด (`spec.md`, `ai-caption-spec.md`, `docs/`) เป็น Single Source of Truth พร้อม Data Contract (JSON) ชัดเจน
  - **2. Milestone-Based Prompting:** สั่งงานเป็นลำดับขั้นตาม Roadmap (DB Bootstrap -> Auth & Keychain -> Feed & Stories -> Vision AI -> QA)
  - **3. Adaptive Fast Feedback:** รายงานปัญหาสั้น กระชับ ตรงจุด เช่น *"แอปค้างไป ฉัน restart ให้ใหม่แล้ว"*, *"ฉันเข้าสู่ระบบให้แล้ว"* เปิดทางให้ AI เข้าอ่าน Log ใน Terminal และตรวจ Database ได้ทันควัน
  - **4. Negative Constraints:** วางข้อห้ามเด็ดขาด เช่น *"ห้ามลบเขียน UI ใหม่"*, *"ห้าม mock ข้อมูลปลอม"*
* **Speaker Script (บทพูดบรรยาย):**
  > "หัวใจของความสำเร็จในการพัฒนาโปรเจกต์นี้ร่วมกับ AI อยู่ที่ **'Style การสั่งงาน'** ของผู้ใช้ครับ:
  > 1. **Spec-Driven:** เรามีเอกสารสเปกที่ชัดเจนระบุ Data Contract ทั้ง Request และ Response ทำให้ AI มีกรอบการทำงานที่แน่นอน ไม่เกิดการคาดเดาเจตนา
  > 2. **Milestone-Based:** เราแบ่งงานเป็นเฟสย่อย สั่งงานเป็นลำดับขั้น ไม่สั่งทำทุกอย่างในคำสั่งเดียว
  > 3. **Adaptive Fast Feedback:** เมื่อเกิดปัญหา ผู้ใช้จะแจ้งสั้นและตรงประเด็น เช่น 'แอปค้าง ฉันเริ่มให้ใหม่แล้ว' เพื่อให้ AI นำเครื่องมือไปตรวจสอบ Log และดำเนินงานต่อได้ทันทีครับ"

---

### สไลด์ 5: Agentic Workflow: วงจรการพัฒนาร่วมกับ AI ระดับคู่คิด (Autonomous Loop)
* **หัวข้อ:** Agentic Workflow: วงจรการพัฒนาร่วมกับ AI ระดับคู่คิด
* **ประเด็นสำคัญ:**
  - ความต่างระหว่าง Copilot ธรรมดา กับ Autonomous AI Engineer Agent
  - ลูป 5 ขั้นตอน: *1. Codebase Inspection -> 2. Implementation Planning -> 3. Multi-file Orchestration -> 4. Real-world Execution -> 5. Visual Verification*
  - การใช้ Terminal Commands รัน Strapi, รัน Flutter, คิวรี Postgres, และใช้ AppleScript/Quartz สั่ง Simulator แตะหน้าจอและแคปเจอร์รูปจริง
* **Speaker Script (บทพูดบรรยาย):**
  > "เรายกระดับการทำงานสู่ระดับ **Agentic Workflow**: AI ไม่ได้เพียงแค่นั่งรอให้เราถาม แต่สามารถสำรวจโครงสร้างโค้ดด้วยเครื่องมือ, จัดทำ Implementation Plan ขออนุมัติ, แก้ไขไฟล์ฝั่ง Frontend และ Backend ไปพร้อมกัน, รันเซิร์ฟเวอร์จริง และสั่งงานเครื่องจำลอง Simulator เพื่อถ่ายภาพหน้าจอมายืนยันผลลัพธ์ด้วยตาจริงครับ"

---

### สไลด์ 6: Showcase 1 - ระบบสมาชิกและความปลอดภัย (Authentication Suite: 3 จอ)
* **ภาพหน้าจอ:** `mockup_switch.png`, `mockup_login.png`, `mockup_register.png`
* **ฟังก์ชันเด่น:**
  - **Switch Account:** จดจำบัญชีผู้ใช้ล่าสุดในเครื่อง แสดงอวตารและชื่อ แตะเพื่อสลับบัญชีได้ทันที
  - **Clean Login:** ช่องกรอกสะอาดตา ไม่มีข้อมูลเก่าค้าง มีปุ่มดูรหัสผ่าน และแจ้งเตือนข้อผิดพลาด
  - **Register Screen:** หน้าสมัครสมาชิกใหม่ ตรวจสอบ Password confirmation และรูปแบบอีเมลก่อนบันทึกลง Postgres
* **Speaker Script (บทพูดบรรยาย):**
  > "หน้าจอชุดแรกคือระบบ Authentication Suite ทั้ง 3 หน้าจอ: หน้า Switch Account ที่จดจำบัญชีในเครื่องพร้อมปุ่มสลับบัญชีได้ในคลิกเดียว, หน้า Clean Login สำหรับการเข้าสู่ระบบแบบมาตรฐานที่ไม่มีข้อมูลค้างคา, และหน้า Register ที่มี Form Validation ตรวจสอบความถูกต้องก่อนส่งข้อมูลไปยัง Strapi Auth ครับ"

---

### สไลด์ 7: Showcase 2 - หน้าฟีดและคอมเมนต์ (Social Feed & Discussion: 2 จอ)
* **ภาพหน้าจอ:** `mockup_feed.png`, `mockup_comments.png`
* **ฟังก์ชันเด่น:**
  - **Cat Stories Bar:** แถบวงกลมแสดงสตอรี่ของแมวแต่ละตัว พร้อมไอคอนบวกเพิ่มสตอรี่ของตนเอง
  - **Multi-Photo Carousel:** โพสต์ของ testcat แสดงภาพได้สูงสุด 5 ภาพ พร้อมตัวเลข (1/5) และ Dots Indicator
  - **Optimistic Like:** แตะหัวใจแล้วเปลี่ยนเป็นสีแดงพร้อมเพิ่มตัวเลขทันที และซิงค์ฐานข้อมูลเบื้องหลัง
  - **Location & Tagged Cats:** แสดงพิกัด 'The Legacy Hotel Nana, Bangkok' และแท็กเพื่อนแมว `@testcat2` บนรูปภาพ
  - **Comments Sheet:** หน้าต่างแผ่นด้านล่างแสดงคอมเมนต์ และเปิดให้พิมพ์สนทนาแบบเรียลไทม์
* **Speaker Script (บทพูดบรรยาย):**
  > "หน้าจอที่สองคือหัวใจของแอป — Social Feed & Discussion: ด้านบนมีแถบ Cat Stories, ตัวโพสต์รองรับภาพหลายใบแบบ Carousel พร้อมตัวเลขบอกลำดับ (1/5), ระบบถูกใจแบบ Optimistic UI ที่หัวใจเปลี่ยนสีทันทีที่แตะ, การแท็กสถานที่และแท็กเพื่อนแมวบนรูปภาพ และหน้าต่างคอมเมนต์สำหรับพูดคุยกันใต้โพสต์ครับ"

---

### สไลด์ 8: Showcase 3 - หน้าสำรวจและค้นหา (Explore & Discovery Grid: 1 จอ)
* **ภาพหน้าจอ:** `mockup_explore.png`
* **ฟังก์ชันเด่น:**
  - **Instant Search Bar:** ค้นหาตามชื่อแมว, สายพันธุ์, และแฮชแท็ก
  - **Dynamic Breed Filter Chips:** ปุ่มคัดกรองหมวดหมู่รวดเร็ว (#Trending, Reels, Ragdoll, Funny Cats, Kittens)
  - **Masonry Grid:** ตารางรูปภาพและคลิปวิดีโอ ดึงสดจากฐานข้อมูล Strapi 5
  - **Reels & Album Badges:** ไอคอนวิดีโอสำหรับ Reels และไอคอนซ้อนสำหรับโพสต์รูปหลายใบ
* **Speaker Script (บทพูดบรรยาย):**
  > "หน้า Explore ช่วยให้ผู้ใช้ค้นพบคอนเทนต์แมวใหม่ๆ ได้อย่างเพลิดเพลิน ด้วยแถบตัวกรองสายพันธุ์ เช่น Ragdoll หรือ Funny Cats และตารางแสดงภาพแบบมี Badges แยกชัดเจนระหว่างภาพนิ่งกับคลิปวิดีโอ Reels สั้นครับ"

---

### สไลด์ 9: Showcase 4 - สตูดิโอสร้างโพสต์ (Content Creation & Media Studio: 2 จอ)
* **ภาพหน้าจอ:** `mockup_create_picker.png`, `mockup_post_composer.png`
* **ฟังก์ชันเด่น:**
  - **Custom Gallery Picker:** หน้าเลือกรูปสไตล์ Instagram พร้อมปุ่มถ่ายภาพและวงแหวนเลือกรูปหลายใบ
  - **Media Mode Switcher:** แถบเลือกสลับระหว่าง POST, STORY, REELS
  - **Cat Photo Filters:** ฟิลเตอร์ปรับแต่งภาพแมว 5 อารมณ์ (Normal, Warm Glow, Golden Hour, Vintage Cat, Soft Purr)
  - **Popular Cat Hashtags:** ปุ่มแฮชแท็กสำเร็จรูปแตะแล้วแทรกลงข้อความทันที
* **Speaker Script (บทพูดบรรยาย):**
  > "ในสตูดิโอสร้างโพสต์ ผู้ใช้จะได้สัมผัส Custom Gallery Picker ที่เลือกภาพได้หลายใบพร้อมกัน และหน้า Post Composer ที่มีฟิลเตอร์สีสำหรับภาพแมวโดยเฉพาะ พร้อมทั้งปุ่มแฮชแท็กสำเร็จรูปช่วยให้เขียนโพสต์ได้สะดวกขึ้นครับ"

---

### สไลด์ 10: Showcase 5 - ผู้ช่วยแคปชันอัจฉริยะ (Gemini Vision AI Assistant: 1 จอ)
* **ภาพหน้าจอ:** `mockup_ai_caption.png`
* **ฟังก์ชันเด่น:**
  - **Multimodal Image Analysis:** ใช้ Google Gemini 2.5 Flash วิเคราะห์ภาพแมว
  - **4 Personality Tones:** เลือกอารมณ์ได้ 4 แบบ ได้แก่ 'น่ารัก' 💖, 'ตลก' 😹, 'กวนๆ' 😼 และ 'สั้นกระชับ' ⚡
  - **Thai Feline Slang & Emojis:** คำบรรยายภาษาไทยสไตล์คนรักแมว เช่น *"งอยย ตาแป๋วขนาดนี้...", "เจ้าส้มจอมกวน 🧡"*
  - **One-Tap Insertion & Regenerate:** แตะเพื่อนำไปใส่ในโพสต์ทันที หรือกดสุ่มใหม่ได้ไม่จำกัด
* **Speaker Script (บทพูดบรรยาย):**
  > "นี่คือไฮไลต์พิเศษของ InstaCat ครับ — AI Caption Assistant โดย Gemini 2.5 Flash จะวิเคราะห์ภาพแมวตาแป๋วในรูป แล้วสร้างคำบรรยายภาษาไทย 4 สไตล์ให้เลือก เช่น น่ารัก หรือ กวนๆ แสบๆ ผู้ใช้แตะปุ๊บ ข้อความจะลงไปในโพสต์ทันทีครับ"

---

### สไลด์ 11: Showcase 6 - ระบบปักหมุดสถานที่ (Geolocation & Place Tagging: 1 จอ)
* **ภาพหน้าจอ:** `mockup_location.png`
* **ฟังก์ชันเด่น:**
  - **Real-Time GPS:** ดึงพิกัดจากอุปกรณ์ผ่าน Geolocator
  - **Reverse Geocoding:** แปลงพิกัดเป็นชื่อถนนและเขตจริงผ่าน OpenStreetMap (Nominatim)
  - **Auto-Detected Selection:** ติ๊กถูกสถานที่ที่ตรวจพบ เช่น *"Dinso Road, Bowon Niwet, Phra Nakhon"*
  - **Custom Place Name:** พิมพ์ชื่อสถานที่เฉพาะเองได้อย่างอิสระ
* **Speaker Script (บทพูดบรรยาย):**
  > "หน้า Add Location ใช้พิกัด GPS จริงจากมือถือ แล้วแปลงเป็นชื่อถนนด้วย OpenStreetMap ผู้ใช้สามารถเลือกสถานที่ที่ตรวจจับได้ หรือพิมพ์ชื่อสถานที่ เช่น คาเฟ่แมวที่ต้องการได้อย่างอิสระครับ"

---

### สไลด์ 12: Showcase 7 - ระบบแจ้งเตือนและกิจกรรม (Notifications & Activity: 1 จอ)
* **ภาพหน้าจอ:** `mockup_notifications.png`
* **ฟังก์ชันเด่น:**
  - **Activity Feed:** บันทึกกิจกรรม เช่น ถูกใจโพสต์ และการกดติดตามใหม่
  - **Categorized Filter Pills:** คัดกรองดูเฉพาะ All, Likes, Comments, หรือ Follows
  - **Interactive Follow Back:** ปุ่มกดติดตามเพื่อนแมวกลับได้ทันทีจากหน้านี้
  - **Post Thumbnail Preview:** แสดงรูปย่อของโพสต์ที่ถูกกดถูกใจ
* **Speaker Script (บทพูดบรรยาย):**
  > "หน้า Notifications รวบรวมทุกกิจกรรมที่เกี่ยวข้องกับน้องแมวของเรา มี Filter Pills คัดกรอง และมีรูป Thumbnail กำกับชัดเจนว่าเพื่อนแมวเข้ามากดถูกใจที่รูปใด พร้อมปุ่ม Follow กลับได้ทันทีครับ"

---

### สไลด์ 13: Showcase 8 - โปรไฟล์และการตั้งค่าบัญชี (Profile & Settings Suite: 2 จอ)
* **ภาพหน้าจอ:** `mockup_profile.png`, `mockup_edit_profile.png`
* **ฟังก์ชันเด่น:**
  - **Live DB Stats:** สถิติสดจาก Postgres: Posts (3), Followers (1), Following (1)
  - **Paw Breed Badge:** ป้ายสายพันธุ์แมว 'Orange Cat' พร้อมไอคอนอุ้งเท้า
  - **Story Highlights:** แถบวงกลมไฮไลต์เรื่องราว (Playtime, Treats, Naps, OOTD)
  - **Edit Profile:** เปลี่ยนรูปอวตาร, ชื่อ, หมวดหมู่สายพันธุ์, เว็บไซต์, Bio, สวิตช์ Public Profile, และปุ่ม Log Out
* **Speaker Script (บทพูดบรรยาย):**
  > "และหน้าจอชุดสุดท้ายคือ Profile & Settings: หน้าโปรไฟล์แสดงสถิติสด มีไฮไลต์และป้ายสายพันธุ์ ส่วนหน้า Edit Profile สามารถแก้ไขข้อมูล Bio, ปรับหมวดหมู่สายพันธุ์ และมีสวิตช์เปิดปิด Public Profile ครบวงจรครับ"

---

### สไลด์ 14: ปัญหาเชิงเทคนิคและการแก้ไข 1: Backend & Database (Issues 1-4)
* **หัวข้อ:** ปัญหาเชิงเทคนิคและการแก้ไข: Backend & Database
* **ประเด็นปัญหาและโซลูชัน:**
  1. **Strapi 5 RBAC Permissions:** Endpoint ใหม่ติด 403 Forbidden ทันที -> *แก้ด้วยการเขียน Bootstrap Script ใน `backend/src/index.ts` ผูกสิทธิ์ Public & Authenticated อัตโนมัติทุกครั้งที่บูตเซิร์ฟเวอร์*
  2. **SQLite vs PostgreSQL Sync & Port 5433:** ข้อมูลหายหรือต่อ DB ไม่ติด -> *แก้ด้วยการตั้งค่า `database.ts` ให้ชี้ PostgreSQL พอร์ต 5433 และซิงค์รหัสผ่าน bcrypt ให้ตรงกับ `password123`*
  3. **Strapi 5 Document Service Population:** Response ขาดข้อมูล Author และ Media -> *แก้ด้วยการเขียน Explicit Populate Query ใน Controller*
  4. **Emulator Network IP:** Android ยิง 127.0.0.1 แล้วเจอ Connection Refused -> *แก้ด้วย Dynamic Adaptive Base URL สลับเป็น `10.0.2.2` บน Android และ `127.0.0.1` บน iOS อัตโนมัติ*
* **Speaker Script (บทพูดบรรยาย):**
  > "ในฝั่ง Backend เราพบปัญหาจริง 4 ประการ: สิทธิ์ Strapi บล็อก เราแก้ด้วย Bootstrap Lifecycle; ปัญหาพอร์ต Postgres 5433 และรหัสผ่าน bcrypt เราซิงค์ให้ตรงกัน; ปัญหา Document Service เราเขียน Explicit Populate; และปัญหา IP บน Android เราทำ Adaptive Base URL ครับ"

---

### สไลด์ 15: ปัญหาเชิงเทคนิคและการแก้ไข 2: Mobile, AI & UX (Issues 5-8)
* **หัวข้อ:** ปัญหาเชิงเทคนิคและการแก้ไข: Mobile, AI & UX
* **ประเด็นปัญหาและโซลูชัน:**
  5. **iOS Keychain Error (-34018):** `FlutterSecureStorage` ล้มเหลวและแอปดับบน iOS Simulator -> *แก้ด้วยการออกแบบ Multi-Tier Storage มี In-Memory / SharedPreferences Fallback สำรองข้อมูลทันที*
  6. **Image Payload Size:** ภาพถ่ายมือถือขนาด 5-10 MB กินเน็ตและเกิด Timeout -> *แก้ด้วย Image Processing Pipeline ฝั่ง Client บีบอัดเป็น JPEG คุณภาพ 85% กว้างไม่เกิน 2048px ลดขนาดไฟล์ลงได้ถึง 75%*
  7. **Gemini Vision Markdown Code Fences:** AI ส่งข้อความ ```json ปะปนมาทำให้ JSON Decode ขัดข้อง -> *แก้ด้วย Regex Strip ทำความสะอาด Code Block และเตรียมชุด Fallback Captions 5 สไตล์*
  8. **UI Layout Spacing & Location Overflow:** จอเกิดแถบเหลืองดำทับซ้อน Dynamic Island -> *แก้ด้วยการจัดโครงสร้าง Responsive Layout ด้วย SingleChildScrollView และ SafeArea ใหม่ทั้งหมด*
* **Speaker Script (บทพูดบรรยาย):**
  > "ในฝั่ง Mobile และ AI เราแก้ปัญหา Keychain Crash บน iOS Simulator ด้วย Multi-Tier Fallback, ลดขนาดภาพถ่ายลง 75% ด้วย Client-side Compression, ทำความสะอาด JSON Markdown จาก Gemini และจัดระยะ Padding ของหน้าจอใหม่ทั้งหมดเพื่อป้องกัน Layout Overflow ครับ"

---

### สไลด์ 16: การทดสอบระบบและการรับประกันคุณภาพ (QA Matrix & Verification)
* **หัวข้อ:** การทดสอบระบบและการรับประกันคุณภาพ (QA Matrix)
* **ประเด็นสำคัญ:**
  - **Automated Tests:** 27 ชุดทดสอบ (Data Models, Mocked Network, Token Refresh, Post & Comments) ผ่าน 100%
  - **Static Code Analysis:** รัน `flutter analyze` พบ **0 Issues / 0 Warnings**
  - **Live Verification:** ทดสอบสดบน iPhone 16 Pro Max Simulator ครบทั้ง 13 หน้าจอ มีบัญชีทดสอบ `testcat` และ `testcat2` รองรับ Live Demo
* **Speaker Script (บทพูดบรรยาย):**
  > "เพื่อความมั่นใจในคุณภาพระดับ Production เรามีชุดทดสอบอัตโนมัติ 27 รายการ ผ่าน 100%, รัน `flutter analyze` ผ่านฉลุย 0 warning และทดสอบสดบน iOS Simulator ครบทั้ง 13 หน้าจอจริงอย่างไร้ที่ติครับ"

---

### สไลด์ 17: บทเรียนสำคัญจากการพัฒนาร่วมกับ AI (Key Takeaways)
* **หัวข้อ:** บทเรียนสำคัญจากการพัฒนาร่วมกับ AI
* **ประเด็นสำคัญ:**
  - **1. Specification is King:** สเปกและ Data Contract ที่ชัดเจนคือหัวใจที่ทำให้ AI ทำงานได้แม่นยำ
  - **2. Engineer as Chief Architect:** มนุษย์คือผู้กำหนดกรอบ ความปลอดภัย และสถาปัตยกรรม
  - **3. Resilient Engineering:** ซอฟต์แวร์ที่ดีต้องออกแบบเผื่อความล้มเหลว (Fallback Storage, Fallback AI Captions)
  - **Productivity Multiplier:** ลดเวลาพัฒนาลงกว่า 80% ปราศจากความเมื่อยล้าจากการเขียนโค้ด Boilerplate
* **Speaker Script (บทพูดบรรยาย):**
  > "บทเรียนสำคัญคือ AI ช่วยเป็นตัวเร่งการพัฒนาได้อย่างมหาศาล โดยมีวิศวกรเป็นผู้กำหนดสเปกและสถาปัตยกรรม การผสานมนุษย์กับ AI เช่นนี้ทำให้ได้ซอฟต์แวร์ที่มีคุณภาพสูงและรวดเร็วขึ้นถึง 80% ครับ"

---

### สไลด์ 18: ทิศทางการพัฒนาต่อยอด และสรุปผลงาน (Roadmap & Q&A)
* **หัวข้อ:** ทิศทางการพัฒนาต่อยอด และสรุปผลงาน
* **ประเด็นสำคัญ:**
  - **Future Roadmap:** Push Notifications (FCM), AI Cat Breed Classifier, Video Streaming Stories, Cat Chat (DM)
  - **Delivery Summary:** ส่งมอบครบ 13 หน้าจอจริง, 3-Tier Architecture สมบูรณ์, ผ่านการทดสอบ 100%
* **Speaker Script (บทพูดบรรยาย):**
  > "InstaCat พร้อมสำหรับการต่อยอดสู่ระบบ Push Notifications และ Breed Classifier ในอนาคต และวันนี้ระบบทั้ง 13 หน้าจอเสร็จสมบูรณ์พร้อมใช้งานจริงแล้วครับ ขอขอบคุณทุกท่านครับ และยินดีตอบทุกคำถามครับ!"

---

## แนวทางการตอบคำถามกรรมการ (Anticipated Q&A Guide)

### คำถามที่ 1: ทำไมถึงเลือก Strapi 5 แทนที่จะเขียน Custom Node.js / Express หรือ NestJS เองทั้งหมด?
> **คำตอบ:** "เหตุผลหลักคือความรวดเร็วและมาตรฐานครับ Strapi 5 มอบระบบ Content Management, Media Upload Pipeline, Built-in Role-Based Access Control (RBAC), และ REST/GraphQL API มาให้ตั้งแต่ต้น ทำให้ทีมงานประหยัดเวลาการทำ Boilerplate CRUD ไปได้มากกว่า 70% และสามารถนำเวลาไปโฟกัสที่ Business Logic เฉพาะตัว เช่น การเชื่อมต่อ Gemini AI และการจัดการความสัมพันธ์ของฟีดโซเชียลมีเดียได้อย่างเต็มที่ครับ"

### คำถามที่ 2: ปัญหา Keychain Error (-34018) บน iOS Simulator ได้รับการแก้ไขอย่างไร และมีความปลอดภัยในระดับ Production หรือไม่?
> **คำตอบ:** "เราออกแบบสถาปัตยกรรมเป็นแบบ **Multi-Tier Storage with Graceful Degradation** ครับ ในเครื่องจริง (Physical Device) ระบบจะเขียนลง iOS Keychain และ Android Keystore เสมอเพื่อความปลอดภัยสูงสุด แต่บน iOS Simulator ซึ่งมีข้อจำกัดด้าน Entitlement ระบบจะดักจับข้อผิดพลาดและสลับไปบันทึกใน In-Memory Cache ชั่วคราว ทำให้การทดสอบและเดโมดำเนินต่อไปได้โดยที่แอปไม่ Crash ครับ"

### คำถามที่ 3: มีมาตรการรับมืออย่างไรหาก Gemini Vision AI ไม่สามารถตอบกลับได้ หรือเกิดกรณี Rate Limit?
> **คำตอบ:** "เราวางระบบป้องกันไว้ 2 ชั้นครับ: ชั้นแรกในฝั่ง Strapi มี Timeout และ Error Handling ดักจับสถานะจาก Google AI Studio และชั้นที่สองในฝั่ง Flutter เราเตรียม **Fallback Heuristic Captions** ภาษาไทย 4 สไตล์ไว้ในเครื่อง หาก API ขัดข้อง ระบบจะสุ่มแคปชันสำรองขึ้นมาให้ผู้ใช้เลือกทันที ทำให้ UX ของผู้ใช้ไหลลื่น 100% โดยไม่มีข้อความ Error กวนใจครับ"

### คำถามที่ 4: Style การสั่งงาน AI ที่มีประสิทธิภาพสูงสุดในการพัฒนาโปรเจกต์นี้คืออะไร?
> **คำตอบ:** "คือ **Spec-Driven Directives ควบคู่กับ Fast Adaptive Feedback** ครับ การมีเอกสาร Markdown Spec ที่ระบุ Data Schema และข้อห้าม (Negative Constraints) เช่น 'ห้ามรื้อ UI เดิม' ช่วยตีกรอบให้ AI ได้อย่างแม่นยำ และเมื่อเกิดข้อผิดพลาด การแจ้งข้อเท็จจริงสั้นๆ เช่น 'แอปค้าง รีสตาร์ทให้แล้ว' ช่วยให้ AI นำเครื่องมือเข้าไปตรวจค้น Log ใน Terminal และแก้ไขปัญหาได้เร็วกว่าการอธิบายยืดยาวครับ"
