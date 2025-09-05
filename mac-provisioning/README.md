# 🚀 Mac Development Environment Provisioning

> Transform a fresh macOS into a fully-configured development machine with one command.

[![macOS](https://img.shields.io/badge/macOS-Sequoia%2B-blue.svg)](https://www.apple.com/macos/)
[![Shell](https://img.shields.io/badge/shell-zsh-green.svg)](https://www.zsh.org/)
[![Homebrew](https://img.shields.io/badge/package%20manager-Homebrew-orange.svg)](https://brew.sh/)

## ✨ What This Does

This provisioning kit automatically configures your Mac with:

- **🛠️ Development Tools**: Git, Node.js, Python, Go, Rust, Docker, and more
- **📱 Essential Apps**: VS Code, iTerm2, Raycast, Slack, Chrome, and productivity tools
- **⚙️ System Configuration**: Sensible macOS defaults and optimizations
- **🎨 Terminal Enhancement**: Starship prompt, syntax highlighting, and useful aliases
- **🔧 Developer Environment**: Language version managers, shell completions, and configurations

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/mac-provisioning.git
cd mac-provisioning

# Make the script executable
chmod +x bootstrap.sh

# Run the provisioning (will prompt for passwords and preferences)
./bootstrap.sh
```

**That's it!** ☕ Go grab a coffee while your Mac gets configured.

## 📋 What Gets Installed

<details>
<summary><strong>🔧 Core Development Tools</strong></summary>

- **Version Control**: Git, GitHub CLI, GitLab CLI, Lazygit
- **Languages**: Python (3.11, 3.12), Node.js, Go, Rust, Java (11, 17, 21)
- **Package Managers**: Homebrew, npm, yarn, pnpm, pip, poetry, maven, gradle
- **Runtime Managers**: chruby, pyenv, fnm
- **Build Tools**: cmake, ninja, automake, bison

</details>

<details>
<summary><strong>☁️ Cloud & DevOps</strong></summary>

- **Infrastructure**: Terraform, Ansible, Docker, Kubernetes
- **Cloud CLIs**: AWS CLI, Azure CLI, Google Cloud SDK
- **Monitoring**: kubectl, helm, k9s

</details>

<details>
<summary><strong>🗄️ Databases & Data</strong></summary>

- **Databases**: PostgreSQL, MySQL, Redis, SQLite, MongoDB
- **Management**: TablePlus, Sequel Pro, Redis Insight

</details>

<details>
<summary><strong>📱 Applications</strong></summary>

- **Editors**: VS Code, Cursor, JetBrains Toolbox, Sublime Text
- **Terminals**: iTerm2, Warp, Alacritty
- **Productivity**: Raycast, Rectangle, Obsidian, Notion
- **Communication**: Slack, Discord, Zoom, Telegram
- **Browsers**: Chrome, Firefox, Arc, Brave
- **Media**: Spotify, VLC, IINA

</details>

<details>
<summary><strong>⚙️ System Enhancements</strong></summary>

- **Shell**: Zsh with autosuggestions, syntax highlighting, and completions
- **Prompt**: Starship cross-shell prompt
- **Utilities**: bat, exa, ripgrep, fd, fzf, htop, tree
- **QuickLook**: Plugins for code, markdown, JSON, and more

</details>

## 📁 Project Structure

```
mac-provisioning/
├── 📜 bootstrap.sh           # Main provisioning script
├── 📦 Brewfile              # Homebrew package definitions
├── 🐚 zshrc_additions       # Shell configuration and aliases
├── 🍎 macos_defaults.sh     # macOS system preferences
├── 📝 README.md             # This file
├── ⚙️  configs/
│   ├── .gitconfig           # Global Git configuration
│   └── .gitignore_global    # Global Git ignore rules
└── 📚 docs/
    ├── customization.md     # How to customize the setup
    └── troubleshooting.md   # Common issues and solutions
```

## 🎛️ Customization

### Adding/Removing Packages

Edit the `Brewfile` to add or remove packages:

```ruby
# Add a new CLI tool
brew "neovim"

# Add a new application
cask "figma"

# Comment out to skip installation
# cask "slack"
```

### Custom Shell Configuration

Add your personal aliases and functions to `zshrc_additions`:

```bash
# Custom aliases
alias myproject="cd ~/Development/my-awesome-project"
alias weather="curl wttr.in"

# Custom functions
mkcd() { mkdir -p "$1" && cd "$1"; }
```

### System Preferences

Modify `macos_defaults.sh` to change system settings:

```bash
# Change dock size
defaults write com.apple.dock tilesize -int 64

# Enable dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
```

## 🔧 Advanced Usage

### Selective Installation

Run specific parts of the setup:

```bash
# Only install Homebrew packages
brew bundle --file=Brewfile

# Only configure macOS defaults
./macos_defaults.sh

# Only configure shell
source zshrc_additions
```

### Backup Current Settings

Before running, backup your current configuration:

```bash
# Backup current settings
cp ~/.zshrc ~/.zshrc.backup
cp ~/.gitconfig ~/.gitconfig.backup
```

## 🆘 Troubleshooting

### Common Issues

**Homebrew Installation Fails**
```bash
# Manually install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**App Store Applications Won't Install**
- Make sure you're signed into the App Store
- Some apps may require manual installation

**Permission Errors**
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew
```

### Getting Help

1. Check the [troubleshooting guide](docs/troubleshooting.md)
2. Run `brew doctor` to diagnose Homebrew issues
3. Open an issue on GitHub with error details

## 📱 Verification

After installation, verify everything works:

```bash
# Check installed versions
git --version
node --version
python3 --version
go version

# Verify Homebrew health
brew doctor

# Test shell enhancements
which starship
which bat
which exa
```

## 🔄 Updates

Keep your setup current:

```bash
# Update the provisioning scripts
git pull origin main

# Re-run to apply updates
./bootstrap.sh

# Update all packages
brew update && brew upgrade
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-tool`)
3. Test your changes on a fresh macOS installation
4. Commit your changes (`git commit -m 'Add amazing development tool'`)
5. Push to the branch (`git push origin feature/amazing-tool`)
6. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
- Built with [Homebrew](https://brew.sh/)
- Shell enhancements powered by [Starship](https://starship.rs/)

## 📞 Support

- 💬 **Issues**: [GitHub Issues](https://github.com/kentstone84/mac-provisioning/issues)
- 📧 **Email**: kent.stone@gmail.com    

---

<p align="center">Made with ❤️ for macOS developers</p>
<p align="center">⭐ Star this repo if it helped you!</p>
