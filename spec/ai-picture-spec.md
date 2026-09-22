# InstaCat — Development Specification

> **Project:** InstaCat  
> **Purpose:** MVP Mobile Social App for teaching App Development with AI  
> **Frontend:** Flutter  
> **Backend:** Strapi 5  
> **Database:** PostgreSQL  
> **Architecture:** Flutter → Strapi REST API → PostgreSQL / Media Storage

---

## 1. Project Overview

InstaCat is a mobile social application for cat lovers, conceptually similar to Instagram but intentionally limited to an MVP scope for teaching and demonstrating AI-assisted application development.

The existing project already has this structure:

```text
InstaCat/
├── backend/    # Existing Strapi project
└── frontend/   # Existing Flutter project
```

### Critical project rule

**Do not recreate the project.**

The existing `frontend/` and `backend/` projects are the starting point and must be preserved.

The Flutter UI has already been partially designed and implemented. Existing UI is the **visual source of truth**.

The goal is to connect the existing Flutter UI to a real Strapi backend and PostgreSQL database, not to replace the application with a newly generated UI.

---

# 2. Project Goals

The MVP must provide:

- User registration
- User login
- Logout
- Persistent authenticated session
- Password change
- User profile
- Profile image
- Display name
- Bio
- Public / Private profile
- Create image posts
- Multiple images per post
- Caption
- Edit own posts
- Delete own posts
- Like / Unlike
- Follow / Unfollow
- Public feed
- Following feed
- Public user profiles
- Post detail
- Image carousel for multi-image posts
- Image resize/compression before upload
- AI Photo Studio before posting
- AI image enhancement/editing from a user prompt
- AI-assisted prompt generation for image editing
- Strapi Admin Portal
- PostgreSQL persistence

---

# 3. Explicit MVP Scope

## 3.1 Included

### Authentication

- Register
- Login
- Logout
- Current user
- Access token
- Refresh token
- Session persistence
- Change password

### Profile

- Username
- Email
- Display name
- Bio
- Avatar
- Public / Private profile
- Posts count
- Followers count
- Following count

### Posts

- Image only
- 1–10 images per post
- Caption
- Create
- Read
- Update
- Delete
- Multi-image viewer

### AI Photo Studio

The MVP includes AI-assisted image editing before a post is published. The feature is focused on **image-to-image editing**, not text-to-image generation from scratch.

- Upload/select an image before posting
- Request one-tap AI enhancement
- Enter a natural-language editing prompt
- Ask AI to generate an editing prompt from the selected image and optional user intent
- Let the user review and edit the generated prompt before applying it
- Send the image + final prompt to the backend AI service
- Display generated result
- Compare original and edited image
- Accept edited image as the post image
- Retry editing with another prompt
- Keep original image available during the current editing session
- Support AI editing for each selected image before creating the post

### Social

- Like
- Unlike
- Follow
- Unfollow

### Feed

- Public feed
- Following feed
- Pagination
- Infinite scroll
- Pull to refresh

### Admin

Use the existing Strapi Admin Panel for:

- User management
- Post management
- Media management
- Likes
- Follows
- Moderation

---

# 4. Explicitly Out of Scope

Do **not** implement the following in the MVP:

- Video
- Reels
- Stories
- Live streaming
- Comments
- Direct messages
- Chat
- Push notifications
- Hashtags
- Mentions
- Saved posts
- Post sharing
- Instagram/Facebook OAuth
- Google Login
- Apple Login
- Email verification
- Phone verification
- OTP
- Two-factor authentication
- Recommendation algorithm
- Full-text search engine
- Text-to-image generation from scratch
- AI video generation/editing
- AI filters that require a separate real-time rendering engine
- Advanced manual image editing such as layer-based editing, masks, brushes, curves, or Photoshop-style tools
- Video processing

The architecture should remain extensible for future features, but these features must not increase MVP complexity.

---

# 5. High-Level Architecture

```text
┌──────────────────────────────┐
│      Flutter Mobile App     │
│         frontend/           │
└──────────────┬───────────────┘
               │
               │ HTTPS / REST
               ▼
┌──────────────────────────────┐
│          Strapi 5            │
│          backend/            │
└──────────────┬───────────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
┌──────────────┐  ┌──────────────┐
│ PostgreSQL   │  │ Media Storage│
│    Data      │  │ / Upload     │
└──────────────┘  └──────────────┘
```

### Important architecture rule

Flutter must **never connect directly to PostgreSQL**.

Correct:

```text
Flutter
   ↓
Strapi REST API
   ↓
PostgreSQL
```

Incorrect:

```text
Flutter
   ↓
PostgreSQL
```

## 5.1 AI Architecture

AI image editing must be implemented through the backend. **Flutter must not contain or expose AI provider API keys.**

Recommended architecture:

```text
Flutter
   │
   │ image + prompt / edit request
   ▼
Strapi 5
   │
   │ AI Service
   ▼
AI Image Provider
   │
   │ generated image
   ▼
Strapi Media Storage
   │
   ▼
Flutter
```

The backend should use a provider-agnostic adapter so the AI provider can be changed later without changing the Flutter application.

Recommended logical structure:

```text
backend/src/services/ai/
├── ai-image.service.ts
├── ai-prompt.service.ts
├── providers/
│   ├── base.provider.ts
│   └── <provider>.provider.ts
└── ai.types.ts
```

Do not hard-code a specific AI vendor into Flutter.

---

# 6. Existing Project Rules

## 6.1 Do not recreate projects

Do not create a new Flutter project.

Do not create a new Strapi project.

Do not reset or overwrite the existing application.

## 6.2 Do not change root structure

Keep:

```text
backend/
frontend/
```

Do not rename them.

Do not move them to:

```text
mobile/
server/
app/
api/
```

