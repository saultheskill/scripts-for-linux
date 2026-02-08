#!/bin/bash

# =============================================================================
# Eza 美化工具安装脚本
# 作者: saul
# 版本: 1.0
# 描述: 自动安装 eza（现代化的 ls 替代品）并配置 ZSH 别名
# 支持平台: Ubuntu 20-24, Debian 10-12, x64/ARM64
# =============================================================================

set -e

# =============================================================================
# 导入通用函数库
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [ -f "$SCRIPT_DIR/../common.sh" ]; then
    source "$SCRIPT_DIR/../common.sh"
else
    echo "错误：找不到 common.sh 文件"
    echo "请确保在项目根目录中运行此脚本"
    exit 1
fi

# =============================================================================
# Eza 安装函数
# =============================================================================

# 检查 eza 是否已安装
check_eza_installed() {
    if command -v eza >/dev/null 2>&1; then
        log_info "eza 已安装: $(eza --version 2>/dev/null | head -1 || echo '版本信息不可用')"
        return 0
    else
        return 1
    fi
}

# 安装 GPG（如果需要）
install_gpg_if_needed() {
    if ! command -v gpg >/dev/null 2>&1; then
        log_info "安装 GPG..."
        apt update >/dev/null 2>&1
        apt install -y gpg
    fi
}

# 添加 eza 软件源
add_eza_repository() {
    log_info "添加 eza 软件源..."

    # 创建 keyrings 目录
    mkdir -p /etc/apt/keyrings

    # 下载 GPG 密钥
    local gpg_key_url="https://raw.githubusercontent.com/eza-community/eza/main/deb.asc"
    log_info "下载 GPG 密钥..."
    if ! wget -qO- "$gpg_key_url" | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg; then
        log_error "下载 GPG 密钥失败"
        return 1
    fi

    # 添加软件源
    local arch=$(dpkg --print-architecture)
    echo "deb [arch=$arch signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
        tee /etc/apt/sources.list.d/gierens.list >/dev/null

    # 设置权限
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

    log_info "软件源添加成功"
    return 0
}

# 安装 eza
install_eza_package() {
    log_info "更新软件包列表..."
    if ! apt update; then
        log_error "apt update 失败"
        return 1
    fi

    log_info "安装 eza..."
    if ! apt install -y eza; then
        log_error "eza 安装失败"
        return 1
    fi

    log_info "eza 安装成功"
    return 0
}

# 配置 ZSH 别名
configure_zsh_aliases() {
    log_info "配置 ZSH 别名..."

    local zshrc="$HOME/.zshrc"

    # 检查 .zshrc 是否存在
    if [ ! -f "$zshrc" ]; then
        log_warn "找不到 $zshrc，跳过别名配置"
        return 1
    fi

    # 检查是否已配置 eza 别名
    if grep -q "# Eza aliases" "$zshrc"; then
        log_info "eza 别名已配置，跳过"
        return 0
    fi

    # 添加 eza 别名配置
    cat >> "$zshrc" << 'EOF'

# Eza aliases
alias ls='eza --color=always --group-directories-first --icons=auto'
alias ll='eza --color=always --group-directories-first --icons=auto -lh --header'
alias la='eza --color=always --group-directories-first --icons=auto -a'
alias lla='eza --color=always --group-directories-first --icons=auto -lha --header'
alias lt='eza --color=always --group-directories-first --icons=auto --tree'
alias llt='eza --color=always --group-directories-first --icons=auto -l --tree --header'
alias l='eza --color=always --group-directories-first --icons=auto'
EOF

    log_info "ZSH 别名配置完成"
    return 0
}

