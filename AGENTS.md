# AGENTS.md

iOS app (SwiftUI + SwiftData) for tracking daily tasks, routines, and life obligations (trámites). Targets iOS 17+, supports iPhone and iPad. Includes a WidgetKit extension.

## Build & Run

- Open `Recuerda tus Trámites.xcodeproj` in Xcode (26.5+).
- Two targets: `Tramites` (main app) and `TramiteWidgets` (widget extension, embedded in app).
- Bundle ID: `com.manuelcazalla.recuerdatustramites`
- Development Team: `YNAD5X38LN`
- No Swift Package Manager packages to resolve locally; RevenueCat is pulled via `purchases-ios-spm` (remote SPM).
- Build folder is gitignored; use `build/` for local builds.

## Architecture

Clean-ish MVVM with clear layer separation:

- **Domain/** — SwiftData `@Model` classes (`TramiteTask`, `LifeObligation`, `WeekPlan`, `DailyRitual`, `FamilyProfile`, `TramiteIdea`), enums (`Priority`, `Recurrence`, `TramiteCountry`, `LifeAdminCategory`, `ObligationTemplate`), and repository protocols.
- **Data/** — SwiftData `ModelContainer` setup (`TramiteModelContainer`) and concrete repositories.
- **Services/** — Business logic: `NotificationService`, `PurchasesService` (RevenueCat), `CountryStore`, `SmartScheduler`, `ObligationPDFExporter`.
- **Presentation/** — SwiftUI views and view models organized by feature: `Day`, `Routine`, `Obligations`, `Ideas`, `Settings`, `Onboarding`, `FamilyProfile`, `Shared`.
- **TramiteWidgets/** — WidgetKit extension with its own mirror of the domain models (cannot import app code).

### Key patterns

- **SwiftData + App Group**: The app and widget share a SwiftData store via App Group `group.com.manuelcazalla.recuerdatustramites`. The store URL is `recuerdatustramites.sqlite` in the App Group container. Legacy stores (`daysorted.sqlite`, `pare.sqlite`) are auto-migrated.
- **Widget models are mirrored**: `TramiteWidgets/WidgetModels.swift` contains copies of the domain models. After changing `LifeAdminCategory`, `TramiteCountry`, or `ObligationTemplate` in the app's Domain layer, run `python3 sync_widget_models.py` to regenerate the widget's copy.
- **RevenueCat IAP**: `PurchasesService` is a singleton `@Observable` `@MainActor` class injected via `@Environment`. Pro status is shared with the widget via `UserDefaults(suiteName: "group.com.manuelcazalla.recuerdatustramites")` key `isProActive`.
- **Localization**: String catalogs (`Localizable.xcstrings`) in both `Recuerda tus Trámites/Resources/` and `TramiteWidgets/Resources/`. The widget catalog is a copy of the app catalog — keep them in sync.
- **Deep linking**: URL scheme `recuerdatustramites` with hosts `today`, `routine`, `obligations`, `ideas` to switch tabs.

## Localization scripts

Python scripts at repo root for managing `Localizable.xcstrings`:

- `python3 sync_widget_models.py` — Regenerate widget's mirrored domain models after changing app enums/templates.
- `python3 add_translations.py` — Add English translations to the app catalog.
- `python3 add_country_translations.py` — Add translations for country names and obligation templates across all 6 languages (en, fr, de, it, pt, ar).
- `python3 fill_pro_strings.py` — Fill Pro-related strings and copy app catalog to widget.
- `python3 parse_strings.py` — List keys missing English translations.

## Conventions

- Code comments and commit messages are in Spanish.
- The app was previously named "DaySorted" / "Pare" — some legacy references may remain.
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` for the app target; `nonisolated` for the widget target.
- Dark mode only (`.preferredColorScheme(.dark)`).
- Brand color: `Color.tramiteGreen` (#22C55E).
