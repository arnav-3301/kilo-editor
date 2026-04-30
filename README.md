# Kilo Text Editor

A minimalist terminal-based text editor written in C, implementing low-level terminal control and raw mode handling. This project explores the interaction between a C program and the POSIX terminal interface to create a functional text editing environment without high-level libraries like ncurses.

## Technical Architecture

### Terminal State Management
The editor manipulates the `termios` structure to transition the terminal from canonical mode to **Raw Mode**. Key flag modifications include:
* **Input Flags (`c_iflag`):** Disables `BRKINT`, `ICRNL` (preventing `Ctrl-M` from being processed as `\n`), `INPCK`, `ISTRIP`, and `IXON` (disabling software flow control).
* **Output Flags (`c_oflag`):** Disables `OPOST` to prevent the terminal from automatically translating `\n` to `\r\n`.
* **Local Flags (`c_lflag`):** Disables `ECHO` (character echoing), `ICANON` (line-buffered input), `IEXTEN` (implementation-defined processing), and `ISIG` (disables `SIGINT`/`SIGTSTP` signals).
* **Control Characters (`c_cc`):** Sets `VMIN` to 0 and `VTIME` to 1, enabling non-blocking `read()` calls with a 100ms timeout.

### Rendering Engine
To mitigate terminal flicker, the editor utilizes a custom dynamic buffer (`struct abuf`). Instead of making multiple `write()` system calls for every character or line, the editor:
1. Appends all screen updates (ANSI escape sequences and text) into a single heap-allocated buffer.
2. Performs a single `write()` call to `STDOUT_FILENO`.
3. Frees the buffer memory after each refresh cycle.

### Window Dimension Discovery
The editor retrieves screen size using the `TIOCGWINSZ` ioctl call. It implements a fallback strategy that positions the cursor at the extreme bottom-right (`\x1b[999C\x1b[999B`) and queries the position using the Device Status Report (`\x1b[6n`) if the ioctl fails.

## Features
* Byte-by-byte input processing.
* Support for VT100 escape sequences (Arrow keys, Page Up/Down, Home, End).
* Custom screen padding and center-aligned welcome message.
* Safe terminal restoration via `atexit` hooks.

## Keybindings

| Key | Function |
|:---|:---|
| Ctrl + Q | Safe Quit |
| Arrow Keys | Move Cursor |
| Page Up / Down | Scroll full screen |
| Home / End | Move to start/end of current window boundaries |

## Build Instructions

### Compilation
Requires a POSIX-compliant system and a C compiler (GCC/Clang).
```bash
gcc -o kilo kilo.c -Wall -Wextra -pedantic -std=c99
