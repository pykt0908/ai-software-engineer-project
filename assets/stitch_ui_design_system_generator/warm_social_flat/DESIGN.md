---
name: Warm Social Flat
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e4e2e1'
  on-surface: '#1b1c1c'
  on-surface-variant: '#584237'
  inverse-surface: '#303030'
  inverse-on-surface: '#f3f0ef'
  outline: '#8c7164'
  outline-variant: '#e0c0b1'
  surface-tint: '#9d4300'
  primary: '#9d4300'
  on-primary: '#ffffff'
  primary-container: '#f97316'
  on-primary-container: '#582200'
  inverse-primary: '#ffb690'
  secondary: '#855316'
  on-secondary: '#ffffff'
  secondary-container: '#ffbc76'
  on-secondary-container: '#79490b'
  tertiary: '#ac3400'
  on-tertiary: '#ffffff'
  tertiary-container: '#ff6d39'
  on-tertiary-container: '#601a00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbca'
  primary-fixed-dim: '#ffb690'
  on-primary-fixed: '#341100'
  on-primary-fixed-variant: '#783200'
  secondary-fixed: '#ffdcbd'
  secondary-fixed-dim: '#fcb973'
  on-secondary-fixed: '#2c1600'
  on-secondary-fixed-variant: '#683c00'
  tertiary-fixed: '#ffdbd0'
  tertiary-fixed-dim: '#ffb59d'
  on-tertiary-fixed: '#390c00'
  on-tertiary-fixed-variant: '#832600'
  background: '#fcf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e1'
  surface-canvas: '#FFFFFF'
  surface-secondary: '#FAFAFA'
  surface-tertiary: '#F4F4F5'
  border-subtle: '#E4E4E7'
  border-muted: '#DBDBDB'
  text-primary: '#262626'
  text-secondary: '#737373'
  text-placeholder: '#A1A1AA'
  story-gradient-start: '#F97316'
  story-gradient-end: '#FBBF24'
  interactive-like: '#EF4444'
typography:
  brand-title:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '800'
    lineHeight: 32px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-bold:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  body-regular:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 18px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  body-sm-bold:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
  caption-timestamp:
    fontFamily: Plus Jakarta Sans
    fontSize: 10px
    fontWeight: '400'
    lineHeight: 12px
    letterSpacing: 0.02em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 0.75rem
  margin: 1rem
  space-2xs: 0.125rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
  space-2xl: 2rem
---

## Brand & Style

This design system establishes a playful, community-centric, and image-forward social platform dedicated to cat enthusiasts. It builds upon battle-tested mobile feed conventions—instant content legibility, crisp boundary dividers, fluid media carousels, and minimal chrome—while transforming the platform personality through a vibrant, warm orange signature palette.

### Design Movement & Aesthetic
The visual style fuses **Modern Flat UI** with subtle **Tactile Warmth**:
- **Content-First Canvas:** Pristine, distraction-free neutral backgrounds ensure pet photography takes center stage without visual contention.
- **Warm Chromatic Accents:** Unlike cool corporate blues, vibrant citrus and amber accents evoke coziness, vitality, and playfulness.
- **Hairline Precision:** Clean 0.5px to 1px dividers separate content blocks, mimicking native iOS and Android edge treatments seen in modern social mobile clients.
- **Micro-Interactions:** Subtle haptic-friendly active states, responsive like animations, and gentle spring-physics overlays.

## Colors

The color system delivers high legibility and strong brand recognition while preserving pristine conditions for user-submitted media.

### Brand Palette Strategy
- **Primary (`#F97316`):** The signature vibrant orange. Reserved for key calls to action, brand wordmarks, active tab indicators, primary button fills, and highlighted interactive elements.
- **Secondary (`#FDBA74`):** Soft peach accent used for subtle badges, secondary tags, and active states on light backgrounds.
- **Tertiary (`#C2410C`):** Deep burnt orange for high-contrast pressed states and focused accessible text links.
- **Neutral (`#262626`):** Authentic `black87` equivalent, replacing harsh pure black with a softened off-black that maintains contrast while reducing optical fatigue.

### Surface & Border Hierarchy
- `surface-canvas` (`#FFFFFF`) covers primary viewports, cards, and top bars.
- `surface-secondary` (`#FAFAFA`) provides clean backdrops for inactive fields, exploration pills, and profile tab panels.
- `border-subtle` and `border-muted` (`#E4E4E7` and `#DBDBDB`) define post separations and form borders with 0.5px to 1px hairline rendering.
- `story-gradient-start` and `story-gradient-end` provide the circular linear gradient ring around avatar profiles with unseen stories.

## Typography

The typography system relies on **Plus Jakarta Sans**, providing clean geometric construction, wide apertures, and friendly rounded terminals that resonate with warm social aesthetics.

### Typography Hierarchy & Rules
- **Brand Title:** Used exclusively for top navigation app identity and welcome screens. Rendered in full primary orange `#F97316`.
- **Usernames & Meta Headings:** Rendered using `body-bold` (`14px/600`). In inline captions, bold usernames seamlessly combine with standard weight body text via rich text styling.
- **Engagement Counters & Stat Numbers:** Set in `headline-md` (`18px/600`) in profile overviews, accompanied by `body-sm` (`12px/400`) labels directly below.
- **Timestamps and Utility Microcopy:** Rendered with `caption-timestamp` (`10px/400`) using muted secondary text coloring.

