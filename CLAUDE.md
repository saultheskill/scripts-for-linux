# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular Bash script library for Ubuntu 20-24 and Debian 10-12 server initialization. It provides automated configuration for shell environments, containerization tools, development tools, and security settings.

## Architecture

### Script Organization

```
scripts-for-linux/
├── install.sh              # Main entry point with interactive menu
├── scripts/common.sh       # Shared library: logging, package management, UI functions
├── scripts/shell/          # ZSH environment (modular: core + plugins)
├── scripts/containers/     # Docker installation and image management
├── scripts/development/    # Neovim setup
├── scripts/security/       # SSH configuration
├── scripts/system/         # Time sync and system config
├── scripts/utilities/      # Disk formatting tools
├── scripts/beautify/       # Beautify tools (eza, fzf, bat)
├── scripts/software/       # Common software installation
└── bash-scripts/           # Standalone advanced tools (docker-push-auto.sh, etc.)
```

### Key Design Patterns

1. **Common Library Pattern**: All scripts source `scripts/common.sh` for:
   - Color-coded logging (`log_info`, `log_warn`, `log_error`, `log_debug`)
   - Package manager abstraction (`install_package`, `update_package_manager`)
   - Interactive UI components (`interactive_ask_confirmation`, `select_menu`)
   - System detection (`detect_os`, `detect_arch`, `check_root`)

2. **Modular ZSH Installation**: Split into two independent scripts:
   - `zsh-core-install.sh`: ZSH shell, Oh My Zsh, Powerlevel10k theme
   - `zsh-plugins-install.sh`: Plugins (autosuggestions, syntax-highlighting, zoxide, tmux, ssh-agent)
   - Core must be installed before plugins; plugins script checks for core installation
   - ZSH plugins include: git, extract, systemadmin, zsh-interactive-cd, systemd, sudo, docker, ubuntu, man, command-not-found, common-aliases, docker-compose, zsh-autosuggestions, zsh-syntax-highlighting, tmux, you-should-use, ssh-agent

3. **Error Handling Strategy**:
   - `set -e` for immediate exit on errors
   - `trap 'handle_error $LINENO $?' ERR` for centralized error handling
   - Rollback functions in complex scripts
   - Non-zero exit codes propagate but don't crash the main menu

4. **Interactive Menu System**:
   - `select_menu` function provides keyboard-navigable menus (arrow keys, vim keys)
   - Falls back to default selection in non-interactive environments
   - Ctrl+C handling returns exit code 130

## Common Development Commands

### Testing Scripts

```bash
# Syntax check a script
bash -n scripts/shell/zsh-core-install.sh

# Run with debug output
bash -x scripts/shell/zsh-core-install.sh

# Run with full logging
LOG_LEVEL=0 bash install.sh
```

### Running Individual Components

```bash
# Main interactive installer
bash install.sh

# Individual modules (can run standalone)
bash scripts/shell/zsh-core-install.sh
bash scripts/shell/zsh-plugins-install.sh
bash scripts/shell/zsh-plugins-install.sh --tmux-help  # Show tmux key bindings
bash scripts/containers/docker-install.sh
bash scripts/development/nvim-setup.sh
bash scripts/security/ssh-config.sh
bash scripts/beautify/beautify-install.sh  # Install eza, fzf, bat, tmuxinator

# Advanced standalone tools
bash bash-scripts/docker-push-auto.sh
bash bash-scripts/harbor-push-auto.sh
bash bash-scripts/ssh-agent-auto.sh
```

### Project Maintenance

```bash
# Make scripts executable
chmod +x scripts/**/*.sh

# Check for bash syntax errors in all scripts
for f in scripts/**/*.sh; do bash -n "$f" || echo "Syntax error in $f"; done
```

## Important Implementation Details

### Common.sh Key Functions

- `execute_command "$cmd" "$description"`: Runs commands with detailed logging
- `verify_command "$cmd" "$package"`: Confirms installation success
- `interactive_ask_confirmation "$message" "$default"`: Returns 0/1 for yes/no
- `select_menu "$array_name" "$message" "$default_index"`: Sets `MENU_SELECT_RESULT` and `MENU_SELECT_INDEX`

### Script Entry Pattern

All scripts follow this pattern:
```bash
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd 2>/dev/null)"
source "$SCRIPT_DIR/../common.sh"  # Adjust path as needed
# ... script logic ...
```

### Architecture-Specific Handling

The main `install.sh` detects ARM architecture and routes to `zsh-arm.sh` instead of the modular x86 scripts:
```bash
case "$arch" in
    aarch64|armv7l)
        execute_local_script "shell/zsh-arm.sh" "ARM版ZSH环境"
        ;;
    *)
        # Modular x86 approach
        execute_local_script "shell/zsh-core-install.sh" "ZSH核心环境"
        execute_local_script "shell/zsh-plugins-install.sh" "ZSH插件和工具"
        ;;
esac
```

### Third-Party Dependencies

The `install.sh` script uses external mirror configuration scripts:
- `https://linuxmirrors.cn/main.sh` - System package mirror configuration
- `https://linuxmirrors.cn/docker.sh` - Docker installation and registry mirrors

### Configuration Files

- ZSH configs are backed up to `~/.zshrc.backup.*` before modification
- Docker push tool stores config in `~/.docker-push-config`
- Themes are in `themes/powerlevel10k/` (dracula, rainbow, emoji variants)
- Eza theme config: `~/.config/eza/theme.yml`
- Tmuxinator project configs: `tmuxinator/*.yml`
- Tmux plugins config: `~/.tmux.conf.local` (includes tmux-resurrect and tmux-continuum)

### Environment Variables

- `INSTALLER_CALLED=1`: Set by `install.sh` when calling sub-scripts to skip duplicate confirmations
- `LOG_LEVEL=0`: Enable DEBUG level logging (0=DEBUG, 1=INFO, 2=WARN, 3=ERROR)
- `TERM=xterm-256color`: Required for proper color support

## Testing Considerations

- Scripts target Ubuntu 20.04+ and Debian 10+ primarily
- ARM64 support varies by script (check `zsh-arm.sh` vs `zsh-core-install.sh`)
- Network connectivity is checked before downloads
- All scripts can run in non-interactive mode with sensible defaults

## Recent Updates

### 2025-02-08
- Added `scripts/beautify/` module with eza, fzf (0.67.0), bat, tmuxinator support
- Added tmuxinator installation with Ruby dependency handling and shell completions
- Added ssh-agent plugin to ZSH configuration
- Fixed Powerlevel10k instant prompt compatibility with ssh-agent
- Unified all scripts to use `select_menu` and `interactive_ask_confirmation` from `common.sh`
- Added `--tmux-help` flag to `zsh-plugins-install.sh` for displaying tmux key bindings
- Optimized `install_tmux_config()` to use official Oh My Tmux installation script
- Added tmux-resurrect and tmux-continuum plugins configuration for session save/restore
- Created `tmuxinator/` directory with 5 common project templates (basic, docker-dev, kubernetes, monitoring, web-dev)