# 配置 eza 主题（可选）
configure_eza_theme() {
    log_info "配置 eza 主题..."

    local eza_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/eza"
    mkdir -p "$eza_config_dir"

    # 创建主题文件
    cat > "$eza_config_dir/theme.yml" << 'EOF'
# Eza Theme Configuration
# 更多主题选项请参考: https://github.com/eza-community/eza-themes

colors:
  # 文件类型颜色
  filekinds:
    normal: { foreground: "#c0caf5" }
    directory: { foreground: "#7aa2f7" }
    symlink: { foreground: "#9ece6a" }
    executable: { foreground: "#e0af68" }

  # 权限颜色
  permissions:
    read: { foreground: "#9ece6a" }
    write: { foreground: "#e0af68" }
    execute: { foreground: "#f7768e" }

  # 文件大小颜色
  size:
    major: { foreground: "#7aa2f7" }
    minor: { foreground: "#bb9af7" }

  # 用户和组颜色
  users:
    user_you: { foreground: "#9ece6a" }
    user_root: { foreground: "#f7768e" }
    other: { foreground: "#c0caf5" }
EOF

    log_info "主题配置完成: $eza_config_dir/theme.yml"
    return 0
}

# =============================================================================
# tmuxinator 安装函数
# =============================================================================

# 检查 Ruby 是否已安装
check_ruby_installed() {
    if command -v ruby >/dev/null 2>&1; then
        log_info "Ruby 已安装: $(ruby --version 2>/dev/null | head -1)"
        return 0
    else
        return 1
    fi
}

# 安装 Ruby
install_ruby() {
    log_info "安装 Ruby..."

    if apt install -y ruby-full 2>/dev/null; then
        log_info "Ruby 安装成功"
        return 0
    else
        log_error "Ruby 安装失败"
        return 1
    fi
}

# 检查 tmuxinator 是否已安装
check_tmuxinator_installed() {
    if command -v tmuxinator >/dev/null 2>&1; then
        log_info "tmuxinator 已安装: $(tmuxinator version 2>/dev/null)"
        return 0
    else
        return 1
    fi
}

# 安装 tmuxinator
install_tmuxinator() {
    log_info "开始安装 tmuxinator..."

    # 检查是否已安装
    if check_tmuxinator_installed; then
        if interactive_ask_confirmation "tmuxinator 已安装，是否重新安装/配置？" "false"; then
            log_info "继续重新安装..."
        else
            log_info "跳过安装"
            show_tmuxinator_usage
            return 0
        fi
    fi

    # 检查并安装 Ruby
    if ! check_ruby_installed; then
        log_info "tmuxinator 需要 Ruby 环境"
        if ! install_ruby; then
            log_error "Ruby 安装失败，无法继续安装 tmuxinator"
            return 1
        fi
    fi

    # 安装 tmuxinator gem
    log_info "安装 tmuxinator gem..."
    if gem install tmuxinator 2>/dev/null; then
        log_info "tmuxinator 安装成功"
    else
        log_error "tmuxinator gem 安装失败"
        return 1
    fi

    # 确保 gem 二进制文件目录在 PATH 中
    local gem_bin_path="$(ruby -e 'puts Gem.bindir' 2>/dev/null || echo "$HOME/.local/share/gem/ruby/3.0.0/bin")"
    if [ -d "$gem_bin_path" ] && [[ ":$PATH:" != *":$gem_bin_path:"* ]]; then
        log_info "添加 gem 二进制目录到 PATH..."
        echo "export PATH=\"$gem_bin_path:\$PATH\"" >> "$HOME/.zshrc"
    fi

    # 安装 shell 补全
    install_tmuxinator_completions

    # 显示使用说明
    show_tmuxinator_usage

    return 0
}

# 安装 tmuxinator shell 补全
install_tmuxinator_completions() {
    log_info "配置 tmuxinator 命令补全..."

    local zsh_completion_dir="/usr/local/share/zsh/site-functions"
    mkdir -p "$zsh_completion_dir"

    # 下载 zsh 补全文件
    if wget -q "https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh" -O "$zsh_completion_dir/_tmuxinator" 2>/dev/null; then
        log_info "ZSH 补全配置完成"
    else
        log_warn "ZSH 补全下载失败，不影响正常使用"
    fi
}