unless explicitly requested by the project owner.

## 6.3 Preserve existing Flutter UI

Existing UI must be treated as the source of truth.

Do not replace existing:

- Screens
- Colors
- Typography
- Navigation
- Components
- Spacing
- Icons
- Assets
- Layouts

unless required for functionality or explicitly requested.

## 6.4 Reuse existing code

Before creating a new service, widget, model, provider, repository, or utility:

1. Search for an existing implementation.
2. Reuse it if appropriate.
3. Extend it instead of duplicating it.

---

# 7. First Task for Cursor

Before modifying code, inspect both projects.

### Frontend audit

Inspect:

- Flutter version
- Dart version
- `pubspec.yaml`
- Current folder structure
- Routing
- State management
- Network/API layer
- Authentication code
- Models
- Screens
- Widgets
- Theme
- Fonts
- Assets
- Mock data
- TODOs
- Existing services

### Backend audit

Inspect:

- Strapi version
- Node.js requirements
- `package.json`
- Database configuration
- PostgreSQL configuration
- Existing plugins
- Users & Permissions
- Upload configuration
- Content Types
- Controllers
- Routes
- Services
- Policies
- Middleware
- Environment variables
- TODOs

### Audit output

Before implementation, produce:

1. Existing architecture
2. Existing features
3. Existing Flutter screens
4. Existing backend APIs
5. Existing content types
6. Existing reusable components
7. Missing features
8. Potential conflicts
9. Recommended implementation order

Do not rewrite the application during the audit.

---

# 8. Technology Stack

## Frontend

- Flutter
- Dart
- Existing state management where practical
- Existing routing where practical
- Dio or existing HTTP client
- `flutter_secure_storage` for authentication tokens
- Image picker package appropriate to the existing project
- Image compression package appropriate to the existing project
- Cached image package appropriate to the existing project

Do not add packages without a concrete reason.

## Backend

- Strapi 5
- Node.js
- TypeScript where supported by the existing Strapi project
- Users & Permissions
- Upload / Media Library
- REST API

## Database

- PostgreSQL

## Admin

- Strapi Admin Panel

No separate admin frontend is required for the MVP.

---

# 9. Authentication

Use Strapi Users & Permissions.

## Required operations

```text
POST /api/auth/local/register
POST /api/auth/local
POST /api/auth/change-password
POST /api/auth/refresh
POST /api/auth/logout
```

Do not implement custom password hashing.

Do not create a second authentication system outside Strapi.

---

# 10. Registration

Registration must require only the minimum information needed.

Example:

```json
{
  "username": "panya",
  "email": "panya@example.com",
  "password": "Password123"
}
```

Requirements:

- Registration enabled
- Email confirmation disabled
- No email verification
- No phone verification
- User can log in immediately
- Default role = Authenticated

Default profile:

```text
isPublic = true
```

unless existing business rules specify otherwise.

---

# 11. Authentication Token Storage

The Flutter app must store authentication tokens securely.

Preferred:

```text
flutter_secure_storage
```

Store:

```text
accessToken
refreshToken
```

Do not store tokens as the primary auth mechanism in:

```text
SharedPreferences
```

Do not log tokens.

Do not include tokens in URLs.

---

# 12. Token Refresh

The Flutter API client must support refresh-token flow.

When a protected request returns:

```text
401 Unauthorized
```

the client should:

1. Detect token expiration.
2. Refresh the access token.
3. Save the new token securely.
4. Retry the original request.
5. If refresh fails:
   - Clear authentication state.
   - Navigate to Login.

Avoid infinite refresh loops.

---

# 13. User Profile

Use the built-in Strapi User model and extend it with application profile fields.

Recommended fields:

```text
displayName : string
bio         : text
avatar      : media (single)
isPublic    : boolean
```

Do not duplicate:

- password
- confirmation token
- reset token
- authentication secrets

into a custom user content type.

---

# 14. Profile API

## Current user

```text
GET /api/me
```

Example response:

```json
{
  "documentId": "user-document-id",
  "username": "panya",
  "email": "panya@example.com",
  "displayName": "Panya",
  "bio": "Cat lover 🐱",
  "avatar": {
    "url": "https://..."
  },
  "isPublic": true,
  "postsCount": 12,
  "followersCount": 30,
  "followingCount": 25
}
```

Do not expose password or private authentication fields.

## Update current user

```text
PUT /api/me
```

Example:

```json
{
  "displayName": "Panya Kotoom",
  "bio": "Cat lover",
  "isPublic": true,
  "avatar": 123
}
```

The backend must automatically use the authenticated user.

The Flutter client must not be able to update another user's profile through this endpoint.

## Public profile

```text
GET /api/profiles/:username
```

Response should include:

- username
- displayName
- bio
- avatar
- isPublic
- postsCount
- followersCount
- followingCount
- isFollowing

---

# 15. Profile Privacy

## Public

When:

```text
isPublic = true
```

Other users can:

- View the profile
- View public posts
- See avatar
- See display name
- See bio
- Follow the user

## Private

When:

```text
isPublic = false
```

Other users can still identify the account, but:

- Its posts must not appear in public feed.
- Its posts must not be publicly readable.

For MVP there is no follow approval request system.

---

# 16. Post Content Type

Create a `Post` content type.

Fields:

```text
caption
author
images
moderationStatus
```

Recommended schema:

```text
caption
  type: text
  required: false
  maxLength: 2200

author
  many-to-one → User

images
  media
  multiple: true
  required: true

moderationStatus
  enum:
    - visible
    - hidden
```

Default:

```text
moderationStatus = visible
```

Image count:

```text
1–10 images
```

No video field.

---

# 17. Post Ownership

The backend must determine the author from the authenticated request.

Example:

