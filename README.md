# Peblo AI Story Buddy & Quiz

A kid-friendly Flutter app where an AI Buddy reads a story
aloud to a child and follows up with an interactive quiz.
Built for Peblo's Flutter Developer Intern Challenge.

---

## Framework Choice

**Flutter** with **Provider** state management.

I chose Flutter because:
- Single codebase for Android and iOS
- `flutter_tts` uses the device's native speech engine —
  no internet needed, no buffering, lightweight
- Provider is the simplest state management that meets
  the brief's requirement — no unnecessary BLoC/Riverpod
  overhead
- Ideal for mid-range Android (~3GB RAM) due to minimal
  runtime overhead

---

## Audio → Quiz Transition

TTS playback is modeled as a 5-state enum in `TtsProvider`:
idle → loading → playing → completed → error

In `HomeScreen`, I use `context.watch<TtsProvider>()` to
listen to state changes. When `TtsState.completed` is
detected, `WidgetsBinding.instance.addPostFrameCallback`
fires `StoryProvider.reveal()` — switching `QuizState`
from `hidden` to `visible`.

A `_quizRevealed` boolean flag prevents `reveal()` from
being called on every rebuild — it fires only once per
narration session.

The quiz card animates in via `AnimatedSwitcher` with a
smooth crossfade transition the moment `reveal()` is called.

---

## Data-Driven Quiz Renderer

The quiz is stored in `assets/Story_Quiz.json`:

```json
{
  "story": "Once upon a time, a clever little robot named
  Pip lost his shiny blue gear in the Whispering Woods...",
  "quiz": [
    {
      "question": "What colour was Pip the Robot's lost gear?",
      "options": ["Red", "Green", "Blue", "Yellow"],
      "answer": "Blue"
    },
    {
      "question": "Where did Pip lose his gear?",
      "options": ["Whispering Woods", "The City", "His House"],
      "answer": "Whispering Woods"
    }
  ]
}
```

Loaded once at app start via `StoryRepo.loadAll()` and
stored in `StoryProvider`.

In `quiz.dart`, options are rendered by mapping over
`quizData.options`:

```dart
...optionQuiz.map((option) {
  return OptionButton(
    text: option,
    isCorrect: isSelected && quizState == QuizState.success,
    isWrong: isSelected && quizState == QuizState.wrong,
    onTap: () => storyData.selectOption(option),
  );
})
```

**This handles 3, 4, or 5 options with zero code changes.**
Swapping the entire JSON file requires no changes to any
Dart file — the UI adapts automatically.

---

## Caching Approach

Currently using on-device TTS (`flutter_tts`) — the device's
native Android/iOS speech engine synthesizes audio locally.
No network call is made so no caching is needed.

**If integrating ElevenLabs or a remote TTS API:**
- On first request, call the API and save the returned
  audio file to local storage using `path_provider`
- Key the cache file by `md5(storyText)` — unique per story
- On subsequent plays, check local cache first before
  hitting the API
- If cache exists → play local file (instant, offline)
- If cache missing and API fails → fall back to on-device
  TTS so the app never crashes

---

## Audio Loading & Failure States

Five explicit states in `TtsProvider`:

| State | What shows |
|---|---|
| `idle` | "Read Me a Story" button |
| `loading` | Spinner + "Preparing..." + Buddy thinking |
| `playing` | Disabled button "Reading..." + Buddy reading |
| `completed` | Quiz reveals automatically |
| `error` | Friendly message + "Try Again" + Buddy sad |

Three failure points handled:
1. `setErrorHandler` callback — TTS engine crash or
   missing voice data
2. `speak()` returns result != 1 — engine rejected call
3. 5-second safety timeout — if `loading` state persists
   without `setStartHandler` firing, switches to `error`
   so the app never hangs indefinitely

On error, Buddy shows sad expression and a "Try Again"
button re-calls `speak()` — fully recoverable without
restarting the app.

---

## Performance Profiling

**What I measured:**
Ran the app in profile mode using Flutter DevTools
Performance tab. Recorded frame times across the full flow:
button tap → TTS loading → quiz reveal → wrong answer
shake → correct answer confetti.

**Issues found before optimization:**
- `ListView.builder` inside `Column` caused layout overflow
  errors and unnecessary scroll context creation for a
  fixed 3-5 item list
- `ShakeWidget` initially wrapped the entire quiz column
  causing full-tree rebuilds on every animation frame

**Changes made:**
- Replaced `ListView.builder` with spread operator `.map()`
  directly in `Column.children` — eliminates scroll
  overhead entirely
- Scoped `ShakeWidget` to individual option buttons —
  only the tapped option's subtree rebuilds during shake
- `confetti` configured with `numberOfParticles: 20`,
  `emissionFrequency: 0.05`, `gravity: 0.3` — balanced
  celebration effect vs CPU cost on low-end devices