# 显示 tmuxinator 使用说明
show_tmuxinator_usage() {
    echo
    echo -e "${CYAN}tmuxinator 使用说明：${RESET}"
    echo
    echo -e "${GREEN}常用命令：${RESET}"
    echo -e "  ${YELLOW}tmuxinator new [project]${RESET}     - 创建新项目配置"
    echo -e "  ${YELLOW}tmuxinator start [project]${RESET}   - 启动项目会话"
    echo -e "  ${YELLOW}tmuxinator stop [project]${RESET}    - 停止项目会话"
    echo -e "  ${YELLOW}tmuxinator list${RESET}              - 列出所有项目"
    echo -e "  ${YELLOW}tmuxinator copy [old] [new]${RESET}  - 复制项目配置"
    echo -e "  ${YELLOW}tmuxinator delete [project]${RESET}  - 删除项目配置"
    echo -e "  ${YELLOW}mux [project]${RESET}                - 快捷命令（tmuxinator 别名）"
    echo
    echo -e "${GREEN}示例配置 (~/.config/tmuxinator/sample.yml)：${RESET}"
    cat << 'EOF'
name: sample
root: ~/projects/sample

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
  - server: bundle exec rails s
  - logs: tail -f log/development.log
EOF
    echo
    echo -e "${YELLOW}提示：重新登录或运行 'source ~/.zshrc' 使配置生效${RESET}"
    echo -e "${YELLOW}更多文档：https://github.com/tmuxinator/tmuxinator${RESET}"
}

# =============================================================================
# bat 安装函数
# =============================================================================

# 检查 bat 是否已安装
check_bat_installed() {
    if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
        log_info "bat 已安装"
        return 0
    else
        return 1
    fi
}

# 安装 bat
install_bat() {
    log_info "安装 bat..."

    # 使用 apt 安装
    if apt install -y bat 2>/dev/null; then
        log_info "bat 安装成功"

        # 创建 bat -> batcat 符号链接（Ubuntu/Debian 上 bat 命令名为 batcat）
        if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
            log_info "创建 bat -> batcat 符号链接..."
            mkdir -p ~/.local/bin
            ln -sf /usr/bin/batcat ~/.local/bin/bat
            log_info "符号链接创建完成: ~/.local/bin/bat"
        fi

        return 0
    else
        log_error "bat 安装失败"
        return 1
    fi
}

# =============================================================================
# fzf 安装函数 (使用最新二进制版本 0.67.0)
# =============================================================================

readonly FZF_VERSION="0.67.0"
readonly FZF_INSTALL_DIR="/usr/local/bin"

# 检查 fzf 是否已安装
check_fzf_installed() {
    if command -v fzf >/dev/null 2>&1; then
        local installed_version
        installed_version=$(fzf --version 2>/dev/null | awk '{print $1}')
        log_info "fzf 已安装: 版本 $installed_version"
        return 0
    else
        return 1
    fi
}

# 获取系统架构
get_system_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            log_error "不支持的架构: $arch"
            exit 1
            ;;
    esac
}

# 安装 fzf 二进制文件
install_fzf_binary() {
    log_info "安装 fzf $FZF_VERSION..."

    local arch=$(get_system_arch)
    local download_url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${arch}.tar.gz"
    local temp_dir=$(mktemp -d)
    local temp_file="$temp_dir/fzf.tar.gz"

    log_info "下载 fzf 二进制文件..."
    log_info "URL: $download_url"

    if ! wget -q --show-progress -O "$temp_file" "$download_url"; then
        log_error "下载 fzf 失败"
        rm -rf "$temp_dir"
        return 1
    fi

    log_info "解压 fzf..."
    if ! tar -xzf "$temp_file" -C "$temp_dir"; then
        log_error "解压 fzf 失败"
        rm -rf "$temp_dir"
        return 1
    fi

    log_info "安装 fzf 到 $FZF_INSTALL_DIR..."
    if ! mv "$temp_dir/fzf" "$FZF_INSTALL_DIR/fzf"; then
        log_error "安装 fzf 失败"
        rm -rf "$temp_dir"
        return 1
    fi

    chmod +x "$FZF_INSTALL_DIR/fzf"
    rm -rf "$temp_dir"

    # 验证安装
    if command -v fzf >/dev/null 2>&1; then
        log_info "fzf 安装成功: $(fzf --version)"
        return 0
    else
        log_error "fzf 安装验证失败"
        return 1
    fi
}