```ts
const user = ctx.state.user;
```

The Flutter client must NOT be trusted to provide the author.

Incorrect:

```json
{
  "author": 123
}
```

Correct:

```json
{
  "caption": "My cat ❤️",
  "images": [12, 13]
}
```

Backend:

```text
author = authenticated user
```

---

# 18. Post APIs

## Create

```text
POST /api/posts
```

## Read

```text
GET /api/posts/:documentId
```

## Update

```text
PUT /api/posts/:documentId
```

## Delete

```text
DELETE /api/posts/:documentId
```

Only the owner or administrator can update/delete a post.

---

# 19. Post Response

Do not force the Flutter application to understand complicated raw Strapi response structures.

Use an application-level response model such as:

```json
{
  "documentId": "abc123",
  "caption": "My cat ❤️",
  "createdAt": "2026-09-20T04:20:00.000Z",
  "author": {
    "documentId": "user123",
    "username": "panya",
    "displayName": "Panya",
    "avatar": {
      "url": "https://..."
    }
  },
  "images": [
    {
      "id": 1,
      "url": "https://...",
      "width": 1080,
      "height": 1350
    }
  ],
  "likeCount": 10,
  "isLiked": true
}
```

Flutter should convert API responses into Dart model classes.

---

# 20. Multi-Image Post

A post can contain:

```text
1–10 images
```

The Flutter UI must support:

- Horizontal swipe
- Image carousel / PageView
- Current image indicator
- Correct image ordering
- Post detail viewer

Example:

```text
1 / 4
2 / 4
3 / 4
4 / 4
```

Image order must be preserved.

---

# 21. Post Creation Flow

Required flow:

```text
Select images
      ↓
Validate count
      ↓
Resize
      ↓
Compress
      ↓
Upload to Strapi
      ↓
Receive media IDs
      ↓
Create Post
      ↓
Refresh / update Feed
```

The user should not upload huge original images when a smaller optimized version is sufficient.

---

# 22. Image Optimization

Image processing should happen on the Flutter client before upload.

Recommended target:

```text
Maximum long edge ≈ 2048 px
JPEG quality ≈ 80–85
```

Avatar:

```text
≈ 512 × 512
```

Requirements:

- Preserve aspect ratio
- Never stretch images
- Reduce file size
- Handle portrait and landscape
- Handle image picker cancellation
- Handle permissions
- Show upload progress
- Clean up temporary files where appropriate

---

# 23. Image Upload

Use Strapi Upload / Media Library.

Do not store raw image binaries inside PostgreSQL.

Recommended flow:

```text
POST /api/upload
```

then:

```text
POST /api/posts
{
  "caption": "...",
  "images": [101, 102, 103]
}
```

If post creation fails after upload, clean up orphaned media only when it is safe and the media is not referenced elsewhere.

---

# 24. Like System

Do not use only an integer like counter as the source of truth.

Create:

```text
PostLike
```

Fields:

```text
user
post
```

Relations:

```text
User 1 --- N PostLike
Post 1 --- N PostLike
```

Uniqueness:

```text
(user, post)
```

must be unique.

---

# 25. Like APIs

## Like

```text
POST /api/posts/:documentId/like
```

## Unlike

```text
DELETE /api/posts/:documentId/like
```

Response:

```json
{
  "liked": true,
  "likeCount": 12
}
```

Repeated like requests must not create duplicate records.

---

# 26. Follow System

Create:

```text
Follow
```

Fields:

```text
follower
following
```

Example:

```text
User A → User B
```

means:

```text
follower  = A
following = B
```

Rules:

- No duplicate follow
- A user cannot follow themselves

Recommended unique constraint:

```text
(follower, following)
```

---

# 27. Follow APIs

## Follow

```text
POST /api/users/:documentId/follow
```

## Unfollow

```text
DELETE /api/users/:documentId/follow
```

Response:

```json
{
  "following": true,
  "followersCount": 123
}
```

---

# 28. Public Feed

Endpoint:

```text
GET /api/feed/public?page=1&pageSize=10
```

Rules:

- Public users only
- Visible posts only
- Newest first
- Pagination required
- Include author
- Include images
- Include like count
- Include current user's `isLiked` when authenticated
- Guest users can read public feed

---

# 29. Following Feed

Endpoint:

```text
GET /api/feed/following?page=1&pageSize=10
```

Rules:

- Authentication required
- Show posts from followed users
- Respect privacy rules
- Show newest first

For the main MVP, Public Feed should remain the primary discovery experience.

---

# 30. Feed Pagination

Default:

```text
pageSize = 10
```

Maximum:

```text
pageSize = 20
```

Do not load all posts at once.

Flutter should implement:

- Initial load
- Infinite scroll
- Pull to refresh
- Loading-more state
- Empty state
- Error state

---

# 31. Feed Performance

Do not introduce unnecessary infrastructure.

Avoid:

- Redis
- Kafka
- Elasticsearch
- Microservices
- Event sourcing
- CQRS

for the MVP.

Avoid N+1 queries.

Prefer:

- Relations/population
- Batch queries
- Efficient service-level serialization

---

# 32. Admin Portal

Use the existing Strapi Admin Panel.

The project does not need a separate Admin Flutter application.

Administrator should be able to manage:

## Users

- View users
- Edit users
- Block/unblock users
- Manage profile data
- Delete users when necessary

## Posts

- View posts
- Edit posts
- Hide posts
- Delete posts

## Media

- View uploaded images
- Remove unused media
- Inspect uploads

## Social data

- Inspect PostLike records
- Inspect Follow records

---

# 33. Moderation

Use:

```text
moderationStatus
```

with:

```text
visible
hidden
```

Public Feed only returns:

```text
moderationStatus = visible
```

An administrator can change:

