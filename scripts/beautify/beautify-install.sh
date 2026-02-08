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

# fzf 快捷键说明：
# CTRL-T - 粘贴选中的文件/目录到命令行
# CTRL-R - 搜索命令历史
# ALT-C  - cd 到选中的目录
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
    echo -e "${CYAN}包括 eza（现代化的 ls）和 fzf（模糊查找器）${RESET}"
    echo
}

# 显示菜单
show_menu() {
    echo
    echo -e "${BLUE}================================================================${RESET}"
    echo -e "${BLUE}请选择要安装的美化工具：${RESET}"
    echo -e "${BLUE}================================================================${RESET}"
    echo
    echo -e "  ${CYAN}1)${RESET} eza    - 现代化的 ls 替代品（彩色列表、图标、树形显示）"
    echo -e "  ${CYAN}2)${RESET} fzf    - 模糊查找器（快速文件查找、历史搜索）"
    echo -e "  ${CYAN}3)${RESET} 全部   - 安装以上所有工具"
    echo -e "  ${CYAN}0)${RESET} 退出"
    echo
}

# 主函数
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

    # 显示菜单
    show_menu

    # 读取用户选择
    local choice
    read -p "请输入选项 [0-3]: " choice

    case "$choice" in
        1)
            if interactive_ask_confirmation "是否安装 eza？" "true"; then
                install_eza
            fi
            ;;
        2)
            if interactive_ask_confirmation "是否安装 fzf？" "true"; then
                install_fzf
            fi
            ;;
        3)
            if interactive_ask_confirmation "是否安装所有美化工具？" "true"; then
                install_eza
                echo
                install_fzf
            fi
            ;;
        0)
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