# 配置 fzf ZSH 集成 (仅支持新版本 0.48.0+)
configure_fzf_zsh() {
    log_info "配置 fzf ZSH 集成..."

    local zshrc="$HOME/.zshrc"

    if [ ! -f "$zshrc" ]; then
        log_warn "找不到 $zshrc，跳过配置"
        return 1
    fi

    if grep -q "# fzf configuration" "$zshrc"; then
        log_info "fzf 已配置，跳过"
        return 0
    fi

    cat >> "$zshrc" << 'EOF'

# fzf configuration - 使用 full 预设主题
export FZF_DEFAULT_OPTS='--style full --height 40% --layout=reverse --border --inline-info'

# fzf ZSH 集成 (需要 fzf 0.48.0+)
source <(fzf --zsh)

# fzf 预览配置 - 使用 bat 进行语法高亮预览
# 检测 bat 或 batcat 命令
if command -v bat >/dev/null 2>&1; then
    _fzf_bat_cmd='bat'
elif command -v batcat >/dev/null 2>&1; then
    _fzf_bat_cmd='batcat'
fi

# CTRL-T: 文件选择（带预览）
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview '\${_fzf_bat_cmd} --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {} 2>/dev/null || echo \"无法预览\"'
  --preview-window 'right:50%:wrap'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --bind 'ctrl-o:execute(\${_fzf_bat_cmd} {} 2>/dev/null || less {} 2>/dev/null || cat {})'
  --header 'CTRL-T:选择文件 | CTRL-O:打开文件 | CTRL-/:切换预览'"

# CTRL-R: 历史命令
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard 2>/dev/null || echo -n {2..} | pbcopy 2>/dev/null || true)+abort'
  --color header:italic
  --header 'CTRL-R:搜索历史 | CTRL-Y:复制命令'"

# ALT-C: 目录跳转（带 tree 预览）
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {} 2>/dev/null | head -200 || ls -la {} 2>/dev/null | head -50'
  --preview-window 'right:50%'
  --header 'ALT-C:跳转目录'"

# 清理临时变量
unset _fzf_bat_cmd

# fzf 快捷键说明：
# CTRL-T - 粘贴选中的文件/目录到命令行（带文件预览）
# CTRL-R - 搜索命令历史
# ALT-C  - cd 到选中的目录（带目录预览）
# **<TAB> - 模糊补全（文件、目录、进程等）
EOF

    log_info "fzf ZSH 配置完成"
    return 0
}

# 安装 fzf
install_fzf() {
    log_info "开始安装 fzf $FZF_VERSION..."

    if check_fzf_installed; then
        if interactive_ask_confirmation "fzf 已安装，是否重新安装/配置？" "false"; then
            log_info "重新安装 fzf..."
        else
            log_info "跳过安装"
            configure_fzf_zsh
            return 0
        fi
    fi

    if ! install_fzf_binary; then
        log_error "fzf 安装失败"
        return 1
    fi

    configure_fzf_zsh

    log_info "fzf $FZF_VERSION 安装完成！"
    echo
    echo -e "${CYAN}快捷键：${RESET}"
    echo -e "  ${GREEN}CTRL-T${RESET} - 查找文件并粘贴到命令行"
    echo -e "  ${GREEN}CTRL-R${RESET} - 搜索命令历史"
    echo -e "  ${GREEN}ALT-C${RESET}  - 跳转目录"
    echo -e "  ${GREEN}**${RESET}<${GREEN}TAB>${RESET} - 模糊补全"
    echo
    echo -e "${YELLOW}提示：重新登录或运行 'source ~/.zshrc' 使配置生效${RESET}"
    return 0
}

