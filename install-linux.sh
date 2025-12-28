#!/bin/bash
# Installation script for ClaudeBar on Linux

set -e

echo "📦 Installing ClaudeBar..."

# Check if binary exists
if [ ! -f ".build/release/claudebar" ]; then
    echo "❌ Binary not found. Please run ./build-linux.sh first."
    exit 1
fi

# Install binary
echo "📍 Installing binary to /usr/local/bin..."
sudo cp .build/release/claudebar /usr/local/bin/

# Create desktop entry
echo "🖥️ Creating desktop entry..."
cat > claudebar.desktop <<EOF
[Desktop Entry]
Name=ClaudeBar
Comment=AI Usage Monitor for Linux
Exec=/usr/local/bin/claudebar
Icon=utilities-system-monitor
Terminal=false
Type=Application
Categories=Utility;System;
StartupNotify=false
EOF

sudo cp claudebar.desktop /usr/share/applications/
rm claudebar.desktop

echo "✅ Installation complete!"
echo ""
echo "ClaudeBar has been installed to /usr/local/bin/claudebar"
echo ""
echo "To run:"
echo "  claudebar"
echo ""
echo "Or search for 'ClaudeBar' in your application menu."
