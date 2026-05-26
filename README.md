<div align="center">
  <img src="assets/images/app_icon.png" alt="StorySync Logo" width="160"/>
  <h1>StorySync</h1>
  <p><strong>A Premium, Local-First Manga & Manhwa Tracker Built for Productivity.</strong></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.38.6+-02569B?logo=flutter)](https://flutter.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Local First](https://img.shields.io/badge/Architecture-Local%20First-blueviolet)](#)
  [![Design](https://img.shields.io/badge/Design-Void%20Ink-gold)](#)
</div>

---

**StorySync** is a lightning-fast, highly aesthetic library tracker focusing solely on performance, dynamic design, and rich analytics. Keep track of what you read, seamlessly discover new chapters, and generate deep behavioral insights—all driven entirely offline via Isar NoSQL.

To see StorySync in action, read on or check out the [Releases](https://github.com/amr0-1/storysync/releases) tab for pre-compiled binaries. Note: compiling from source is supported, but releases are recommended.

## ✨ Key Features

- **Void Ink Global Theming:** Every single pixel respects the state of the app. Smoothly switches between high-fidelity dark ("Void") and ceramic light tones securely and instantly down to system the overlays.
- **Isar Speed Data Engine:** Built with a fully local backend. Searching your 500+ series reading list? Sub-millisecond. Analytics aggregations? Pushed to background isolates.
- **Reading Intelligence & Insights:** Forget basic lists. Access a 35-day interactive heatmap of your chapter activity alongside real-time metrics detailing read velocity, streak detection, and custom personality designations based on your schedule.
- **Intelligent Alert Protections:** An advanced context-aware warning system ensures your daily pace data doesn’t corrupt historic behavioral heat maps.
- **Zero-Friction JSON Portability:** Moving devices? No cloud tracking needed. Instantiate a clean JSON dump of all arrays.
- **Native iOS & Android Widgets:** Real-time updating tracking dashboards deployed straight to your phone's home screen.

## 📸 Interface Preview

_(We highly recommend downloading the latest APK/IPA from the [Releases](https://github.com/amr0-1/storysync/releases) section to experience the 120hz interaction design.)_

## 🚀 Getting Started

If you wish to compile StorySync from source, ensure you have the Flutter SDK (3.38.6+) installed.

### Prerequisites

```bash
flutter --version
```

### Setup & Build

1. **Clone the repository.**

   ```bash
   git clone https://github.com/yourusername/StorySync.git
   cd StorySync
   ```

2. **Acquire Design Typography:**
   Due to strict licensing restrictions, fonts are unbundled. Download the .TTF variants and install them to `assets/fonts/`:
   - [DMSans](https://fonts.google.com/specimen/DM+Sans) (Regular, Medium)
   - [Cormorant Garamond](https://fonts.google.com/specimen/Cormorant+Garamond) (Regular, SemiBold)
   - [JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono) (Regular, Medium)

3. **Install Dependencies:**

   ```bash
   flutter pub get
   ```

4. **Code Generation:**
   StorySync utilizes built-in models and annotations that must be compiled using `build_runner`.

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run StorySync:**
   ```bash
   flutter run --release
   ```

## 🏗 System Architecture

StorySync refuses legacy tech debt. The architecture revolves strictly around the following integrations:

- **Riverpod (v2):** Immutable, unidirectional global state tracking without massive `BuildContext` nesting logic.
- **GoRouter:** Clean, URI-declarative pathing utilizing `StatefulShellRoute` context trees for fluid view persistence.
- **Isar NoSQL:** Multi-threaded asynchronous queries directly off the UI thread pushing read logs to complex computation endpoints using `compute()` isolate abstractions.

## 🤝 Contributing

We love contributions! Be sure to submit PRs focusing on architectural fluidity and design token (`AppDimensions`/`VoidInkColors`) usage rather than raw hardcoded modifications. Read the complete `VOID_INK_PLAN.md` specification prior to executing massive migrations.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This project uses the MangaDex API via open protocol standards. StorySync provides analytics aggregation endpoints and does not possess server ownership.