```text
visible → hidden
hidden → visible
```

---

# 34. Blocked Users

Use Strapi's built-in user blocked status.

Blocked users:

- Cannot use protected APIs normally
- Cannot log in/use the authenticated app flow
- Their content should not appear in normal feed

Do not create a second `isBlocked` field unless there is a concrete requirement.

---

# 35. API Endpoints

## Authentication

```text
POST /api/auth/local/register
POST /api/auth/local
POST /api/auth/change-password
POST /api/auth/refresh
POST /api/auth/logout
```

## Profile

```text
GET /api/me
PUT /api/me
GET /api/profiles/:username
```

## Feed

```text
GET /api/feed/public
GET /api/feed/following
```

## Posts

```text
POST   /api/posts
GET    /api/posts/:documentId
PUT    /api/posts/:documentId
DELETE /api/posts/:documentId
```

## Likes

```text
POST   /api/posts/:documentId/like
DELETE /api/posts/:documentId/like
```

## Follows

```text
POST   /api/users/:documentId/follow
DELETE /api/users/:documentId/follow
```

## Upload

Use the Strapi Upload API.

---

# 36. API Response Standard

Application-specific APIs should use a consistent response structure.

### Success

```json
{
  "data": {},
  "meta": {}
}
```

### Error

```json
{
  "error": {
    "code": "POST_NOT_FOUND",
    "message": "Post not found"
  }
}
```

Recommended error codes:

```text
AUTH_REQUIRED
INVALID_CREDENTIALS
USER_NOT_FOUND
POST_NOT_FOUND
POST_FORBIDDEN
INVALID_IMAGE_COUNT
INVALID_MEDIA
ALREADY_LIKED
NOT_LIKED
ALREADY_FOLLOWING
NOT_FOLLOWING
SELF_FOLLOW_NOT_ALLOWED
```

---

# 37. HTTP Status Codes

Use proper HTTP status codes:

```text
200 OK
201 Created
204 No Content
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict
422 Unprocessable Entity
429 Too Many Requests
500 Internal Server Error
```

Do not return HTTP 200 for every error.

---

# 38. Flutter Architecture

The existing Flutter architecture takes priority.

If the project already has an established structure, extend it rather than replacing it.

Preferred logical flow:

```text
UI
 ↓
Provider / Controller / State
 ↓
Repository
 ↓
API Client
 ↓
Strapi REST API
```

Widgets should not contain direct HTTP/database logic.

---

# 39. Recommended Flutter Responsibilities

## API Client

Responsible for:

- Base URL
- Authorization
- Refresh token
- HTTP errors
- Timeouts
- Multipart uploads

## Repository

Responsible for:

- Auth API
- Feed API
- Post API
- Profile API
- Social API
- Upload API

## State layer

Responsible for:

- Loading
- Data
- Error
- Refresh
- Pagination
- User interaction state

## UI

Responsible for:

- Rendering
- User interaction
- Navigation
- Form validation display
- Visual state

---

# 40. Flutter Environment

Do not hardcode API URLs throughout the app.

Use a centralized configuration such as:

```text
API_BASE_URL
```

Example development:

```text
http://localhost:1337/api
```

Android emulator may require:

```text
http://10.0.2.2:1337/api
```

iOS simulator can use:

```text
http://127.0.0.1:1337/api
```

Production:

```text
https://api.example.com/api
```

Use environment/configuration appropriate to the existing Flutter setup.

---

# 41. Image URL Handling

Strapi may return:

- relative URLs
- absolute URLs

Flutter should have one centralized helper to resolve media URLs.

Do not concatenate URLs throughout individual widgets.

Example logical helper:

```text
ImageUrlHelper.resolve(...)
```

---

# 42. Loading / Error / Empty States

Every async screen should handle:

### Loading

- Initial loading
- Loading more
- Uploading
- Updating
- Deleting

### Error

- Network failure
- Timeout
- Unauthorized
- Forbidden
- Server error
- Upload failure

### Empty

Examples:

```text
No posts yet
No followers yet
No following yet
No posts from people you follow
```

Do not leave blank screens when the state is empty.

---

# 43. Like UX

Use optimistic UI where practical.

Example:

```text
♡ → ❤️
10 → 11
```

If API fails:

```text
❤️ → ♡
11 → 10
```

The state must eventually match the server.

Prevent duplicate requests while a like/unlike action is pending when necessary.

---

# 44. Follow UX

Example:

```text
Follow → Following
```

After successful follow:

- Update button
- Update local follower count
- Update follow state

After unfollow:

- Update button
- Update local follower count

---

# 45. Profile UI

Recommended information:

```text
Avatar

Display Name
Username
Bio

Posts    Followers    Following

Edit Profile / Follow

Post Grid
```

Own profile:

```text
Edit Profile
Change Password
```

Other profile:

```text
Follow / Following
```

Use the existing design instead of creating a new visual style.

---

# 46. Post UI

Recommended structure:

```text
Avatar   Username   More

Image Carousel

Like        ...

Like count

Caption

Created time
```

For own post:

```text
More
 ├── Edit
 └── Delete
```

For other user's post:

```text
More
 └── Follow / Unfollow
```

Do not add comments in MVP.

---

# 47. Post Editing

Owner can modify:

- Caption
- Images
- Image order

Image count must remain:

```text
1–10
```

Recommended edit process:

```text
Existing images
      +
New images
      ↓
Prepare
      ↓
Upload new media if needed
      ↓
Update post
```

---

# 48. Delete Post

Delete workflow:

```text
Tap Delete
   ↓
Confirmation
   ↓
DELETE API
   ↓
Success
   ↓
Remove from current UI
```

Do not silently delete without confirmation.

---

# 49. AI Photo Studio

## 49.1 Feature Purpose