# 主安装函数
install_eza() {
    log_info "开始安装 eza..."

    # 检查是否已安装
    if check_eza_installed; then
        if interactive_ask_confirmation "eza 已安装，是否重新安装？" "false"; then
            log_info "继续重新安装..."
        else
            log_info "跳过安装"
            # 仍然尝试配置别名
            configure_zsh_aliases
            return 0
        fi
    fi

    # 安装依赖
    install_gpg_if_needed

    # 添加软件源
    if ! add_eza_repository; then
        log_error "添加软件源失败"
        return 1
    fi

    # 安装 eza
    if ! install_eza_package; then
        log_error "eza 安装失败"
        return 1
    fi

    # 配置 ZSH 别名
    configure_zsh_aliases

    # 配置主题
    if interactive_ask_confirmation "是否配置 eza 主题？" "true"; then
        configure_eza_theme
    fi

    # 验证安装
    if check_eza_installed; then
        log_info "eza 安装完成！"
        echo
        echo -e "${CYAN}常用命令：${RESET}"
        echo -e "  ${GREEN}ls${RESET}  - 彩色列表（替代 ls）"
        echo -e "  ${GREEN}ll${RESET}  - 详细列表（替代 ls -l）"
        echo -e "  ${GREEN}la${RESET}  - 显示隐藏文件（替代 ls -a）"
        echo -e "  ${GREEN}lt${RESET}  - 树形显示（替代 tree）"
        echo
        echo -e "${YELLOW}提示：重新登录或运行 'source ~/.zshrc' 使别名生效${RESET}"
        return 0
    else
        log_error "eza 安装验证失败"
        return 1
    fi
}

# 显示脚本头部
show_header() {
    clear
    echo -e "${BLUE}================================================================${RESET}"
    echo -e "${BLUE}美化工具安装脚本${RESET}"
    echo -e "${BLUE}版本: 1.0${RESET}"
    echo -e "${BLUE}作者: saul${RESET}"
    echo -e "${BLUE}================================================================${RESET}"
    echo
    echo -e "${CYAN}本脚本将安装各种命令行美化工具${RESET}"
    echo -e "${CYAN}包括 eza（现代化的 ls）、fzf（模糊查找器）、tmuxinator（会话管理）${RESET}"
    echo
}

# 主函数 - 使用 select_menu 进行菜单选择
main() {
    show_header

    # 检查系统要求
    if [ ! -f /etc/os-release ]; then
        log_error "无法检测操作系统"
        exit 1
    fi

    . /etc/os-release

    case "$ID" in
        ubuntu|debian)
            log_info "检测到支持的操作系统: $ID $VERSION_ID"
            ;;
        *)
            log_error "不支持的操作系统: $ID"
            log_error "本脚本仅支持 Ubuntu 和 Debian"
            exit 1
            ;;
    esac

    # 检查是否为 root
    if [ "$(id -u)" -ne 0 ]; then
        log_error "请使用 root 用户运行此脚本"
        exit 1
    fi

    # 定义菜单选项数组
    local menu_options=(
        "eza        - 现代化的 ls 替代品（彩色列表、图标、树形显示）"
        "fzf        - 模糊查找器（快速文件查找、历史搜索、文件预览）"
        "tmuxinator - 项目会话管理器（YAML配置工作流）"
        "bat        - 语法高亮文件查看器（配合 fzf 预览使用）"
        "全部       - 安装以上所有工具"
        "退出"
    )

    # 使用 select_menu 显示菜单
    select_menu "menu_options" "请选择要安装的美化工具：" 0

    case $MENU_SELECT_INDEX in
        0)
            if interactive_ask_confirmation "是否安装 eza？" "true"; then
                install_eza
            fi
            ;;
        1)
            if interactive_ask_confirmation "是否安装 fzf？" "true"; then
                # 建议先安装 bat 以获得更好的预览体验
                if ! check_bat_installed; then
                    log_warn "提示：安装 bat 可获得更好的文件预览效果"
                    if interactive_ask_confirmation "是否同时安装 bat？" "true"; then
                        install_bat
                    fi
                fi
                install_fzf
            fi
            ;;
        2)
            if interactive_ask_confirmation "是否安装 tmuxinator？" "true"; then
                install_tmuxinator
            fi
            ;;
        3)
            if interactive_ask_confirmation "是否安装 bat？" "true"; then
                install_bat
            fi
            ;;
        4)
            if interactive_ask_confirmation "是否安装所有美化工具？" "true"; then
                install_eza
                echo
                install_bat
                echo
                install_fzf
                echo
                install_tmuxinator
            fi
            ;;
        5)
            log_info "退出安装"
            exit 0
            ;;
        *)
            log_error "无效选项"
            exit 1
            ;;
    esac
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
