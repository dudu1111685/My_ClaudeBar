#!/bin/bash
# Complete setup script for ClaudeBar on Linux
# Installs all dependencies and builds the application

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ClaudeBar Linux Setup & Installation  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo -e "${RED}❌ Cannot detect Linux distribution${NC}"
    exit 1
fi

echo -e "${GREEN}📍 Detected distribution: $PRETTY_NAME${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Please run this script as a regular user (not root)${NC}"
    echo "   Sudo will be requested when needed."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Install Swift
echo -e "${BLUE}[1/5] Checking Swift installation...${NC}"
if command_exists swift; then
    SWIFT_VERSION=$(swift --version | head -n1)
    echo -e "${GREEN}✅ Swift is already installed: $SWIFT_VERSION${NC}"
else
    echo -e "${YELLOW}📥 Swift not found. Installing Swift...${NC}"

    if command_exists swiftly; then
        echo "Using swiftly to install Swift..."
        swiftly install latest
    else
        echo "Installing swiftly first..."
        curl -s https://swiftlang.github.io/swiftly/swiftly-install.sh | bash

        # Source the swiftly environment
        export PATH="$HOME/.local/bin:$PATH"

        echo "Installing Swift..."
        swiftly install latest
    fi

    # Verify installation
    if command_exists swift; then
        echo -e "${GREEN}✅ Swift installed successfully${NC}"
    else
        echo -e "${RED}❌ Swift installation failed. Please install manually:${NC}"
        echo "   Visit: https://www.swift.org/download/"
        exit 1
    fi
fi
echo ""

# Step 2: Install GTK4 and dependencies
echo -e "${BLUE}[2/5] Installing GTK4 and dependencies...${NC}"

case "$DISTRO" in
    ubuntu|debian|pop)
        echo "Installing via apt..."
        sudo apt update
        sudo apt install -y libgtk-4-dev libglib2.0-dev pkg-config git build-essential
        ;;
    fedora)
        echo "Installing via dnf..."
        sudo dnf install -y gtk4-devel glib2-devel pkg-config git
        ;;
    arch|manjaro)
        echo "Installing via pacman..."
        sudo pacman -S --noconfirm gtk4 glib2 pkg-config git base-devel
        ;;
    opensuse*)
        echo "Installing via zypper..."
        sudo zypper install -y gtk4-devel glib2-devel pkg-config git
        ;;
    *)
        echo -e "${YELLOW}⚠️  Unsupported distribution: $DISTRO${NC}"
        echo "Please install these packages manually:"
        echo "  - GTK4 development libraries"
        echo "  - GLib 2.0 development libraries"
        echo "  - pkg-config"
        echo "  - git"
        exit 1
        ;;
esac

# Verify GTK4 installation
if pkg-config --exists gtk4; then
    GTK_VERSION=$(pkg-config --modversion gtk4)
    echo -e "${GREEN}✅ GTK4 installed: version $GTK_VERSION${NC}"
else
    echo -e "${RED}❌ GTK4 installation failed${NC}"
    exit 1
fi
echo ""

# Step 3: Install Node.js and AI CLI tools (optional but recommended)
echo -e "${BLUE}[3/5] Checking AI CLI tools...${NC}"

if ! command_exists node; then
    echo -e "${YELLOW}📥 Node.js not found. Installing Node.js...${NC}"

    case "$DISTRO" in
        ubuntu|debian|pop)
            # Install Node.js 20.x via NodeSource
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt install -y nodejs
            ;;
        fedora)
            sudo dnf install -y nodejs
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm nodejs npm
            ;;
        *)
            echo -e "${YELLOW}⚠️  Please install Node.js manually for CLI tools${NC}"
            ;;
    esac
fi

if command_exists npm; then
    echo -e "${GREEN}✅ Node.js/npm installed${NC}"
    echo ""
    echo "You can now install AI CLI tools:"
    echo "  • Claude: npm install -g @anthropics/claude-cli"
    echo "  • Codex:  npm install -g @openai/codex-cli"
    echo "  • Gemini: npm install -g @google/gemini-cli"
else
    echo -e "${YELLOW}⚠️  Node.js not installed - AI CLI tools will need manual installation${NC}"
fi
echo ""

# Step 4: Build ClaudeBar
echo -e "${BLUE}[4/5] Building ClaudeBar...${NC}"

# Clean previous builds
if [ -d ".build" ]; then
    echo "Cleaning previous builds..."
    swift package clean
fi

# Resolve dependencies
echo "Resolving Swift package dependencies..."
swift package resolve

# Build release version
echo "Building release binary..."
swift build -c release

if [ -f ".build/release/claudebar" ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
else
    echo -e "${RED}❌ Build failed!${NC}"
    echo "Check the error messages above."
    exit 1
fi
echo ""

# Step 5: Install
echo -e "${BLUE}[5/5] Installing ClaudeBar...${NC}"

# Install binary
echo "Installing binary to /usr/local/bin..."
sudo cp .build/release/claudebar /usr/local/bin/

# Create desktop entry
echo "Creating desktop entry..."
cat > /tmp/claudebar.desktop <<EOF
[Desktop Entry]
Name=ClaudeBar
Comment=AI Usage Monitor for Linux
Exec=/usr/local/bin/claudebar
Icon=utilities-system-monitor
Terminal=false
Type=Application
Categories=Utility;System;Monitor;
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

sudo cp /tmp/claudebar.desktop /usr/share/applications/
rm /tmp/claudebar.desktop

# Update desktop database
if command_exists update-desktop-database; then
    sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Setup Complete! 🎉              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}ClaudeBar is now installed!${NC}"
echo ""
echo "To run ClaudeBar:"
echo -e "  ${YELLOW}claudebar${NC}"
echo ""
echo "Or search for 'ClaudeBar' in your application menu."
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Install AI CLI tools (if not already installed):"
echo "   • Claude: npm install -g @anthropics/claude-cli"
echo "   • Codex:  npm install -g @openai/codex-cli"
echo "   • Gemini: npm install -g @google/gemini-cli"
echo ""
echo "2. Login to your AI providers:"
echo "   • claude login"
echo "   • codex auth login"
echo "   • gemini auth login"
echo ""
echo "3. Launch ClaudeBar and enjoy! 🚀"
echo ""
