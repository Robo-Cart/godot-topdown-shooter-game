# Godot Topdown Shooter Game - GEMINI.md

This project is a Twinstick Topdown Shooter developed in **Godot 4.6 (GL Compatibility)**, inspired by games like *SmashTV* and *Enter the Gungeon*. It uses the [TakinGodotTemplate](https://github.com/TinyTakinTeller/TakinGodotTemplate) as its foundation.

## 🚀 Project Overview

- **Engine:** Godot 4.6+
- **Primary Language:** GDScript
- **Architecture:** Component-based (located in `root/scenes/component/`) with a robust Autoload system for global management.
- **Key Features:**
  - **Global Signal Bus:** Centralized event handling via `SignalBus`.
  - **Data Management:** Automated save/load system using `Data` (json-based, supports encryption).
  - **Wrapped Plugins:** External addons (SceneManager, Logger) are wrapped in `root/autoload/wrapper/` for easier internal usage and decoupling.
  - **Localization:** Multi-language support via `root/assets/i18n/`.

## 🛠 Building and Running

### Prerequisites
- **Godot 4.6+** (Editor)
- **Python** (for linting tools)
- **gdtoolkit:** `python -m pip install 'gdtoolkit==4.*'`

### Key Commands
- **Launch Game:** Run via Godot Editor or press `F5` in VS Code (with `Godot Tools` extension).
- **Formatting:** `gdformat .` (usually handled automatically on save in VS Code).
- **Linting:** `gdlint .` (enforced via `.gdlintrc`).
- **Exporting:** Use `godot --export-release "Export Preset Name" path/to/build` (requires `export_presets.cfg` configuration).

## 📂 Directory Structure

- `godot/addons/`: Third-party plugins (DebugMenu, Log, Resonate, SceneManager, etc.).
- `godot/root/`: Project-specific content.
  - `assets/`: Media files (art, audio, fonts, i18n).
  - `autoload/`: Globals and Wrappers (Log, SceneManager, SignalBus, Data).
  - `resources/`: Global themes and audio bus layouts.
  - `scenes/`: UI, Components, and Levels.
  - `scripts/`: Static constants, object definitions, and utility scripts.
  - `shaders/`: Visual effects.

## 📜 Development Conventions

### Coding Style
- **Naming:** `snake_case` for files/folders/variables/functions; `PascalCase` for classes/enums/nodes/types.
- **Typing:** Static typing is **strictly enforced** (`untyped_declaration=1` in `project.godot`).
- **Private Symbols:** Prefix with `_` (e.g., `_private_function()`, `_private_var`).
- **Class Structure:** Follows the order defined in `.gdlintrc`:
  1. signals, 2. enums, 3. constants, 4. exports, 5. public vars, 6. private vars, 7. onready vars, 8. static vars, 9. functions.

### Architecture Guidelines
- **Child to Parent:** Use normal signals.
- **Cross-Component:** Use `SignalBus`.
- **Global State:** Access through `Data`, `Configuration`, or `AssetReference`.
- **Plugin Usage:** Always use the wrappers in `root/autoload/wrapper/` instead of calling addon singletons directly when available.

## 🧪 Testing and Validation
- **Linting:** CI checks are performed using `gdlint` with rules defined in `godot/.gdlintrc`.
- **Debug Tools:** Integrated `DebugMenu` addon (access via `cycle_debug_menu` input, default `F10` or `F12` variants).
- **Logging:** Use `LogWrapper` for consistent formatting and file logging.