AI Photo Studio allows the user to improve or creatively edit an image **before publishing a post**.

The user can either:

1. Write an editing prompt themselves.
2. Ask AI to generate an editing prompt based on the selected image and optional user intention.
3. Use a one-tap enhancement preset when they do not want to write a prompt.

The user must always be able to review the prompt before sending the final edit request.

---

## 49.2 Core User Flow

```text
Create Post
    ↓
Select Image
    ↓
Resize / Compress
    ↓
AI Photo Studio
    ├── Improve Photo
    ├── Write Prompt
    └── Generate Prompt with AI
            ↓
      Review / Edit Prompt
            ↓
      Apply AI Edit
            ↓
      Generate Result
            ↓
      Compare Original / Result
            ↓
      Use This Image
            ↓
      Caption
            ↓
      Publish Post
```

AI editing is optional. A user must still be able to publish the original image without AI.

---

## 49.3 AI Editing Modes

### Mode A — Enhance Photo

Provide simple preset actions without requiring the user to understand prompting.

Examples:

```text
Improve lighting
Improve sharpness
Reduce noise
Improve colors
Brighten subject
Enhance details
Upscale image
```

The backend may map these actions to provider-specific prompts or parameters.

### Mode B — Custom Prompt

The user writes a natural-language instruction.

Examples:

```text
Make the photo brighter and warmer.

Make the cat look like it is sitting in a cozy cafe.

Improve the lighting but keep the cat's appearance natural.

Create a soft cinematic style while keeping the original cat and background composition.
```

The application must make it clear that the prompt is an **editing instruction for the existing image**, not a request to create a completely unrelated image.

### Mode C — AI Prompt Generator

The user selects an image and optionally describes their intention:

```text
User intention:
"อยากให้รูปดูน่ารักและอบอุ่นขึ้น"
```

AI analyzes the source image and produces an editable prompt, for example:

```text
Enhance the existing cat photo with warm soft lighting,
slightly brighter colors, gentle contrast and a cozy atmosphere.
Preserve the cat's identity, pose, fur pattern and original composition.
```

The user can:

- Accept the generated prompt
- Edit the prompt
- Regenerate the prompt
- Cancel

Only the final user-approved prompt is sent to the image-editing operation.

---

## 49.4 Prompt Generator Requirements

Input:

```text
source image
optional user intention
optional edit style
```

Optional style examples:

```text
Natural
Cute
Warm
Cinematic
Studio
Bright
Soft
Colorful
```

Output:

```text
editable prompt
```

The AI prompt generator should be instructed to:

- Describe edits rather than inventing unrelated content.
- Preserve the main subject when requested.
- Preserve important visual characteristics.
- Avoid unnecessary changes.
- Produce a clear prompt suitable for an image-to-image editing model.
- Prefer concise but sufficiently detailed instructions.

The generated prompt is not automatically applied without user confirmation.

---

## 49.5 AI Edit Request

The backend should expose an application API such as:

```text
POST /api/ai/image-edit
```

Request concept:

```json
{
  "sourceMediaId": 123,
  "prompt": "Make the photo brighter and warmer while preserving the cat's appearance.",
  "operation": "edit"
}
```

Optional prompt generation endpoint:

```text
POST /api/ai/generate-edit-prompt
```

Request concept:

```json
{
  "sourceMediaId": 123,
  "userIntent": "อยากให้รูปดูอบอุ่นและน่ารักขึ้น",
  "style": "warm"
}
```

The exact provider payload must remain inside the backend AI adapter.

Flutter must never send an AI provider API key.

---

## 49.6 AI Job Model

Because image generation/editing may take longer than a normal API request, the backend should support an asynchronous job model where the selected provider requires it.

Recommended content type:

```text
AIImageJob
```

Fields:

```text
status
operation
sourceMedia
prompt
resultMedia
errorMessage
provider
createdBy
```

Status:

```text
queued
processing
completed
failed
cancelled
```

Operation:

```text
enhance
edit
generate_prompt
```

For `generate_prompt`, `resultMedia` is not required; store the generated prompt in the job result or response metadata.

---

## 49.7 AI Job API

Recommended endpoints:

```text
POST /api/ai/image-edit
GET  /api/ai/jobs/:documentId
POST /api/ai/jobs/:documentId/cancel
POST /api/ai/generate-edit-prompt
```

Example response:

```json
{
  "jobId": "abc123",
  "status": "processing"
}
```

Flutter can poll the job status when asynchronous processing is used.

If the selected AI provider supports a fast synchronous operation and the implementation is reliable, the backend may return the result directly. The client architecture should still support job-based responses.

---

## 49.8 AI Result

Completed edit response should contain:

```text
jobId
status
original image
edited image
prompt
createdAt
```

Example:

```json
{
  "jobId": "abc123",
  "status": "completed",
  "prompt": "Make the photo brighter and warmer...",
  "resultMedia": {
    "id": 456,
    "url": "https://..."
  }
}
```

---

## 49.9 Original vs Edited Image

The UI should provide a simple comparison experience.

Possible interactions:

```text
Original | AI Result
```

or:

```text
Before → After
```

Minimum MVP requirement:

- Show original image
- Show generated image
- Allow user to select the generated image
- Allow user to discard it and return to the original

The app does not need a professional before/after editor.

---

## 49.10 Accepting AI Result

When the user selects:

```text
Use This Image
```

the generated media becomes the image used by the post composer.

Recommended flow:

```text
Original Media
      ↓
AI Edit
      ↓
Generated Media
      ↓
User selects result
      ↓
Post Composer uses Generated Media
```

The application should not create the final `Post` until the user taps the normal Publish action.

This allows the user to:

- Edit again
- Change caption
- Cancel AI changes
- Add more images
- Continue editing

---