- Added `const` constructors on static widgets to prevent
  unnecessary rebuilds

**Result:** Smooth 60fps animations. No dropped frames
detected in DevTools after optimization.

---

## Optimizations for Mid-Range Android (~3GB RAM)

- **On-device TTS** — no network, no buffering, works
  offline, zero memory overhead from audio files
- **Provider over BLoC** — no stream subscriptions,
  minimal runtime overhead
- **Spread operator over ListView** — no scroll context
  for a fixed 3-5 item list
- **Static PNG assets** — 5 small buddy expression images
  instead of video files or heavy Lottie animations
- **Single screen app** — no navigation stack memory
  buildup
- **Programmatic confetti** — `confetti` package generates
  particles in code, not video/GIF playback
- **`numberOfParticles: 20`** — enough celebration without
  GPU overload on budget devices

---

## AI Usage & Judgment

**Files fully written by AI (~30% of codebase):**
- `tts_provider.dart` — TTS engine setup, state machine
  handlers, safety timeout logic
- `shake_widget.dart` — sine-wave animation math
- `design_constraint.dart` — design tokens
- `confetti_overlay.dart` — package configuration

**Files written independently (~70% of codebase):**
- `quiz_model.dart`, `story_model.dart`, `story_repo.dart`,
  `main.dart` — 100% independent
- `buddy_provider.dart`, `story_provider.dart` — fully
  independent, AI only reviewed small corrections
- All widget files — written independently, AI corrected
  minor issues only

**Architecture decisions made independently:**
- Single JSON containing both story and quiz data
- Combining story + quiz logic in one `StoryProvider`
- Buddy bottom-right corner positioning during quiz
- 5 buddy expression states (normal/thinking/reading/
  sad/happy) mapped to app states
- AI-generated robot mascot via Gemini matching brand
  purple color scheme

**One AI suggestion I rejected:**
AI suggested `Navigator.pushReplacement(HomeScreen())`
to restart the quiz after finishing all questions.
I rejected this because it destroys and recreates all
providers, causing unnecessary state reset and a visible
screen flash. Instead I added `restart()` in
`StoryProvider` which resets `currentIndex`, `quizState`,
and `selectedOption` in place — providers stay alive,
no navigation overhead, no flash.

**One thing AI got wrong:**
AI suggested `AnimatedPositioned` to animate Buddy moving
from story screen to bottom-right corner during quiz.
This required a fixed-size `Stack` and broke the
`SingleChildScrollView` layout. I reverted to simple
conditional positioning — `Buddy()` in `Column` for story
screen, `Positioned` widget for quiz screen. Simpler,
more reliable, easier to maintain.

**What didn't work and how I resolved it:**
- `context.watch` inside `onPressed` callbacks →
  switched to `context.read`
- `ListView.builder` inside `Column` →
  switched to spread operator
- `AnimatedSwitcher` not animating between states →
  added `ValueKey('quiz')` and `ValueKey('success')`
  to each child
- `selectOption()` firing for all options simultaneously →
  added early return guard when state is already
  `wrong` or `success`
- `late String _story` causing initial load crash →
  changed to `String _story = ""` with empty string
  default and loading fallback text in UI

---

## Project Structure
lib/

├── core/

│   └── design_constraint.dart     # colors, fonts, spacing

├── data/

│   ├── model/

│   │   ├── quiz_model.dart         # quiz data class

│   │   └── story_model.dart        # story + quiz wrapper

│   └── repo/

│       └── story_repo.dart         # JSON asset loading

├── provider/

│   ├── buddy_provider.dart         # mascot expression state

│   ├── story_provider.dart         # quiz logic + story data

│   └── tts_provider.dart           # audio state machine

├── screen/

│   └── home_screen.dart            # single screen

├── widget/

│   ├── buddy.dart                  # animated mascot

│   ├── confetti_overlay.dart       # celebration animation

│   ├── error.dart                  # TTS error state

│   ├── loading.dart                # TTS loading state

│   ├── option_button.dart          # quiz option row

│   ├── quiz.dart                   # data-driven quiz renderer

│   ├── shake_widget.dart           # wrong answer animation

│   ├── story.dart                  # story text card

│   └── success_card.dart           # correct answer state

└── main.dart
assets/

├── image/

│   ├── normal.png                  # buddy idle

│   ├── happy.png                   # buddy correct answer

│   ├── sad.png                     # buddy wrong answer/error

│   ├── reading.png                 # buddy while TTS plays

│   └── thinking.png                # buddy loading/quiz

└── Story_Quiz.json                 # story + all quiz questions

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  flutter_tts: ^4.0.2
  confetti: ^0.7.0
  google_fonts: ^6.2.1
```

---

## How to Run

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x and an Android device or emulator
with TTS engine installed (standard on all Android phones).
