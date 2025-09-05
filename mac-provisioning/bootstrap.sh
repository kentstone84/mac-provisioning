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
log_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error()   { echo -e "${RED}❌ $1${NC}"; }
log_step()    { echo -e "${PURPLE}🚀 $1${NC}"; }

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != darwin* ]]; then
        log_error "This script is designed for macOS only."
        exit 1
    fi
}

# Check for required tools
check_xcode_tools() {
    log_step "Checking for Xcode Command Line Tools..."
    if ! xcode-select -p &>/dev/null; then
        log_warning "Xcode Command Line Tools not found. Installing..."
        xcode-select --install || true
        log_info "Please complete the installation, then re-run this script."
        exit 1
    fi
    log_success "Xcode Command Line Tools found."
}

# Install Homebrew
install_homebrew() {
    if command -v brew &>/dev/null; then
        log_success "Homebrew already installed."
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
        log_success "Homebrew installed successfully."
    fi
}

# Install packages from Brewfile
install_packages() {
    log_step "Installing packages from Brewfile..."
    if [[ -f Brewfile ]]; then
        brew bundle --file=Brewfile --verbose
        log_success "All packages installed successfully."
    else
        log_error "Brewfile not found in current directory!"
        exit 1
    fi
}

# Configure shell
configure_shell() {
    log_step "Configuring shell..."

    local zshrc="$HOME/.zshrc"
    local additions_file="$HOME/.zshrc_additions"

    if [[ -f zshrc_additions ]]; then
        cp zshrc_additions "$additions_file"
        log_success "Copied zshrc_additions to home directory."
    fi

    if [[ -f "$zshrc" ]]; then
        if ! grep -q "zshrc_additions" "$zshrc"; then
            cat >> "$zshrc" << 'EOF'

# Source additional configurations
if [ -f ~/.zshrc_additions ]; then
    source ~/.zshrc_additions
fi
EOF
            log_success "Added sourcing of zshrc_additions to .zshrc."
        fi
    else
        cat > "$zshrc" << 'EOF'
# Basic zsh configuration
autoload -Uz compinit
compinit

# Source additional configurations
if [ -f ~/.zshrc_additions ]; then
    source ~/.zshrc_additions
fi
EOF
        log_success "Created new .zshrc with sourcing."
    fi
}

# Configure Git
configure_git() {
    log_step "Configuring Git..."

    # Check if global gitignore exists and copy if provided
    if [[ -f gitignore_global && ! -f "$HOME/.gitignore_global" ]]; then
        cp gitignore_global "$HOME/.gitignore_global"
        log_success "Copied global .gitignore file."
    fi

    # Check if .gitconfig template exists
    if [[ -f .gitconfig ]]; then
        if [[ ! -f "$HOME/.gitconfig" ]]; then
            cp .gitconfig "$HOME/.gitconfig"
            log_success "Copied .gitconfig template."
        fi
    fi

    # Configure user details if not already set
    if [[ -z "$(git config --global user.name || true)" ]]; then
        read -rp "Enter your Git username: " git_username
        git config --global user.name "$git_username"
    fi

    if [[ -z "$(git config --global user.email || true)" ]]; then
        read -rp "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    fi

    # Set basic Git configurations
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.autocrlf input
    git config --global core.excludesfile ~/.gitignore_global

    log_success "Git configured."
}

# Configure macOS defaults
configure_macos_defaults() {
    log_step "Setting macOS defaults..."

    if [[ -f macos_defaults.sh ]]; then
        chmod +x macos_defaults.sh
        ./macos_defaults.sh
        log_success "macOS defaults applied."
    else
        log_warning "macos_defaults.sh not found, skipping macOS configuration."
    fi
}

# Setup SSH
setup_ssh() {
    log_step "Setting up SSH..."

    if [[ ! -f "$HOME/.ssh/id_ed25519" && ! -f "$HOME/.ssh/id_rsa" ]]; then
        read -rp "Generate SSH key? (y/n): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            read -rp "Enter email for SSH key: " ssh_email
            ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519" -N ""

            eval "$(ssh-agent -s)"
            ssh-add "$HOME/.ssh/id_ed25519"

            pbcopy < "$HOME/.ssh/id_ed25519.pub"
            log_success "SSH key generated and copied to clipboard."
            log_info "Add this key to GitHub/GitLab/etc."
        fi
    else
        log_success "SSH key already exists."
    fi
}

