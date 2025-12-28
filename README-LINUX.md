# ClaudeBar for Linux

**AI Usage Monitor for Linux** - Complete port from macOS with identical functionality.

![ClaudeBar Linux](docs/screenshots/linux-preview.png)

## Features

✨ **Identical UI to macOS version** - Same glassmorphism, gradients, and animations
📊 **Multi-Provider Support** - Claude, Codex, Gemini, GitHub Copilot
🎨 **Theme Support** - Light, Dark, and System themes
💰 **Budget Tracking** - Claude API cost monitoring
🔔 **Desktop Notifications** - Native Linux notifications
🎯 **System Tray** - Menu bar integration (GTK4)

## Screenshots

### Dark Theme
![Dark Theme](docs/screenshots/linux-dark.png)

### Light Theme
![Light Theme](docs/screenshots/linux-light.png)

## Requirements

- **Linux** - Ubuntu 22.04+, Pop!_OS 22.04+, Fedora 36+, Arch Linux
- **Swift 6.2+** - [Install Swift for Linux](https://www.swift.org/download/)
- **GTK4** - System UI toolkit
- **GLib 2.0** - Core libraries

## Installation

### Quick Setup (Recommended)

**One command to install everything:**

```bash
# Clone the repository
git clone https://github.com/yourusername/ClaudeBar.git
cd ClaudeBar

# Run the automated installer (installs Swift, GTK4, builds, and installs)
./setup-linux.sh
```

The setup script will:
1. ✅ Install Swift (via swiftly)
2. ✅ Install GTK4 and dependencies for your distro
3. ✅ Install Node.js for AI CLI tools (optional)
4. ✅ Build ClaudeBar
5. ✅ Install to `/usr/local/bin`
6. ✅ Create desktop entry

**Supported distributions:**
- Ubuntu 22.04+ / Pop!_OS 22.04+
- Debian 11+
- Fedora 36+
- Arch Linux / Manjaro
- openSUSE

### Manual Installation (Advanced)

If you prefer manual control:

**1. Install Dependencies:**

```bash
# Ubuntu/Debian/Pop!_OS
sudo apt install libgtk-4-dev libglib2.0-dev pkg-config git

# Fedora
sudo dnf install gtk4-devel glib2-devel pkg-config git

# Arch Linux
sudo pacman -S gtk4 glib2 pkg-config git
```

**2. Install Swift:**
```bash
curl -s https://swiftlang.github.io/swiftly/swiftly-install.sh | bash
swiftly install latest
```

**3. Build & Install:**
```bash
./build-linux.sh
./install-linux.sh
```

## Running

```bash
# From terminal
claudebar

# Or search for "ClaudeBar" in your application menu
```

## Configuration

### Theme Settings

ClaudeBar supports 3 themes:
- **Light** - Bright purple-pink gradients
- **Dark** - Deep purple with glassmorphism
- **System** - Follows system theme

Change theme in: **Settings → Appearance**

### Provider Setup

#### Claude
```bash
# Install Claude CLI
npm install -g @anthropics/claude-cli

# Login
claude login
```

#### Codex/OpenAI
```bash
# Install Codex CLI
npm install -g @openai/codex-cli

# Configure
codex auth login
```

#### Gemini
```bash
# Install Gemini CLI
npm install -g @google/gemini-cli

# Setup
gemini auth login
```

#### GitHub Copilot (Optional)
1. Open ClaudeBar Settings
2. Enable "GitHub Copilot"
3. Enter your GitHub username
4. Create a [Personal Access Token](https://github.com/settings/tokens?type=beta) with `Plan: read` permission
5. Save token in ClaudeBar

### Budget Tracking

For Claude API accounts:
1. Open Settings → Claude API Budget
2. Enable budget tracking
3. Set monthly budget in USD
4. Get warnings when approaching limit

## Architecture

ClaudeBar maintains the same layered architecture as the macOS version:

```
ClaudeBar/
├── Sources/
│   ├── Domain/              # Pure business logic (unchanged)
│   │   ├── Provider/        # AI provider models
│   │   └── Monitor/         # QuotaMonitor actor
│   ├── Infrastructure/      # Linux adapters
│   │   ├── CLI/             # CLI probes (unchanged)
│   │   ├── Network/         # HTTP client (unchanged)
│   │   └── Notifications/   # Linux notifications
│   └── App/                 # GTK4 UI layer
│       ├── Main.swift       # Application entry
│       ├── StatusIconController.swift
│       ├── MenuPopover.swift
│       ├── SettingsDialog.swift
│       └── ThemeManager.swift
└── Tests/                   # Unit tests (unchanged)
```

**Key Changes from macOS:**
- ✅ **Domain & Infrastructure** - 100% compatible (no changes!)
- ⚡ **UI Layer** - Ported from SwiftUI → GTK4
- 🎨 **Styling** - CSS instead of SwiftUI modifiers
- 🔔 **Notifications** - GNotification instead of UNUserNotificationCenter
- 🗄️ **Storage** - UserDefaults (compatible on Linux)

## Development

### Build Commands

```bash
# Development build
swift build

# Release build
swift build -c release

# Run tests
swift test

# Run specific test
swift test --filter DomainTests
```

### Project Structure

All Domain and Infrastructure code is **shared** between macOS and Linux:
- Domain models work identically
- CLI probes are platform-agnostic
- Parsing logic is pure Swift

Only the **UI layer** differs (SwiftUI vs GTK4).

## Troubleshooting

### System Tray Not Showing

Some desktop environments require extensions:
```bash
# GNOME Shell - Install AppIndicator extension
sudo apt install gnome-shell-extension-appindicator

# Restart GNOME
Alt+F2, type 'r', press Enter
```

### GTK Theme Not Applying

Set GTK4 theme manually:
```bash
# Edit ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-application-prefer-dark-theme=1
```

### Notifications Not Working

Enable notifications for ClaudeBar:
```bash
# GNOME
gnome-control-center notifications

# Check permissions
notify-send "Test" "ClaudeBar notifications"
```

### Build Errors

**Missing GTK4:**
```
error: pkg-config: gtk4 not found
```
Solution: Install `libgtk-4-dev` (see Installation section)

**Swift version too old:**
```
error: package requires minimum Swift version 6.2
```
Solution: Install latest Swift with `swiftly install latest`

## Differences from macOS Version

| Feature | macOS | Linux |
|---------|-------|-------|
| UI Framework | SwiftUI | GTK4 |
| System Tray | NSStatusItem | GtkStatusIcon |
| Notifications | UNUserNotificationCenter | GNotification |
| Styling | SwiftUI modifiers | CSS |
| Auto-updates | Sparkle | Manual (no auto-update yet) |
| Domain/Infrastructure | ✅ Shared | ✅ Shared |

## Contributing

ClaudeBar for Linux is a complete port maintaining feature parity with macOS.

**Areas for contribution:**
- 📦 Package for distributions (.deb, .rpm, AUR)
- 🎨 Additional themes
- 🌍 Translations
- 📱 Wayland-specific optimizations
- 🔄 Auto-update mechanism

## License

Same license as the macOS version.

---

**Enjoy monitoring your AI usage on Linux! 🐧**
