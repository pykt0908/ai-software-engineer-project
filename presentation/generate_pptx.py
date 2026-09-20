#!/usr/bin/env python3
"""
InstaCat Presentation Generator
Generates a professional 16:9 widescreen PowerPoint presentation (.pptx)
with embedded mobile smartphone mockups for ALL app screens,
comprehensive problem-solving analysis, user prompt engineering style,
and uses LINE Seed Sans TH font across all text runs.
"""

import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE
from pptx.oxml import parse_xml

FONT_FAMILY = "LINE Seed Sans TH"

def set_font_for_run(run, font_name=FONT_FAMILY, size=None, bold=False, color=None):
    if size:
        run.font.size = size
    run.font.bold = bold
    if color:
        run.font.color.rgb = color
    run.font.name = font_name

    # Set DrawingML XML attributes for Latin, East Asian, and Complex Script (Thai)
    rPr = run._r.get_or_add_rPr()
    rPr.set('altLang', 'th-TH')
    for tag in ['a:cs', 'a:ea', 'a:latin']:
        el = rPr.find(f'{{http://schemas.openxmlformats.org/drawingml/2006/main}}{tag[2:]}')
        if el is None:
            el = parse_xml(f'<{tag} xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" typeface="{font_name}"/>')
            rPr.append(el)
        else:
            el.set('typeface', font_name)

