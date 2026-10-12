# DankCalc (`dcalc`)

Material 3 Expressive Calculator built for Linux and the [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) ecosystem.

Powered by a lightweight **Go** backend and a hardware-accelerated **Quickshell** (Qt 6 / QML) frontend.

---

## Features

- **Material 3 Expressive UI**: Smooth morphing shape transitions (circle to pill) and spring scale bounce feedback on keypress.
- **Dynamic Theming**: Seamlessly inherits DankMaterialShell Matugen palettes, system fonts, and Dark/Light modes.
- **Dual Mode (Standard & Scientific)**: Collapsible scientific drawer with trigonometric functions (`sin`, `cos`, `tan`), inverse modes (`asin`, `acos`, `atan`), angle units (`Rad` vs `Deg`), logarithms (`ln`, `log`), roots (`√`), powers (`^`), and factorials (`!`).
- **Unit Converter Mode**: Real-time conversion across Length, Mass/Weight, Temperature, Area, Volume, Speed, Time, Data Storage, Energy, and Pressure.
- **Live Evaluation**: Instant preview of math results as you type.
- **Calculation History**: Recalls previous equations and answers with one click.
- **Headless CLI Evaluator**: Run `dcalc -e "12 + 5 * 3"` directly from scripts or terminal.
- **Full Keyboard Navigation**: Complete hotkey support for all digits, operators, parens, and actions.

---

## Keyboard Shortcuts

| Category | Shortcut | Action |
|---|---|---|
| **Numbers & Math** | `0` – `9` | Digits |
| | `.` / `,` | Decimal point |
| | `+` / `-` / `*` / `/` | Arithmetic operators (`+`, `−`, `×`, `÷`) |
| | `%` | Percentage |
| | `(` / `)` | Parentheses |
| | `^` | Exponentiation (Power) |
| | `!` | Factorial |
| **Actions** | `Enter` / `=` | Evaluate result |
| | `Backspace` | Delete last character |
| | `Delete` / `Esc` | Clear expression (AC) |
| | `Ctrl + C` | Copy result to clipboard |
| **Interface** | `Tab` / `Ctrl + S` | Toggle Scientific drawer |
| | `Ctrl + H` | Toggle History drawer |
| | `F11` | Toggle Fullscreen / Maximize |
| | `Esc` | Close history/menu or quit |

---

## CLI Usage

```bash
dcalc                              # Open calculator window
dcalc -e "12 + 5 * 3"              # Headless evaluation (prints result and exits)
dcalc -e "sin(90)" -rad=false      # Evaluate using degrees
dcalc -v                           # Print version
```

---

## Build & Install

```bash
cd dankcalc

# Build development binary
make dev

# Run locally
make run

# Run unit tests
make test

# Install to ~/.local/bin
make install-user
```

---

## License

MIT
