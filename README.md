# Game Hub

A SwiftUI iOS app featuring multiple mini-games (Tap Frenzy, Light It Up, Quiz Rush), a daily challenge, high scores, and a map-based history of gameplay sessions.

## Table of Contents
- Overview
- Architecture
- Features
- Data Model
- Setup & Requirements
- Known Limitations
- Reflections & Future Work
- Screens & Navigation
- Contributing
- License

## Overview
Tap Frenzy Game bundles several lightweight game experiences under a unified, modern SwiftUI interface. Players can:
- Launch game modes from the Home tab
- Complete a rotating Daily Challenge
- View high scores and recent runs
- Explore where games were played on an interactive map

## Architecture
The project uses a lightweight MVVM-ish approach with SwiftUI views and simple shared managers.

- Views (SwiftUI):
  - `HomeTab`: Entry point for launching game modes, daily challenge card, and navigation to scores.
  - `MapTab`: Interactive MapKit view with markers grouped by location and a details pane.
  - Game Views: `TapFrenzyView`, `LightItUpView`, `QuizRushView` encapsulate gameplay UI/logic.
  - `HighScoresView`: Displays best scores for each mode.

- Managers (State/Logic):
  - `ScoreManager.shared`: Tracks and persists high scores.
  - `GameSessionManager.shared`: Stores historical `GameSession`s used by `MapTab` and other views.

- Models:
  - `GameMode`: Enum describing supported modes (Tap Frenzy, Light It Up, Quiz Rush).
  - `GameSession`: Represents a single play (mode, score, timestamp, latitude/longitude, etc.).
  - `LocationGroup`: View-only grouping of sessions by rounded coordinates for map display.

- Persistence:
  - `@AppStorage` for daily challenge state.
  - UserDefaults (or similar lightweight approach) for scores and sessions via managers.

- Navigation:
  - `NavigationStack` drives navigation from `HomeTab` to game modes and other screens.

## Features
- Modern SwiftUI interface with gradients and system icons
- Three game modes:
  - Tap Frenzy
  - Light It Up
  - Quiz Rush
- Daily Challenge card that routes to the scheduled mode
- High Scores screen for quick comparison
- Map tab:
  - Groups sessions by location
  - Selecting a pin reveals a bottom detail pane with per-mode summaries and history
- Basic persistence for daily challenge state using `@AppStorage`

## Data Model
- `GameMode`: Enum with helpers for title, icon, and color (used across the UI).
- `GameSession`: Identifiable record including `mode`, `score`, `timestamp`, `latitude`, and `longitude`.
- `LocationGroup`: Transient struct created by grouping sessions at ~4 decimal places (≈11m).

## Setup & Requirements
- Xcode 15+ recommended
- iOS 17+ target for modern SwiftUI and MapKit APIs
- Build and run on device or simulator

## Known Limitations
- Persistence for sessions/scores may be in-memory or UserDefaults-based; consider SwiftData for durability and queries.
- Location grouping uses fixed precision (4 decimal places); very close sessions may be merged.
- Map style is set to `.standard` and does not explicitly adapt beyond system defaults.
- Daily challenge logic is basic (`@AppStorage` mode string + completion flag) without scheduling or streaks.
- Error handling (location permissions, failures) is minimal.
- Accessibility (VoiceOver labels, Dynamic Type scaling) could be improved.
- Automated tests are not yet included.

## Reflections & Future Work
- Architecture: Introduce dependency injection and dedicated view models to improve testability and separation of concerns.
- Persistence: Adopt SwiftData for `GameSession` and high scores to enable richer queries and reliable storage.
- Map Experience: Add clustering, filters (by date/mode), and smarter camera framing based on selection.
- Daily Challenge: Implement scheduling, streak tracking, and rewards; consider remote configuration.
- Accessibility: Audit for contrast, labels, focus order, haptics, and Reduce Motion support.
- Testing: Add Swift Testing-based unit tests and snapshot tests for critical UI.
- Theming: Offer light/dark specific palettes and a user-toggle for themes.

## Screens & Navigation
- Home Tab (root)
  - Daily Challenge (navigates to the day’s mode)
  - Tap Frenzy / Light It Up / Quiz Rush
  - High Scores
- Map Tab
  - Map with grouped markers
  - Bottom detail pane showing per-mode summaries and session history

## Contributing
Pull requests are welcome! For substantial changes, please open an issue first to discuss what you’d like to change.

## License
This project is provided as-is for educational and demonstration purposes. Add your preferred license (e.g., MIT) as needed.