# Create development directories
setup_directories() {
    log_step "Creating development directories..."

    mkdir -p "$HOME/Development/personal" \
             "$HOME/Development/work" \
             "$HOME/Development/opensource" \
             "$HOME/Desktop/Screenshots"

    log_success "Development directories created."
}

# Install VS Code extensions
install_vscode_extensions() {
    log_step "Installing VS Code extensions..."
    
    if command -v code &>/dev/null; then
        local extensions=(
            "ms-python.python"
            "ms-python.black-formatter"
            "ms-vscode.vscode-typescript-next"
            "bradlc.vscode-tailwindcss"
            "ms-vscode.vscode-json"
            "redhat.vscode-yaml"
            "ms-vscode.docker"
            "hashicorp.terraform"
            "github.copilot"
            "github.vscode-github-actions"
            "eamodio.gitlens"
            "esbenp.prettier-vscode"
            "ms-vscode.sublime-keybindings"
            "PKief.material-icon-theme"
            "zhuangtongfa.Material-theme"
        )

        for extension in "${extensions[@]}"; do
            if ! code --list-extensions | grep -q "$extension"; then
                log_info "Installing VS Code extension: $extension"
                code --install-extension "$extension" --force
            fi
        done
        log_success "VS Code extensions installed."
    else
        log_warning "VS Code not found, skipping extension installation."
    fi
}

# Check for version conflicts
check_version_conflicts() {
    log_step "Checking for potential version conflicts..."

    local warnings=0

    # Check for Python version managers
    if command -v pyenv &>/dev/null && brew list python@3.11 &>/dev/null; then
        log_warning "Both pyenv and Homebrew Python detected. Consider using one approach."
        ((warnings++))
    fi

    # Check for Node version managers
    if command -v fnm &>/dev/null && command -v node &>/dev/null; then
        log_info "Both fnm and system Node.js detected. Use 'fnm use' to switch versions."
    fi

    if [[ $warnings -eq 0 ]]; then
        log_success "No major version conflicts detected."
    else
        log_warning "$warnings potential conflicts found. Check the warnings above."
    fi
}

# Verify installation
verify_installation() {
    log_step "Verifying installation..."

    local errors=0
    
    # Check Homebrew
    if ! brew doctor &>/dev/null; then
        log_warning "Homebrew doctor found issues (may be normal)."
    fi

    # Check essential tools
    local tools=(
        "git:git --version"
        "node:node --version"
        "python3:python3 --version"
        "go:go version"
        "terraform:terraform version"
        "docker:docker --version"
    )
    
    for tool_check in "${tools[@]}"; do
        local tool="${tool_check%:*}"
        local cmd="${tool_check#*:}"
        
        if command -v "$tool" &>/dev/null; then
            local version
            version=$($cmd 2>/dev/null | head -n1 || echo "unknown")
            log_success "$tool: $version"
        else
            log_error "$tool not found."
            ((errors++))
        fi
    done

    # Check shell enhancements
    local shell_tools=("starship" "bat" "exa" "fzf")
    for tool in "${shell_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            log_success "$tool: installed"
        else
            log_warning "$tool not found (shell enhancement)."
        fi
    done

    if [[ $errors -eq 0 ]]; then
        log_success "All core verifications passed!"
    else
        log_warning "$errors core tools had issues."
    fi
}

# Cleanup
cleanup() {
    log_step "Cleaning up..."
    brew cleanup || true
    log_success "Cleanup completed."
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
    install_vscode_extensions
    check_version_conflicts
    verify_installation
    cleanup

    log_success "🎉 Provisioning complete!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Restart your terminal or run 'exec zsh' to apply shell changes"
    log_info "2. If you generated an SSH key, add it to GitHub/GitLab"
    log_info "3. Configure your Git user.name and user.email if not done already"
    log_info "4. Consider restarting your Mac for all system changes to take effect"

    # Restart system UI components
    killall Finder Dock SystemUIServer 2>/dev/null || true
}

# Set up error handling
trap 'log_error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"