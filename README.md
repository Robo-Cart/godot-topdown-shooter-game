
![](https://raw.githubusercontent.com/Robo-Cart/godot-topdown-shooter-game/refs/heads/master/.github/docs/image/readme_header.jpg)


# Topdown Shooter Game

Inspired by the likes of SmashTV, Moonlighter, Alien Breed and Enter the Gungeon.  

Twinstick, single screen, SmashTV/Binding of Isaac-like level navigation and potentially local multiplayer.

## Development Environment Setup (VS Code + Godot 4)

This project uses a strict linting and formatting pipeline via GitHub Actions. To ensure a smooth development experience and avoid failing CI builds, it is highly recommended to use **Visual Studio Code** as your primary script editor alongside the Godot Engine. 

The repository already includes the required `.gdlintrc` style rules and `.vscode/launch.json` debug configurations. Follow these steps to link your local tools:

### Step 1: Install Prerequisites

Strict linting and formatting rely on the Python-based `gdtoolkit`.

1. Ensure you have **Python** installed on your system.
2. Open your terminal and install the Godot 4 toolkit globally:
   `python -m pip install 'gdtoolkit==4.*`

### Step 2: Configure Godot to use VS Code
Tell Godot to hand off all script editing to VS Code.

1. Open the project in Godot.
2. Go to **Editor** -> **Editor Settings** -> **Text Editor** -> **External**.
3. Check the box for **Use External Editor**.
4. Set the **Exec Path** to your VS Code executable:
   * **Windows:** `code` (or the absolute path to Godot's `Code.exe`)
   * **Mac:** `/usr/local/bin/code` (or the path to the VS Code app package)
5. Set the **Exec Flags** exactly to: `{project} --goto {file}:{line}:{col}`

### Step 3: Install VS Code Extensions
Open the project folder in VS Code and install the following extensions:

* **Godot Tools** (by *geequlim*): Provides autocomplete, syntax highlighting, and connects to the Godot Language Server.
* **GDScript Formatter & Linter** (by *Eddie Dover*): Bridges VS Code to `gdtoolkit` to enforce our strict `.gdlintrc` rules.
* **Error Lens** (by *Alexander*): **Highly recommended.** Highlights linting errors directly inline with your code for immediate feedback.

### Step 4: Configure VS Code Settings
Open VS Code Settings (`Ctrl + ,` or `Cmd + ,`) and configure the following:

**1. Connect the Engine:**
* Search for `Godot_tools: Editor_path`. Paste the absolute file path to your Godot Engine executable (e.g., `C:\Program Files\Godot\Godot_v4.exe`).
* Search for `Godot_tools: Gdscript_lsp_server_port` and ensure it is set to `6005` (default for Godot 4).

**2. Enable Auto-Formatting:**
* Search for `Format On Save` and check the box for **Editor: Format On Save**.
* Open any `.gd` file, press `Ctrl + Shift + P` (or `Cmd + Shift + P`), type `Format Document With...`, select **Configure Default Formatter**, and choose **GDScript Formatter & Linter**.

### Debugging
The repository includes a pre-configured `launch.json` file. To debug:

1. Ensure the Godot Editor is open in the background.
2. Set your breakpoints in VS Code by clicking to the left of the line numbers.
3. Press `F5` in VS Code to launch the game with the debugger attached.

# Template Information

Uses https://github.com/TinyTakinTeller/TakinGodotTemplate as a base.


- 👁️ [Preview](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/PREVIEW.md)
- 📂 [Structure](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/STRUCTURE.md)
- ⭐ [Features](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/FEATURES.md)
- 🧩 [Plugins](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/PLUGINS.md)
- 🤖 [Code](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/CODE.md)
- 🎉 [CI/CD](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/CICD.md)
- ⚡ [Hacks](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/HACKS.md)
- 📖 [Get Started](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/GET_STARTED.md)
- 💕 [Examples](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/EXAMPLES.md)
- 🫂 [Contribute](https://github.com/TinyTakinTeller/TakinGodotTemplate/blob/master/.github/docs/CONTRIBUTE.md)
