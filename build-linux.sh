#!/bin/bash
# Build script for ClaudeBar on Linux

set -e

echo "🔨 Building ClaudeBar for Linux..."

# Check dependencies
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is not installed. Please install Swift for Linux."
    echo "   Visit: https://www.swift.org/download/"
    exit 1
fi

if ! pkg-config --exists gtk4; then
    echo "❌ GTK4 is not installed. Please install GTK4 development libraries."
    echo "   Ubuntu/Debian: sudo apt install libgtk-4-dev"
    echo "   Fedora: sudo dnf install gtk4-devel"
    echo "   Arch: sudo pacman -S gtk4"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
swift package clean

# Build the project
echo "📦 Building project..."
swift build -c release

# Check if build succeeded
if [ -f ".build/release/claudebar" ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📍 Executable location: .build/release/claudebar"
    echo ""
    echo "To install system-wide:"
    echo "  sudo cp .build/release/claudebar /usr/local/bin/"
    echo ""
    echo "To run:"
    echo "  ./.build/release/claudebar"
else
    echo "❌ Build failed!"
    exit 1
fi
