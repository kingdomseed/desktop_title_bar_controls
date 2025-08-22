# Repository Guidelines

## Project Structure & Module Organization

- `bitsdojo_window/`: Core Flutter plugin package (widgets, API surface).
- `bitsdojo_window_platform_interface/`: Shared platform interface for the federated plugin.
- `bitsdojo_window_macos/`, `bitsdojo_window_windows/`, `bitsdojo_window_linux/`: Platform implementation packages (Swift/Obj‑C++, C++/Win32, GTK) and plugin wiring.
- `bitsdojo_window/*/example/`: Example app to validate behavior on each platform.
- `resources/`: Images/assets for docs.

## Build, Test, and Development Commands

- Install deps (per package): `cd <package> && dart pub get`
- Analyze: `dart analyze .` (run in each Dart package)
- Format: `dart format .` (2‑space indent; use trailing commas)
- Run example for manual testing:
  - macOS: `cd bitsdojo_window/example && flutter run -d macos`
  - Windows: `cd bitsdojo_window/example && flutter run -d windows`
  - Linux: `cd bitsdojo_window/example && flutter run -d linux`

## Coding Style & Naming Conventions

- Dart: 2 spaces; files `snake_case.dart`; classes `UpperCamelCase`; members `lowerCamelCase`.
- Prefer `const`; keep constructors and args trailing‑comma friendly for stable formatting.
- Platform sources: headers `.h`, impl `.mm`/`.mm` (macOS) or `.cpp` (Windows/Linux); filenames `snake_case`.

## Testing Guidelines

- No unit tests currently. Validate via the example app on each target OS.
- Manual checks: draggable regions, caption buttons, resize/hover states, theme transitions.
- When filing issues, include OS + Flutter versions (`flutter doctor -v`).

## Commit & Pull Request Guidelines

- Commits: short, imperative subject with optional scope, e.g. `windows: fix maximize`, `macos: avoid titlebar flicker`, `core: null‑safety cleanup`.
- PRs should include:
  - Summary and rationale; linked issues.
  - Platforms tested + steps; screenshots/GIFs for UI changes.
  - Notes on breaking changes or migrations.

## Publishing (pub.dev) Checklist

- Bump versions in each published `pubspec.yaml` and update corresponding `CHANGELOG.md`.
- Dry run per package: `dart pub publish --dry-run`
- Publish order (typical): `platform_interface` → platform packages → `bitsdojo_window`.
- Tag release(s) after publish; verify package pages render README and assets.
