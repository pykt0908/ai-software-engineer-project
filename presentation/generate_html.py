#!/usr/bin/env python3
"""
Generate the complete interactive presentation/index.html web deck
with 18 slides, 13 mobile phone mockups, prompt engineering style,
comprehensive problem-solving analysis, and full speaker notes.
"""

import os

HTML_CONTENT = """<!DOCTYPE html>
<html lang="th">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>InstaCat: The Purr-fect Pet Community | Full Project Presentation</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Noto+Sans+Thai:wght@300;400;500;600;700&family=Fira+Code:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    @font-face {
      font-family: 'LINESeedSansTH';
      src: url('fonts/LINESeedSansTH_W_Th.woff2') format('woff2'),
           url('fonts/LINESeedSansTH_W_Th.ttf') format('truetype');
      font-weight: 300;
      font-style: normal;
    }
    @font-face {
      font-family: 'LINESeedSansTH';
      src: url('fonts/LINESeedSansTH_W_Rg.woff2') format('woff2'),
           url('fonts/LINESeedSansTH_W_Rg.ttf') format('truetype');
      font-weight: 400;
      font-style: normal;
    }
    @font-face {
      font-family: 'LINESeedSansTH';
      src: url('fonts/LINESeedSansTH_W_Bd.woff2') format('woff2'),
           url('fonts/LINESeedSansTH_W_Bd.ttf') format('truetype');
      font-weight: 700;
      font-style: normal;
    }
    @font-face {
      font-family: 'LINESeedSansTH';
      src: url('fonts/LINESeedSansTH_W_XBd.woff2') format('woff2'),
           url('fonts/LINESeedSansTH_W_XBd.ttf') format('truetype');
      font-weight: 800;
      font-style: normal;
    }
    @font-face {
      font-family: 'LINESeedSansTH';
      src: url('fonts/LINESeedSansTH_W_He.woff2') format('woff2'),
           url('fonts/LINESeedSansTH_W_He.ttf') format('truetype');
      font-weight: 900;
      font-style: normal;
    }

    :root {
      --bg-base: #0a0c10;
      --bg-surface: #12161f;
      --bg-card: rgba(26, 32, 44, 0.75);
      --bg-glass: rgba(255, 255, 255, 0.05);
      --border-glass: rgba(255, 255, 255, 0.1);
      --border-accent: rgba(255, 138, 61, 0.3);
      --primary: #ff8a3d;
      --primary-gradient: linear-gradient(135deg, #ff8a3d 0%, #ff5252 100%);
      --secondary: #8b5cf6;
      --secondary-gradient: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);
      --accent-cyan: #0ea5e9;
      --accent-green: #10b981;
      --accent-red: #ef4444;
      --text-main: #f8fafc;
      --text-muted: #94a3b8;
      --text-dim: #64748b;
      --font-sans: 'LINESeedSansTH', 'LINE Seed Sans TH', 'Plus Jakarta Sans', 'Noto Sans Thai', sans-serif;
      --font-mono: 'Fira Code', monospace;
      --shadow-elevation: 0 20px 40px -15px rgba(0, 0, 0, 0.6);
      --radius-sm: 8px;
      --radius-md: 14px;
      --radius-lg: 20px;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      background-color: var(--bg-base);
      color: var(--text-main);
      font-family: var(--font-sans);
      min-height: 100vh;
      overflow-x: hidden;
      display: flex;
      flex-direction: column;
      position: relative;
    }

    .ambient-glow {
      position: fixed;
      width: 500px;
      height: 500px;
      border-radius: 50%;
      pointer-events: none;
      filter: blur(120px);
      z-index: 0;
      opacity: 0.15;
    }
    .glow-1 { top: -100px; left: -100px; background: #ff8a3d; }
    .glow-2 { bottom: -100px; right: -100px; background: #8b5cf6; }

    header.deck-header {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      height: 60px;
      background: rgba(10, 12, 16, 0.8);
      backdrop-filter: blur(16px);
      border-bottom: 1px solid var(--border-glass);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 28px;
      z-index: 100;
    }

    .brand-container {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .brand-badge {
      background: var(--primary-gradient);
      color: #fff;
      font-weight: 800;
      font-size: 13px;
      padding: 4px 10px;
      border-radius: 6px;
      letter-spacing: 0.5px;
      text-transform: uppercase;
    }

    .brand-title {
      font-size: 15px;
      font-weight: 600;
      color: var(--text-main);
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .brand-title span {
      color: var(--text-muted);
      font-weight: 400;
    }

    .header-actions {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .action-btn {
      background: var(--bg-glass);
      border: 1px solid var(--border-glass);
      color: var(--text-muted);
      padding: 6px 14px;
      border-radius: 8px;
      font-size: 13px;
      font-weight: 500;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 6px;
      transition: all 0.2s ease;
      font-family: inherit;
    }
    .action-btn:hover {
      background: rgba(255, 255, 255, 0.1);
      color: var(--text-main);
      border-color: rgba(255, 255, 255, 0.2);
    }
    .action-btn.active {
      background: var(--primary);
      color: #fff;
      border-color: var(--primary);
    }

    .progress-track {
      position: fixed;
      top: 60px;
      left: 0;
      right: 0;
      height: 3px;
      background: rgba(255, 255, 255, 0.05);
      z-index: 100;
    }
    .progress-bar {
      height: 100%;
      background: var(--primary-gradient);
      width: 0%;
      transition: width 0.3s ease;
    }

    main.deck-viewport {
      position: relative;
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 80px 40px 70px;
      z-index: 1;
      width: 100%;
      max-width: 1440px;
      margin: 0 auto;
    }

    section.slide {
      display: none;
      width: 100%;
      min-height: calc(100vh - 150px);
      background: var(--bg-card);
      border: 1px solid var(--border-glass);
      border-radius: var(--radius-lg);
      padding: 40px 48px;
      backdrop-filter: blur(20px);
      box-shadow: var(--shadow-elevation);
      flex-direction: column;
      animation: fadeInSlide 0.35s cubic-bezier(0.16, 1, 0.3, 1);
    }
    section.slide.active {
      display: flex;
    }

    @keyframes fadeInSlide {
      from { opacity: 0; transform: translateY(12px) scale(0.99); }
      to { opacity: 1; transform: translateY(0) scale(1); }
    }

    .slide-meta {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 12px;
    }
    .slide-tag {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: var(--primary);
      background: rgba(255, 138, 61, 0.12);
      border: 1px solid rgba(255, 138, 61, 0.3);
      padding: 3px 10px;
      border-radius: 4px;
    }
    .slide-category {
      font-size: 12px;
      color: var(--text-dim);
    }

    .slide-title-area {
      margin-bottom: 28px;
    }
    .slide-title {
      font-size: 28px;
      font-weight: 800;
      color: var(--text-main);
      line-height: 1.25;
      letter-spacing: -0.5px;
    }
    .slide-subtitle {
      font-size: 15px;
      color: var(--text-muted);
      margin-top: 6px;
      font-weight: 400;
      line-height: 1.4;
    }

    .slide-body {
      flex: 1;
      display: flex;
      flex-direction: column;
    }

    .grid-2 {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 24px;
    }
    .grid-3 {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 24px;
    }
    .grid-4 {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
    }

    .card {
      background: rgba(18, 22, 31, 0.7);
      border: 1px solid var(--border-glass);
      border-radius: var(--radius-md);
      padding: 24px;
      display: flex;
      flex-direction: column;
      transition: transform 0.2s ease, border-color 0.2s ease;
    }
    .card:hover {
      border-color: rgba(255, 255, 255, 0.2);
    }
    .card-accent {
      border-color: var(--border-accent);
      background: rgba(255, 138, 61, 0.04);
    }
    .card-purple {
      border-color: rgba(139, 92, 246, 0.3);
      background: rgba(139, 92, 246, 0.04);
    }
    .card-cyan {
      border-color: rgba(14, 165, 233, 0.3);
      background: rgba(14, 165, 233, 0.04);
    }
    .card-green {
      border-color: rgba(16, 185, 129, 0.3);
      background: rgba(16, 185, 129, 0.04);
    }
    .card-red {
      border-color: rgba(239, 68, 68, 0.3);
      background: rgba(239, 68, 68, 0.04);
    }

    .card h3 {
      font-size: 17px;
      font-weight: 700;
      margin-bottom: 12px;
      color: var(--text-main);
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .card p, .card li {
      font-size: 13.5px;
      color: var(--text-muted);
      line-height: 1.6;
    }
    .card ul {
      list-style-type: none;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .card li::before {
      content: "•";
      color: var(--primary);
      font-weight: bold;
      display: inline-block;
      width: 1em;
      margin-left: -1em;
    }

    .mockup-wrapper {
      display: flex;
      justify-content: center;
      align-items: center;
      text-align: center;
    }

    .mockup-img {
      height: 480px;
      width: auto;
      max-width: 100%;
      object-fit: contain;
      filter: drop-shadow(0 20px 35px rgba(0,0,0,0.6));
      border-radius: 36px;
      transition: transform 0.25s ease;
    }
    .mockup-img:hover {
      transform: scale(1.02);
    }

    .mockup-img-sm {
      height: 380px;
      width: auto;
      max-width: 100%;
      object-fit: contain;
      filter: drop-shadow(0 15px 25px rgba(0,0,0,0.5));
      border-radius: 30px;
      transition: transform 0.25s ease;
    }
    .mockup-img-sm:hover {
      transform: scale(1.03);
    }

    .hero-container {
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      padding: 40px 20px;
    }
    .hero-badge {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 6px 16px;
      background: rgba(255, 138, 61, 0.1);
      border: 1px solid rgba(255, 138, 61, 0.3);
      border-radius: 100px;
      font-size: 13px;
      font-weight: 600;
      color: var(--primary);
      margin-bottom: 24px;
    }
    .hero-title {
      font-size: 46px;
      font-weight: 900;
      line-height: 1.15;
      letter-spacing: -1px;
      margin-bottom: 16px;
      background: linear-gradient(180deg, #ffffff 0%, #cbd5e1 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    .hero-subtitle {
      font-size: 18px;
      color: var(--text-muted);
      max-width: 800px;
      line-height: 1.6;
      margin-bottom: 36px;
    }

    footer.deck-footer {
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      height: 54px;
      background: rgba(10, 12, 16, 0.85);
      backdrop-filter: blur(16px);
      border-top: 1px solid var(--border-glass);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 28px;
      z-index: 100;
    }
    .footer-hints {
      font-size: 12px;
      color: var(--text-dim);
      display: flex;
      gap: 16px;
    }
    .kbd {
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid rgba(255, 255, 255, 0.15);
      padding: 2px 6px;
      border-radius: 4px;
      color: var(--text-muted);
      font-family: var(--font-mono);
      font-size: 11px;
    }
    .nav-controls {
      display: flex;
      align-items: center;
      gap: 16px;
    }
    .slide-counter {
      font-size: 13px;
      font-weight: 600;
      color: var(--text-muted);
      min-width: 60px;
      text-align: center;
    }
    .btn-nav {
      background: var(--bg-glass);
      border: 1px solid var(--border-glass);
      color: var(--text-main);
      width: 32px;
      height: 32px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      font-size: 16px;
      transition: all 0.2s;
    }
    .btn-nav:hover:not(:disabled) {
      background: rgba(255, 255, 255, 0.15);
    }
    .btn-nav:disabled {
      opacity: 0.3;
      cursor: not-allowed;
    }

    .speaker-notes-panel {
      position: fixed;
      bottom: 54px;
      right: 28px;
      width: 440px;
      max-height: 280px;
      background: rgba(18, 22, 31, 0.95);
      border: 1px solid var(--border-accent);
      border-radius: var(--radius-md) var(--radius-md) 0 0;
      padding: 20px;
      backdrop-filter: blur(20px);
      box-shadow: 0 -10px 30px rgba(0,0,0,0.5);
      z-index: 99;
      transform: translateY(120%);
      transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      overflow-y: auto;
    }
    .speaker-notes-panel.visible {
      transform: translateY(0);
    }
    .notes-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
      padding-bottom: 8px;
      border-bottom: 1px solid var(--border-glass);
    }
    .notes-header h4 {
      font-size: 13px;
      font-weight: 700;
      color: var(--primary);
    }
    .notes-content {
      font-size: 13px;
      color: var(--text-muted);
      line-height: 1.6;
    }
    .notes-content p {
      margin-bottom: 8px;
    }

    .overview-modal {
      position: fixed;
      inset: 0;
      background: rgba(10, 12, 16, 0.9);
      backdrop-filter: blur(24px);
      z-index: 200;
      display: none;
      flex-direction: column;
      padding: 40px;
      overflow-y: auto;
    }
    .overview-modal.visible {
      display: flex;
    }
    .overview-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
    }
    .overview-header h3 {
      font-size: 24px;
      font-weight: 700;
    }
    .overview-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 20px;
    }
    .overview-card {
      background: var(--bg-surface);
      border: 1px solid var(--border-glass);
      border-radius: var(--radius-md);
      padding: 16px;
      cursor: pointer;
      transition: all 0.2s;
    }
    .overview-card:hover {
      border-color: var(--primary);
      transform: translateY(-3px);
    }
    .overview-card.current {
      border-color: var(--primary);
      box-shadow: 0 0 15px rgba(255, 138, 61, 0.3);
    }
    .overview-card-num {
      font-size: 12px;
      font-weight: 700;
      color: var(--primary);
      margin-bottom: 6px;
    }
    .overview-card-title {
      font-size: 14px;
      font-weight: 600;
      color: var(--text-main);
    }

    @media print {
      header.deck-header, footer.deck-footer, .speaker-notes-panel, .ambient-glow {
        display: none !important;
      }
      body {
        background: #0f172a !important;
        color: #f8fafc !important;
      }
      section.slide {
        display: flex !important;
        page-break-after: always;
        min-height: 100vh;
        box-shadow: none !important;
        border: none !important;
      }
    }
  </style>
</head>
<body>
  <div class="ambient-glow glow-1"></div>
  <div class="ambient-glow glow-2"></div>

  <header class="deck-header">
    <div class="brand-container">
      <div class="brand-badge">CAPSTONE</div>
      <div class="brand-title">
        InstaCat <span>/ AI Software Engineer Project</span>
      </div>
    </div>
    <div class="header-actions">
      <button class="action-btn" id="btnNotes" title="เปิด/ปิดบทพูดผู้บรรยาย (S)">📝 Notes</button>
      <button class="action-btn" id="btnOverview" title="แสดงภาพรวมสไลด์ทั้งหมด (O)">📑 Overview</button>
      <button class="action-btn" id="btnFullscreen" title="เต็มจอ (F)">⛶ Fullscreen</button>
      <button class="action-btn" id="btnPrint" title="พิมพ์หรือบันทึกเป็น PDF (P)">🖨️ PDF</button>
    </div>
  </header>

  <div class="progress-track">
    <div class="progress-bar" id="progressBar"></div>
  </div>

  <main class="deck-viewport">

    <!-- SLIDE 1: Title & Hero -->
    <section class="slide active" data-slide="1">
      <div class="hero-container">
        <div class="hero-badge">🐾 AI SOFTWARE ENGINEER CAPSTONE</div>
        <h1 class="hero-title">InstaCat: The Purr-fect Pet Community</h1>
        <p class="hero-subtitle">
          การพัฒนาโมบายโซเชียลมีเดียแบบ Full-Stack (Flutter ↔ Strapi 5 ↔ PostgreSQL ↔ Gemini AI)<br>
          ด้วยสไตล์การสั่งงาน AI ชั้นสูง (Spec-Driven Prompting) และ Agentic Workflow
        </p>
        <div class="grid-3" style="width: 100%; max-width: 1100px; margin-top: 10px;">
          <div class="card card-accent">
            <h3>สถาปัตยกรรมระดับองค์กร</h3>
            <p>3-Tier Production Architecture<br>Flutter + Strapi 5 + PostgreSQL 16</p>
          </div>
          <div class="card card-purple">
            <h3>ปัญญาประดิษฐ์วิทัศน์ (Vision AI)</h3>
            <p>Google Gemini 2.5 Flash Multimodal<br>วิเคราะห์รูปภาพแมวสร้างแคปชัน 4 สไตล์</p>
          </div>
          <div class="card card-green">
            <h3>ความสมบูรณ์ 100%</h3>
            <p>แสดงผลครบทุก 13 หน้าจอจริง<br>27 Automated Tests ผ่าน 100%</p>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 2: Vision & Scope -->
    <section class="slide" data-slide="2">
      <div class="slide-meta">
        <span class="slide-tag">Part 1: Concept & Planning</span>
        <span class="slide-category">ภาพรวมและวิสัยทัศน์</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">ภาพรวมและความเป็นมาของ InstaCat</h2>
        <p class="slide-subtitle">เปลี่ยนโจทย์โซเชียลมีเดียสำหรับคนรักแมวสู่แอปพลิเคชันใช้งานจริงที่เสร็จสมบูรณ์</p>
      </div>
      <div class="slide-body">
        <div class="grid-3">
          <div class="card card-accent">
            <h3>🎯 วิสัยทัศน์ (Project Vision)</h3>
            <ul>
              <li>สร้างพื้นที่คอมมูนิตี้เฉพาะกลุ่มสำหรับคนรักสัตว์เลี้ยง</li>
              <li>แชร์ภาพ เรื่องราว และไลฟ์สไตล์ของน้องแมวอย่างสร้างสรรค์</li>
              <li>เชื่อมโยง Mobile App, Headless CMS และ Cloud AI เข้าด้วยกันอย่างไร้รอยต่อ</li>
              <li>เป็นกรณีศึกษาต้นแบบของ AI Software Engineer Workflow</li>
            </ul>
          </div>
          <div class="card card-purple">
            <h3>📏 ขอบเขตฟังก์ชัน (Feature Scope)</h3>
            <ul>
              <li><strong>Authentication:</strong> One-Tap Switch Account, Login, Register</li>
              <li><strong>Feed & Stories:</strong> ฟีดภาพหลายรูป, Cat Stories, Like, Comments</li>
              <li><strong>Explore & Search:</strong> ค้นหาตามสายพันธุ์ และตารางภาพแบบมี Reels</li>
              <li><strong>Studio & Creation:</strong> คัดเลือกรูปหลายใบ, ฟิลเตอร์, ปักหมุดพิกัด</li>
              <li><strong>Gemini AI:</strong> ผู้ช่วยแต่งคำบรรยายแมว 4 สไตล์อัตโนมัติ</li>
            </ul>
          </div>
          <div class="card card-cyan">
            <h3>🔒 กฎเหล็กของโปรเจกต์</h3>
            <ul>
              <li><em>"Do not recreate the project"</em></li>
              <li>UI ของ Flutter เดิมคือ Visual Source of Truth</li>
              <li>ห้ามลบทิ้งหรือสร้างแอปใหม่แบบ generic เด็ดขาด</li>
              <li>มุ่งเน้นการต่อท่อเชื่อม UI เดิมเข้ากับ Backend จริง</li>
              <li>ประสบการณ์ผู้ใช้ (UX/UI) ต้องประณีต ตรงตามต้นฉบับ 100%</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 3: System Architecture -->
    <section class="slide" data-slide="3">
      <div class="slide-meta">
        <span class="slide-tag">Part 1: Concept & Planning</span>
        <span class="slide-category">สถาปัตยกรรมระบบ</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">สถาปัตยกรรมระบบ 3-Tier Enterprise Architecture</h2>
        <p class="slide-subtitle">การแยก Layer อิสระเพื่อความเสถียร รองรับการขยายตัว และง่ายต่อการทดสอบ</p>
      </div>
      <div class="slide-body">
        <div class="grid-4">
          <div class="card card-accent">
            <h3>📱 1. Client Tier</h3>
            <ul>
              <li>Flutter 3.x (Dart)</li>
              <li>Material 3 Design System</li>
              <li>LINE Seed Sans TH Font</li>
              <li>Dio Network Interceptor</li>
              <li>Flutter Secure Storage</li>
              <li>Client Image Compression</li>
              <li>Optimistic State Updates</li>
            </ul>
          </div>
          <div class="card card-purple">
            <h3>⚡ 2. CMS / API Tier</h3>
            <ul>
              <li>Strapi 5 Headless CMS</li>
              <li>Node.js & TypeScript</li>
              <li>Document Service Life-cycles</li>
              <li>JWT & Refresh Token Policies</li>
              <li>Automated RBAC Bootstrap</li>
              <li>Multipart Media Pipeline</li>
              <li>Secure REST Endpoints</li>
            </ul>
          </div>
          <div class="card card-cyan">
            <h3>🗄️ 3. Data Tier</h3>
            <ul>
              <li>PostgreSQL 16 (Port 5433)</li>
              <li>Relational Data Integrity</li>
              <li>Tables: Users, Posts, Media</li>
              <li>PostLikes, Comments</li>
              <li>Follows & Notifications</li>
              <li>Foreign Key Constraints</li>
              <li>Indexed Query Optimization</li>
            </ul>
          </div>
          <div class="card card-green">
            <h3>🤖 4. Cloud AI Tier</h3>
            <ul>
              <li>Google Gemini 2.5 Flash</li>
              <li>Multimodal Vision Analysis</li>
              <li>OpenStreetMap / Nominatim</li>
              <li>Reverse Geocoding Engine</li>
              <li>JSON Schema Strict Prompting</li>
              <li>Fallback Heuristic Captions</li>
              <li>Resilient Error Handling</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 4: User Prompt Engineering Style -->
    <section class="slide" data-slide="4">
      <div class="slide-meta">
        <span class="slide-tag">Part 2: Human-AI Collaboration</span>
        <span class="slide-category">กลยุทธ์การสั่งงาน AI</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">Style การสั่งงาน AI: กลยุทธ์การกำกับ AI ให้ได้งานสูงสุด</h2>
        <p class="slide-subtitle">ถอดรหัสเทคนิค Prompt Engineering และรูปแบบการสั่งงานที่ทำให้ AI ส่งงานได้ตรงเป้า 100%</p>
      </div>
      <div class="slide-body">
        <div class="grid-3">
          <div class="card card-accent">
            <h3>📑 1. Spec-Driven Directives</h3>
            <ul>
              <li><strong>Single Source of Truth:</strong> ส่งมอบเอกสาร Markdown Spec ที่ละเอียด (Data Contract, Models, Endpoints)</li>
              <li><strong>Contract Definition:</strong> กำหนด JSON Request/Response ชัดเจน ไม่ปล่อยให้ AI ออกแบบเดาสุ่ม</li>
              <li><strong>Acceptance Criteria:</strong> ระบุเงื่อนไขการตรวจรับงานอย่างโปร่งใส</li>
              <li><strong>ผลลัพธ์:</strong> ลดความคลาดเคลื่อนและลดข้อผิดพลาดจากการ Hallucinate ได้กว่า 90%</li>
            </ul>
          </div>
          <div class="card card-purple">
            <h3>🪜 2. Milestone-Based Prompting</h3>
            <ul>
              <li><strong>สั่งงานเป็นช่วงๆ ตามลำดับ:</strong></li>
              <li>Phase 1: Database Setup & Permissions Bootstrap</li>
              <li>Phase 2: Authentication Flow & Secure Storage</li>
              <li>Phase 3: Social Feed, Carousel & Optimistic Likes</li>
              <li>Phase 4: Gemini Vision AI & Location Integration</li>
              <li>Phase 5: UI Layout Polish & QA Across 13 Screens</li>
            </ul>
          </div>
          <div class="card card-cyan">
            <h3>⚡ 3. Adaptive Fast Feedback</h3>
            <ul>
              <li><strong>รายงานสั้น กระชับ ตรงจุด:</strong> เช่น <em>"แอปค้างไป ฉัน restart ให้ใหม่แล้ว"</em> หรือ <em>"ฉันเข้าสู่ระบบให้แล้ว"</em></li>
              <li><strong>ปลดล็อกทันที:</strong> เปิดทางให้ AI เข้าอ่าน Log ใน Terminal และตรวจ Database ได้ทันควัน</li>
              <li><strong>Negative Constraints:</strong> กำชับข้อห้ามชัดเจน เช่น <em>"ห้ามเขียนทับ UI เดิม"</em> และ <em>"ห้ามสร้าง mock ข้อมูลปลอม"</em></li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 5: Agentic Workflow -->
    <section class="slide" data-slide="5">
      <div class="slide-meta">
        <span class="slide-tag">Part 2: Human-AI Collaboration</span>
        <span class="slide-category">วงจรการพัฒนาร่วมกับ AI</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">Agentic Workflow: วงจรการพัฒนาร่วมกับ AI ระดับคู่คิด</h2>
        <p class="slide-subtitle">เปลี่ยนจากการขอแค่ Snippet โค้ด มาเป็น Autonomous Pair-Programming ตลอดกระบวนการ</p>
      </div>
      <div class="slide-body">
        <div class="grid-2">
          <div class="card card-accent">
            <h3>🔄 ลูปการปฏิบัติการของ AI (Autonomous Loop)</h3>
            <ul>
              <li><strong>1. Codebase Inspection:</strong> สำรวจโค้ดจริงผ่าน Ripgrep และ File Viewer ตรวจสอบ package.json และ pubspec.yaml อย่างละเอียด</li>
              <li><strong>2. Implementation Planning:</strong> จัดทำแผนงาน ละเอียด แจกแจงไฟล์ที่จะแก้ ประเมินความเสี่ยงและขอความเห็นชอบก่อนเริ่มลงมือ</li>
              <li><strong>3. Multi-file Orchestration:</strong> แก้ไข Controller ฝั่ง Strapi ควบคู่กับ Service ฝั่ง Dart ให้สอดคล้องกันในรอบเดียว</li>
              <li><strong>4. Real-time Verification:</strong> รันเซิร์ฟเวอร์, อ่าน Log ข้อผิดพลาด และคิวรี Database ด้วยคำสั่ง Terminal จริง</li>
              <li><strong>5. Visual Verification:</strong> สั่งแตะหน้าจอและแคปเจอร์รูปหน้าจอจริงจาก Simulator เพื่อตรวจงานด้วยตา</li>
            </ul>
          </div>
          <div class="card card-purple">
            <h3>🚀 ประโยชน์ของการทำงานแบบ AI-First Workflow</h3>
            <ul>
              <li><strong>Zero Context Switching:</strong> ไม่ต้องสลับหน้าต่างก๊อปปี้ Error มาแปะ AI จัดการผ่าน Shell ในตัว</li>
              <li><strong>High Velocity Delivery:</strong> พัฒนาระบบ Full-Stack ขนาด 13 หน้าจอเสร็จสมบูรณ์ในเวลาอันรวดเร็ว</li>
              <li><strong>High Code Quality:</strong> รัน flutter analyze และชุดทดสอบอัตโนมัติ 27 รายการจนผ่าน 100%</li>
              <li><strong>End-to-End Alignment:</strong> ข้อมูลใน Database สอดคล้องกับหน้าจอ UI จริงในทุกจุด</li>
              <li><strong>Live Screen Proof:</strong> มีภาพถ่ายหน้าจอเครื่องจำลองจริงยืนยันการทำงานของทุกฟังก์ชัน</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 6: Showcase 1 - Auth Suite (3 Mockups) -->
    <section class="slide" data-slide="6">
      <div class="slide-meta">
        <span class="slide-tag">Part 3: App Showcase (1/8)</span>
        <span class="slide-category">ระบบสมาชิกและความปลอดภัย</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">ระบบสมาชิกและความปลอดภัย (Authentication Suite)</h2>
        <p class="slide-subtitle">รองรับ One-Tap Account Switching, การล็อกอินมาตรฐาน และการสมัครสมาชิกใหม่</p>
      </div>
      <div class="slide-body">
        <div class="grid-3">
          <div class="card" style="text-align: center; display: flex; flex-direction: column; align-items: center;">
            <div class="mockup-wrapper" style="margin-bottom: 16px;">
              <img src="images/mockup_switch.png" alt="Switch Account" class="mockup-img-sm">
            </div>
            <h3>🔑 1. Switch Account</h3>
            <p>จดจำโปรไฟล์บัญชีล่าสุดที่เคยล็อกอินในเครื่อง แสดงรูปอวตารและชื่อ สามารถแตะเพื่อสลับบัญชีได้ง่ายในคลิกเดียว</p>
          </div>
          <div class="card" style="text-align: center; display: flex; flex-direction: column; align-items: center;">
            <div class="mockup-wrapper" style="margin-bottom: 16px;">
              <img src="images/mockup_login.png" alt="Clean Login" class="mockup-img-sm">
            </div>
            <h3>📝 2. Clean Login</h3>
            <p>ช่องกรอกข้อมูลสะอาดตา มีปุ่มสลับซ่อน/แสดงรหัสผ่าน พร้อมการแจ้งเตือนข้อผิดพลาดที่ชัดเจนและปลอดภัย</p>
          </div>
          <div class="card" style="text-align: center; display: flex; flex-direction: column; align-items: center;">
            <div class="mockup-wrapper" style="margin-bottom: 16px;">
              <img src="images/mockup_register.png" alt="Register Screen" class="mockup-img-sm">
            </div>
            <h3>✨ 3. Register Screen</h3>
            <p>หน้าลงทะเบียนสมาชิกใหม่ ตรวจสอบความถูกต้องของข้อมูล (Form Validation) อย่างรัดกุมก่อนส่งเข้าบันทึกลง Postgres</p>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 7: Showcase 2 - Feed & Comments (2 Mockups) -->
    <section class="slide" data-slide="7">
      <div class="slide-meta">
        <span class="slide-tag">Part 3: App Showcase (2/8)</span>
        <span class="slide-category">ฟีดชุมชนและคอมเมนต์</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">หน้าฟีดและคอมเมนต์ (Social Feed & Discussion)</h2>
        <p class="slide-subtitle">ระบบแสดงโพสต์ภาพแมวส้มแบบมัลติโฟโต้ สตอรี่แมว และการสนทนาใต้โพสต์</p>
      </div>
      <div class="slide-body">
        <div style="display: grid; grid-template-columns: 280px 280px 1fr; gap: 24px; align-items: center;">
          <div class="mockup-wrapper">
            <img src="images/mockup_feed.png" alt="Feed Screen" class="mockup-img">
          </div>
          <div class="mockup-wrapper">
            <img src="images/mockup_comments.png" alt="Comments Sheet" class="mockup-img">
          </div>
          <div class="card card-accent" style="height: 100%; display: flex; flex-direction: column; justify-content: center;">
            <h3>🐾 ฟีเจอร์เด่นบนหน้า Feed & Comments</h3>
            <ul>
              <li><strong>Cat Stories Bar:</strong> แถบวงกลมแสดงสตอรี่ของแมวแต่ละตัว พร้อมไอคอนบวกเพิ่มสตอรี่ของตนเอง</li>
              <li><strong>Multi-Photo Carousel:</strong> โพสต์ของ testcat แสดงภาพได้สูงสุด 5 ภาพ พร้อมตัวเลข (1/5) และ Dots Indicator</li>
              <li><strong>Optimistic Like Interactions:</strong> กดหัวใจแล้วเปลี่ยนเป็นสีแดงพร้อมเพิ่มตัวเลขทันที และซิงค์ฐานข้อมูลเบื้องหลัง</li>
              <li><strong>Location & Tagged Cats:</strong> แสดงพิกัด <em>"The Legacy Hotel Nana, Bangkok"</em> และแท็กเพื่อนแมว <code>@testcat2</code> บนรูปภาพ</li>
              <li><strong>Comments Bottom Sheet:</strong> แตะดูความคิดเห็นและร่วมพิมพ์ข้อความสนทนาใต้โพสต์แบบเรียลไทม์</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 8: Showcase 3 - Explore & Discovery (1 Large Mockup) -->
    <section class="slide" data-slide="8">
      <div class="slide-meta">
        <span class="slide-tag">Part 3: App Showcase (3/8)</span>
        <span class="slide-category">การสำรวจและค้นหา</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">หน้าสำรวจและค้นหา (Explore & Discovery Grid)</h2>
        <p class="slide-subtitle">ค้นหาน้องแมวตามสายพันธุ์ ค้นหาแฮชแท็ก และตารางภาพแมวยอดนิยมแบบมี Reels</p>
      </div>
      <div class="slide-body">
        <div class="grid-2" style="align-items: center;">
          <div class="mockup-wrapper">
            <img src="images/mockup_explore.png" alt="Explore Grid" class="mockup-img">
          </div>
          <div class="card card-purple" style="display: flex; flex-direction: column; justify-content: center;">
            <h3>🔍 ฟังก์ชันเด่นบนหน้า Explore</h3>
            <ul>
              <li><strong>Instant Cat Search Bar:</strong> ช่องค้นหาอัจฉริยะ ค้นหาได้ทั้งชื่อน้องแมว, สายพันธุ์, และ #แฮชแท็ก</li>
              <li><strong>Dynamic Breed Filter Chips:</strong> แถบปุ่มคัดกรองหมวดหมู่อย่างรวดเร็ว เช่น #Trending, Reels, Ragdoll, Funny Cats, Kittens</li>
              <li><strong>Masonry Media Grid:</strong> ตารางแสดงรูปภาพน้องแมวและคลิปวิดีโอที่ดึงสดจากฐานข้อมูล Strapi</li>
              <li><strong>Reels & Carousel Badges:</strong> ไอคอนแสดงประเภทสื่อบนมุมขวาบน เช่น ไอคอนกล้องวิดีโอสำหรับคลิป Reels และไอคอนซ้อนสำหรับอัลบั้มรูป</li>
              <li><strong>Interactive Navigation:</strong> แตะรูปภาพใดๆ เพื่อเปิดดูโพสต์ฉบับเต็มและกดติดตามเจ้าของแมวได้ทันที</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 9: Showcase 4 - Content Studio & Media Picker (2 Mockups) -->
    <section class="slide" data-slide="9">
      <div class="slide-meta">
        <span class="slide-tag">Part 3: App Showcase (4/8)</span>
        <span class="slide-category">สตูดิโอสร้างโพสต์</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">สตูดิโอสร้างโพสต์ (Content Creation & Media Studio)</h2>
        <p class="slide-subtitle">ระบบคัดเลือกภาพมัลติมีเดียสไตล์อินสตาแกรม และหน้าแต่งโพสต์พร้อมฟิลเตอร์</p>
      </div>
      <div class="slide-body">
        <div style="display: grid; grid-template-columns: 280px 280px 1fr; gap: 24px; align-items: center;">
          <div class="mockup-wrapper">
            <img src="images/mockup_create_picker.png" alt="Media Picker" class="mockup-img">
          </div>
          <div class="mockup-wrapper">
            <img src="images/mockup_post_composer.png" alt="Post Composer" class="mockup-img">
          </div>
          <div class="card card-cyan" style="height: 100%; display: flex; flex-direction: column; justify-content: center;">
            <h3>📸 ฟีเจอร์สร้างสรรค์โพสต์</h3>
            <ul>
              <li><strong>Custom Gallery Picker:</strong> หน้าเลือกรูปจากเครื่องพร้อมปุ่มเปิดกล้อง และวงแหวนเลือกภาพหลายใบ (Multi-Select)</li>
              <li><strong>Media Mode Switcher:</strong> สลับโหมดการสร้างคอนเทนต์ได้ง่ายระหว่าง POST, STORY และ REELS</li>
              <li><strong>Live Cat Photo Filters:</strong> ฟิลเตอร์ปรับแต่งภาพแมว 5 อารมณ์ (Normal, Warm Glow, Golden Hour, Vintage Cat, Soft Purr)</li>
              <li><strong>Popular Cat Hashtags:</strong> ปุ่มแฮชแท็กสำเร็จรูปแตะแล้วแทรกลงข้อความทันที เช่น #CatLife, #Purrfect, #Meow, #Caturday</li>
              <li><strong>AI Assistant & Tagging:</strong> ปุ่มเรียกผู้ช่วย AI และเมนูแท็กเพื่อนแมวกับสถานที่</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 10: Showcase 5 - Gemini Vision AI Studio (1 Large Mockup) -->
    <section class="slide" data-slide="10">
      <div class="slide-meta">
        <span class="slide-tag">Part 3: App Showcase (5/8)</span>
        <span class="slide-category">ผู้ช่วยแคปชันอัจฉริยะ</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">ผู้ช่วยแคปชันอัจฉริยะ (Gemini Vision AI Assistant)</h2>
        <p class="slide-subtitle">วิเคราะห์ลักษณะภาพแมวและสร้างคำบรรยายภาษาไทย 4 สไตล์อัตโนมัติ</p>
      </div>
      <div class="slide-body">
        <div class="grid-2" style="align-items: center;">
          <div class="mockup-wrapper">
            <img src="images/mockup_ai_caption.png" alt="AI Caption Sheet" class="mockup-img">
          </div>
          <div class="card card-green" style="display: flex; flex-direction: column; justify-content: center;">
            <h3>🤖 เจาะลึกความฉลาดของ Gemini 2.5 Flash</h3>
            <ul>
              <li><strong>Multimodal Image Understanding:</strong> วิเคราะห์สีขน, สายตา, และพฤติกรรมของแมวในรูปภาพอย่างละเอียด</li>
              <li><strong>4 Personality Tones:</strong> เลือกอารมณ์ได้ 4 แบบ ได้แก่ "น่ารัก" 💖, "ตลก" 😹, "กวนๆ" 😼 และ "สั้นกระชับ" ⚡</li>
              <li><strong>Authentic Thai Feline Slang:</strong> คำบรรยายภาษาไทยสไตล์คนรักแมว เช่น <em>"งอยย ตาแป๋วขนาดนี้...", "เจ้าส้มจอมกวน 🧡"</em></li>
              <li><strong>One-Tap Caption Insertion:</strong> แตะแคปชันที่ชอบเพียงครั้งเดียว ข้อความจะถูกนำไปกรอกลงในช่องแคปชันพร้อมโพสต์ทันที</li>
              <li><strong>Interactive Regenerate:</strong> กดปุ่ม "สุ่มใหม่" เพื่อให้ AI คิดชุดแคปชันใหม่ๆ ได้ไม่จำกัดรอบ</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 11: Showcase 6 - Geolocation (1 Large Mockup) -->
    <section class="slide" data-slide="11">
      <div class="slide-meta">
        <span class="slide-tag">Part 3: App Showcase (6/8)</span>
        <span class="slide-category">ระบบปักหมุดสถานที่</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">ระบบปักหมุดสถานที่ (Geolocation & Place Tagging)</h2>
        <p class="slide-subtitle">ระบุพิกัดอัตโนมัติด้วย GPS ร่วมกับ OpenStreetMap Reverse Geocoding</p>
      </div>
      <div class="slide-body">
        <div class="grid-2" style="align-items: center;">
          <div class="mockup-wrapper">
            <img src="images/mockup_location.png" alt="Location Picker" class="mockup-img">
          </div>
          <div class="card card-accent" style="display: flex; flex-direction: column; justify-content: center;">
            <h3>📍 ฟังก์ชันปักหมุดสถานที่</h3>
            <ul>
              <li><strong>Real-Time GPS Location:</strong> ตรวจจับพิกัดปัจจุบันผ่านแพ็กเกจ Geolocator เมื่อผู้ใช้อนุญาต Location Permission</li>
              <li><strong>Reverse Geocoding Engine:</strong> แปลงพิกัดละติจูด/ลองจิจูดเป็นชื่อถนนและเขตจริงผ่าน OpenStreetMap (Nominatim API)</li>
              <li><strong>Auto-Detected Selection:</strong> แสดงชื่อสถานที่ที่ตรวจพบพร้อมติ๊กถูกสีส้ม (เช่น <em>"Dinso Road, Bowon Niwet, Phra Nakhon"</em>)</li>
              <li><strong>Custom Place Name Editing:</strong> รองรับการพิมพ์ชื่อสถานที่เฉพาะเอง เช่น "คาเฟ่แมวเหมียวสุขุมวิท" หรือชื่อโรงแรม</li>
              <li><strong>Interactive Place Search:</strong> มีช่องค้นหาสถานที่ ร้านค้า คาเฟ่ และแลนด์มาร์กสำคัญเพื่อเลือกปักหมุดได้อย่างแม่นยำ</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 12: Showcase 7 - Notifications (1 Large Mockup) -->
    <section class="slide" data-slide="12">
      <div class="slide-meta">
        <span class="slide-tag">Part 3: App Showcase (7/8)</span>
        <span class="slide-category">ระบบแจ้งเตือนและกิจกรรม</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">ระบบแจ้งเตือนและกิจกรรม (Notifications & Activity)</h2>
        <p class="slide-subtitle">ติดตามทุกการเคลื่อนไหว ทั้งการกดถูกใจ การติดตามใหม่ และคอมเมนต์ใต้โพสต์</p>
      </div>
      <div class="slide-body">
        <div class="grid-2" style="align-items: center;">
          <div class="mockup-wrapper">
            <img src="images/mockup_notifications.png" alt="Notifications Activity" class="mockup-img">
          </div>
          <div class="card card-purple" style="display: flex; flex-direction: column; justify-content: center;">
            <h3>🔔 ฟังก์ชันแจ้งเตือนแบบครบวงจร</h3>
            <ul>
              <li><strong>Comprehensive Activity Feed:</strong> รวมประวัติกิจกรรมทั้งหมด เช่น <em>"testcat2 liked your post"</em> และ <em>"started following you"</em></li>
              <li><strong>Categorized Filter Pills:</strong> ปุ่มตัวกรองด้านบนเพื่อแยกดูเฉพาะกิจกรรมที่สนใจ: All, Likes, Comments, และ Follows</li>
              <li><strong>Interactive Follow Button:</strong> มีปุ่ม "Following" หรือ "Follow Back" ให้กดติดตามเพื่อนแมวกลับได้ทันทีจากหน้านี้</li>
              <li><strong>Post Preview Thumbnail:</strong> แสดงภาพขนาดย่อของโพสต์ที่ถูกกดถูกใจที่มุมขวา ช่วยให้ทราบว่าถูกใจโพสต์ไหน</li>
              <li><strong>Real-Time Badge Counters:</strong> ตัวเลขนับการแจ้งเตือนที่ยังไม่ได้อ่านบนแถบเมนูด้านล่าง ซิงค์ตรงกับฐานข้อมูล Strapi 5</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 13: Showcase 8 - Profile Suite (2 Mockups) -->
    <section class="slide" data-slide="13">
      <div class="slide-meta">
        <span class="slide-tag">Part 3: App Showcase (8/8)</span>
        <span class="slide-category">โปรไฟล์และการตั้งค่าบัญชี</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">โปรไฟล์และการตั้งค่าบัญชี (Profile & Settings Suite)</h2>
        <p class="slide-subtitle">หน้าแสดงประวัติน้องแมว สถิติจริง และหน้าแก้ไขข้อมูลโปรไฟล์พร้อมการสลับโหมดสาธารณะ</p>
      </div>
      <div class="slide-body">
        <div style="display: grid; grid-template-columns: 280px 280px 1fr; gap: 24px; align-items: center;">
          <div class="mockup-wrapper">
            <img src="images/mockup_profile.png" alt="Profile Screen" class="mockup-img">
          </div>
          <div class="mockup-wrapper">
            <img src="images/mockup_edit_profile.png" alt="Edit Profile Screen" class="mockup-img">
          </div>
          <div class="card card-cyan" style="height: 100%; display: flex; flex-direction: column; justify-content: center;">
            <h3>👤 ฟีเจอร์จัดการโปรไฟล์แมว</h3>
            <ul>
              <li><strong>Live DB Stats:</strong> ดึงตัวเลขจริงจาก PostgreSQL: Posts (3), Followers (1), Following (1)</li>
              <li><strong>Paw Breed Badge:</strong> แสดงป้ายกำกับสายพันธุ์แมว "Orange Cat" พร้อมไอคอนอุ้งเท้าสุดน่ารัก</li>
              <li><strong>Story Highlights:</strong> แถบวงกลมไฮไลต์เรื่องราวที่น่าประทับใจ (New, Playtime, Treats, Naps, OOTD)</li>
              <li><strong>Edit Profile Screen:</strong> แก้ไขรูปอวตาร, ชื่อ, ชื่อผู้ใช้ (@testcat), หมวดหมู่สายพันธุ์, เว็บไซต์ และ Bio (35/150)</li>
              <li><strong>Privacy & Account Controls:</strong> สวิตช์เปิด/ปิด Public Profile และปุ่ม Log Out ปลอดภัย</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 14: Problem Solving 1 (Backend & DB) -->
    <section class="slide" data-slide="14">
      <div class="slide-meta">
        <span class="slide-tag">Part 4: Problem Solving (1/2)</span>
        <span class="slide-category">ปัญหาและการแก้ไขฝั่งเซิร์ฟเวอร์</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">ปัญหาเชิงเทคนิคและการแก้ไข: Backend & Database</h2>
        <p class="slide-subtitle">อุปสรรคจริงที่พบในฝั่งเซิร์ฟเวอร์ และการออกแบบโซลูชันแก้ไขที่ยั่งยืน</p>
      </div>
      <div class="slide-body">
        <div class="grid-2">
          <div class="card card-red">
            <h3>⚠️ ปัญหาที่ 1: Strapi 5 RBAC Permissions บล็อก</h3>
            <ul>
              <li><strong>อาการ:</strong> Endpoint ที่สร้างขึ้นใหม่ทั้งหมดติดสถานะ <code>403 Forbidden</code> ทันที</li>
              <li><strong>สาเหตุ:</strong> Strapi 5 มี Security Model ที่บล็อกทุก Route เป็นค่าเริ่มต้นจนกว่าจะเปิดใน Admin UI</li>
              <li><strong>วิธีแก้ไข:</strong> เขียนระบบ Bootstrap Lifecycle ใน <code>backend/src/index.ts</code> ให้ตรวจจับ Role 'public' และ 'authenticated' แล้วสร้าง Record สิทธิ์ลงตาราง permission อัตโนมัติทุกครั้งที่บูตเซิร์ฟเวอร์</li>
            </ul>
          </div>
          <div class="card card-red">
            <h3>⚠️ ปัญหาที่ 2: SQLite vs PostgreSQL Sync & Port 5433</h3>
            <ul>
              <li><strong>อาการ:</strong> ฐานข้อมูลไม่เชื่อมต่อ หรือข้อมูลบัญชีทดสอบหายหลังรีสตาร์ทเซิร์ฟเวอร์</li>
              <li><strong>สาเหตุ:</strong> ค่าคอนฟิกเริ่มต้นสลับระหว่าง SQLite กับ Postgres (รันบนพอร์ต 5433 ไม่ใช่ 5432)</li>
              <li><strong>วิธีแก้ไข:</strong> ตั้งค่า <code>database.ts</code> ให้ชี้ไปยัง PostgreSQL พอร์ต 5433 พร้อมซิงค์ bcrypt password hash ของบัญชี testcat และ testcat2 ให้ตรงกับ password123</li>
            </ul>
          </div>
          <div class="card card-green">
            <h3>✅ ปัญหาที่ 3: Strapi 5 Document Service & Population</h3>
            <ul>
              <li><strong>อาการ:</strong> Response ของ Feed และ Profile ขาดรูปภาพผู้ใช้ หรือขาดข้อมูล Relations</li>
              <li><strong>สาเหตุ:</strong> Strapi 5 เปลี่ยนเอนจินภายในจาก Entity Service มาเป็น Document Service ซึ่งไม่ Populate ข้อมูล Relation ให้อัตโนมัติ</li>
              <li><strong>วิธีแก้ไข:</strong> เขียนตัวแปลง Param ให้เรียก <code>populate: ['media', 'user', 'likes', 'comments']</code> อย่างเจาะจงใน Controller</li>
            </ul>
          </div>
          <div class="card card-green">
            <h3>✅ ปัญหาที่ 4: เครือข่าย Emulator ข้ามระบบปฏิบัติการ</h3>
            <ul>
              <li><strong>อาการ:</strong> ยิง API ไปที่ 127.0.0.1 แล้วเกิดข้อผิดพลาด Connection Refused บน Android</li>
              <li><strong>สาเหตุ:</strong> Android Emulator มอง 127.0.0.1 เป็นตัวเอง ต้องใช้ 10.0.2.2 เพื่อคุยกับคอมพิวเตอร์แม่ข่าย</li>
              <li><strong>วิธีแก้ไข:</strong> เขียน <code>ApiConfig.serverUrl</code> ให้สลับ Host อัตโนมัติในระดับไคลเอนต์ตาม TargetPlatform</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 15: Problem Solving 2 (Mobile & AI) -->
    <section class="slide" data-slide="15">
      <div class="slide-meta">
        <span class="slide-tag">Part 4: Problem Solving (2/2)</span>
        <span class="slide-category">ปัญหาและการแก้ไขฝั่งไคลเอนต์และ AI</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">ปัญหาเชิงเทคนิคและการแก้ไข: Mobile, AI & UX</h2>
        <p class="slide-subtitle">การแก้ปัญหาด้านความเข้ากันได้ของระบบ ความปลอดภัย และการตอบสนองของแอป</p>
      </div>
      <div class="slide-body">
        <div class="grid-2">
          <div class="card card-red">
            <h3>⚠️ ปัญหาที่ 5: iOS Keychain Error (-34018)</h3>
            <ul>
              <li><strong>อาการ:</strong> FlutterSecureStorage ล้มเหลวและทำให้แอป Crash ทันทีที่เซฟ Token บน iOS Simulator</li>
              <li><strong>สาเหตุ:</strong> Simulator ขาด Entitlements ในการเข้าถึง Keychain ของระบบ macOS</li>
              <li><strong>วิธีแก้ไข:</strong> ออกแบบ Multi-Tier Storage ที่ครอบ <code>try-catch</code> โดยหากเขียน Keychain ล้มเหลว จะสลับไปเก็บใน SharedPreferences / In-Memory Cache อัตโนมัติ ทำให้สลับบัญชีได้อย่างราบรื่น</li>
            </ul>
          </div>
          <div class="card card-red">
            <h3>⚠️ ปัญหาที่ 6: ขนาดรูปถ่ายจากกล้องและการอัปโหลดช้า</h3>
            <ul>
              <li><strong>อาการ:</strong> ภาพถ่ายขนาด 5-10 MB ส่งผลให้เกิด Request Timeout และเปลืองหน่วยความจำ</li>
              <li><strong>สาเหตุ:</strong> การส่งภาพ Raw โดยไม่ผ่านการบีบอัดทำให้ Network I/O ติดขัด</li>
              <li><strong>วิธีแก้ไข:</strong> ติดตั้ง Image Processing Pipeline ฝั่ง Client บีบอัดเป็น JPEG คุณภาพ 85% ขนาดสูงสุดไม่เกิน 2048px ลดขนาดไฟล์ลงได้กว่า 75% โดยคุณภาพยังคงคมชัด</li>
            </ul>
          </div>
          <div class="card card-green">
            <h3>✅ ปัญหาที่ 7: Gemini Vision AI ส่ง Markdown Code Fences</h3>
            <ul>
              <li><strong>อาการ:</strong> JSON Decode ใน Dart ขัดข้องเมื่อ Gemini แนบ <code>```json</code> หรือข้อความอธิบายนอกกรอบมา</li>
              <li><strong>สาเหตุ:</strong> LLM มักส่ง Markdown Formatting มาปะปนกับ Raw JSON</li>
              <li><strong>วิธีแก้ไข:</strong> เขียน Regex Strip ทำความสะอาด Code Block ก่อนแปลงเข้า JSON Parser และเพิ่มชุด Fallback Captions 5 อารมณ์เพื่อรับประกันว่าแอปจะไม่มีวันค้างหรือ Crash</li>
            </ul>
          </div>
          <div class="card card-green">
            <h3>✅ ปัญหาที่ 8: UI Layout Spacing & Location Overflow</h3>
            <ul>
              <li><strong>อาการ:</strong> หน้าจอ Add Location และ Edit Profile เกิด Yellow-Black Overflow Banner</li>
              <li><strong>สาเหตุ:</strong> ระยะ Padding คงที่ทับซ้อนกับ Dynamic Island และปุ่ม Bottom Navigation</li>
              <li><strong>วิธีแก้ไข:</strong> ปรับใช้ Responsive Layout ด้วย SingleChildScrollView, SafeArea และจัดระยะ Gap การ์ดใหม่ทั้งหมดให้รองรับทุกขนาดหน้าจออย่างสมบูรณ์แบบ</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 16: Quality Assurance -->
    <section class="slide" data-slide="16">
      <div class="slide-meta">
        <span class="slide-tag">Part 5: Quality Assurance</span>
        <span class="slide-category">การทดสอบและรับประกันคุณภาพ</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">การทดสอบระบบและการรับประกันคุณภาพ (QA Matrix)</h2>
        <p class="slide-subtitle">ยืนยันความพร้อมในการใช้งานระดับ Production ด้วยชุดการทดสอบอัตโนมัติรอบด้าน</p>
      </div>
      <div class="slide-body">
        <div class="grid-3">
          <div class="card card-green">
            <h3>✅ Automated Tests (27/27)</h3>
            <ul>
              <li>ชุดทดสอบอัตโนมัติรวม 27 รายการ</li>
              <li>ผลการทดสอบ: ผ่าน 100% (All Passed)</li>
              <li>ครอบคลุม CatUser, Post, Comment, Like Models</li>
              <li>จำลอง Network Response ทุกสถานะ (200, 401, 500)</li>
              <li>ทดสอบ Auth State Persistence & Token Refresh</li>
            </ul>
          </div>
          <div class="card card-cyan">
            <h3>🔍 Static Code Analysis</h3>
            <ul>
              <li>รันคำสั่ง <code>flutter analyze</code> ตรวจสอบทั้งโปรเจกต์</li>
              <li>ผลลัพธ์: <strong>No issues found!</strong> (0 Warnings, 0 Errors)</li>
              <li>จัดระเบียบ Import และลบ Unused Dependencies</li>
              <li>ผ่านเกณฑ์ Flutter Lints และ Best Practices</li>
              <li>โค้ดสะอาด เป็นไปตามหลัก Clean Architecture</li>
            </ul>
          </div>
          <div class="card card-purple">
            <h3>🧪 End-to-End Live Verification</h3>
            <ul>
              <li>ทดสอบสดบน iPhone 16 Pro Max Simulator</li>
              <li>ครบทั้ง 13 หน้าจอจริงแบบ Real-time</li>
              <li>บัญชีทดสอบที่พร้อมใช้งานทันที:</li>
              <li>• <code>testcat</code> / <code>password123</code> (บัญชีหลัก)</li>
              <li>• <code>testcat2</code> / <code>password123</code> (บัญชีรอง)</li>
              <li>ทดสอบสร้างโพสต์, ไลก์, คอมเมนต์ และสลับบัญชีได้จริง</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 17: Key Takeaways -->
    <section class="slide" data-slide="17">
      <div class="slide-meta">
        <span class="slide-tag">Part 6: Conclusion</span>
        <span class="slide-category">บทเรียนและผลิตภาพ</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">บทเรียนสำคัญจากการพัฒนาร่วมกับ AI</h2>
        <p class="slide-subtitle">การปฏิวัติผลิตภาพของนักพัฒนาซอฟต์แวร์ด้วยแนวคิด AI-First Engineering</p>
      </div>
      <div class="slide-body">
        <div class="grid-2">
          <div class="card card-accent">
            <h3>💡 3 กฎเหล็กของการเป็น AI Software Engineer</h3>
            <ul>
              <li><strong>1. Specification is King:</strong> สเปกที่ชัดเจนคือตัวกำหนดคุณภาพงาน AI ทำงานตามสเปกได้อย่างไร้ที่ติเมื่อเรามี Data Contract และ Acceptance Criteria ที่รัดกุม</li>
              <li><strong>2. Engineer as the Chief Architect:</strong> วิศวกรมนุษย์ต้องทำหน้าที่เป็นสถาปนิกผู้คุมทิศทาง กำหนด Boundaries, Security Model และกติกา ไม่ปล่อยให้ AI สร้างโค้ดสะเปะสะปะ</li>
              <li><strong>3. Resilient Fault-Tolerant Design:</strong> ความสำเร็จของซอฟต์แวร์อยู่ที่การรับมือกับ Edge Cases เช่น Fallback Storage เมื่อ Keychain พัง, Fallback Captions เมื่อ AI ขัดข้อง</li>
            </ul>
          </div>
          <div class="card card-purple">
            <h3>🚀 การประเมินผลิตภาพ (Productivity Multiplier)</h3>
            <ul>
              <li><strong>Velocity:</strong> พัฒนาแอป Full-Stack ขนาด 13 หน้าจอพร้อม Backend และ AI เสร็จสิ้นในเวลาที่สั้นลงกว่า 80%</li>
              <li><strong>Reduced Boilerplate Fatigue:</strong> ลดภาระการเขียน DTO, Model Parsing, และ CRUD Controllers</li>
              <li><strong>Seamless Full-Stack Alignment:</strong> การสั่งให้ AI แก้ไขทั้ง Dart และ TypeScript ควบคู่กันช่วยลดปัญหา API Mismatch</li>
              <li><strong>Enhanced Verification:</strong> การสั่งให้ AI แคปเจอร์หน้าจอและอ่าน Log ใน Terminal ช่วยให้ตรวจสอบงานได้แม่นยำยิ่งขึ้น</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- SLIDE 18: Roadmap & Conclusion -->
    <section class="slide" data-slide="18">
      <div class="slide-meta">
        <span class="slide-tag">Part 6: Conclusion</span>
        <span class="slide-category">แผนงานในอนาคตและสรุปผล</span>
      </div>
      <div class="slide-title-area">
        <h2 class="slide-title">ทิศทางการพัฒนาต่อยอด และสรุปผลงาน</h2>
        <p class="slide-subtitle">InstaCat พร้อมแล้วสำหรับการขยายผลสู่แพลตฟอร์มคอมมูนิตี้ระดับโลก</p>
      </div>
      <div class="slide-body">
        <div class="grid-2">
          <div class="card card-cyan">
            <h3>🔮 แผนพัฒนาต่อยอด (Future Roadmap)</h3>
            <ul>
              <li><strong>1. Push Notifications (FCM):</strong> ระบบแจ้งเตือนเข้ามือถือเมื่อมีคนมากดถูกใจหรือคอมเมนต์น้องแมว</li>
              <li><strong>2. AI Cat Breed Classifier:</strong> สแกนภาพแมวแล้วระบุสายพันธุ์และแนะนำวิธีดูแลเฉพาะสายพันธุ์</li>
              <li><strong>3. Video Streaming Stories:</strong> รองรับการอัปโหลดคลิปวิดีโอสั้นของน้องแมวความยาว 15-30 วินาที</li>
              <li><strong>4. Direct Messaging (Cat Chat):</strong> ระบบส่งข้อความส่วนตัวระหว่างเจ้าของสัตว์เลี้ยง พร้อมแชร์รูปภาพ</li>
              <li><strong>5. Adoption & Lost Pets Board:</strong> กระดานหาบ้านใหม่ให้น้องแมวและตามหาแมวหาย</li>
            </ul>
          </div>
          <div class="card card-green">
            <h3>🎉 สรุปผลการส่งมอบ (Delivery Summary)</h3>
            <ul>
              <li>✅ <strong>13 หน้าจอ</strong> ของแอปพลิเคชันทำงานได้จริง 100% พร้อมภาพจำลอง Smartphone Mockup</li>
              <li>✅ เชื่อมต่อ <strong>Flutter ↔ Strapi 5 ↔ PostgreSQL ↔ Gemini AI</strong> ครบวงจร</li>
              <li>✅ <strong>27 Automated Tests</strong> ผ่าน 100% พร้อม Static Analysis ผ่านฉลุย (0 Warning)</li>
              <li>✅ เอกสารสเปก ระบบ API Reference และ Setup Guide ครบถ้วน</li>
              <li>✅ พร้อมสำหรับการเดโมสด และใช้งานบนระบบจริง</li>
              <li style="margin-top: 14px; font-weight: 700; color: #fff;">🙏 ขอขอบคุณทุกท่านครับ พร้อมตอบทุกคำถาม (Q&A)</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

  </main>

  <!-- Speaker Notes Flyout -->
  <div class="speaker-notes-panel" id="speakerNotesPanel">
    <div class="notes-header">
      <h4>📝 SPEAKER NOTES (บทพูดบรรยาย)</h4>
      <span style="font-size: 11px; color: var(--text-dim);">กด 'S' เพื่อซ่อน</span>
    </div>
    <div class="notes-content" id="speakerNotesContent">
      <!-- Injected via JS -->
    </div>
  </div>

  <!-- Overview Modal -->
  <div class="overview-modal" id="overviewModal">
    <div class="overview-header">
      <h3>📑 ภาพรวมสไลด์ทั้งหมด (18 สไลด์)</h3>
      <button class="action-btn" id="btnCloseOverview">✕ ปิด (Esc)</button>
    </div>
    <div class="overview-grid" id="overviewGrid">
      <!-- Generated via JS -->
    </div>
  </div>

  <!-- Footer Navigation -->
  <footer class="deck-footer">
    <div class="footer-hints">
      <span><span class="kbd">←</span> <span class="kbd">→</span> / <span class="kbd">Space</span> สลับสไลด์</span>
      <span><span class="kbd">S</span> Speaker Notes</span>
      <span><span class="kbd">O</span> Overview</span>
      <span><span class="kbd">F</span> Fullscreen</span>
    </div>
    <div class="nav-controls">
      <button class="btn-nav" id="btnPrev" title="สไลด์ก่อนหน้า (←)">‹</button>
      <div class="slide-counter" id="slideCounter">1 / 18</div>
      <button class="btn-nav" id="btnNext" title="สไลด์ถัดไป (→)">›</button>
    </div>
  </footer>

  <script>
    const slides = document.querySelectorAll('.slide');
    const totalSlides = slides.length;
    let currentSlide = 1;

    const speakerNotesData = {
      1: `<p><strong>บทพูดแนะนำ:</strong> สวัสดีครับทุกคน วันนี้ผมยินดีเป็นอย่างยิ่งที่จะมานำเสนอโปรเจกต์ <strong>InstaCat</strong> ซึ่งเป็นโซเชียลมีเดียแอปพลิเคชันสำหรับคนรักแมว ที่ถูกพัฒนาขึ้นอย่างสมบูรณ์แบบตั้งแต่ระดับ Mobile Frontend ไปจนถึง Backend Database และ Generative AI Vision</p>
          <p>จุดเด่นของโปรเจกต์นี้ไม่ได้มีเพียงแค่ฟีเจอร์ที่สมบูรณ์เท่านั้น แต่คือกระบวนการพัฒนาที่เป็นเลิศ ด้วยการผสานพลังระหว่าง Software Engineer และ AI Coding Assistant ในรูปแบบ Spec-Driven Development ครับ</p>`,
      2: `<p><strong>บทพูด:</strong> ในสไลด์นี้คือภาพรวมและที่มาของโปรเจกต์ครับ เราต้องการสร้างชุมชนสำหรับคนรักสัตว์เลี้ยง โดยมีข้อกำหนดของ MVP ที่ชัดเจน ทั้งเรื่องระบบ Authentication, Social Feed, โพสต์ภาพได้หลายรูป และระบบโต้ตอบ</p>
          <p>ที่สำคัญคือเรามีกฎเหล็ก <em>"Do not recreate the project"</em> ซึ่งหมายความว่าเรามีโครงสร้าง UI เดิมของ Flutter อยู่แล้ว โจทย์ของเราไม่ใช่การลบแล้วสร้างใหม่ แต่คือการต่อท่อเชื่อมโยงเข้ากับฐานข้อมูลและ Backend จริงให้ทำงานได้อย่างสมบูรณ์แบบครับ</p>`,
      3: `<p><strong>บทพูด:</strong> ด้านสถาปัตยกรรมระบบ เราเลือกใช้ <strong>3-Tier Architecture</strong> แบ่งเป็น:</p>
          <p>1. <em>Client Tier:</em> Flutter พร้อม Material 3 และการจัดการ Secure Storage<br>
          2. <em>CMS Tier:</em> Strapi 5 บน TypeScript ทำหน้าที่เป็น Headless API<br>
          3. <em>Data Tier:</em> PostgreSQL 16 สำหรับเก็บข้อมูลเชิงสัมพันธ์อย่างปลอดภัย<br>
          และมี <em>External Tier</em> คือ Google Gemini 2.5 Flash สำหรับระบบ AI Vision ช่วยคิดแคปชันครับ</p>`,
      4: `<p><strong>บทพูด:</strong> สไตล์การสั่งงาน AI (Prompt Engineering) ของเรามี 3 เสาหลักที่ทำให้งานออกมาแม่นยำ 100% ครับ:</p>
          <p>1. <strong>Spec-Driven Directives:</strong> เราใช้ไฟล์ Markdown Spec เป็น Single Source of Truth ระบุ Data Contract ชัดเจน<br>
          2. <strong>Milestone-Based Prompting:</strong> สั่งงานเป็นลำดับขั้น เริ่มจาก Database -> Auth -> Feed -> Vision AI<br>
          3. <strong>Adaptive Fast Feedback:</strong> เมื่อพบปัญหา เราให้ฟีดแบ็กสั้น กระชับ ตรงจุด เช่น "แอปค้าง รีสตาร์ทให้แล้ว" ปล่อยให้ AI วิเคราะห์ Log และแก้ต่อทันทีครับ</p>`,
      5: `<p><strong>บทพูด:</strong> หัวข้อนี้คือหัวใจสำคัญของการทำงานร่วมกับ AI ครับ เราไม่ได้มอง AI เป็นแค่ตัวช่วยพิมพ์โค้ด (Copilot) แต่เรายกระดับเป็น <strong>Agentic Collaborator</strong></p>
          <p>AI สามารถอ่านทำความเข้าใจโปรเจกต์เดิม, นำเสนอแผนการเขียนโค้ด (Implementation Plan) ให้เราตรวจสอบ, รันเซิร์ฟเวอร์ และแคปเจอร์หน้าจอจาก Emulator มาให้เราตรวจงานได้ทันที ทำให้รอบการพัฒนา (Feedback Loop) รวดเร็วกว่าปกติหลายเท่าตัวครับ</p>`,
      6: `<p><strong>บทพูด:</strong> หน้าจอชุดแรกคือ Authentication Suite ครับ เรามีหน้า <strong>Switch Account</strong> ที่จดจำบัญชีในเครื่อง, หน้า <strong>Clean Login</strong> ที่ไม่มีข้อมูลเก่าค้างเพื่อความปลอดภัย และหน้า <strong>Register</strong> พร้อมระบบตรวจสอบความถูกต้องของฟอร์มครับ</p>`,
      7: `<p><strong>บทพูด:</strong> หน้าจอนี้เป็นภาพหน้าจอจริงที่แคปเจอร์สดๆ จาก iPhone 16 Pro Max Simulator ครับ</p>
          <p>นี่คือหน้า Feed ของ InstaCat จะเห็นว่ามีแถบ Cat Stories ด้านบน, โพสต์ภาพแมวส้มของบัญชี <code>testcat</code> ที่รองรับการเลื่อนดูหลายรูปพร้อม Dots Indicator, และการกดถูกใจแบบ Optimistic UI ที่ผู้ใช้แตะปุ๊บ หัวใจเปลี่ยนสีทันที พร้อมหน้ารายการคอมเมนต์ใต้โพสต์ครับ</p>`,
      8: `<p><strong>บทพูด:</strong> หน้า Explore ช่วยให้ผู้ใช้ค้นพบคอนเทนต์แมวใหม่ๆ ด้วยช่อง Search อัจฉริยะ, แถบตัวกรองสายพันธุ์ เช่น Ragdoll, Funny Cats และตารางภาพแบบมีสัญลักษณ์แยกระหว่างภาพนิ่งและคลิปวิดีโอ Reels ครับ</p>`,
      9: `<p><strong>บทพูด:</strong> หน้าสร้างโพสต์ประกอบด้วย Custom Gallery Picker สไตล์ Instagram สำหรับเลือกรูปหลายใบพร้อมกัน และหน้า Post Composer ที่มีฟิลเตอร์สีแมว 5 อารมณ์, แฮชแท็กสำเร็จรูป และปุ่ม Generate with AI ครับ</p>`,
      10: `<p><strong>บทพูด:</strong> นี่คือไฮไลต์พิเศษของ InstaCat ครับ — <strong>AI Caption Generator</strong></p>
          <p>เราเชื่อมต่อภาพถ่ายเข้ากับ Google Gemini 2.5 Flash Vision Model โดยมีอารมณ์ให้เลือกถึง 4 สไตล์ เช่น น่ารัก, ตลกมีมุก, หรือกวนๆ แสบๆ สไตล์เจ้านายแมว ผู้ใช้สามารถแตะเลือกแคปชันที่ชอบ หรือกดสุ่มใหม่ได้ไม่จำกัดครับ</p>`,
      11: `<p><strong>บทพูด:</strong> หน้า Add Location ใช้ GPS ดึงพิกัดจริงและแปลงเป็นชื่อถนนด้วย OpenStreetMap ผู้ใช้สามารถเลือกสถานที่ที่ตรวจจับได้ หรือพิมพ์ชื่อสถานที่ที่กำหนดเองได้อย่างอิสระครับ</p>`,
      12: `<p><strong>บทพูด:</strong> หน้า Notifications รวมกิจกรรมของผู้ใช้ มี Filter Pills แยกดูเฉพาะ Likes หรือ Comments พร้อมปุ่ม Follow กลับได้ในคลิกเดียว และมีรูป Thumbnail ของโพสต์ที่ถูก Like กำกับไว้ชัดเจนครับ</p>`,
      13: `<p><strong>บทพูด:</strong> หน้า Profile ดึงสถิติจริงจาก PostgreSQL มี Highlights และป้ายสายพันธุ์ ส่วนหน้า Edit Profile สามารถอัปเดตข้อมูล Bio, หมวดหมู่สายพันธุ์ และมีสวิตช์เปิดปิด Public Profile ครับ</p>`,
      14: `<p><strong>บทพูด:</strong> ในการพัฒนาจริงเราพบปัญหา Strapi 5 permission บล็อก, ปัญหา SQLite vs Postgres Port 5433, ปัญหา Document Service Population และปัญหา Localhost IP บน Android ซึ่งเราได้สร้าง Bootstrap Script และ Adaptive Base URL แก้ไขจนสำเร็จครับ</p>`,
      15: `<p><strong>บทพูด:</strong> ในฝั่ง Mobile และ AI เราแก้ปัญหา iOS Keychain Error -34018 ด้วย In-Memory Fallback, ติดตั้ง Image Compression ลดขนาดรูป 75%, ทำความสะอาด JSON Markdown จาก Gemini และจัด Spacing ใหม่ทั้งหมดครับ</p>`,
      16: `<p><strong>บทพูด:</strong> ด้าน QA เรามี Automated Tests 27 ชุด ผ่าน 100%, รัน <code>flutter analyze</code> ผ่าน 0 warning และทดสอบใช้งานจริงบน Simulator ผ่านทั้ง 13 หน้าจออย่างไร้ข้อผิดพลาดครับ</p>`,
      17: `<p><strong>บทพูด:</strong> สรุปบทเรียนสำคัญ: การมี AI เข้ามาช่วยไม่ได้แปลว่าเราลดความสำคัญของวิศวกรลง ในทางกลับกัน วิศวกรต้องเก่งขึ้นในแง่การกำหนดสเปกและสถาปัตยกรรม การผสานมนุษย์กับ AI เช่นนี้ทำให้ได้ซอฟต์แวร์ที่มีคุณภาพสูงและรวดเร็วขึ้นถึง 80% ครับ</p>`,
      18: `<p><strong>บทพูด:</strong> InstaCat พร้อมสำหรับการต่อยอดสู่ระบบ Push Notifications และ Breed Classifier ในอนาคต และวันนี้ระบบทั้ง 13 หน้าจอเสร็จสมบูรณ์พร้อมใช้งานจริงแล้วครับ ขอขอบคุณทุกท่านครับ และยินดีตอบทุกคำถามครับ!</p>`
    };

    const slideTitles = [
      "1. หน้าปก (Title & Hero)",
      "2. ภาพรวมและความเป็นมา (Vision & Scope)",
      "3. สถาปัตยกรรมระบบ 3-Tier Architecture",
      "4. Style การสั่งงาน AI (Prompt Engineering)",
      "5. Agentic Workflow (Pair-Programming Loop)",
      "6. Showcase 1: Authentication Suite (3 จอ)",
      "7. Showcase 2: Feed & Comments (2 จอ)",
      "8. Showcase 3: Explore & Discovery (1 จอ)",
      "9. Showcase 4: Content Studio & Picker (2 จอ)",
      "10. Showcase 5: Gemini AI Caption Studio (1 จอ)",
      "11. Showcase 6: Geolocation & Tagging (1 จอ)",
      "12. Showcase 7: Notifications & Activity (1 จอ)",
      "13. Showcase 8: Profile & Settings (2 จอ)",
      "14. ปัญหาที่พบและการแก้ไข 1 (Backend & DB)",
      "15. ปัญหาที่พบและการแก้ไข 2 (Mobile & AI)",
      "16. การทดสอบและรับประกันคุณภาพ (QA Matrix)",
      "17. บทเรียนสำคัญจากการพัฒนาร่วมกับ AI",
      "18. ทิศทางในอนาคตและสรุปผลงาน (Roadmap & Q&A)"
    ];

    function updateSlide(targetIndex) {
      if (targetIndex < 1 || targetIndex > totalSlides) return;
      
      slides.forEach((slide, idx) => {
        slide.classList.toggle('active', idx + 1 === targetIndex);
      });

      currentSlide = targetIndex;
      document.getElementById('slideCounter').textContent = `${currentSlide} / ${totalSlides}`;
      document.getElementById('progressBar').style.width = `${(currentSlide / totalSlides) * 100}%`;

      document.getElementById('btnPrev').disabled = (currentSlide === 1);
      document.getElementById('btnNext').disabled = (currentSlide === totalSlides);

      document.getElementById('speakerNotesContent').innerHTML = speakerNotesData[currentSlide] || "<p>ไม่มีบทพูดเพิ่มเติมสำหรับสไลด์นี้</p>";

      document.querySelectorAll('.overview-card').forEach((card, idx) => {
        card.classList.toggle('current', idx + 1 === currentSlide);
      });
    }

    const overviewGrid = document.getElementById('overviewGrid');
    slideTitles.forEach((title, idx) => {
      const card = document.createElement('div');
      card.className = `overview-card ${idx + 1 === currentSlide ? 'current' : ''}`;
      card.innerHTML = `
        <div class="overview-card-num">Slide ${idx + 1}</div>
        <div class="overview-card-title">${title}</div>
      `;
      card.addEventListener('click', () => {
        updateSlide(idx + 1);
        toggleOverview(false);
      });
      overviewGrid.appendChild(card);
    });

    function toggleNotes() {
      const panel = document.getElementById('speakerNotesPanel');
      panel.classList.toggle('visible');
      document.getElementById('btnNotes').classList.toggle('active', panel.classList.contains('visible'));
    }

    function toggleOverview(force) {
      const modal = document.getElementById('overviewModal');
      const isVisible = force !== undefined ? force : !modal.classList.contains('visible');
      modal.classList.toggle('visible', isVisible);
      document.getElementById('btnOverview').classList.toggle('active', isVisible);
    }

    function toggleFullscreen() {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => console.log(err));
      } else {
        document.exitFullscreen();
      }
    }

    document.getElementById('btnPrev').addEventListener('click', () => updateSlide(currentSlide - 1));
    document.getElementById('btnNext').addEventListener('click', () => updateSlide(currentSlide + 1));
    document.getElementById('btnNotes').addEventListener('click', toggleNotes);
    document.getElementById('btnOverview').addEventListener('click', () => toggleOverview());
    document.getElementById('btnCloseOverview').addEventListener('click', () => toggleOverview(false));
    document.getElementById('btnFullscreen').addEventListener('click', toggleFullscreen);
    document.getElementById('btnPrint').addEventListener('click', () => window.print());

    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' || e.key === ' ' || e.key === 'PageDown') {
        e.preventDefault();
        updateSlide(currentSlide + 1);
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        e.preventDefault();
        updateSlide(currentSlide - 1);
      } else if (e.key === 'Home') {
        e.preventDefault();
        updateSlide(1);
      } else if (e.key === 'End') {
        e.preventDefault();
        updateSlide(totalSlides);
      } else if (e.key.toLowerCase() === 's') {
        e.preventDefault();
        toggleNotes();
      } else if (e.key.toLowerCase() === 'o') {
        e.preventDefault();
        toggleOverview();
      } else if (e.key.toLowerCase() === 'f') {
        e.preventDefault();
        toggleFullscreen();
      } else if (e.key.toLowerCase() === 'p') {
        e.preventDefault();
        window.print();
      } else if (e.key === 'Escape') {
        toggleOverview(false);
      }
    });

    updateSlide(1);
  </script>
</body>
</html>
"""

with open('/Users/panya/Documents/ai-engineer-course/presentation/index.html', 'w', encoding='utf-8') as f:
    f.write(HTML_CONTENT)

print("Updated presentation/index.html successfully!")
