# Frankenstein's D&D 5e Character Builder

## Overview

Frankenstein's is a free, open-source Windows desktop application for creating, editing, and managing Dungeons & Dragons 5th Edition characters. Built with Flutter and Dart, it allows for comprehensive character creation with PDF export, custom content management, and content sharing capabilities.

## Key Features:
- Character creation workflow
- Character sheet generation
- Custom spell creation
- Content import/export and sharing
- Modern, responsive and customisable UI

## Prerequisites (Windows)

- Flutter (includes Dart): https://flutter.dev/docs/get-started/install/windows
- Git: https://git-scm.com/

Note: This repository targets Windows desktop only. If you want to run on other platforms you'll need appropriate SDK/tooling.

## Getting started
1. Clone the repo:

```powershell
git clone https://github.com/Elidcoder/Frankensteins.git
cd Frankensteins
```

2. Install Flutter and Dart, then get packages:

```powershell
flutter pub get
```

3. Generate model serialisation code:

```powershell
dart pub run build_runner build --delete-conflicting-outputs
```

4. Run the app (Windows desktop):

```powershell
flutter run -d windows
```

5. Build a release executable:

```powershell
flutter build windows --release
```

## Project Structure
```
.githooks/                          # Custom scripts for pre-commit hooks

assets/
└── userContent.json                # Default content provided with install

docs/
└── images/                         # Documentation screenshots
lib/
├── core/                           # Shared application infrastructure
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── features/                       # Feature modules (independent, self-contained)
│   ├── character_creation/         # Character creation workflow (tabbed interface)
│   ├── character_management/       # Character viewing & quick edits
│   ├── content_search/             # Content library search & browsing
│   ├── custom_content/             # Custom spell & content creation
│   ├── home/                       # Application entry point & navigation
│   └── pdf_export/                 # PDF generation & preview
│
├── models/                         # Domain models & data structures
│   ├── content/                    # D&D content types (background, class, race, etc.)
│   ├── core/                       # Core data models (character, ability score ...)
│   └── index.dart                  # Model exports
│
└── shared/
    └── widgets/                    # Shared UI components

```

## Code generation (json_serializable)

This project uses `json_serializable` and `build_runner` to generate model serialization (`*.g.dart`) files.

Install dev tools (if not already present):

```powershell
flutter pub add --dev json_serializable build_runner
```

Generate files once:

```powershell
dart pub run build_runner build --delete-conflicting-outputs
```

Or run watch mode during development:

```powershell
dart pub run build_runner watch
```

CI enforces that generated files are committed. Run the build_runner locally before opening PRs.

## Pre-commit setup

We use `pre-commit` to run linters, formatters, commit message checks, and small safety scripts before commits.

### Install pre-commit

Preferred (isolated): install with `pipx`:

```powershell
python -m pip install --user pipx
python -m pipx ensurepath
pipx install pre-commit
```

Alternatives:

- plain pip: `python -m pip install --user pre-commit`
- Chocolatey: `choco install pre-commit` (if you use Chocolatey)
- Scoop: `scoop install pre-commit` (if you use Scoop)

If you don't have Python on Windows, download the installer from https://www.python.org/downloads/windows/.

> If you prefer not to install any Python tooling locally, you can still rely on CI to enforce checks (but local feedback is recommended).

### Install the git hooks

```powershell
pre-commit install --install-hooks
```

This will install the hooks configured in `.pre-commit-config.yaml` and enable automatic checks on `git commit`.

### Notes about `.githooks/`

The `.githooks/` directory contains small helper scripts referenced by the pre-commit config (commit message validation, branch protection checks). On Windows use Git Bash or WSL to ensure these scripts run correctly.

### Run checks manually

```powershell
# Run all hooks on all files
pre-commit run --all-files --verbose

# Run a specific hook by ID
pre-commit run dart-format --all-files
pre-commit run dart-analyse --all-files
pre-commit run commit-message-format --all-files

# To skip for a specific commit (should be avoided):
git commit --no-verify
```

## Development workflow

### Branch naming

Use conventional branch prefixes:

- `feat/<name>` — new feature
- `fix/<name>` — bug fix
- `refactor/<desc>` — refactor
- `docs/<section>` — documentation

### Commit messages

Use Conventional Commits format (brief):

```
type(scope): short description

type: feat | fix | refactor | docs | chore | style | perf | test
scope: optional area (e.g., character, pdf)
description: ≤ 72 chars, no trailing period
```

Example:

```
feat(character): add ability score validation
```

## License & Usage

This project is free to use and modify.
