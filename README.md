# InstaCat 🐾

> A full-stack cat social media mobile application built with **Flutter**, **Strapi 5**, and **PostgreSQL**.

📖 **[Full Documentation / คู่มือระบบฉบับละเอียดทั้งหมด](docs/README.md)**

---

## 📌 Features

- **Authentication & Security**
  - Registration with username, email, and password validation.
  - Login & One-Tap Quick Login.
  - JWT session persistence with auto-refresh via secure storage (`flutter_secure_storage`).
  - Change password & account logout with confirmation dialogs.
- **Feed & Exploration**
  - Public Feed & Following Feed with pagination and pull-to-refresh.
  - Multi-image posts (1–10 images per post) with carousel and image compression.
  - Optimistic like / unlike toggle.
  - Author post management (edit caption, delete post).
- **Profile & Social**
  - Profile screen displaying user stats (Posts, Followers, Following), bio, badges, and story highlights.
  - Tabbed grid of user posted photos with full detail view and pull-to-refresh.
  - Follow / Unfollow functionality.
  - Edit Profile (display name, bio, public/private account switch, avatar upload).
- **Notifications & Direct Messages UI**
  - Categorized notifications (Likes, Comments, Follows, Treats).

---

## 🏗 Architecture

```
ai-software-engineer-project/
├── frontend/       # Flutter mobile application (iOS, Android)
│   ├── lib/
│   │   ├── models/       # Data models & JSON serialization
│   │   ├── screens/      # Application screens & modals
│   │   ├── services/     # API client, Auth, Post, Profile services
│   │   ├── theme/        # App colors, typography & Material 3 theme
│   │   └── widgets/      # Reusable UI components
│   └── test/             # Unit and widget test suite
├── backend/        # Strapi 5 Headless CMS (TypeScript)
│   ├── src/
│   │   ├── api/          # Feed, Post, PostLike, Follow, Profile APIs
│   │   ├── extensions/   # User schema extensions
│   │   └── index.ts      # Automated role permission bootstrap
│   └── config/           # Database, server & plugin configurations
└── spec/           # Project specifications & documentation
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.10.7`
- Node.js `^18.x` or `^20.x`
- PostgreSQL `^14.x`

### 1. Backend Setup (Strapi 5)
```bash
cd backend
npm install
cp .env.example .env
# Configure your PostgreSQL database credentials in .env
npm run build
npm run dev
```
The Strapi server will start at `http://localhost:1337`.

### 2. Frontend Setup (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

### 3. Running Tests
```bash
cd frontend
flutter test
```
