# District

District is an iOS app (SwiftUI, iOS 27 deployment target, bundle id `com.jyotiraditya.district`) for booking sports turfs. We are actively building the **District Huddle** feature into this app — see below.

## Feature: District Huddle — "Book a seat, not the whole turf"

Full pitch: `/Users/adityachauhan/Downloads/arc_download/district-huddle-pitch.md` — read it before working on any Huddle-related screen or service.

**Core idea:** today District only sells a whole turf booking. Huddle adds a **Lobby** — a game a host opens up with a turf, time, sport, and number of spots — that other people can join and pay for individually, seat by seat.

**Host flow:** pick turf/time/sport/player count → app computes price per person → create lobby with **no upfront payment** (slot is held, not booked) → share link (WhatsApp / public lobby for strangers).

**Joiner flow:** tap link → opens instantly via **App Clip** even without District installed → see turf, time, roster, price per seat → pay with **Apple Pay** in one tap.

**Money mechanics (critical business rule):**
- Joining only **authorizes** a card, never charges it.
- **2 hours before the game**, the app checks headcount.
  - Enough players → everyone is **charged simultaneously**, turf confirmed, **Apple Wallet** entry passes issued.
  - Not enough players → **nobody is charged**, slot releases back to the turf.
- Nobody ever loses money on a game that doesn't happen — this guarantee must hold in all edge cases.

**Solo players:** public lobbies let a single player with no group find and join a game near them.

**Trust/safety:** phone-verified profiles (+ optional higher verification), skill-level matching, women-only/mixed lobby controls (host-set), geofence-based automatic attendance, karma score for no-shows, post-match player ratings.

**Apple platform integration (this is the point of the feature — use these properly, not superficially):**
- **Live Activity / Dynamic Island** — live join-counter on host's lock screen ("6 of 10 joined, locks in 2h"), switches to gate code/countdown on match day.
- **App Clip** (+ App Clip Codes at physical turfs) — join and pay without installing the app.
- **Apple Wallet** — entry pass auto-surfaces on lock screen on arrival at the turf.
- **App Intents / Siri & Shortcuts** — natural-language game search and actions.
- **Home Screen Widget** — tonight's game + live headcount.
- **HealthKit** — auto-log the match as a workout on leaving the turf.
- **Game Center** — skill ratings, turf leaderboards, achievements.

**On-device AI (Apple Foundation Models — on-device only, nothing leaves the phone):** natural-language lobby search, auto-written share invites, group-chat summarization, one-line match-suggestion explanations, on-device chat moderation, auto-generated post-match recap cards, Hindi/English mixed-chat translation. AI only interprets/explains language — it never decides price, availability, or matching; that stays in deterministic app code.

## Architecture & conventions

Follow the structure and style already established in this codebase exactly — do not invent new patterns.

- **MVVM, always.** Every screen is `View` + `ViewModel` (`@Observable final class`), optionally backed by a `Service`. Views hold `@State private var viewModel = SomeViewModel()`; view models own state and logic, views stay declarative.
- **Feature module layout:** `Core/<Feature>/View`, `Core/<Feature>/ViewModel`, `Core/<Feature>/Service`, `Core/<Feature>/Widgets` (see `Core/Home`, `Core/Booking`). New features (e.g. `Core/Huddle`, `Core/Lobby`) follow this same subfolder split.
- **Shared UI/design system lives in `Config/`:**
  - `Config/Components` — reusable SwiftUI components (e.g. `PrimaryButton`, `CustomButton`).
  - `Config/Theme` — `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `Color+Hex`. Never hardcode colors, fonts, spacing, or corner radii in a view/component — add or reuse a token in `Config/Theme`.
  - `Config/Constants` — `AppConfig`, `Constants`.
  - `Config/entities` — model/entity types.
  - `Config/Managers` — cross-cutting managers/services.
- **Routing:** `Routing/Routers/AppRoute.swift` (route enum), `Routing/AppRouter` (`@Observable` navigation-path owner), `Routing/Navigation/RootNavigationView`. New destinations get a new `AppRoute` case, not ad-hoc navigation.
- **File header only, no other comments.** Every file starts with the standard header block (filename + `District`), and that is the *only* comment allowed anywhere in the code. No inline comments, no `// MARK:`, no doc comments — code must be self-explanatory through naming.
  ```swift
  //
  //  FileName.swift
  //  District
  //
  ```
- **Use the latest Swift/SwiftUI APIs.** Target is iOS 27 — use `@Observable`, Swift Concurrency (`async`/`await`, actors), `App Intents`, the modern `NavigationStack`/`NavigationPath` APIs, and current SwiftUI idioms. Don't reach for older patterns (`ObservableObject`/`@Published`, completion-handler callbacks, `NavigationView`) when a modern equivalent exists.
- **Liquid Glass everywhere it's applicable.** Use `.glassEffect()` (and `GlassEffectContainer` where multiple glass elements combine) on buttons, cards, bars, and other surfaces by default — match the pattern used in `Config/Components/CustomButton.swift`. Only skip it where a flat/opaque surface is a deliberate design requirement (e.g. full-bleed dark backgrounds).
- **Use the installed Swift/iOS skills proactively** (`mobile-ios-design`, `swiftui-pro`) for any SwiftUI implementation or review work — don't skip straight to writing code without checking HIG/best-practice guidance from these skills first.