## 49.11 Multiple Images

If a post contains multiple images, each image may be edited independently.

Example:

```text
Image 1 → AI Edit → Result 1
Image 2 → Original
Image 3 → AI Edit → Result 3
```

The user should be able to choose which image is currently being edited.

Do not run all image edits automatically without explicit user action because it may create unnecessary AI usage and cost.

---

## 49.12 AI Prompt UX

Inside the Create Post flow, provide an optional action such as:

```text
✨ AI แต่งภาพ
```

Within the AI screen:

```text
┌──────────────────────────────┐
│         Image Preview        │
└──────────────────────────────┘

What do you want to change?
┌──────────────────────────────┐
│ ทำให้ภาพสว่างและอบอุ่นขึ้น   │
└──────────────────────────────┘

[ ✨ Generate Prompt ]

AI Generated Prompt
┌──────────────────────────────┐
│ Enhance the existing cat...  │
│ Preserve the original...     │
└──────────────────────────────┘

[ Edit Prompt ] [ Apply AI Edit ]
```

The exact UI must follow the existing InstaCat design language.

---

## 49.13 Prompt Suggestions

Provide optional predefined actions to make the AI feature easy for beginners.

Examples:

```text
✨ Enhance
☀️ Brighter
🎨 Better Colors
🌙 Moody
🐱 Cute
🎬 Cinematic
🏠 Cozy
📷 Studio
```

Selecting one may prefill an editable prompt.

Example:

```text
Enhance the existing cat photo with natural lighting,
clearer details and balanced colors while preserving
its original appearance.
```

---

## 49.14 AI Image Quality Guardrails

The editing prompt should encourage the AI to preserve the important subject and overall composition when that is the user's intention.

Examples of useful constraints:

```text
Preserve the original cat.
Preserve the cat's fur pattern and markings.
Keep the original pose unless explicitly requested otherwise.
Do not add unnecessary objects.
Do not remove the main subject.
```

These are prompt-level guidelines, not guarantees. The UI should make it possible for the user to discard an unwanted result and try again.

---

## 49.15 AI Provider Abstraction

Do not couple the application to a single AI provider.

Use an internal interface such as:

```ts
interface AIImageProvider {
  generateEditPrompt(input: GeneratePromptInput): Promise<GeneratePromptResult>;
  editImage(input: EditImageInput): Promise<EditImageResult>;
}
```

Provider-specific code belongs in:

```text
backend/src/services/ai/providers/
```

The service layer decides which provider to use.

Flutter should only know about InstaCat application APIs.

---

## 49.16 AI Configuration

Use environment variables for provider settings.

Example:

```env
AI_PROVIDER=<provider-name>
AI_API_KEY=<secret>
AI_IMAGE_MODEL=<model-name>
AI_PROMPT_MODEL=<model-name>
AI_IMAGE_TIMEOUT_MS=120000
```

Never commit AI API keys to Git.

Never send the AI provider API key to Flutter.

---

## 49.17 AI Cost and Abuse Protection

Because image editing can be expensive, implement basic protection.

At minimum:

- Authentication required for AI image editing
- Rate limit AI requests per user
- Limit source image size
- Limit maximum concurrent jobs per user
- Reject unsupported media types
- Reject excessively large uploads
- Do not automatically regenerate indefinitely
- Allow the user to cancel a pending job when possible

Do not introduce a billing system in the MVP.

---

## 49.18 AI Errors

The backend should normalize provider errors.

Recommended error codes:

```text
AI_PROVIDER_UNAVAILABLE
AI_TIMEOUT
AI_RATE_LIMITED
AI_INVALID_PROMPT
AI_INVALID_IMAGE
AI_CONTENT_REJECTED
AI_JOB_FAILED
AI_JOB_NOT_FOUND
```

Flutter should convert these into understandable messages.

Do not expose raw AI provider responses or secrets to the user.

---

## 49.19 AI Data Lifecycle

The AI workflow is considered a pre-post editing session.

Recommended MVP behavior:

```text
Source image
    ↓
Temporary / uploaded media
    ↓
AI edit result
    ↓
User chooses result
    ↓
Post is published
```

Unused temporary AI results should be eligible for cleanup later.

Do not create permanent Post records for draft AI edits.

---

## 49.20 AI Privacy

The app should clearly indicate when an image is being sent to an external AI provider.

Do not send unnecessary user profile or account information to the provider.

Send only what is needed for the AI operation:

- image
- editing prompt
- minimal technical metadata

---

## 49.21 AI Feature Acceptance Criteria

The AI feature is complete when:

- User can select an image before publishing a post.
- User can open AI Photo Studio.
- User can choose a one-tap enhancement.
- User can enter a custom edit prompt.
- User can ask AI to generate an editing prompt.
- Generated prompt is editable before execution.
- User can apply the final prompt to the selected image.
- Backend processes the AI request.
- Flutter never receives or stores the AI provider API key.
- AI result can be previewed.
- Original and result can be compared.
- User can accept the result.
- User can discard the result.
- User can retry with another prompt.
- User can still publish the original image without AI.
- AI errors are handled gracefully.
- AI usage is rate limited.
- Multi-image posts can edit individual images independently.
- Final Post creation only happens after the user explicitly publishes.

---

# 49. Security Requirements

The backend must enforce authorization.

Never trust IDs sent by Flutter.

Never allow:

```text
User A → edit User B's post
User A → delete User B's post
User A → modify User B's profile
User A → create Like as User B
User A → create Follow as User B
```

The current authenticated user must come from the backend authentication context.

---

# 50. Environment Variables

Never hardcode secrets.

Use `.env`.

Examples:

```env
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=instacat
DATABASE_USERNAME=instacat
DATABASE_PASSWORD=change-me
```

Use `.env.example` for documentation.

