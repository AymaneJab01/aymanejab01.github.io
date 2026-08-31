# 💚 FinTrack — Personal Finance Manager

A friendly, easy-to-use personal finance app built with **Flutter**. Track spending,
manage linked accounts, set budgets and savings goals, and see where your money
goes — on phone, tablet, **and desktop**.

<p align="center">
  <img src="assets/icons/app_icon.svg" width="120" alt="FinTrack logo">
</p>

## Why this version is easier to use

* **Add anything in a few taps** — every "Add" flow (transaction, account, budget,
  goal, or your own profile info) is a short guided form with clear validation
  messages, instead of a raw data-entry screen.
* **Manage, not just add** — every list item (transactions, accounts, budgets,
  goals) can be tapped to edit or swiped to delete. Nothing is permanent by accident.
* **Never stuck without a way back** — every screen that isn't a main tab shows a
  **Back** button *and* a **Home** button in the app bar, so you can always get
  back to the dashboard in one tap, even deep inside a form.
* **Works the same on desktop** — navigation is built with `go_router` and a
  responsive `Scaffold`, so resizing the window (or running `flutter run -d
  windows/macos/linux/chrome`) keeps the same back/home controls instead of
  relying on a phone's hardware back button.

## Structure

```
lib/
├── core/
│   ├── theme/        # colors + ThemeData
│   ├── router/        # go_router config (single source of truth for navigation)
│   └── constants/     # app-wide constants (categories, spacing, etc.)
├── features/
│   ├── dashboard/      # Home tab — balance, add/withdraw money, overview
│   ├── transactions/    # Activity tab — spend chart, add/edit/delete transactions
│   ├── budgets/         # Monthly budgets per category
│   ├── analytics/       # Spend-by-category breakdown
│   ├── goals/           # Savings goals with progress
│   ├── accounts/        # Banking tab — linked accounts/cards
│   └── settings/        # Account tab + editable personal profile
├── data/
│   ├── database/        # SQLite (sqflite) setup, works on desktop via sqflite_common_ffi
│   ├── models/           # Plain data models
│   └── repositories/     # CRUD + state, the only layer that talks to the database
└── main.dart
assets/
├── icons/                # app_icon.svg (logo)
└── illustrations/
test/
└── widget_test.dart
```

## Getting started

```bash
flutter pub get
flutter run                 # phone / emulator
flutter run -d chrome        # web
flutter run -d windows        # or macos / linux — desktop
```

## Notes

* Data is stored locally with SQLite, so it persists across restarts.
* State is shared through `provider`; each feature has its own
  `ChangeNotifier` repository in `data/repositories`.
* To change the logo, replace `assets/icons/app_icon.svg` and regenerate
  platform launcher icons with a tool like `flutter_launcher_icons`.
