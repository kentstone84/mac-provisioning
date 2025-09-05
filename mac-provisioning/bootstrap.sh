#!/usr/bin/env bash

# Enhanced Mac Provisioning Script
# Exit on any error, undefined variables, and pipe failures
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_step() { echo -e "${PURPLE}🚀 $1${NC}"; }

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
}

# Check for required tools
check_xcode_tools() {
    log_step "Checking for Xcode Command Line Tools..."
    if ! xcode-select -p &>/dev/null; then
        log_warning "Xcode Command Line Tools not found. Installing..."
        xcode-select --install
        log_info "Please complete the Xcode Command Line Tools installation and re-run this script"
        exit 1
    fi
    log_success "Xcode Command Line Tools found"
}

# Install Homebrew
install_homebrew() {
    if command -v brew &>/dev/null; then
        log_success "Homebrew already installed"
        log_info "Updating Homebrew..."
        brew update
    else
        log_step "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log_success "Homebrew installed successfully"
    fi
}

# Install packages from Brewfile
install_packages() {
    log_step "Installing packages from Brewfile..."
    if [[ -f "Brewfile" ]]; then
        brew bundle --file=Brewfile --verbose
        log_success "All packages installed successfully"
    else
        log_error "Brewfile not found!"
        exit 1
    fi
}

# Configure shell
configure_shell() {
    log_step "Configuring shell..."
    
    local zshrc="$HOME/.zshrc"
    local additions_file="$HOME/.zshrc_additions"
    
    # Copy our additions file to home directory
    if [[ -f "zshrc_additions" ]]; then
        cp zshrc_additions "$additions_file"
        log_success "Copied shell configuration"
    fi
    
    # Add sourcing line to .zshrc if not present
    if [[ -f "$zshrc" ]] && ! grep -q "zshrc_additions" "$zshrc"; then
        cat >> "$zshrc" << 'EOF'

# Source additional configurations from provisioning
if [ -f ~/.zshrc_additions ]; then
    source ~/.zshrc_additions
fi
EOF
        log_success "Added sourcing to .zshrc"
    elif [[ ! -f "$zshrc" ]]; then
        cat > "$zshrc" << 'EOF'
# Basic zsh configuration
autoload -Uz compinit
compinit

# Source additional configurations from provisioning
if [ -f ~/.zshrc_additions ]; then
    source ~/.zshrc_additions
fi
EOF
        log_success "Created new .zshrc with sourcing"
    fi
}

# Configure Git (if not already configured)
configure_git() {
    log_step "Configuring Git..."
    
    if [[ -z "$(git config --global user.name 2>/dev/null || true)" ]]; then
        read -p "Enter your Git username: " git_username
        git config --global user.name "$git_username"
    fi
    
    if [[ -z "$(git config --global user.email 2>/dev/null || true)" ]]; then
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    fi
    
    # Set some sensible Git defaults
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.autocrlf input
    
    log_success "Git configured"
}

# Configure macOS defaults
configure_macos_defaults() {
    log_step "Setting macOS defaults..."
    
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    
    # Faster dock animation
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    
    # Remove dock hide delay
    defaults write com.apple.dock autohide-delay -float 0
    
    # Show battery percentage
    defaults write com.apple.menuextra.battery ShowPercent -bool true
    
    # Disable screenshot shadows
    defaults write com.apple.screencapture disable-shadow -bool true
    
    # Set up better screenshot location
    mkdir -p "$HOME/Desktop/Screenshots"
    defaults write com.apple.screencapture location "$HOME/Desktop/Screenshots"
    
    log_success "macOS defaults configured"
}

# Generate SSH key if needed
setup_ssh() {
    log_step "Setting up SSH..."
    
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]] && [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
        read -p "Generate SSH key? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Enter email for SSH key: " ssh_email
            ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519" -N ""
            
            # Start ssh-agent and add key
            eval "$(ssh-agent -s)"
            ssh-add "$HOME/.ssh/id_ed25519"
            
            # Copy public key to clipboard
            pbcopy < "$HOME/.ssh/id_ed25519.pub"
            log_success "SSH key generated and copied to clipboard"
            log_info "Add this key to your GitHub/GitLab account"
        fi
    else
        log_success "SSH key already exists"
    fi
}

# Create useful directories
setup_directories() {
    log_step "Creating development directories..."
    
    mkdir -p "$HOME/Development"
    mkdir -p "$HOME/Development/personal"
    mkdir -p "$HOME/Development/work"
    mkdir -p "$HOME/Development/opensource"
    
    log_success "Development directories created"
}

# Verify installation
verify_installation() {
    log_step "Verifying installation..."
    
    local errors=0
    
    # Check Homebrew
    if ! brew doctor &>/dev/null; then
        log_warning "Homebrew doctor found issues (this might be normal)"
    fi
    
    # Check key tools
    local tools=("git" "node" "python3" "go" "terraform")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            local version=$($tool --version 2>/dev/null | head -n1 || echo "unknown")
            log_success "$tool: $version"
        else
            log_error "$tool not found"
            ((errors++))
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        log_success "All verifications passed!"
    else
        log_warning "$errors tools had issues"
    fi
}

# Cleanup function
cleanup() {
    log_step "Cleaning up..."
    brew cleanup
    log_success "Cleanup completed"
}

# Main execution
main() {
    log_step "Starting Mac provisioning..."
    
    check_macos
    check_xcode_tools
    install_homebrew
    install_packages
    configure_shell
    configure_git
    configure_macos_defaults
    setup_ssh
    setup_directories
    verify_installation
    cleanup
    
    log_success "🎉 Provisioning complete!"
    log_info "Please restart your terminal or run 'exec zsh' to apply shell changes"
    
    # Restart Finder and Dock to apply changes
    killall Finder Dock 2>/dev/null || true
}

# Handle script interruption
trap 'log_error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
