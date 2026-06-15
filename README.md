



# Peblo AI Story Buddy & Quiz

A kid-friendly Flutter app where an AI Buddy reads a story
aloud to a child and follows up with an interactive quiz.
Built for Peblo's Flutter Developer Intern Challenge.

---

## Screen Recording

https://github.com/user-attachments/assets/ddea72b4-038f-4c0c-8519-0c6d64dc9827

---

## Screenshots

### Story Screen
<img width="720" height="1600" alt="WhatsApp Image 2026-06-15 at 7 35 38 PM" src="https://github.com/user-attachments/assets/e46ad135-e0d0-41be-bc8a-3729f8e55416" />

### Reading State (Buddy reading expression)
<img width="720" height="1600" alt="WhatsApp Image 2026-06-15 at 7 35 39 PM" src="https://github.com/user-attachments/assets/2f0e201e-4240-432d-9ed4-5f66629d6962" />

### Quiz Screen (4 options)
<img width="720" height="1600" alt="WhatsApp Image 2026-06-15 at 7 35 39 PM (1)" src="https://github.com/user-attachments/assets/88ae67b0-3287-46c0-bfe8-690306fff8ae" />

### Wrong Answer (red highlight + sad buddy)
<img width="720" height="1600" alt="WhatsApp Image 2026-06-15 at 7 35 39 PM (2)" src="https://github.com/user-attachments/assets/e56be8e0-6736-43dd-af49-e52100458f9c" />


### Quiz Screen (5 options — data-driven proof)

<img width="720" height="1600" alt="WhatsApp Image 2026-06-15 at 7 35 40 PM (1)" src="https://github.com/user-attachments/assets/c2177584-ef52-4c0e-bbc2-98c8a08621e9" />


