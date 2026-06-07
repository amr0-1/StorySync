<div align="center">
  <img src="assets/images/app_icon.png" alt="StorySync Logo" width="160"/>
  <h1>StorySync</h1>
  <p><strong>A Premium Local-First Manga & Manhwa Tracking Experience.</strong></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.38.6+-02569B?logo=flutter)](https://flutter.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Local First](https://img.shields.io/badge/Architecture-Local%20First-blueviolet)](#)
  [![Design](https://img.shields.io/badge/Design-Void%20Ink-gold)](#)
</div>

---

**StorySync** is a lightning-fast, highly aesthetic manga and manhwa tracker focused on performance, dynamic design, and rich analytics.. Keep track of what you read, seamlessly discover new chapters, and generate deep behavioral insights—all driven entirely offline via Isar NoSQL.

To see StorySync in action, read on or check out the [Releases](https://github.com/amr0-1/storysync/releases) tab for pre-compiled binaries. Note: compiling from source is supported, but releases are recommended.

## ✨ Key Features

- **Void Ink Global Theming:** Every single pixel respects the state of the app. Smoothly switches between high-fidelity dark ("Void") and ceramic light themes instantly, including synchronized system overlay styling.
- **Isar Speed Data Engine:** Built with a fully local backend. Searching your 500+ series reading list? Sub-millisecond. Heavy analytics aggregation? Executed in background isolates.
- **Reading Intelligence & Insights:** Forget basic lists. Access a 35-day interactive heatmap of your chapter activity alongside real-time metrics detailing read velocity, streak detection, and custom personality designations based on your schedule.
- **Intelligent Alert Protections:** An advanced context-aware warning system ensures your daily pace data doesn’t corrupt historic behavioral heat maps.
- **Zero-Friction JSON Portability:** Moving devices? No accounts, cloud sync, or telemetry required. Generate clean JSON exports of your entire library and tracking data.
- **Native Android Widgets:** Real-time tracking dashboards deployed directly to your Android home screen.


_(We highly recommend downloading the latest APK from the [Releases](https://github.com/amr0-1/storysync/releases) section to experience the 120hz interaction design.)_

## 🚀 Getting Started

If you wish to compile StorySync from source, ensure you have the Flutter SDK (3.38.6+) installed.

### Prerequisites

```bash
flutter --version
```

### Setup & Build

1. **Clone the repository.**

   ```bash
   git clone https://github.com/amr0-1/storysync.git
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

StorySync is built around a modern local-first architecture focused on performance, scalability, and maintainability. The core stack includes:

- **Riverpod (v2):** Immutable, unidirectional global state tracking without massive `BuildContext` nesting logic.
- **GoRouter:** Clean, URI-declarative pathing utilizing `StatefulShellRoute` context trees for fluid view persistence.
- **Isar NoSQL:** Multi-threaded asynchronous queries executed off the UI thread, with heavy analytics and read-log computations delegated to Dart isolates via `compute()`.

## ⚠ Current Development Status

StorySync is under active development by a solo developer.  
Most core systems are stable and production-ready for daily use. The native Android home screen widgets are fully integrated and working without any issues. If you encounter any problems, please feel free to open a ticket in the [Issues](https://github.com/amr0-1/storysync/issues) section of the repository.

Additionally, chapter progress tracking currently requires manual value adjustments when increasing or decreasing chapter counts. This exists due to limitations within the currently integrated public API, which does not reliably expose all progression metadata required for fully automated synchronization.

## 🔮 Future Scope

A custom companion API is planned for a future release to eliminate these limitations and provide significantly more accurate progression synchronization. The long-term goal is to integrate this alongside the existing system as an optional enhanced backend, enabling:

- Automated chapter progression synchronization
- Improved metadata consistency
- Faster update propagation
- Expanded analytics capabilities
- More resilient cross-source tracking support

The existing local-first architecture is already being designed to support this future multi-source integration model cleanly without disrupting current user data.

## ⚖ Disclaimer

StorySync is an unofficial client/tracker and is not affiliated with MangaDex or its contributors in any form.

StorySync does not host, distribute, or mirror manga/manhwa content. The application functions solely as a local-first tracking and analytics platform utilizing publicly available metadata endpoints.

## 🔒 Privacy

StorySync is fully local-first by design.

No reading history, analytics, behavioral insights, or personal tracking data is transmitted to external servers. All core tracking operations, statistics generation, and data persistence occur entirely on-device.

Users maintain complete ownership and control over their library data, including optional manual JSON exports for portability and backups.

## 🤝 Contributing

We love contributions! Be sure to submit PRs focusing on architectural fluidity and design token (`AppDimensions`/`VoidInkColors`) usage rather than raw hardcoded modifications. Read the complete `VOID_INK_PLAN.md` specification prior to executing massive migrations.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This project uses the MangaDex API via open protocol standards. StorySync provides analytics aggregation endpoints and does not possess server ownership.
