# InstaCat 🐾

> A full-stack cat social media mobile application built with **Flutter**, **Strapi 5**, **PostgreSQL**, and **Google Gemini AI**.

📖 **[Full Documentation / คู่มือระบบฉบับละเอียดทั้งหมด](docs/README.md)**

---

## 📌 Features

- **Authentication & Security**
  - Registration with username, email, and password validation.
  - Multi-Account Switcher (`SwitchAccountScreen`) & Quick Login.
  - JWT session persistence with auto-refresh via secure storage (`flutter_secure_storage`).
  - Change password & account logout with confirmation dialogs.
- **Feed & Exploration**
  - Public Feed & Following Feed with pagination and pull-to-refresh.
  - Multi-image posts (1–10 images per post) with carousel and image compression.
  - Optimistic like / unlike toggle.
  - Author post management (edit caption, location, delete post).
- **AI-Powered Post Creation**
  - **AI Caption Assistant**: Powered by **Google Gemini 2.5 Flash**, generates cat captions in 5 tones (Cute, Funny, Sarcastic, Poetic, Trendy) with hashtags.
  - **Location Picker**: Search real-world places full-screen with Google Places / OpenStreetMap, or use GPS location detection.
  - **Custom Gallery Picker**: Instagram-style multi-selection photo picker from device photo library.
  - **Tag Friends**: Tag users in posts.
- **Comments & Activity**
  - Real-time comment threads on posts.
  - In-app notifications for likes, comments, and new followers.
- **Profile & Social**
  - Profile screen displaying user stats (Posts, Followers, Following), bio, and post grid.
  - Follow / Unfollow system with self-follow protection.
  - Edit Profile (display name, bio, public/private account switch, avatar upload, and username).
- **In-App Browser**
  - Built-in webview for opening external links safely within the application.

---

## 🏗 Architecture

```
ai-software-engineer-project/
├── frontend/       # Flutter mobile application (iOS, Android)
│   ├── lib/
│   │   ├── models/       # Data models & JSON serialization
│   │   ├── screens/      # Application screens & modals
│   │   ├── services/     # API client, Auth, Post, Profile, AI, Location services
│   │   ├── theme/        # App colors, typography & Material 3 theme
│   │   └── widgets/      # Reusable UI components
│   └── test/             # Unit and widget test suite (27 tests)
├── backend/        # Strapi 5 Headless CMS (TypeScript)
│   ├── src/
│   │   ├── api/          # Feed, Post, PostLike, Comment, Notification, AI Caption APIs
│   │   ├── extensions/   # User schema extensions
│   │   └── index.ts      # Automated role permission bootstrap
│   └── config/           # Database, server & plugin configurations
└── docs/           # Complete technical documentation & setup guides
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.10.7`
- Node.js `^18.x` or `^20.x`
- PostgreSQL `^14.x`
- Google Cloud API Key (Optional: for Google Maps / Places & Gemini AI)

### 1. Backend Setup (Strapi 5)
```bash
cd backend
npm install
cp .env.example .env
# Configure your PostgreSQL database credentials and GEMINI_API_KEY in .env
npm run build
npm run dev
```
The Strapi server will start at `http://localhost:1337`.

### 2. Frontend Setup (Flutter)
```bash
cd frontend
flutter pub get
flutter run
# Or with Google Maps key: flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key
```

### 3. Running Tests
```bash
cd frontend
flutter test
```