### Correct Answer + Confetti
<img width="720" height="1600" alt="WhatsApp Image 2026-06-15 at 7 35 40 PM" src="https://github.com/user-attachments/assets/b6f5a73c-0994-4f13-b6e1-f732fa687e7b" />


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
    },
    {
      "question": "What is Pip?",
      "options": ["A robot", "A dragon", "A wizard", "A bird", "A car"],
      "answer": "A robot"
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
The screenshot above shows a 5-option question rendering
correctly — same code, different JSON, no changes needed.

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

**Note on ElevenLabs attempt:**
ElevenLabs integration was fully implemented with caching
and fallback logic. However, the free tier returned HTTP
402 for library voices via API:
`"Free users cannot use library voices via the API"`
The integration code is included but disabled via
`_useElevenLabs = false` — can be enabled with a paid
plan and a VoiceLab-created voice ID.

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

### What I measured
Ran the app in profile mode on a real Android device
(RMX3870) using Flutter DevTools Performance tab.
Recorded frame times across the full flow:
button tap → TTS loading → quiz reveal →
wrong answer shake → correct answer confetti.

Total frames recorded: **3,164 frames**
Average FPS: **59 FPS** (DevTools confirmed)

### Before optimization — frame chart
<img width="1919" height="1079" alt="Screenshot 2026-06-15 194202" src="https://github.com/user-attachments/assets/b7a62056-e7c2-4b2b-845e-0dafdf9c42ca" />

Early frames (1-15) show spikes up to 27ms — these
occurred during initial app load and `ListView.builder`
layout calculations inside `Column`.

### Issues found
- `ListView.builder` inside `Column` caused layout
  overflow and unnecessary scroll context creation for
  a fixed 3-5 item list
- `ShakeWidget` initially wrapped the entire quiz column
  causing full-tree rebuilds on every animation frame

### Changes made
- Replaced `ListView.builder` with spread operator
  `.map()` directly in `Column.children` — eliminates
  scroll overhead entirely
- Scoped `ShakeWidget` to individual option buttons —
  only the tapped option's subtree rebuilds during shake
- `confetti` configured with `numberOfParticles: 20`,
  `emissionFrequency: 0.05`, `gravity: 0.3`
- Added `const` constructors on static widgets

### After optimization — frame chart
<img width="1918" height="1079" alt="Screenshot 2026-06-15 194216" src="https://github.com/user-attachments/assets/24804910-5478-4bc9-966c-0f208706effc" />

<img width="1919" height="1079" alt="Screenshot 2026-06-15 194226" src="https://github.com/user-attachments/assets/3264d338-74ca-4302-9d89-808e20155ba3" />

Post-optimization frames (54-130) show consistent
sub-7ms frame times. No red jank frames detected
during quiz interaction, shake animation, or confetti.
**Result: stable 59 FPS average on real Android device.**

---

## Optimizations for Mid-Range Android (~3GB RAM)

- **On-device TTS** — no network, no buffering, offline
- **Provider over BLoC** — no stream subscriptions
- **Spread operator over ListView** — no scroll overhead
- **Static PNG assets** — 5 small buddy expression PNGs
  instead of video or Lottie animations
- **Single screen app** — no navigation stack buildup
- **Programmatic confetti** — particles in code, not GIF
- **`numberOfParticles: 20`** — celebration without GPU
  overload on budget devices
- **`const` constructors** — prevents unnecessary rebuilds

---

## AI Usage & Judgment

**Files fully written by AI (~30% of codebase):**
- `tts_provider.dart` — TTS state machine, safety timeout
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
- Buddy bottom-right corner during quiz
- 5 buddy expression states mapped to app states
- AI-generated robot mascot via Gemini matching brand colors

**One AI suggestion I rejected:**
AI suggested `Navigator.pushReplacement(HomeScreen())`
to restart the quiz after finishing all questions.
I rejected this because it destroys and recreates all
providers, causing unnecessary state reset and a visible
screen flash. Instead I added `restart()` in
`StoryProvider` — providers stay alive, no navigation
overhead, no flash.

**One thing AI got wrong:**
AI suggested `AnimatedPositioned` to animate Buddy moving
from story screen to bottom-right corner during quiz.
This required a fixed-size `Stack` and broke
`SingleChildScrollView`. I reverted to simple conditional
positioning — `Buddy()` in `Column` for story screen,
`Positioned` for quiz screen.

**What didn't work and how I resolved it:**
- `context.watch` inside `onPressed` → `context.read`
- `ListView.builder` inside `Column` → spread operator
- `AnimatedSwitcher` not animating → added `ValueKey`
- `selectOption()` firing for all options → guard added
- `late String _story` crash → `String _story = ""`
- ElevenLabs free tier rejected library voices (HTTP 402)
  → reverted to `flutter_tts`, kept ElevenLabs code
  disabled via flag

---

## Project Structure
lib/

├── core/

│   └── design_constraint.dart

├── data/

│   ├── model/

│   │   ├── quiz_model.dart

│   │   └── story_model.dart

│   └── repo/

│       └── story_repo.dart

├── provider/

│   ├── buddy_provider.dart

│   ├── story_provider.dart

│   └── tts_provider.dart

├── screen/

│   └── home_screen.dart

├── widget/

│   ├── buddy.dart

│   ├── confetti_overlay.dart

│   ├── error.dart

│   ├── loading.dart

│   ├── option_button.dart

│   ├── quiz.dart

│   ├── shake_widget.dart

│   ├── story.dart

│   └── success_card.dart

└── main.dart
assets/

├── image/

│   ├── normal.png

│   ├── happy.png

│   ├── sad.png

│   ├── reading.png

│   └── thinking.png

└── Story_Quiz.json


---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1
  flutter_tts: ^4.2.5
  confetti: ^0.8.0
  google_fonts: ^8.1.0
```

---

## How to Run

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x and an Android device or emulator
with TTS engine installed (standard on all Android phones).
Tested on RMX3870 Android device — 59 FPS average, arm64 64-bit, running profile build.
3,164 frames recorded, no jank detected post-optimization.
