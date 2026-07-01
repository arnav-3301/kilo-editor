
# Kilo Text Editor

A minimalist terminal-based text editor written in C, implementing low-level terminal control, raw mode handling, and structural file buffer manipulation. This project explores the interaction between a C program and the POSIX terminal interface to create a functional, self-contained text editing environment without high-level libraries like `ncurses`.

## Technical Architecture

### Terminal State Management
The editor manipulates the `termios` structure to transition the terminal from canonical mode to **Raw Mode**. Key flag modifications include:
* **Input Flags (`c_iflag`):** Disables `BRKINT`, `ICRNL` (preventing `Ctrl-M` from being processed as `\n`), `INPCK`, `ISTRIP`, and `IXON` (disabling software flow control).
* **Output Flags (`c_oflag`):** Disables `OPOST` to prevent the terminal from automatically translating `\n` to `\r\n`.
* **Local Flags (`c_lflag`):** Disables `ECHO` (character echoing), `ICANON` (line-buffered input), `IEXTEN` (implementation-defined processing), and `ISIG` (disables `SIGINT`/`SIGTSTP` signals).
* **Control Characters (`c_cc`):** Sets `VMIN` to 0 and `VTIME` to 1, enabling non-blocking `read()` calls with a 100ms timeout.

### Rendering Engine & Buffer Operations
To mitigate terminal flicker, the editor utilizes a custom dynamic append buffer (`struct abuf`). Instead of making multiple `write()` system calls for every character or line, the editor appends all screen updates (ANSI escape sequences and text strings) into a single heap-allocated buffer, executing a single atomic `write()` call to `STDOUT_FILENO` per refresh cycle.

### State & Modification Tracking (Dirty Flag)
The global editor state maintains a **dirty flag** to monitor file modifications. 
* The flag increments upon any text editing operation (insertions, deletions).
* **Note on State:** Reverting edits manually does not clear the flag; the file continues to be tracked as modified until explicitly committed to disk via a save operation.

### File I/O & Interactive Prompting
File serialization is handled safely through an internal save pipeline:
* If saving a newly initialized buffer, the engine invokes `editorPrompt()` to capture a target filename interactively from the status bar.
* For existing files, modifications are committed directly to the established filename.

### Compilation Design
To accommodate C's single-pass compilation model without breaking sequential structural design, the codebase implements forward-declared **prototypes**. Three core functional dependencies are explicitly prototyped at the top of the file to resolve implicit declaration hazards prior to their full definitions.

## Features
* Byte-by-byte raw input processing and safe terminal restoration via `atexit` hooks.
* Multi-row text rendering and dynamic status bar display.
* **Text Editing:** In-buffer text insertion, Backspace, and Delete key routing.
* **State Safety:** Warns users of unsaved changes in the status bar upon exit termination attempts. To bypass and force-quit, the user must trigger the quit sequence a defined number of times (`KILO_QUIT_TIMES`).

## Keybindings

| Key | Function |
|:---|:---|
| `Ctrl + Q` | Safe Quit / Force Quit (Requires hitting `KILO_QUIT_TIMES` if file is dirty) |
| `Ctrl + S` | Save File (Triggers `editorPrompt` for filenames on new buffers) |
| `Arrow Keys` | Move Cursor |
| `Page Up / Down`| Scroll full screen |
| `Home / End` | Move to start/end of current window boundaries |
| `Backspace` / `Ctrl + H` | Delete character to the left of the cursor |
| `Delete` | Delete character directly under the cursor |

## Build Instructions

This project includes a `Makefile` for streamlined compilation. Ensure your core source file is named `main.c`.

### Compilation
To build the executable, run:
```bash
make
```

### Execution
To launch the editor (with an optional file path):
```bash
./kilo [filename]
```

### Cleanup
To remove the compiled binary and clean your working directory:
```bash
make clean
```