## Layout & Spacing

Layout geometry follows standard mobile viewport guidelines with strict 4px and 8px rhythmic increments.

### Grid & Density Rules
- **Mobile Feed Stream:** Vertical single-column feed. Zero horizontal canvas margins on full-width square media (`aspect-ratio: 1/1`) ensures edge-to-edge viewing. Header, action row, and caption zones employ horizontal padding of `space-lg` (`16px`).
- **Profile & Explore Grid:** Strict 3-column square grid layout (`crossAxisCount: 3`) separated by `1.5px` to `2px` micro-gutters without outer boundary margins.
- **Stories Tray:** Horizontal scroll container height fixed at `96px`. Items padded with `space-sm` (`8px`) laterally.
- **Bottom Navigation Bar:** Height fixed at `52px` (excluding platform safe area insets). Five balanced touch targets with vertical padding of `space-sm`.

## Elevation & Depth

This design system avoids heavy realistic drop shadows in favor of flat editorial social clarity, relying on hairline borders and stacked surface layers.

### Elevation Hierarchy
- **Level 0 (Flat Surface / Canvas):** Main view background (`#FFFFFF`) and profile grid tiles. No shadows, separated strictly by borders or whitespace.
- **Level 1 (Separation Hairlines):** 1px solid `border-subtle` (`#E4E4E7`) pinning the top navigation app bar, post bottom dividers, and bottom tab bar.
- **Level 2 (Floating Action Sheet / Dialogs):** Modals, comment drawers, and media action sheets utilize a diffused ambient shadow:
  - `box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.08)`
  - Background: `#FFFFFF` with 16px top corner radii.
- **Level 3 (Overlay Badges & Indicators):** Photo counters (e.g., "1/3") and live indicators use semi-translucent dark glass:
  - Background: `rgba(20, 20, 20, 0.75)` with `backdrop-filter: blur(8px)`, text color `#FFFFFF`.

## Shapes

The design system uses soft, restrained corner radii to retain structural precision while introducing playful circular accents for identity elements.

### Shape Guidelines
- **Avatars & Story Frames:** Fully circular (`rounded-full` / `50%` radius).
- **Standard Action Buttons:** Soft rounded corners with `0.25rem` (4px) to `0.375rem` (6px) radius, preventing harsh corners without becoming toy-like pills.
- **Input Fields & TextAreas:** `0.375rem` (6px) radius with clean 1px border.
- **Filter Chips & Quick Tags:** Subtle rounded capsules (`rounded-lg`, 8px to 12px radius).
- **Action Sheets & Bottom Drawers:** Top-left and top-right radii set to `1rem` (16px).

## Components

### 1. App Header & Navigation
- **Feed Header:** Background `#FFFFFF`, height 44px (plus status bar). Left-aligned wordmark "InstaCat" in `brand-title` size and `#F97316`. Right-aligned utility icons (Messages/Direct, Activity) in `#262626`.
- **Bottom Navigation Bar:** Fixed at bottom with safe area compensation. Icons: Home, Search, Create (`add_box`), Activity (`heart`), and Profile (`CircleAvatar`). Active tab tinted in `#F97316`; inactive tabs in `#262626`.

### 2. Story Avatars & Rings
- **Unviewed Story Ring:** Circular avatar framed with a 2px offset border rendered in a 45-degree linear gradient from `#F97316` to `#FBBF24`.
- **Viewed Story Ring:** 1.5px border rendered in `#DBDBDB`.
- **Current User "Add Story" Ring:** 2px circular avatar with a floating orange `#F97316` badge and white plus icon at the bottom-right corner.

### 3. Post Card
- **Header:** Height 54px. User thumbnail (36px circle), username (`body-bold`), secondary location or audio tag (`body-sm`), and right-aligned overflow icon (`Icons.more_vert`).
- **Media Canvas:** Square 1:1 aspect ratio, edge-to-edge width, `#FAFAFA` fallback placeholder while loading.
- **Action Row:** Left cluster containing Like, Comment, and Share action buttons with 12px gap. Right icon slot for Bookmark. Like button transitions to filled state with `#EF4444` or primary orange `#F97316`.
- **Caption & Details:** Likes counter in `body-bold`. User caption rendered with bold author name preceding the text. "View all X comments" link styled in `text-secondary`.

### 4. Buttons
- **Primary Action Button:** Background `#F97316`, text `#FFFFFF`, height 44px, radius 6px, font `label-md`. Active state darkens to `#C2410C`.
- **Secondary / Follow Button:** Background `#F4F4F5`, text `#262626`, 1px border `#DBDBDB`, height 32px to 36px, radius 4px.
- **Outlined Button (Edit Profile):** Background `#FFFFFF`, border 1px solid `#DBDBDB`, text `#262626` font `body-bold`. Full width across profile headers.

### 5. Input Fields & Form Controls
- **Post Caption & Comment Inputs:** Surface `#FFFFFF`, border 1px solid `#E4E4E7`. Placeholder in `#A1A1AA`.
- **Floating Comment Bar:** Sticky bottom safe area row featuring current user avatar (32px), expandable single-line input field, and an orange text button labeled "Post" that activates when text length > 0.