# 🎓 Video Player — Mini Offline LMS

![Flutter](https://img.shields.io/badge/Flutter-3.44.0-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.12.0-0175C2?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-green)
![Offline](https://img.shields.io/badge/Mode-Fully_Offline-blueviolet)
![Languages](https://img.shields.io/badge/Languages-EN%20|%20AR%20|%20HI%20|%20ZH-orange)

> A **Flutter-based offline Learning Management System (LMS)** for students. Watch course videos, track your progress, take lesson notes, manage favorites — all without an internet connection.

---

## ✨ Features

### 🎬 Video Player
- **Offline video playback** from local assets
- **Custom video controls** — Play/Pause, Seek (±10s), Progress Slider
- **Fullscreen mode** with auto-orientation (landscape ↔ portrait)
- **Playback speed control** — 0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x
- **Auto-pause on screen exit** — Video pauses when app goes to background or navigated away
- **Buffering indicator** with loading overlay
- **Auto-hide controls** after 4 seconds of inactivity

### 📚 Courses & Lessons
- **Course listing** with thumbnail, title, description
- **Course Details** — Sections & Lessons with lock/unlock system
- **Lesson unlock progression** — Complete one lesson to unlock the next
- **90% rule completion** — Lesson marked complete after watching 90%
- **Continue Watching** — Resume from where you left off

### 📈 Progress Tracking
- **Per-lesson progress** saved with position, completion status, speed
- **Last played lesson** remembered across app restarts
- **Persistent storage** via `SharedPreferences`
- **Progress restored** automatically on re-opening a lesson

### 📝 Lesson Notes
- **Per-lesson text notes** — write and save notes while watching
- **Clear & Save** note functionality
- Notes **persist across sessions**

### ❤️ Favorites
- **Bookmark courses** with toggle favorite
- **Favorites screen** showing all bookmarked courses

### 🌍 Localization (Multi-language)
- Supports **4 languages**: English 🇬🇧, Arabic 🇸🇦, Hindi 🇮🇳, Chinese 🇨🇳
- **RTL layout support** for Arabic
- Language preference saved and restored

### 🎨 Theme
- **Light / Dark / System** theme modes
- Custom `AppTheme` with curated color palette
- Uses **Google Fonts** for modern typography
- Theme preference persisted across sessions

---

## 🗂️ Project Structure

```
video_player/
├── lib/
│   ├── main.dart                            # App entry point, ProviderScope setup
│   │
│   ├── core/                                # App-wide shared utilities
│   │   ├── constants/
│   │   │   ├── app_colors.dart              # Color palette constants
│   │   │   └── app_theme.dart               # Light & Dark ThemeData
│   │   ├── localization/
│   │   │   └── app_localizations.dart       # Multi-language strings (en/ar/hi/zh)
│   │   ├── routing/
│   │   │   └── app_router.dart              # GoRouter — all app routes defined here
│   │   └── widgets/
│   │       ├── error_view.dart              # Reusable error screen widget
│   │       └── loading_view.dart            # Reusable loading spinner widget
│   │
│   ├── data/                                # Data layer
│   │   ├── datasources/                     # JSON / local data sources
│   │   ├── models/
│   │   │   ├── course.dart                  # Course model (id, title, sections)
│   │   │   ├── lesson.dart                  # Lesson model (id, title, video path)
│   │   │   ├── section.dart                 # Section model (groups lessons)
│   │   │   └── lesson_progress.dart         # Progress model (position, completion, speed)
│   │   └── repositories/
│   │       ├── courses_repository.dart      # Loads courses from JSON asset
│   │       └── progress_repository.dart     # Saves/loads progress via SharedPreferences
│   │
│   ├── domain/                              # Business logic layer
│   │   └── services/
│   │       └── progress_service.dart        # Completion rules, next lesson logic
│   │
│   ├── features/                            # UI feature modules (screen-by-screen)
│   │   ├── splash/                          # App launch splash screen
│   │   ├── courses/
│   │   │   ├── courses_screen.dart          # Home — course list + continue watching banner
│   │   │   └── widgets/
│   │   │       ├── course_card.dart             # Single course display card
│   │   │       └── continue_watching_card.dart  # Resume banner card
│   │   ├── course_details/                  # Course detail & lesson list screen
│   │   ├── lesson_player/
│   │   │   ├── lesson_player_screen.dart    # Main video player screen
│   │   │   └── widgets/
│   │   │       ├── video_controls.dart          # Play/Pause/Seek/Fullscreen controls
│   │   │       ├── speed_selector.dart          # Playback speed picker bottom sheet
│   │   │       └── lesson_notes_widget.dart     # Per-lesson notes editor UI
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart        # Bookmarked courses list
│   │   └── settings/
│   │       └── settings_screen.dart         # Language & theme settings
│   │
│   └── providers/
│       └── app_providers.dart               # All Riverpod providers (state management)
│
├── assets/
│   ├── data/
│   │   └── courses.json                     # Course & lesson data (offline content)
│   ├── images/                              # Course thumbnails & images
│   └── videos/                             # Offline lesson video files (.mp4)
│
├── pubspec.yaml                             # Dependencies & asset declarations
└── analysis_options.yaml                    # Dart lint rules
```

---

## 🔌 State Management — Riverpod Providers

All state is managed using **Riverpod v3** with the modern `Notifier` API:

| Provider | Type | Purpose |
|---|---|---|
| `sharedPreferencesProvider` | `Provider` | Base SharedPreferences instance (injected at root) |
| `coursesRepositoryProvider` | `Provider` | Provides `CoursesRepository` |
| `progressRepositoryProvider` | `Provider` | Provides `ProgressRepository` |
| `progressServiceProvider` | `Provider` | Provides `ProgressService` (business logic) |
| `coursesProvider` | `FutureProvider` | Loads & caches all courses from JSON asset |
| `progressMapProvider` | `NotifierProvider` | Per-lesson progress map (position, completion, speed) |
| `lastPlayedLessonIdProvider` | `Provider` | Returns the ID of last opened lesson |
| `continueWatchingProvider` | `Provider` | Resolves which lesson to resume on home screen |
| `localeProvider` | `NotifierProvider` | App language locale (en / ar / hi / zh) |
| `themeModeProvider` | `NotifierProvider` | App theme mode (light / dark / system) |
| `favoritesProvider` | `NotifierProvider` | Set of bookmarked course IDs |
| `lessonNotesProvider` | `NotifierProvider` | Per-lesson text notes stored as Map |
| `defaultPlaybackSpeedProvider` | `NotifierProvider` | Globally remembered playback speed |

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^3.4.3 | State management (Notifier API) |
| `go_router` | ^18.0.1 | Declarative URL-based routing |
| `video_player` | ^2.14.0 | Video playback from local assets |
| `shared_preferences` | ^2.5.5 | Persistent key-value local storage |
| `google_fonts` | ^8.2.1 | Custom typography (modern fonts) |
| `flutter_localizations` | sdk | Multi-language & RTL support |
| `cupertino_icons` | ^1.0.8 | iOS-style icon set |
| `flutter_lints` | ^6.0.0 | Dart/Flutter lint rules (dev) |

---

## 🗺️ App Routes (GoRouter)

| Route Path | Screen | Description |
|---|---|---|
| `/` | Splash Screen | App launch screen, auto-redirects to home |
| `/courses` | Courses Screen | Home — all courses + continue watching |
| `/course/:courseId` | Course Details | Sections & lesson list for a course |
| `/course/:courseId/lesson/:lessonId` | Lesson Player | Full video player with controls & notes |
| `/favorites` | Favorites Screen | All bookmarked/favorited courses |
| `/settings` | Settings Screen | Language & theme configuration |

---

## 🏗️ Architecture

The project follows **Clean Architecture** with clear separation of concerns:

```
┌────────────────────────────────────────────┐
│         Presentation Layer                 │
│   (features/ — Screens & Widgets)          │
├────────────────────────────────────────────┤
│         State Layer                        │
│   (providers/ — Riverpod Providers)        │
├────────────────────────────────────────────┤
│         Domain Layer                       │
│   (domain/services/ — Business Logic)      │
├────────────────────────────────────────────┤
│         Data Layer                         │
│   (data/ — Models, Repositories, JSON)     │
└────────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.12.0`
- Dart SDK `>=3.12.0`
- Android Studio / VS Code with Flutter extension
- Android Emulator, iOS Simulator, or physical device

### Setup

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd video_player

# 2. Install dependencies
flutter pub get

# 3. Add your assets
#    Place .mp4 files in:  assets/videos/
#    Place thumbnails in:  assets/images/
#    Update course data:   assets/data/courses.json

# 4. Run the app
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📄 Course Data Format (`assets/data/courses.json`)

```json
[
  {
    "id": "course_001",
    "title": {
      "en": "Course Title",
      "ar": "عنوان الدورة",
      "hi": "कोर्स का शीर्षक",
      "zh": "课程标题"
    },
    "description": { "en": "Course description..." },
    "thumbnail": "assets/images/course_thumb.jpg",
    "sections": [
      {
        "id": "section_001",
        "title": { "en": "Section 1: Introduction" },
        "lessons": [
          {
            "id": "lesson_001",
            "title": { "en": "Lesson 1: Getting Started" },
            "video": "assets/videos/lesson_01.mp4",
            "duration": 71
          }
        ]
      }
    ]
  }
]
```

---

## 🔑 Key Behaviors

| Behavior | Implementation Details |
|---|---|
| **Auto-pause on background** | `WidgetsBindingObserver.didChangeAppLifecycleState` — detects `paused / inactive / hidden` |
| **Auto-pause on navigation** | `_controller?.pause()` called inside `dispose()` before screen is removed |
| **Progress auto-save** | Saved every 3 seconds via `Timer.periodic` + forced save on exit |
| **Lesson completion rule** | Triggered when watch position ≥ 90% of total duration |
| **Lesson unlock system** | Next lesson unlocks only after previous lesson is marked complete |
| **Speed memory** | Per-lesson speed saved; falls back to global remembered speed |
| **Language RTL** | Arabic locale automatically switches entire UI to RTL layout |
| **Theme persistence** | Light/Dark/System choice saved to SharedPreferences |

---

## 👨‍💻 Developer Notes

- All UI strings are **fully localized** — no hardcoded text in any widget
- `SharedPreferences` keys are **namespaced** (prefixed with `video_player_app_`) to avoid conflicts
- `VideoPlayerController` is properly **paused and disposed** before screen removal
- `WidgetsBindingObserver` is registered in `initState()` and removed in `dispose()` to prevent memory leaks
- All Riverpod state uses the **modern `Notifier` API** (not the deprecated `StateNotifier`)
- Architecture strictly separates UI, State, Domain, and Data concerns

---

## 📃 License

This project is private. Not published to pub.dev.

```
App Version:  1.0.0+1
Flutter SDK:  ^3.12.0
Dart SDK:     ^3.12.0
```