def create_deck():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    blank_layout = prs.slide_layouts[6] # Blank layout

    # Premium Dark Color Palette
    BG_DARK = RGBColor(15, 23, 42)         # Slate 900
    CARD_BG = RGBColor(30, 41, 59)         # Slate 800
    CARD_BORDER = RGBColor(51, 65, 85)     # Slate 700
    ACCENT_ORANGE = RGBColor(255, 138, 61) # Primary Brand Orange
    ACCENT_PURPLE = RGBColor(139, 92, 246) # Secondary Purple
    ACCENT_CYAN = RGBColor(14, 165, 233)   # Sky Blue / Cyan
    ACCENT_GREEN = RGBColor(16, 185, 129)  # Emerald Green
    ACCENT_RED = RGBColor(239, 68, 68)     # Crimson Red
    TEXT_WHITE = RGBColor(248, 250, 252)   # Slate 50
    TEXT_MUTED = RGBColor(148, 163, 184)   # Slate 400

    base_dir = os.path.dirname(os.path.abspath(__file__))
    img_dir = os.path.join(base_dir, "images")

    def add_bg(slide):
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, prs.slide_height)
        bg.fill.solid()
        bg.fill.fore_color.rgb = BG_DARK
        bg.line.fill.background()
        return bg

    def add_header(slide, tag, title, subtitle):
        tb_tag = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11.7), Inches(0.35))
        tf_tag = tb_tag.text_frame
        tf_tag.word_wrap = True
        p_tag = tf_tag.paragraphs[0]
        r_tag = p_tag.add_run()
        r_tag.text = tag.upper()
        set_font_for_run(r_tag, size=Pt(11), bold=True, color=ACCENT_ORANGE)

        tb_title = slide.shapes.add_textbox(Inches(0.8), Inches(0.65), Inches(11.7), Inches(0.65))
        tf_title = tb_title.text_frame
        tf_title.word_wrap = True
        p_title = tf_title.paragraphs[0]
        r_title = p_title.add_run()
        r_title.text = title
        set_font_for_run(r_title, size=Pt(24), bold=True, color=TEXT_WHITE)

        if subtitle:
            tb_sub = slide.shapes.add_textbox(Inches(0.8), Inches(1.3), Inches(11.7), Inches(0.4))
            tf_sub = tb_sub.text_frame
            tf_sub.word_wrap = True
            p_sub = tf_sub.paragraphs[0]
            r_sub = p_sub.add_run()
            r_sub.text = subtitle
            set_font_for_run(r_sub, size=Pt(12.5), bold=False, color=TEXT_MUTED)

    def add_card(slide, left, top, width, height, title, items, border_color=None):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        card.fill.solid()
        card.fill.fore_color.rgb = CARD_BG
        card.line.color.rgb = border_color if border_color else CARD_BORDER
        card.line.width = Pt(1.5)

        tb = slide.shapes.add_textbox(left + Inches(0.2), top + Inches(0.18), width - Inches(0.4), height - Inches(0.36))
        tf = tb.text_frame
        tf.word_wrap = True
        
        p_title = tf.paragraphs[0]
        p_title.space_after = Pt(8)
        r_title = p_title.add_run()
        r_title.text = title
        set_font_for_run(r_title, size=Pt(14), bold=True, color=border_color if border_color else TEXT_WHITE)

        for it in items:
            p = tf.add_paragraph()
            p.space_after = Pt(5)
            r = p.add_run()
            r.text = f"• {it}"
            set_font_for_run(r, size=Pt(11.5), bold=False, color=TEXT_MUTED)

    def set_notes(slide, notes_text):
        notes_slide = slide.notes_slide
        tf = notes_slide.notes_text_frame
        tf.text = notes_text
        if len(tf.paragraphs) > 0:
            for p in tf.paragraphs:
                for r in p.runs:
                    set_font_for_run(r, size=Pt(11))

    # ==========================================
    # SLIDE 1: Title Slide
    # ==========================================
    s1 = prs.slides.add_slide(blank_layout)
    add_bg(s1)

    tb_badge = s1.shapes.add_textbox(Inches(0.8), Inches(1.8), Inches(11.7), Inches(0.5))
    tf_b = tb_badge.text_frame
    p_b = tf_b.paragraphs[0]
    r_b = p_b.add_run()
    r_b.text = "🐾 AI SOFTWARE ENGINEER CAPSTONE PROJECT"
    set_font_for_run(r_b, size=Pt(14), bold=True, color=ACCENT_ORANGE)

    tb_hero = s1.shapes.add_textbox(Inches(0.8), Inches(2.3), Inches(11.7), Inches(1.4))
    tf_h = tb_hero.text_frame
    tf_h.word_wrap = True
    p_h = tf_h.paragraphs[0]
    r_h = p_h.add_run()
    r_h.text = "InstaCat: The Purr-fect Pet Community"
    set_font_for_run(r_h, size=Pt(38), bold=True, color=TEXT_WHITE)

    tb_sub = s1.shapes.add_textbox(Inches(0.8), Inches(3.7), Inches(11.7), Inches(1.2))
    tf_s = tb_sub.text_frame
    tf_s.word_wrap = True
    p_s = tf_s.paragraphs[0]
    r_s = p_s.add_run()
    r_s.text = "การพัฒนาโมบายโซเชียลมีเดียแบบ Full-Stack (Flutter ↔ Strapi 5 ↔ PostgreSQL ↔ Gemini AI)\nด้วยสไตล์การสั่งงาน AI ชั้นสูง (Spec-Driven Prompting) และ Agentic Workflow"
    set_font_for_run(r_s, size=Pt(17), bold=False, color=TEXT_MUTED)

    add_card(s1, Inches(0.8), Inches(5.2), Inches(3.6), Inches(1.4), "สถาปัตยกรรมระดับองค์กร", ["3-Tier Full-Stack Production Architecture", "Flutter + Strapi 5 + PostgreSQL 16"], ACCENT_ORANGE)
    add_card(s1, Inches(4.8), Inches(5.2), Inches(3.6), Inches(1.4), "ปัญญาประดิษฐ์วิทัศน์ (Vision AI)", ["Google Gemini 2.5 Flash Multimodal", "วิเคราะห์รูปแมวสร้างแคปชัน 4 สไตล์"], ACCENT_PURPLE)
    add_card(s1, Inches(8.8), Inches(5.2), Inches(3.6), Inches(1.4), "ความสมบูรณ์ 100%", ["แสดงผลครบทุก 13 หน้าจอจริง", "27 Automated Tests ผ่าน 100%"], ACCENT_GREEN)

    set_notes(s1, "ยินดีต้อนรับทุกท่านครับ วันนี้ผมจะนำเสนอโปรเจกต์ InstaCat แอปโซเชียลมีเดียสำหรับคนรักแมวที่พัฒนาขึ้นอย่างสมบูรณ์แบบทั้ง 13 หน้าจอจริง เชื่อมต่อ Flutter, Strapi 5, Postgres และ Gemini Vision AI พร้อมเจาะลึกสไตล์การสั่งงาน AI และการแก้ปัญหาจริงครับ")

    # ==========================================
    # SLIDE 2: Project Vision & Scope
    # ==========================================
    s2 = prs.slides.add_slide(blank_layout)
    add_bg(s2)
    add_header(s2, "Part 1: Concept & Planning", "ภาพรวมและความเป็นมาของ InstaCat", "เปลี่ยนโจทย์โซเชียลมีเดียสำหรับคนรักแมวสู่แอปพลิเคชันใช้งานจริงที่เสร็จสมบูรณ์")

    add_card(s2, Inches(0.8), Inches(1.9), Inches(3.6), Inches(5.0), "🎯 วิสัยทัศน์ (Project Vision)", [
        "สร้างพื้นที่คอมมูนิตี้เฉพาะกลุ่มสำหรับคนรักสัตว์เลี้ยง",
        "แชร์ภาพ เรื่องราว และไลฟ์สไตล์ของน้องแมวอย่างสร้างสรรค์",
        "เชื่อมโยง Mobile App, Headless CMS และ Cloud AI เข้าด้วยกัน",
        "เป็นกรณีศึกษาต้นแบบของ AI Software Engineer Workflow"
    ], ACCENT_ORANGE)

    add_card(s2, Inches(4.8), Inches(1.9), Inches(3.6), Inches(5.0), "📏 ขอบเขตฟังก์ชัน (Feature Scope)", [
        "Authentication: One-Tap Switch Account, Login, Register",
        "Feed & Stories: ฟีดภาพหลายรูป, Cat Stories, Like, Comments",
        "Explore & Search: ค้นหาตามสายพันธุ์ และตารางภาพแบบมี Reels",
        "Studio & Creation: คัดเลือกรูปหลายใบ, ฟิลเตอร์, ปักหมุดพิกัด",
        "Gemini AI: ผู้ช่วยแต่งคำบรรยายแมว 4 สไตล์อัตโนมัติ"
    ], ACCENT_PURPLE)

    add_card(s2, Inches(8.8), Inches(1.9), Inches(3.6), Inches(5.0), "🔒 กฎเหล็กของโปรเจกต์", [
        "'Do not recreate the project'",
        "UI ของ Flutter เดิมคือ Visual Source of Truth",
        "ห้ามลบทิ้งหรือสร้างแอปใหม่แบบ generic เด็ดขาด",
        "มุ่งเน้นการต่อท่อเชื่อม UI เดิมเข้ากับ Backend จริง",
        "ประสบการณ์ผู้ใช้ (UX/UI) ต้องประณีต ตรงตามต้นฉบับ 100%"
    ], ACCENT_CYAN)

    set_notes(s2, "InstaCat มีเป้าหมายชัดเจนคือการเป็นคอมมูนิตี้สำหรับคนรักแมว กฎเหล็กของโปรเจกต์คือห้ามแตะต้องหรือทำลาย UI เดิม แต่ต้องต่อท่อให้ใช้งานได้จริงกับ Backend และฐานข้อมูลครบทุกฟังก์ชันครับ")

    # ==========================================
    # SLIDE 3: System Architecture
    # ==========================================
    s3 = prs.slides.add_slide(blank_layout)
    add_bg(s3)
    add_header(s3, "Part 1: Concept & Planning", "สถาปัตยกรรมระบบ 3-Tier Enterprise Architecture", "การแยก Layer อิสระเพื่อความเสถียร รองรับการขยายตัว และง่ายต่อการทดสอบ")

    add_card(s3, Inches(0.8), Inches(1.9), Inches(2.7), Inches(5.0), "📱 1. Client Tier", [
        "Flutter 3.x (Dart)",
        "Material 3 Design System",
        "LINE Seed Sans TH Font",
        "Dio Network Interceptor",
        "Flutter Secure Storage",
        "Client Image Compression",
        "Optimistic State Updates"
    ], ACCENT_ORANGE)

    add_card(s3, Inches(3.8), Inches(1.9), Inches(2.7), Inches(5.0), "⚡ 2. CMS / API Tier", [
        "Strapi 5 Headless CMS",
        "Node.js & TypeScript",
        "Document Service Life-cycles",
        "JWT & Refresh Token Policies",
        "Automated RBAC Bootstrap",
        "Multipart Media Pipeline",
        "Secure REST Endpoints"
    ], ACCENT_PURPLE)

    add_card(s3, Inches(6.8), Inches(1.9), Inches(2.7), Inches(5.0), "🗄️ 3. Data Tier", [
        "PostgreSQL 16 (Port 5433)",
        "Relational Data Integrity",
        "Tables: Users, Posts, Media",
        "PostLikes, Comments",
        "Follows & Notifications",
        "Foreign Key Constraints",
        "Indexed Query Optimization"
    ], ACCENT_CYAN)

    add_card(s3, Inches(9.8), Inches(1.9), Inches(2.7), Inches(5.0), "🤖 4. Cloud AI Tier", [
        "Google Gemini 2.5 Flash",
        "Multimodal Vision Analysis",
        "OpenStreetMap / Nominatim",
        "Reverse Geocoding Engine",
        "JSON Schema Strict Prompting",
        "Fallback Heuristic Captions",
        "Resilient Error Handling"
    ], ACCENT_GREEN)

    set_notes(s3, "ระบบถูกออกแบบเป็น 4 Tier ชัดเจน: ฝั่ง Client เป็น Flutter 3.x, ฝั่ง Backend ใช้ Strapi 5, ฐานข้อมูลคือ PostgreSQL 16 และเชื่อมต่อ Cloud AI ด้วย Gemini 2.5 Flash สำหรับการวิเคราะห์ภาพแมวครับ")

    # ==========================================
    # SLIDE 4: Style การสั่งงาน AI & Prompt Engineering
    # ==========================================
    s4 = prs.slides.add_slide(blank_layout)
    add_bg(s4)
    add_header(s4, "Part 2: Human-AI Collaboration", "Style การสั่งงาน AI: กลยุทธ์การกำกับ AI สูงสุด", "ถอดรหัสเทคนิค Prompt Engineering และรูปแบบการสั่งงานที่ทำให้ AI ส่งงานได้ตรงเป้า 100%")

    add_card(s4, Inches(0.8), Inches(1.9), Inches(3.6), Inches(5.0), "📑 1. Spec-Driven Directives", [
        "ส่งมอบเอกสาร Markdown Spec ที่ละเอียดเป็น Single Source of Truth",
        "ระบุ Data Contract ครบถ้วน (Request / Response JSON)",
        "กำหนด Acceptance Criteria ของทุกหน้าจอ",
        "ผลลัพธ์: AI มีเข็มทิศที่แน่นอน ไม่คาดเดาเจตนาเอง ลดข้อผิดพลาดได้กว่า 90%"
    ], ACCENT_ORANGE)

    add_card(s4, Inches(4.8), Inches(1.9), Inches(3.6), Inches(5.0), "🪜 2. Milestone-Based Prompting", [
        "แบ่งงานเป็น Milestone ย่อยที่มีลำดับขึ้นลงอย่างมีตรรกะ:",
        "Phase 1: DB & Permissions Bootstrap",
        "Phase 2: Authentication & Keychain Fallback",
        "Phase 3: Social Feed, Carousel & Likes",
        "Phase 4: Gemini Vision AI & Location",
        "Phase 5: UX Spacing & 13 Screens QA"
    ], ACCENT_PURPLE)

    add_card(s4, Inches(8.8), Inches(1.9), Inches(3.6), Inches(5.0), "⚡ 3. Adaptive Fast Feedback", [
        "รายงานปัญหาแบบสั้น กระชับ ตรงจุด เช่น:",
        "'แอปค้างไป ฉัน restart ให้ใหม่แล้ว'",
        "'ฉันเข้าสู่ระบบให้แล้ว'",
        "เปิดทางให้ AI เข้าอ่าน Log, เข้าเช็ก Database และลุยงานต่อได้ทันที",
        "กำหนด Negative Constraints: 'ห้ามรื้อ UI เดิม', 'ห้าม Hardcode ข้อมูลผู้ใช้'"
    ], ACCENT_CYAN)

    set_notes(s4, "สไตล์การสั่งงาน AI ของโปรเจกต์นี้มีเอกลักษณ์สูง: เราใช้ Spec-Driven กำหนดสเปกชัดเจน, สั่งงานเป็น Milestone ขั้นบันได และใช้วิธี Feedback สั้นตรงประเด็น เพื่อให้ AI แก้ไขปัญหาได้เร็วที่สุดครับ")

    # ==========================================
    # SLIDE 5: Agentic Workflow & Autonomous Pair-Programming
    # ==========================================
    s5 = prs.slides.add_slide(blank_layout)
    add_bg(s5)
    add_header(s5, "Part 2: Human-AI Collaboration", "Agentic Workflow: วงจรการพัฒนาร่วมกับ AI", "เปลี่ยนจากแค่การขอโค้ดมาเป็น Autonomous Pair-Programming ตลอดกระบวนการ")

    add_card(s5, Inches(0.8), Inches(1.9), Inches(5.6), Inches(5.0), "🔄 ลูปการปฏิบัติการของ AI (Autonomous Loop)", [
        "1. Codebase Inspection: สำรวจโครงสร้างโปรเจกต์จริงผ่าน Ripgrep และ File Viewer โดยไม่เดาโครงสร้างเอง",
        "2. Implementation Planning: วางแผนการแก้ไฟล์ละเอียด แจกแจงความเสี่ยง และขออนุมัติก่อนแตะโค้ดส่วนสำคัญ",
        "3. Multi-File Atomic Edits: อัปเดต Controller ในฝั่ง Node.js ควบคู่กับ Service ในฝั่ง Flutter ให้เข้าคู่กันในครั้งเดียว",
        "4. Real-world Execution: รันเซิร์ฟเวอร์ Strapi, รัน Flutter, และคิวรี Database ด้วยคำสั่ง Terminal จริง",
        "5. Visual Verification: สั่งให้เครื่องมือแตะหน้าจอ Simulator และ Capture รูปหน้าจอจริงเพื่อตรวจสอบผลงานด้วยตา"
    ], ACCENT_ORANGE)

    add_card(s5, Inches(6.8), Inches(1.9), Inches(5.6), Inches(5.0), "🚀 ประโยชน์ของการทำงานแบบ AI-First Workflow", [
        "Zero Context Switching: ไม่ต้องสลับหน้าต่างก๊อปปี้ Error มาแปะ AI จัดการผ่าน Shell ในตัว",
        "High Velocity Delivery: พัฒนาระบบ Full-Stack ขนาด 13 หน้าจอเสร็จสมบูรณ์ในเวลาอันรวดเร็ว",
        "High Code Quality: รัน flutter analyze และชุดทดสอบอัตโนมัติ 27 รายการจนผ่าน 100%",
        "End-to-End Alignment: ข้อมูลใน Database สอดคล้องกับหน้าจอ UI จริงในทุกจุด",
        "Live Screen Proof: มีภาพถ่ายหน้าจอเครื่องจำลองจริงยืนยันการทำงานของทุกฟังก์ชัน"
    ], ACCENT_PURPLE)

    set_notes(s5, "วงจรการทำงานของเราคือ Agentic Loop: AI สำรวจ วางแผน แก้ไขไฟล์พร้อมกัน รันคำสั่งจริง และแคปเจอร์หน้าจอยืนยันผลลัพธ์ ทำให้โปรเจกต์ก้าวหน้าอย่างรวดเร็วและมีคุณภาพสูงครับ")

    # ==========================================
    # SLIDE 6: Showcase 1 - Authentication & Security (3 Mockups)
    # ==========================================
    s6 = prs.slides.add_slide(blank_layout)
    add_bg(s6)
    add_header(s6, "Part 3: App Showcase (1/8)", "ระบบสมาชิกและความปลอดภัย (Authentication Suite)", "รองรับ One-Tap Account Switching, การล็อกอินมาตรฐาน และการสมัครสมาชิกใหม่")

    m_sw = os.path.join(img_dir, "mockup_switch.png")
    m_lg = os.path.join(img_dir, "mockup_login.png")
    m_rg = os.path.join(img_dir, "mockup_register.png")

    if os.path.exists(m_sw):
        s6.shapes.add_picture(m_sw, Inches(1.4), Inches(1.8), height=Inches(4.3))
    add_card(s6, Inches(0.8), Inches(6.2), Inches(3.7), Inches(0.95), "🔑 1. Switch Account", ["จดจำบัญชีล่าสุดในเครื่อง สลับบัญชีง่ายดายในคลิกเดียว"], ACCENT_ORANGE)

    if os.path.exists(m_lg):
        s6.shapes.add_picture(m_lg, Inches(5.4), Inches(1.8), height=Inches(4.3))
    add_card(s6, Inches(4.8), Inches(6.2), Inches(3.7), Inches(0.95), "📝 2. Clean Login", ["ช่องกรอกสะอาดตา มีปุ่มซ่อน/แสดงรหัสผ่าน และแจ้งเตือนชัดเจน"], ACCENT_PURPLE)

    if os.path.exists(m_rg):
        s6.shapes.add_picture(m_rg, Inches(9.4), Inches(1.8), height=Inches(4.3))
    add_card(s6, Inches(8.8), Inches(6.2), Inches(3.7), Inches(0.95), "✨ 3. Register Screen", ["ตรวจสอบความถูกต้องของฟอร์ม (Validation) ก่อนบันทึกลง Postgres"], ACCENT_CYAN)

    set_notes(s6, "หน้าจอชุดแรกคือระบบความปลอดภัย: Switch Account จดจำบัญชีในเครื่อง, Clean Login ตรวจสอบรหัสผ่าน, และ Register Screen ที่เชื่อมต่อกับ Strapi Auth อย่างปลอดภัยครับ")

    # ==========================================
    # SLIDE 7: Showcase 2 - Feed & Comments (2 Mockups)
    # ==========================================
    s7 = prs.slides.add_slide(blank_layout)
    add_bg(s7)
    add_header(s7, "Part 3: App Showcase (2/8)", "หน้าฟีดและคอมเมนต์ (Social Feed & Discussion)", "ระบบแสดงโพสต์ภาพแมวส้มแบบมัลติโฟโต้ สตอรี่แมว และการสนทนาใต้โพสต์")

    m_fd = os.path.join(img_dir, "mockup_feed.png")
    m_cm = os.path.join(img_dir, "mockup_comments.png")

    if os.path.exists(m_fd):
        s7.shapes.add_picture(m_fd, Inches(0.8), Inches(1.8), height=Inches(5.2))
    if os.path.exists(m_cm):
        s7.shapes.add_picture(m_cm, Inches(3.6), Inches(1.8), height=Inches(5.2))

    add_card(s7, Inches(6.4), Inches(1.8), Inches(6.1), Inches(5.2), "🐾 ฟีเจอร์เด่นบนหน้า Feed & Comments", [
        "Cat Stories Bar: แถบวงกลมแสดงสตอรี่ของแมวแต่ละตัว พร้อมเครื่องหมายบวกเพิ่มสตอรี่ของตนเอง",
        "Multi-Photo Carousel: โพสต์ของ testcat รองรับการเลื่อนดูรูปได้สูงสุด 5 ภาพ พร้อมตัวเลข (1/5) และ Dots Indicator",
        "Optimistic Like: แตะปุ๊บหัวใจเปลี่ยนเป็นสีแดงและเพิ่มตัวเลขทันทีโดยไม่ต้องรอ API Response",
        "Location & Tagged Cats: แสดงพิกัด 'The Legacy Hotel Nana, Bangkok' และแท็กเพื่อนแมว @testcat2 บนรูปภาพ",
        "Comments Bottom Sheet: แตะดูความคิดเห็นและร่วมคอมเมนต์ใต้โพสต์แบบเรียลไทม์ พร้อมแสดงสถานะ Original Post"
    ], ACCENT_ORANGE)

    set_notes(s7, "หน้า Feed มีฟังก์ชันครบถ้วน: แถบ Cat Stories, Carousel 5 ภาพพร้อมตัวเลขบอกลำดับ, Optimistic Like ที่ตอบสนองทันที และ Bottom Sheet สำหรับคอมเมนต์ใต้โพสต์ครับ")

    # ==========================================
    # SLIDE 8: Showcase 3 - Explore & Discovery (1 Large Mockup)
    # ==========================================
    s8 = prs.slides.add_slide(blank_layout)
    add_bg(s8)
    add_header(s8, "Part 3: App Showcase (3/8)", "หน้าสำรวจและค้นหา (Explore & Discovery Grid)", "ค้นหาน้องแมวตามสายพันธุ์ ค้นหาแฮชแท็ก และตารางภาพแมวยอดนิยมแบบมี Reels")

    m_ex = os.path.join(img_dir, "mockup_explore.png")
    if os.path.exists(m_ex):
        s8.shapes.add_picture(m_ex, Inches(0.8), Inches(1.8), height=Inches(5.2))

    add_card(s8, Inches(3.8), Inches(1.8), Inches(8.7), Inches(5.2), "🔍 ฟังก์ชันเด่นบนหน้า Explore", [
        "Instant Cat Search Bar: ช่องค้นหาอัจฉริยะ ค้นหาได้ทั้งชื่อน้องแมว, สายพันธุ์, และ #แฮชแท็ก",
        "Dynamic Breed Filter Chips: แถบปุ่มคัดกรองหมวดหมู่อย่างรวดเร็ว เช่น #Trending, Reels, Ragdoll, Funny Cats, Kittens",
        "Masonry Media Grid: ตารางแสดงรูปภาพน้องแมวและคลิปวิดีโอที่ดึงสดจากเซิร์ฟเวอร์",
        "Reels & Carousel Badges: ไอคอนแสดงประเภทสื่อบนมุมขวาบน เช่น ไอคอนกล้องวิดีโอสำหรับคลิป Reels และไอคอนซ้อนสำหรับอัลบั้มรูป",
        "Interactive Navigation: แตะรูปภาพใดๆ เพื่อเปิดดูโพสต์ฉบับเต็มและกดติดตามเจ้าของแมวได้ทันที"
    ], ACCENT_PURPLE)

    set_notes(s8, "หน้า Explore ช่วยให้ผู้ใช้ค้นพบคอนเทนต์แมวใหม่ๆ ด้วยช่อง Search อัจฉริยะ, แถบตัวกรองสายพันธุ์ และตารางภาพแบบมีสัญลักษณ์แยกระหว่างภาพนิ่งและคลิปวิดีโอ Reels ครับ")

    # ==========================================
    # SLIDE 9: Showcase 4 - Content Studio & Media Picker (2 Mockups)
    # ==========================================
    s9 = prs.slides.add_slide(blank_layout)
    add_bg(s9)
    add_header(s9, "Part 3: App Showcase (4/8)", "สตูดิโอสร้างโพสต์ (Content Creation & Media Studio)", "ระบบคัดเลือกภาพมัลติมีเดียสไตล์อินสตาแกรม และหน้าแต่งโพสต์พร้อมฟิลเตอร์")

    m_cp = os.path.join(img_dir, "mockup_create_picker.png")
    m_pc = os.path.join(img_dir, "mockup_post_composer.png")

    if os.path.exists(m_cp):
        s9.shapes.add_picture(m_cp, Inches(0.8), Inches(1.8), height=Inches(5.2))
    if os.path.exists(m_pc):
        s9.shapes.add_picture(m_pc, Inches(3.6), Inches(1.8), height=Inches(5.2))

    add_card(s9, Inches(6.4), Inches(1.8), Inches(6.1), Inches(5.2), "📸 ฟีเจอร์สร้างสรรค์โพสต์", [
        "Instagram-style Custom Gallery Picker: หน้าเลือกรูปภาพจากเครื่องพร้อมปุ่มกล้อง และวงแหวนเลือกภาพหลายใบ (Multi-Select)",
        "Media Mode Switcher: สลับโหมดการสร้างได้ง่ายระหว่าง POST, STORY และ REELS",
        "Live Cat Photo Filters: ฟิลเตอร์ปรับแต่งภาพแมว 5 อารมณ์ (Normal, Warm Glow, Golden Hour, Vintage Cat, Soft Purr)",
        "Popular Cat Hashtag Pills: ปุ่มแฮชแท็กสำเร็จรูปแตะแล้วเพิ่มลงข้อความทันที เช่น #CatLife, #Purrfect, #Meow, #Caturday",
        "AI Assistant & Tagging: ปุ่มเรียก AI และปุ่มแท็กเพื่อนแมวกับสถานที่"
    ], ACCENT_CYAN)

    set_notes(s9, "หน้าสร้างโพสต์ประกอบด้วย Gallery Picker สำหรับเลือกรูปหลายใบพร้อมกัน และหน้า Post Composer ที่มีฟิลเตอร์สีแมว, แฮชแท็กสำเร็จรูป และปุ่ม Generate with AI ครับ")

    # ==========================================
    # SLIDE 10: Showcase 5 - Gemini Vision AI Caption Studio (1 Large Mockup)
    # ==========================================
    s10 = prs.slides.add_slide(blank_layout)
    add_bg(s10)
    add_header(s10, "Part 3: App Showcase (5/8)", "ผู้ช่วยแคปชันอัจฉริยะ (Gemini Vision AI Assistant)", "วิเคราะห์ลักษณะภาพแมวและสร้างคำบรรยายภาษาไทย 4 สไตล์อัตโนมัติ")

    m_ai = os.path.join(img_dir, "mockup_ai_caption.png")
    if os.path.exists(m_ai):
        s10.shapes.add_picture(m_ai, Inches(0.8), Inches(1.8), height=Inches(5.2))

    add_card(s10, Inches(3.8), Inches(1.8), Inches(8.7), Inches(5.2), "🤖 เจาะลึกความฉลาดของ Gemini 2.5 Flash", [
        "Multimodal Image Understanding: โมเดลวิเคราะห์สีขน, อารมณ์ทางสายตา, และพฤติกรรมของแมวในรูปภาพอย่างละเอียด",
        "4 Personality Tones: เลือกอารมณ์ได้ 4 แบบ ได้แก่ 'น่ารัก' 💖, 'ตลก' 😹, 'กวนๆ' 😼 และ 'สั้นกระชับ' ⚡",
        "Authentic Thai Feline Slang: ใช้ภาษาพูดที่คนรักแมวชื่นชอบ พร้อมอีโมจิแมว เช่น 'งอยย ตาแป๋วขนาดนี้...', 'เจ้าส้มจอมกวน 🧡'",
        "One-Tap Caption Insertion: ผู้ใช้แตะแคปชันที่ชอบเพียงครั้งเดียว ข้อความจะถูกกรอกลงช่องแคปชันพร้อมโพสต์ทันที",
        "Interactive Regenerate: กดปุ่ม 'สุ่มใหม่' เพื่อสร้างชุดแคปชันชุดใหม่จาก AI ได้ไม่จำกัดครั้ง"
    ], ACCENT_GREEN)

    set_notes(s10, "ฟีเจอร์ AI Caption ใช้ Gemini 2.5 Flash วิเคราะห์ภาพแมวตาแป๋ว แล้วสร้างแคปชันภาษาไทย 4 สไตล์ให้เลือก เช่น น่ารัก หรือ กวนๆ ผู้ใช้แตะปุ๊บข้อความจะลงไปในโพสต์ทันทีครับ")

    # ==========================================
    # SLIDE 11: Showcase 6 - Geolocation & Location Tagging (1 Large Mockup)
    # ==========================================
    s11 = prs.slides.add_slide(blank_layout)
    add_bg(s11)
    add_header(s11, "Part 3: App Showcase (6/8)", "ระบบปักหมุดสถานที่ (Geolocation & Place Tagging)", "ระบุพิกัดอัตโนมัติด้วย GPS ร่วมกับ OpenStreetMap Reverse Geocoding")

    m_loc = os.path.join(img_dir, "mockup_location.png")
    if os.path.exists(m_loc):
        s11.shapes.add_picture(m_loc, Inches(0.8), Inches(1.8), height=Inches(5.2))

    add_card(s11, Inches(3.8), Inches(1.8), Inches(8.7), Inches(5.2), "📍 ฟังก์ชันปักหมุดสถานที่", [
        "Real-Time GPS Location: ตรวจจับพิกัดปัจจุบันผ่านแพ็กเกจ Geolocator เมื่อผู้ใช้อนุญาต Location Permission",
        "Reverse Geocoding Engine: แปลงพิกัดละติจูด/ลองจิจูดเป็นชื่อถนนและเขตจริงผ่าน OpenStreetMap (Nominatim API)",
        "Auto-Detected Selection: แสดงชื่อสถานที่ที่ตรวจพบพร้อมติ๊กถูกสีส้ม (เช่น 'Dinso Road, Bowon Niwet, Phra Nakhon')",
        "Custom Place Name Editing: รองรับการพิมพ์ชื่อสถานที่เฉพาะเอง เช่น 'คาเฟ่แมวเหมียวสุขุมวิท' หรือชื่อโรงแรม",
        "Interactive Place Search: มีช่องค้นหาสถานที่ ร้านค้า คาเฟ่ และแลนด์มาร์กสำคัญเพื่อเลือกปักหมุดได้อย่างแม่นยำ"
    ], ACCENT_ORANGE)

    set_notes(s11, "หน้า Add Location ใช้ GPS ดึงพิกัดจริงและแปลงเป็นชื่อถนนด้วย OpenStreetMap ผู้ใช้สามารถเลือกสถานที่ที่ตรวจจับได้ หรือพิมพ์ชื่อสถานที่ที่กำหนดเองได้อย่างอิสระครับ")

    # ==========================================
    # SLIDE 12: Showcase 7 - Notifications & Activity Stream (1 Large Mockup)
    # ==========================================
    s12 = prs.slides.add_slide(blank_layout)
    add_bg(s12)
    add_header(s12, "Part 3: App Showcase (7/8)", "ระบบแจ้งเตือนและกิจกรรม (Notifications & Activity)", "ติดตามทุกการเคลื่อนไหว ทั้งการกดถูกใจ การติดตามใหม่ และคอมเมนต์ใต้โพสต์")

    m_notif = os.path.join(img_dir, "mockup_notifications.png")
    if os.path.exists(m_notif):
        s12.shapes.add_picture(m_notif, Inches(0.8), Inches(1.8), height=Inches(5.2))

    add_card(s12, Inches(3.8), Inches(1.8), Inches(8.7), Inches(5.2), "🔔 ฟังก์ชันแจ้งเตือนแบบครบวงจร", [
        "Comprehensive Activity Feed: รวมประวัติกิจกรรมทั้งหมด เช่น 'testcat2 liked your post' และ 'started following you'",
        "Categorized Filter Pills: ปุ่มตัวกรองด้านบนเพื่อแยกดูเฉพาะกิจกรรมที่สนใจ: All, Likes, Comments, และ Follows",
        "Interactive Follow Button: มีปุ่ม 'Following' หรือ 'Follow Back' ให้กดติดตามเพื่อนแมวกลับได้ทันทีจากหน้านี้",
        "Post Preview Thumbnail: แสดงภาพขนาดย่อของโพสต์ที่ถูกกดถูกใจที่มุมขวา ช่วยให้ทราบว่าถูกใจโพสต์ไหน",
        "Real-Time Badge Counters: ตัวเลขนับการแจ้งเตือนที่ยังไม่ได้อ่านบนแถบเมนูด้านล่าง ซิงค์ตรงกับฐานข้อมูล Strapi 5"
    ], ACCENT_PURPLE)

    set_notes(s12, "หน้า Notifications รวมกิจกรรมของผู้ใช้ มี Filter Pills แยกดูเฉพาะ Likes หรือ Comments พร้อมปุ่ม Follow กลับได้ในคลิกเดียว และมีรูป Thumbnail ของโพสต์ที่ถูก Like กำกับไว้ชัดเจนครับ")

    # ==========================================
    # SLIDE 13: Showcase 8 - Profile & Settings Suite (2 Mockups)
    # ==========================================
    s13 = prs.slides.add_slide(blank_layout)
    add_bg(s13)
    add_header(s13, "Part 3: App Showcase (8/8)", "โปรไฟล์และการตั้งค่าบัญชี (Profile & Settings Suite)", "หน้าแสดงประวัติน้องแมว สถิติจริง และหน้าแก้ไขข้อมูลโปรไฟล์พร้อมการสลับโหมดสาธารณะ")

    m_pr = os.path.join(img_dir, "mockup_profile.png")
    m_ed = os.path.join(img_dir, "mockup_edit_profile.png")

    if os.path.exists(m_pr):
        s13.shapes.add_picture(m_pr, Inches(0.8), Inches(1.8), height=Inches(5.2))
    if os.path.exists(m_ed):
        s13.shapes.add_picture(m_ed, Inches(3.6), Inches(1.8), height=Inches(5.2))

    add_card(s13, Inches(6.4), Inches(1.8), Inches(6.1), Inches(5.2), "👤 ฟีเจอร์จัดการโปรไฟล์แมว", [
        "Live DB Stats: ดึงตัวเลขจริงจาก PostgreSQL: Posts (3), Followers (1), Following (1)",
        "Paw Breed Badge: แสดงป้ายกำกับสายพันธุ์แมว 'Orange Cat' พร้อมไอคอนอุ้งเท้าสุดน่ารัก",
        "Story Highlights: แถบวงกลมไฮไลต์เรื่องราวที่น่าประทับใจ (New, Playtime, Treats, Naps, OOTD)",
        "Edit Profile Screen: แก้ไขรูปอวตาร, ชื่อ, ชื่อผู้ใช้ (@testcat), หมวดหมู่สายพันธุ์, เว็บไซต์ และ Bio (35/150)",
        "Privacy & Account Controls: สวิตช์เปิด/ปิด Public Profile และปุ่ม Log Out ปลอดภัย"
    ], ACCENT_CYAN)

    set_notes(s13, "หน้า Profile ดึงสถิติจริงจาก PostgreSQL มี Highlights และป้ายสายพันธุ์ ส่วนหน้า Edit Profile สามารถอัปเดตข้อมูล Bio, หมวดหมู่สายพันธุ์ และมีสวิตช์เปิดปิด Public Profile ครับ")

    # ==========================================
    # SLIDE 14: Comprehensive Problem Solving 1 (Backend & DB)
    # ==========================================
    s14 = prs.slides.add_slide(blank_layout)
    add_bg(s14)
    add_header(s14, "Part 4: Problem Solving (1/2)", "ปัญหาเชิงเทคนิคและการแก้ไข: Backend & Database", "อุปสรรคจริงที่พบในฝั่งเซิร์ฟเวอร์ และการออกแบบโซลูชันแก้ไขที่ยั่งยืน")

    add_card(s14, Inches(0.8), Inches(1.9), Inches(5.6), Inches(2.4), "⚠️ ปัญหาที่ 1: Strapi 5 RBAC Permissions บล็อก", [
        "อาการ: Endpoint ที่สร้างขึ้นใหม่ทั้งหมดติดสถานะ 403 Forbidden ทันที",
        "สาเหตุ: Strapi 5 มี Security Model ที่บล็อกทุก Route เป็นค่าเริ่มต้น",
        "วิธีแก้ไข: เขียนระบบ Bootstrap Lifecycle ใน backend/src/index.ts ให้ตรวจจับ Role 'public' และ 'authenticated' แล้วสร้าง Record สิทธิ์ลงตาราง permission อัตโนมัติทุกครั้งที่บูตเซิร์ฟเวอร์"
    ], ACCENT_RED)

    add_card(s14, Inches(6.8), Inches(1.9), Inches(5.6), Inches(2.4), "⚠️ ปัญหาที่ 2: SQLite vs PostgreSQL Sync & Port 5433", [
        "อาการ: ฐานข้อมูลไม่เชื่อมต่อ หรือข้อมูลบัญชีทดสอบหายหลังรีสตาร์ท",
        "สาเหตุ: ค่าคอนฟิกเริ่มต้นสลับระหว่าง SQLite กับ Postgres (รันบนพอร์ต 5433 ไม่ใช่ 5432)",
        "วิธีแก้ไข: ตั้งค่า database.ts ให้ชี้ไปยัง PostgreSQL พอร์ต 5433 พร้อมซิงค์ bcrypt password hash ของบัญชี testcat และ testcat2 ให้ตรงกับ password123"
    ], ACCENT_RED)

    add_card(s14, Inches(0.8), Inches(4.5), Inches(5.6), Inches(2.4), "⚠️ ปัญหาที่ 3: Strapi 5 Document Service & Population", [
        "อาการ: Response ของ Feed และ Profile ขาดรูปภาพผู้ใช้ หรือขาดข้อมูล Relations",
        "สาเหตุ: Strapi 5 เปลี่ยนเอนจินภายในจาก Entity Service มาเป็น Document Service ซึ่งไม่ Populate ข้อมูล Relation ให้อัตโนมัติ",
        "วิธีแก้ไข: เขียนตัวแปลง Param ให้เรียก populate: ['media', 'user', 'likes', 'comments'] อย่างเจาะจงใน Controller"
    ], ACCENT_GREEN)

    add_card(s14, Inches(6.8), Inches(4.5), Inches(5.6), Inches(2.4), "⚠️ ปัญหาที่ 4: เครือข่าย Emulator ข้ามระบบปฏิบัติการ", [
        "อาการ: ยิง API ไปที่ 127.0.0.1 แล้วเกิดข้อผิดพลาด Connection Refused บน Android",
        "สาเหตุ: Android Emulator มอง 127.0.0.1 เป็นตัวเอง ต้องใช้ 10.0.2.2 เพื่อคุยกับคอมพิวเตอร์แม่ข่าย",
        "วิธีแก้ไข: เขียน ApiConfig.serverUrl ให้สลับ Host อัตโนมัติในระดับไคลเอนต์ตาม TargetPlatform"
    ], ACCENT_GREEN)

    set_notes(s14, "ในฝั่ง Backend เราแก้ปัญหา Strapi 5 RBAC ด้วย Bootstrap Script, แก้ปัญหาพอร์ต Postgres 5433, จัดการการ Populate ข้อมูลใน Document Service และรองรับ IP 10.0.2.2 บน Android ครับ")

    # ==========================================
    # SLIDE 15: Comprehensive Problem Solving 2 (Mobile & AI)
    # ==========================================
    s15 = prs.slides.add_slide(blank_layout)
    add_bg(s15)
    add_header(s15, "Part 4: Problem Solving (2/2)", "ปัญหาเชิงเทคนิคและการแก้ไข: Mobile, AI & UX", "การแก้ปัญหาด้านความเข้ากันได้ของระบบ ความปลอดภัย และการตอบสนองของแอป")

    add_card(s15, Inches(0.8), Inches(1.9), Inches(5.6), Inches(2.4), "⚠️ ปัญหาที่ 5: iOS Keychain Error (-34018)", [
        "อาการ: FlutterSecureStorage ล้มเหลวและทำให้แอป Crash ทันทีที่เซฟ Token บน iOS Simulator",
        "สาเหตุ: Simulator ขาด Entitlements ในการเข้าถึง Keychain ของระบบ macOS",
        "วิธีแก้ไข: ออกแบบ Multi-Tier Storage ที่ครอบ try-catch โดยหากเขียน Keychain ล้มเหลว จะสลับไปเก็บใน SharedPreferences / In-Memory Cache อัตโนมัติ ทำให้สลับบัญชีได้อย่างราบรื่น"
    ], ACCENT_RED)

    add_card(s15, Inches(6.8), Inches(1.9), Inches(5.6), Inches(2.4), "⚠️ ปัญหาที่ 6: ขนาดรูปถ่ายจากกล้องและการอัปโหลดช้า", [
        "อาการ: ภาพถ่ายขนาด 5-10 MB ส่งผลให้เกิด Request Timeout และเปลืองหน่วยความจำ",
        "สาเหตุ: การส่งภาพ Raw โดยไม่ผ่านการบีบอัดทำให้ Network I/O ติดขัด",
        "วิธีแก้ไข: ติดตั้ง Image Processing Pipeline ฝั่ง Client บีบอัดเป็น JPEG คุณภาพ 85% ขนาดสูงสุดไม่เกิน 2048px ลดขนาดไฟล์ลงได้กว่า 75% โดยคุณภาพยังคงคมชัด"
    ], ACCENT_RED)

    add_card(s15, Inches(0.8), Inches(4.5), Inches(5.6), Inches(2.4), "⚠️ ปัญหาที่ 7: Gemini Vision AI ส่ง Markdown Code Fences", [
        "อาการ: JSON Decode ใน Dart ขัดข้องเมื่อ Gemini แนบ ```json หรือข้อความอธิบายนอกกรอบมา",
        "สาเหตุ: LLM มักส่ง Markdown Formatting มาปะปนกับ Raw JSON",
        "วิธีแก้ไข: เขียน Regex Strip ทำความสะอาด Code Block ก่อนแปลงเข้า JSON Parser และเพิ่มชุด Fallback Captions 5 อารมณ์เพื่อรับประกันว่าแอปจะไม่มีวันค้างหรือ Crash"
    ], ACCENT_GREEN)

    add_card(s15, Inches(6.8), Inches(4.5), Inches(5.6), Inches(2.4), "⚠️ ปัญหาที่ 8: UI Layout Spacing & Location Overflow", [
        "อาการ: หน้าจอ Add Location และ Edit Profile เกิด Yellow-Black Overflow Banner",
        "สาเหตุ: ระยะ Padding คงที่ทับซ้อนกับ Dynamic Island และปุ่ม Bottom Navigation",
        "วิธีแก้ไข: ปรับใช้ Responsive Layout ด้วย SingleChildScrollView, SafeArea และจัดระยะ Gap การ์ดใหม่ทั้งหมดให้รองรับทุกขนาดหน้าจออย่างสมบูรณ์แบบ"
    ], ACCENT_GREEN)

    set_notes(s15, "ในฝั่ง Mobile และ AI เราแก้ปัญหา iOS Keychain Error -34018 ด้วย In-Memory Fallback, ติดตั้ง Image Compression ลดขนาดรูป 75%, ทำความสะอาด JSON จาก Gemini และจัด Spacing ใหม่ทั้งหมดครับ")

    # ==========================================
    # SLIDE 16: Quality Assurance & Test Verification
    # ==========================================
    s16 = prs.slides.add_slide(blank_layout)
    add_bg(s16)
    add_header(s16, "Part 5: Quality Assurance", "การทดสอบระบบและการรับประกันคุณภาพ (QA Matrix)", "ยืนยันความพร้อมในการใช้งานระดับ Production ด้วยชุดการทดสอบอัตโนมัติรอบด้าน")

    add_card(s16, Inches(0.8), Inches(1.9), Inches(3.6), Inches(5.0), "✅ Automated Tests (27/27)", [
        "ชุดทดสอบอัตโนมัติรวม 27 รายการ",
        "ผลการทดสอบ: ผ่าน 100% (Passed)",
        "ครอบคลุม CatUser, Post, Comment, Like Models",
        "จำลอง Network Response ทุกสถานะ (200, 401, 500)",
        "ทดสอบ Auth State Persistence & Token Refresh"
    ], ACCENT_GREEN)

    add_card(s16, Inches(4.8), Inches(1.9), Inches(3.6), Inches(5.0), "🔍 Static Code Analysis", [
        "รันคำสั่ง flutter analyze ตรวจสอบทั้งโปรเจกต์",
        "ผลลัพธ์: No issues found! (0 Warnings, 0 Errors)",
        "จัดระเบียบ Import และลบ Unused Dependencies",
        "ผ่านเกณฑ์ Flutter Lints และ Best Practices",
        "โค้ดสะอาด เป็นไปตามหลัก Clean Architecture"
    ], ACCENT_CYAN)

    add_card(s16, Inches(8.8), Inches(1.9), Inches(3.6), Inches(5.0), "🧪 End-to-End Live Verification", [
        "ทดสอบสดบน iPhone 16 Pro Max Simulator",
        "ครบทั้ง 13 หน้าจอจริงแบบ Real-time",
        "บัญชีทดสอบที่พร้อมใช้งานทันที:",
        "• testcat / password123 (บัญชีหลัก)",
        "• testcat2 / password123 (บัญชีรอง)",
        "ทดสอบสร้างโพสต์, ไลก์, คอมเมนต์ และสลับบัญชีได้จริง"
    ], ACCENT_PURPLE)

    set_notes(s16, "ด้าน QA เรามี Automated Tests 27 ชุด ผ่าน 100%, รัน flutter analyze ผ่าน 0 warning และทดสอบใช้งานจริงบน Simulator ผ่านทั้ง 13 หน้าจออย่างไร้ข้อผิดพลาดครับ")

    # ==========================================
    # SLIDE 17: Key Takeaways & AI Engineering Insights
    # ==========================================
    s17 = prs.slides.add_slide(blank_layout)
    add_bg(s17)
    add_header(s17, "Part 6: Conclusion", "บทเรียนสำคัญจากการพัฒนาร่วมกับ AI", "การปฏิวัติผลิตภาพของนักพัฒนาซอฟต์แวร์ด้วยแนวคิด AI-First Engineering")

    add_card(s17, Inches(0.8), Inches(1.9), Inches(5.6), Inches(5.0), "💡 3 กฎเหล็กของการเป็น AI Software Engineer", [
        "1. Specification is King: สเปกที่ชัดเจนคือตัวกำหนดคุณภาพงาน AI ทำงานตามสเปกได้อย่างไร้ที่ติเมื่อเรามี Data Contract และ Acceptance Criteria ที่รัดกุม",
        "2. Engineer as the Chief Architect: วิศวกรมนุษย์ต้องทำหน้าที่เป็นสถาปนิกผู้คุมทิศทาง กำหนด Boundaries, Security Model และกติกา ไม่ปล่อยให้ AI สร้างโค้ดสะเปะสะปะ",
        "3. Resilient Fault-Tolerant Design: ความสำเร็จของซอฟต์แวร์อยู่ที่การรับมือกับ Edge Cases เช่น Fallback Storage เมื่อ Keychain พัง, Fallback Captions เมื่อ AI ขัดข้อง"
    ], ACCENT_ORANGE)

    add_card(s17, Inches(6.8), Inches(1.9), Inches(5.6), Inches(5.0), "🚀 การประเมินผลิตภาพ (Productivity Multiplier)", [
        "Velocity: พัฒนาแอป Full-Stack ขนาด 13 หน้าจอพร้อม Backend และ AI เสร็จสิ้นในเวลาที่สั้นลงกว่า 80%",
        "Reduced Boilerplate Fatigue: ลดภาระการเขียน DTO, Model Parsing, และ CRUD Controllers",
        "Seamless Full-Stack Alignment: การสั่งให้ AI แก้ไขทั้ง Dart และ TypeScript ควบคู่กันช่วยลดปัญหา API Mismatch",
        "Enhanced Verification: การสั่งให้ AI แคปเจอร์หน้าจอและอ่าน Log ใน Terminal ช่วยให้ตรวจสอบงานได้แม่นยำยิ่งขึ้น"
    ], ACCENT_PURPLE)

    set_notes(s17, "บทเรียนสำคัญคือ AI ช่วยเร่งสปีดการทำงานได้มหาศาล โดยมีวิศวกรเป็นผู้กำหนดสเปกและสถาปัตยกรรม การผสานมนุษย์กับ AI เช่นนี้ทำให้ได้ซอฟต์แวร์ที่มีคุณภาพสูงและรวดเร็วครับ")

    # ==========================================
    # SLIDE 18: Roadmap & Conclusion
    # ==========================================
    s18 = prs.slides.add_slide(blank_layout)
    add_bg(s18)
    add_header(s18, "Part 6: Conclusion", "ทิศทางการพัฒนาต่อยอด และสรุปผลงาน", "InstaCat พร้อมแล้วสำหรับการขยายผลสู่แพลตฟอร์มคอมมูนิตี้ระดับโลก")

    add_card(s18, Inches(0.8), Inches(1.9), Inches(5.6), Inches(5.0), "🔮 แผนพัฒนาต่อยอด (Future Roadmap)", [
        "1. Push Notifications (FCM): ระบบแจ้งเตือนแจ้งเตือนเข้ามือถือเมื่อมีคนมากดถูกใจหรือคอมเมนต์น้องแมว",
        "2. AI Cat Breed Classifier: สแกนภาพแมวแล้วระบุสายพันธุ์และแนะนำวิธีดูแลเฉพาะสายพันธุ์",
        "3. Video Streaming Stories: รองรับการอัปโหลดคลิปวิดีโอสั้นของน้องแมวความยาว 15-30 วินาที",
        "4. Direct Messaging (Cat Chat): ระบบส่งข้อความส่วนตัวระหว่างเจ้าของสัตว์เลี้ยง พร้อมแชร์รูปภาพ",
        "5. Adoption & Lost Pets Board: กระดานหาบ้านใหม่ให้น้องแมวและตามหาแมวหาย"
    ], ACCENT_CYAN)

    add_card(s18, Inches(6.8), Inches(1.9), Inches(5.6), Inches(5.0), "🎉 สรุปผลการส่งมอบ (Delivery Summary)", [
        "✅ 13 หน้าจอของแอปพลิเคชันทำงานได้จริง 100%",
        "✅ เชื่อมต่อ Flutter ↔ Strapi 5 ↔ PostgreSQL ↔ Gemini AI ครบวงจร",
        "✅ 27 Automated Tests ผ่าน 100% พร้อม Static Analysis ผ่านฉลุย",
        "✅ เอกสารสเปก ระบบ API Reference และ Setup Guide ครบถ้วน",
        "✅ พร้อมสำหรับการเดโมสด และใช้งานบนระบบจริง",
        "",
        "🙏 ขอขอบคุณทุกท่านครับ พร้อมตอบทุกคำถาม (Q&A)"
    ], ACCENT_GREEN)

    set_notes(s18, "InstaCat พร้อมสำหรับการต่อยอดสู่ระบบ Push Notifications และ Breed Classifier ในอนาคต และวันนี้ระบบทั้ง 13 หน้าจอเสร็จสมบูรณ์พร้อมใช้งานจริงแล้วครับ ขอขอบคุณทุกท่านครับ")

    # Save presentation
    output_path = os.path.join(base_dir, "InstaCat_Presentation.pptx")
    prs.save(output_path)
    print(f"Presentation successfully created with {FONT_FAMILY} at: {output_path}")

if __name__ == "__main__":
    create_deck()
