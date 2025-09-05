#!/usr/bin/env bash

set -e

echo "🚀 Starting Mac provisioning..."

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure Brewfile dependencies
echo "📦 Installing Homebrew dependencies..."
brew bundle --file=Brewfile

# Add LLVM and common configs to zshrc
echo "⚙️  Configuring shell..."
CONFIG_FILE="$HOME/.zshrc"
if ! grep -q "### Custom Mac Provisioning" "$CONFIG_FILE"; then
  {
    echo ""
    echo "### Custom Mac Provisioning"
    echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"'
    echo 'export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"'
    echo 'export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"'
  } >> "$CONFIG_FILE"
fi

# Copy extra configs if needed
mkdir -p ~/.config/clang
cp configs/arm64-apple-darwin24.cfg ~/.config/clang/ 2>/dev/null || true

echo "✅ Provisioning complete! Restart your shell."