Do not commit real credentials.

Do not commit:

- JWT secrets
- database passwords
- API keys
- admin secrets

---

# 51. PostgreSQL

Recommended development configuration:

```text
Database: instacat
User: instacat
Port: 5432
```

The exact credentials should come from environment variables.

Do not hardcode database credentials in source code.

---

# 52. Optional Docker Development

If the existing backend does not already provide development infrastructure, Docker may be used for PostgreSQL/Strapi.

Example:

```text
PostgreSQL
  port 5432

Strapi
  port 1337
```

Do not introduce Docker if the existing project already has a stable alternative unless required.

---

# 53. Recommended Backend Structure

Use the existing Strapi structure where possible.

Typical layout:

```text
backend/
├── config/
├── src/
│   ├── api/
│   │   ├── post/
│   │   ├── post-like/
│   │   ├── follow/
│   │   ├── feed/
│   │   └── profile/
│   └── extensions/
├── public/
├── .env
├── .env.example
└── package.json
```

Do not force this exact structure if the existing Strapi application is already organized differently.

---

# 54. Backend Responsibilities

## Controller

Responsible for:

- HTTP request
- HTTP response
- Validation handoff

## Service

Responsible for:

- Business logic
- Ownership checks
- Data operations
- Feed building

## Policy

Responsible for:

- Authorization where appropriate

## Route

Responsible for:

- Endpoint declaration

Keep business logic out of routes.

---

# 55. Data Integrity

For `PostLike`:

```text
unique(user, post)
```

For `Follow`:

```text
unique(follower, following)
```

Do not rely only on Flutter to avoid duplicate data.

Backend/database must enforce integrity.

---

# 56. Counters

For the MVP, counts may be calculated from relations:

```text
likeCount
followersCount
followingCount
postsCount
```

Avoid premature denormalized counter fields unless performance requires them.

If counters are later added, all mutation paths must keep them synchronized.

---

# 57. Search

Search is optional and only required if the existing UI includes it.

If implemented:

```text
GET /api/search/users?q=...
```

Search fields:

```text
username
displayName
```

Do not add Elasticsearch or another search server for the MVP.

---

# 58. Testing

## Flutter

At minimum test:

- Auth repository
- Token refresh
- Post repository
- Like logic
- Follow logic
- Image compression
- Important widgets

## Backend

At minimum test:

- Create post ownership
- Update post ownership
- Delete post ownership
- Duplicate like prevention
- Duplicate follow prevention
- Self-follow prevention
- Public feed filtering
- Private profile filtering
- Blocked user behavior
- Invalid image count
- Invalid media

---

# 59. Definition of Done — Authentication

Authentication is complete when:

- Registration works
- User can immediately use the account
- Login works
- Logout works
- Session persists
- Access token refresh works
- Change password works
- Invalid credentials show useful errors
- Failed refresh returns the user to Login

---

# 60. Definition of Done — Profile

Profile is complete when:

- User can view own profile
- User can edit display name
- User can edit bio
- User can change avatar
- User can change public/private state
- User can view another profile
- Public posts are visible
- Private posts are not publicly visible
- Counts are displayed correctly

---

# 61. Definition of Done — Post

Post is complete when:

- User can select images
- User can select multiple images
- Maximum 10 images
- Images are compressed before upload
- Caption can be entered
- Post can be published
- Post appears in feed
- Multiple images can be swiped
- Owner can edit
- Owner can delete
- Other users cannot edit/delete the post

---

# 62. Definition of Done — Like

Like is complete when:

- Heart can be pressed
- Like count updates
- User can unlike
- Reload retains state
- Duplicate likes cannot occur
- Guest can see public like information but cannot create a like
- Feed and detail page show correct state

---

# 63. Definition of Done — Follow

Follow is complete when:

- User can follow another user
- Button changes to Following
- User can unfollow
- Duplicate follow cannot occur
- User cannot follow themselves
- Followers count updates correctly

---

# 64. Definition of Done — Feed

Feed is complete when:

- Public posts appear
- Private posts do not appear in public feed
- Hidden posts do not appear
- Posts are newest first
- Pagination works
- Infinite scroll works
- Pull to refresh works
- Author info renders
- Images render
- Like state renders
- Guest users can browse public feed

---

# 65. Definition of Done — Admin

Admin is complete when the Strapi Admin Panel can:

- Manage users
- Block/unblock users
- Inspect posts
- Edit posts
- Hide/delete posts
- Manage media
- Inspect likes
- Inspect follows

No separate admin mobile application is required.

---

# 66. Recommended Implementation Order

## Phase 0 — Project Audit

No code changes.

Inspect:

```text
frontend/
backend/
```

Produce audit.

---

## Phase 1 — Backend Foundation

Implement:

- Profile fields
- Post
- PostLike
- Follow
- Permissions
- Ownership checks
- Media validation
- Feed APIs

Do not redesign Flutter UI.

---

## Phase 2 — Flutter Authentication

Implement:

- API client
- Login
- Register
- Session
- Refresh token
- Logout
- Change password

Reuse existing Flutter UI.

---

## Phase 3 — Profile

Implement:

- Current user
- Profile
- Edit profile
- Avatar
- Bio
- Display name
- Public/private

---

## Phase 4 — Post & Upload

Implement:

- Image picker
- Multi-image selection
- Resize
- Compression
- Upload
- Create post
- Edit post
- Delete post
- Multi-image viewer

---

## Phase 5 — Feed

Implement:

- Public feed
- Following feed
- Pagination
- Infinite scroll
- Pull to refresh
- Empty states
- Loading states
- Error states

---

## Phase 6 — Social

Implement:

- Like
- Unlike
- Follow
- Unfollow
- Optimistic UI

---

## Phase 7 — Admin & Moderation

Configure:

- Users
- Posts
- Media
- Moderation status

using Strapi Admin.

---

## Phase 8 — Testing & Polish

Review:

- API errors
- Auth edge cases
- Image upload failures
- Ownership rules
- Privacy
- Loading states
- Empty states
- Offline/network errors
- Flutter analyzer
- Backend validation/tests

---

# 67. Cursor Development Rules

Cursor must follow these rules throughout the project.

### Rule 1
Read existing code before editing it.

### Rule 2
Do not recreate the project.

### Rule 3
Do not delete working code without a clear reason.

### Rule 4
Do not replace existing UI unless explicitly instructed.

### Rule 5
Reuse existing components.

### Rule 6
Do not duplicate services or API clients.

### Rule 7
Use Strapi 5 conventions.

### Rule 8
Do not assume Strapi v4 response structures.

### Rule 9
Use `documentId` where required by the Strapi 5 API.

### Rule 10
Never trust client-supplied author/user IDs.

### Rule 11
Enforce ownership on the backend.

### Rule 12
Do not expose passwords or private authentication fields.

### Rule 13
Keep business logic outside Flutter widgets.

### Rule 14
Keep business logic outside Strapi routes.

### Rule 15
Do not add unnecessary infrastructure.

### Rule 16
Do not implement video in the MVP.

### Rule 17
Do not implement comments in the MVP.

### Rule 18
Do not implement notifications in the MVP.

### Rule 19
Keep code readable enough for students to understand.

### Rule 20
After meaningful changes, run the project's analyzer, tests, and build checks.

---

# 68. Cursor Working Method

For each feature:

```text
1. Inspect existing implementation
2. Identify reusable code
3. Explain planned changes
4. Implement smallest complete version
5. Run validation/tests
6. Fix errors
7. Verify API and UI
8. Document changed files
9. Move to next feature
```

Do not implement the entire MVP in one uncontrolled generation.

---

# 69. Suggested Cursor Initial Prompt

Use the following prompt as the first instruction after opening the project:

```text
You are working on an existing InstaCat project.

Current structure:

InstaCat/
├── backend/    # Existing Strapi project
└── frontend/  # Existing Flutter project

IMPORTANT:

- Do NOT recreate either project.
- Do NOT change the root folder structure.
- Do NOT delete existing code.
- Do NOT replace existing Flutter UI.
- Treat existing Flutter UI as the visual source of truth.
- Reuse existing code whenever possible.
- Backend must remain inside backend/.
- Flutter must remain inside frontend/.
- Backend uses Strapi 5 + PostgreSQL.
- Flutter communicates with Strapi using REST APIs.
- Flutter must never connect directly to PostgreSQL.

FIRST TASK:

Do not modify code yet.

Inspect both projects and prepare a project audit.

For frontend inspect:
- Flutter/Dart versions
- pubspec.yaml
- folder structure
- routing
- state management
- API/network layer
- authentication
- models
- screens
- widgets
- theme
- assets
- fonts
- mock data
- TODOs

For backend inspect:
- Strapi version
- Node requirements
- package.json
- PostgreSQL configuration
- existing content types
- users-permissions configuration
- upload configuration
- routes
- controllers
- services
- policies
- middleware
- environment variables
- TODOs
- AI/image editing code or placeholders
- Existing image upload pipeline

Return:

1. Current architecture
2. Existing functionality
3. Existing Flutter UI/screens
4. Existing backend APIs/content types
5. Reusable code
6. Missing functionality required by spec.md
7. Potential conflicts
8. Recommended implementation order

Do not change code during this audit.
```

---

# 70. Final MVP Flow

The complete MVP should support this scenario:

```text
Open InstaCat
      ↓
Register
      ↓
Login
      ↓
Edit Profile
      ↓
Upload Avatar
      ↓
Set Public Profile
      ↓
Browse Public Feed
      ↓
Create Post
      ↓
Select 1–10 Images
      ↓
Resize / Compress
      ↓
Optional: AI Photo Studio
      ↓
Write Prompt OR Generate Prompt with AI
      ↓
Apply AI Edit
      ↓
Compare Original / Result
      ↓
Use Original or AI Result
      ↓
Add Caption
      ↓
Publish
      ↓
Post appears in Feed
      ↓
Open another user's Profile
      ↓
Follow
      ↓
Like Post
      ↓
View Multi-image Post
      ↓
Edit own Post
      ↓
Delete own Post
      ↓
Change Password
      ↓
Logout
      ↓
Login Again
      ↓
Admin manages Users / Posts / Media in Strapi Admin
```

---

# 71. Final Success Criteria

InstaCat MVP is successful when:

- Existing Flutter UI remains intact.
- Flutter communicates with the real backend.
- Strapi persists application data in PostgreSQL.
- Users can register/login without identity verification.
- Users can edit profile information.
- Users can upload profile images.
- Users can create image posts.
- Multiple images per post work correctly.
- Images are resized/compressed before upload.
- Users can optionally open AI Photo Studio before publishing.
- Users can enhance or edit an image from a natural-language prompt.
- Users can ask AI to generate an editable image-editing prompt.
- Users can review, edit, accept, discard, or retry AI image results.
- AI provider credentials never reach the Flutter app.
- Captions can be created/edited.
- Posts can be edited/deleted by their owners.
- Users can like/unlike posts.
- Users can follow/unfollow users.
- Public feed works.
- Following feed works.
- Privacy rules work.
- Authorization rules work on the backend.
- Strapi Admin can manage the application's content.
- No video/comments/chat/notification systems are unnecessarily introduced.
- Text-to-image generation from scratch is not added to the MVP.
- AI image editing is implemented as an optional pre-post workflow.
- The project remains understandable and maintainable for educational use.
