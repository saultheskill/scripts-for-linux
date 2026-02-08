#!/bin/bash

# =============================================================================
# ZSH 插件和工具安装脚本
# 作者: saul
# 版本: 2.0
# 描述: 安装和配置ZSH插件、额外工具和优化配置的专用脚本
# 功能: 插件安装、工具配置、智能配置管理、依赖处理
# =============================================================================

set -e  # 使用较温和的错误处理

# =============================================================================
# 脚本初始化和配置
# =============================================================================

# 导入通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# 检查是否为远程执行（通过curl | bash）
if [[ -f "$SCRIPT_DIR/../common.sh" ]]; then
    # 本地执行
    source "$SCRIPT_DIR/../common.sh"
else
    # 远程执行，下载common.sh
    COMMON_SH_URL="https://raw.githubusercontent.com/sau1g0dman/scripts-for-linux/main/scripts/common.sh"
    if ! source <(curl -fsSL "$COMMON_SH_URL"); then
        echo "错误：无法加载通用函数库"
        exit 1
    fi
fi

# =============================================================================
# 全局配置变量
# =============================================================================

# 版本和模式配置
readonly ZSH_PLUGINS_VERSION="2.0"
readonly ZSH_INSTALL_MODE=${ZSH_INSTALL_MODE:-"interactive"}  # interactive/auto/minimal

# 安装路径配置
readonly ZSH_INSTALL_DIR=${ZSH_INSTALL_DIR:-"$HOME"}
readonly OMZ_DIR="$ZSH_INSTALL_DIR/.oh-my-zsh"
readonly ZSH_CUSTOM_DIR="$OMZ_DIR/custom"
readonly ZSH_PLUGINS_DIR="$ZSH_CUSTOM_DIR/plugins"

# 插件配置
readonly ZSH_PLUGINS=(
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
    "you-should-use:https://github.com/MichaelAquilina/zsh-you-should-use"
)

# 完整插件列表（用于.zshrc配置）
readonly COMPLETE_PLUGINS="git extract systemadmin zsh-interactive-cd systemd sudo docker ubuntu man command-not-found common-aliases docker-compose zsh-autosuggestions zsh-syntax-highlighting tmux you-should-use ssh-agent"

# 额外工具配置
readonly TMUX_CONFIG_REPO="https://github.com/gpakosz/.tmux.git"

# 状态管理
declare -g PLUGINS_INSTALL_STATE=""
declare -g ROLLBACK_ACTIONS=()
declare -g INSTALL_LOG_FILE="/opt/zsh-plugins-install-$(date +%Y%m%d-%H%M%S).log"
readonly ZSH_BACKUP_DIR="$HOME/.zsh-plugins-backup-$(date +%Y%m%d-%H%M%S)"

# =============================================================================
# 状态管理和回滚功能
# =============================================================================

# 设置安装状态
# 参数: $1 - 状态名称
set_install_state() {
    local state="$1"
    PLUGINS_INSTALL_STATE="$state"
    log_debug "插件安装状态更新: $state"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - STATE: $state" >> "$INSTALL_LOG_FILE"
}

# 添加回滚操作
# 参数: $1 - 回滚命令
add_rollback_action() {
    local action="$1"
    ROLLBACK_ACTIONS+=("$action")
    log_debug "添加回滚操作: $action"
}

# 执行回滚操作
execute_rollback() {
    if [ ${#ROLLBACK_ACTIONS[@]} -eq 0 ]; then
        log_info "无需回滚操作"
        return 0
    fi

    log_warn "开始执行回滚操作..."
    local rollback_count=0

    # 逆序执行回滚操作
    for ((i=${#ROLLBACK_ACTIONS[@]}-1; i>=0; i--)); do
        local action="${ROLLBACK_ACTIONS[i]}"
        log_info "执行回滚: $action"

        if eval "$action" 2>/dev/null; then
            rollback_count=$((rollback_count + 1))
            log_debug "回滚成功: $action"
        else
            log_warn "回滚失败: $action"
        fi
    done

    log_info "回滚完成，执行了 $rollback_count 个操作"
    ROLLBACK_ACTIONS=()
}

# 创建备份
# 参数: $1 - 要备份的文件或目录路径
create_backup() {
    local file_path="$1"
    local backup_name="$(basename "$file_path")"

    if [ -f "$file_path" ] || [ -d "$file_path" ]; then
        log_info "备份文件: $file_path"
        mkdir -p "$ZSH_BACKUP_DIR"

        if cp -r "$file_path" "$ZSH_BACKUP_DIR/$backup_name" 2>/dev/null; then
            add_rollback_action "restore_backup '$file_path' '$ZSH_BACKUP_DIR/$backup_name'"
            log_debug "备份成功: $file_path -> $ZSH_BACKUP_DIR/$backup_name"
            return 0
        else
            log_warn "备份失败: $file_path"
            return 1
        fi
    fi
}

# 恢复备份
# 参数: $1 - 原始路径, $2 - 备份路径
restore_backup() {
    local original_path="$1"
    local backup_path="$2"

    if [ -f "$backup_path" ] || [ -d "$backup_path" ]; then
        rm -rf "$original_path" 2>/dev/null || true
        cp -r "$backup_path" "$original_path" 2>/dev/null || true
        log_debug "恢复备份: $backup_path -> $original_path"
    fi
}

# =============================================================================
# 前置条件检查
# =============================================================================

# 检查ZSH核心环境是否已安装
check_zsh_core_installed() {
    log_info "检查ZSH核心环境..."

    # 检查ZSH是否安装
    if ! command -v zsh >/dev/null 2>&1; then
        log_error "ZSH未安装，请先运行 zsh-core-install.sh"
        return 1
    fi

    # 检查Oh My Zsh是否安装
    if [ ! -d "$OMZ_DIR" ] || [ ! -f "$OMZ_DIR/oh-my-zsh.sh" ]; then
        log_error "Oh My Zsh未安装，请先运行 zsh-core-install.sh"
        return 1
    fi

    # 检查.zshrc是否存在
    if [ ! -f "$HOME/.zshrc" ]; then
        log_error ".zshrc配置文件不存在，请先运行 zsh-core-install.sh"
        return 1
    fi

    # 检查Powerlevel10k主题
    local theme_dir="$ZSH_CUSTOM_DIR/themes/powerlevel10k"
    if [ ! -d "$theme_dir" ]; then
        log_warn "Powerlevel10k主题未安装，建议先运行 zsh-core-install.sh"
    fi

    log_info "ZSH核心环境检查通过"
    return 0
}

# 检查系统依赖
check_system_dependencies() {
    log_info "检查系统依赖..."

    local required_commands=("git" "curl" "zsh")
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        log_error "缺少必需命令: ${missing_commands[*]}"
        log_error "请先安装这些命令或运行 zsh-core-install.sh"
        return 1
    fi

    # 检查网络连接
    if ! curl -fsSL --connect-timeout 5 --max-time 10 "https://github.com" >/dev/null 2>&1; then
        log_error "网络连接失败，无法下载插件"
        return 1
    fi

    log_info "系统依赖检查通过"
    return 0
}

# =============================================================================
# 错误处理
# =============================================================================

# 错误处理函数
# 参数: $1 - 错误行号, $2 - 错误代码
handle_error() {
    local line_no=${1:-"未知"}
    local error_code=${2:-1}

    log_error "脚本在第 $line_no 行发生错误 (退出码: $error_code)"
    log_error "当前安装状态: ${PLUGINS_INSTALL_STATE:-"未知"}"

    # 执行回滚
    execute_rollback

    log_error "ZSH插件安装失败，已执行回滚操作"
    exit $error_code
}

# 初始化环境
init_environment() {
    # 设置调试级别
    export LOG_LEVEL=${LOG_LEVEL:-1}  # 默认INFO级别

    # 调用common.sh的基础初始化
    detect_os
    detect_arch
    check_root

    # 设置错误处理
    trap 'handle_error $LINENO $?' ERR

    # 创建必要的目录
    mkdir -p "$(dirname "$INSTALL_LOG_FILE")"
    mkdir -p "$ZSH_PLUGINS_DIR"

    log_debug "ZSH插件安装脚本初始化完成"
    log_debug "安装日志: $INSTALL_LOG_FILE"
    log_debug "备份目录: $ZSH_BACKUP_DIR"
    log_info "权限模式: $([ -z "$SUDO" ] && echo "root" || echo "sudo")"
}

# =============================================================================
# ZSH 插件安装功能
# =============================================================================

# 安装单个ZSH插件
# 参数: $1 - 插件名称, $2 - 插件仓库URL
install_single_plugin() {
    local plugin_name="$1"
    local plugin_repo="$2"
    local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"

    log_info "安装插件: $plugin_name"

    # 检查插件是否已安装
    if [ -d "$plugin_dir" ] && [ -n "$(ls -A "$plugin_dir" 2>/dev/null)" ]; then
        log_info "插件 $plugin_name 已安装，跳过"
        return 0
    fi

    # 克隆插件仓库
    log_info "克隆插件仓库: $plugin_repo"
    if git clone --depth=1 "$plugin_repo.git" "$plugin_dir" 2>/dev/null; then
        add_rollback_action "rm -rf '$plugin_dir'"
        log_info "插件 $plugin_name 安装成功"
        return 0
    else
        log_error "插件 $plugin_name 安装失败"
        return 1
    fi
}

# 安装所有ZSH插件
install_zsh_plugins() {
    log_info "安装ZSH插件..."
    set_install_state "INSTALLING_PLUGINS"

    local failed_plugins=()
    local success_count=0
    local total_plugins=${#ZSH_PLUGINS[@]}

    # 确保插件目录存在
    mkdir -p "$ZSH_PLUGINS_DIR"

    # 安装每个插件
    for plugin_info in "${ZSH_PLUGINS[@]}"; do
        IFS=':' read -r plugin_name plugin_repo <<< "$plugin_info"

        if install_single_plugin "$plugin_name" "$plugin_repo"; then
            success_count=$((success_count + 1))
        else
            failed_plugins+=("$plugin_name")
        fi
    done

    # 检查安装结果
    if [ ${#failed_plugins[@]} -gt 0 ]; then
        log_warn "以下插件安装失败："
        for failed_plugin in "${failed_plugins[@]}"; do
            log_warn "  • $failed_plugin"
        done
    fi

    log_info "插件安装完成: 成功 $success_count/$total_plugins"

    # 如果有插件安装成功，返回成功
    if [ $success_count -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# 验证插件安装
verify_plugins_installation() {
    log_info "验证插件安装..."

    local verified_count=0
    local total_plugins=${#ZSH_PLUGINS[@]}

    for plugin_info in "${ZSH_PLUGINS[@]}"; do
        IFS=':' read -r plugin_name plugin_repo <<< "$plugin_info"
        local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"

        if [ -d "$plugin_dir" ] && [ -n "$(ls -A "$plugin_dir" 2>/dev/null)" ]; then
            log_debug "插件验证通过: $plugin_name"
            verified_count=$((verified_count + 1))
        else
            log_debug "插件验证失败: $plugin_name"
        fi
    done

    log_info "插件验证结果: $verified_count/$total_plugins"
    return 0
}

# =============================================================================
# 额外工具安装功能
# =============================================================================



# 安装和配置tmux (优化版本，支持Oh My Tmux官方安装方式)
install_tmux_config() {
    log_info "安装和配置tmux (Oh My Tmux)..."
    set_install_state "INSTALLING_TMUX"

    # 检查依赖工具
    local deps=("awk" "perl" "grep" "sed")
    local missing_deps=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_warn "缺少Oh My Tmux依赖: ${missing_deps[*]}"
        log_info "尝试安装依赖..."
        install_package "gawk" || true
        install_package "perl" || true
    fi

    # 检查tmux是否已安装
    if ! command -v tmux >/dev/null 2>&1; then
        log_info "tmux未安装，尝试安装..."
        if ! install_package "tmux"; then
            log_warn "tmux安装失败，跳过配置"
            return 1
        fi
    fi

    # 检查tmux版本 (Oh My Tmux要求 >= 2.6)
    local tmux_version
    tmux_version=$(tmux -V 2>/dev/null | awk '{print $2}' | sed 's/[^0-9.]//g')
    if [ -n "$tmux_version" ]; then
        local required_version="2.6"
        if [ "$(printf '%s\n' "$required_version" "$tmux_version" | sort -V | head -n1)" != "$required_version" ]; then
            log_warn "tmux版本 $tmux_version 过低，Oh My Tmux需要 >= 2.6"
            log_info "尝试更新tmux..."
            # 尝试从源码或更新包
        fi
    fi

    # 检查TERM环境变量
    if [ -z "$TERM" ] || [[ "$TERM" != *"256color"* ]]; then
        log_warn "TERM环境变量未设置或不包含256color"
        log_info "建议在~/.bashrc或~/.zshrc中添加: export TERM=xterm-256color"
    fi

    # 选择安装方式
    log_info "选择Oh My Tmux安装方式..."
    local install_methods=(
        "官方安装脚本 (推荐)"
        "手动安装到 ~/.tmux"
        "手动安装到 ~/.config/tmux (XDG配置目录)"
    )

    # 默认使用官方安装脚本
    local use_official_script=true
    local tmux_config_dir="$HOME/.tmux"
    local tmux_conf_path="$HOME/.tmux.conf"
    local tmux_conf_local_path="$HOME/.tmux.conf.local"

    # 检查是否已存在配置
    if [ -d "$tmux_config_dir" ] || [ -f "$tmux_conf_path" ]; then
        log_info "检测到现有tmux配置"
        if interactive_ask_confirmation "是否重新安装Oh My Tmux？" "false"; then
            log_info "备份并重新安装..."
            local backup_dir="$HOME/.tmux.backup.$(date +%Y%m%d%H%M%S)"
            mv "$tmux_config_dir" "$backup_dir" 2>/dev/null || true
            mv "$tmux_conf_path" "$backup_dir/" 2>/dev/null || true
            mv "$tmux_conf_local_path" "$backup_dir/" 2>/dev/null || true
            log_info "已备份到: $backup_dir"
        else
            log_info "跳过安装"
            return 0
        fi
    fi

    # 方式1: 使用官方安装脚本
    if [ "$use_official_script" = true ]; then
        log_info "使用Oh My Tmux官方安装脚本..."
        local install_script_url="https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh"

        # 下载并执行安装脚本
        local temp_install_script=$(mktemp)
        if curl -fsSL "$install_script_url" -o "$temp_install_script" 2>/dev/null; then
            if bash "$temp_install_script" 2>/dev/null; then
                log_info "Oh My Tmux官方安装完成"
                add_rollback_action "rm -rf '$HOME/.tmux' '$HOME/.tmux.conf' '$HOME/.tmux.conf.local'"
                rm -f "$temp_install_script"

                # 配置Powerline字体支持
                configure_tmux_powerline

                # 显示快捷键帮助
                show_tmux_key_bindings

                return 0
            else
                log_warn "官方安装脚本执行失败，尝试手动安装..."
            fi
        else
            log_warn "下载官方安装脚本失败，尝试手动安装..."
        fi
        rm -f "$temp_install_script"
    fi

    # 方式2: 手动安装
    log_info "手动安装Oh My Tmux..."
    if [ ! -d "$tmux_config_dir" ]; then
        log_info "克隆Oh My Tmux配置..."
        if git clone --single-branch "$TMUX_CONFIG_REPO" "$tmux_config_dir" 2>/dev/null; then
            log_info "Oh My Tmux克隆成功"
            add_rollback_action "rm -rf '$tmux_config_dir'"

            # 创建符号链接
            if ln -sf "$tmux_config_dir/.tmux.conf" "$tmux_conf_path" 2>/dev/null; then
                log_info "创建.tmux.conf符号链接成功"
                add_rollback_action "rm -f '$tmux_conf_path'"
            else
                log_warn "创建.tmux.conf符号链接失败"
            fi

            # 复制本地配置文件
            if cp "$tmux_config_dir/.tmux.conf.local" "$tmux_conf_local_path" 2>/dev/null; then
                log_info "复制.tmux.conf.local成功"
                add_rollback_action "rm -f '$tmux_conf_local_path'"
            else
                log_warn "复制.tmux.conf.local失败"
            fi

            # 配置Powerline字体支持
            configure_tmux_powerline

            # 显示快捷键帮助
            show_tmux_key_bindings

            return 0
        else
            log_warn "Oh My Tmux克隆失败"
            return 1
        fi
    else
        log_info "Oh My Tmux配置已存在，跳过"
        return 0
    fi
}

# 配置tmux Powerline字体支持
configure_tmux_powerline() {
    log_info "配置tmux Powerline字体支持..."

    local tmux_conf_local="$HOME/.tmux.conf.local"

    if [ -f "$tmux_conf_local" ]; then
        # 检查是否已配置Powerline
        if ! grep -q "tmux_conf_theme_left_separator_main" "$tmux_conf_local"; then
            log_info "启用Powerline符号..."
            cat >> "$tmux_conf_local" << 'EOF'

# ==============================================
# Powerline 字体配置 (自动添加)
# ==============================================
# 需要安装Powerline字体: https://github.com/powerline/fonts
# 或使用Nerd Fonts: https://www.nerdfonts.com/
tmux_conf_theme_left_separator_main='\uE0B0'
tmux_conf_theme_left_separator_sub='\uE0B1'
tmux_conf_theme_right_separator_main='\uE0B2'
tmux_conf_theme_right_separator_sub='\uE0B3'
EOF
            log_info "Powerline配置已添加到 $tmux_conf_local"
        fi
    fi

    # 配置 tmux-resurrect 和 tmux-continuum 插件
    configure_tmux_resurrect_plugins
}

# 配置 tmux-resurrect 和 tmux-continuum 插件
configure_tmux_resurrect_plugins() {
    log_info "配置 tmux-resurrect 和 tmux-continuum 插件..."

    local tmux_conf_local="$HOME/.tmux.conf.local"

    if [ ! -f "$tmux_conf_local" ]; then
        log_warn "未找到 $tmux_conf_local，跳过插件配置"
        return 1
    fi

    # 检查是否已配置
    if grep -q "tmux-plugins/tmux-resurrect" "$tmux_conf_local"; then
        log_info "tmux-resurrect 插件已配置，跳过"
        # 仍然检查并安装插件文件
        install_tmux_resurrect_plugins
        return 0
    fi

    log_info "添加 tmux-resurrect 和 tmux-continuum 插件配置..."

    cat >> "$tmux_conf_local" << 'EOF'

# ==============================================
# Tmux Resurrect & Continuum 插件配置
# ==============================================
# 功能说明:
#   - tmux-resurrect: 保存和恢复 tmux 会话
#     * prefix + Ctrl-s : 手动保存会话
#     * prefix + Ctrl-r : 恢复会话
#
#   - tmux-continuum: 自动保存和恢复
#     * 每 15 分钟自动保存
#     * 启动 tmux 时自动恢复上次会话

# 启用自动恢复 (tmux 启动时自动恢复上次会话)
set -g @continuum-restore 'on'

# 自动保存间隔（分钟，默认 15）
set -g @continuum-save-interval '15'

# 保存的额外程序（默认已保存: vi vim nvim emacs man less more tail top htop irssi weechat mutt）
set -g @resurrect-processes 'ssh docker docker-compose npm node python python3'

# 恢复窗格内容（实验性功能，需要 tmux 2.0+）
# set -g @resurrect-capture-pane-contents 'on'

# 恢复 vim/neovim 会话（需要 vim-obsession 插件）
# set -g @resurrect-strategy-vim 'session'
# set -g @resurrect-strategy-nvim 'session'

# 保存目录（默认 ~/.tmux/resurrect/）
# set -g @resurrect-dir '~/.tmux/resurrect'
EOF

    log_info "tmux-resurrect 和 tmux-continuum 配置已添加"

    # 安装插件文件
    install_tmux_resurrect_plugins

    return 0
}

# 安装 tmux-resurrect 和 tmux-continuum 插件文件
install_tmux_resurrect_plugins() {
    log_info "安装 tmux-resurrect 和 tmux-continuum 插件..."

    local plugins_dir="$HOME/.tmux/plugins"
    local resurrect_dir="$plugins_dir/tmux-resurrect"
    local continuum_dir="$plugins_dir/tmux-continuum"
    local install_count=0

    # 创建插件目录
    mkdir -p "$plugins_dir"

    # 安装 tmux-resurrect
    if [ -d "$resurrect_dir/.git" ]; then
        log_info "tmux-resurrect 已安装，检查更新..."
        if git -C "$resurrect_dir" pull --quiet 2>/dev/null; then
            log_info "tmux-resurrect 已更新到最新版本"
        else
            log_warn "tmux-resurrect 更新失败，使用现有版本"
        fi
        install_count=$((install_count + 1))
    else
        log_info "克隆 tmux-resurrect..."
        if git clone --quiet "https://github.com/tmux-plugins/tmux-resurrect" "$resurrect_dir" 2>/dev/null; then
            log_success "tmux-resurrect 安装成功"
            install_count=$((install_count + 1))
        else
            log_error "tmux-resurrect 克隆失败"
        fi
    fi

    # 安装 tmux-continuum
    if [ -d "$continuum_dir/.git" ]; then
        log_info "tmux-continuum 已安装，检查更新..."
        if git -C "$continuum_dir" pull --quiet 2>/dev/null; then
            log_info "tmux-continuum 已更新到最新版本"
        else
            log_warn "tmux-continuum 更新失败，使用现有版本"
        fi
        install_count=$((install_count + 1))
    else
        log_info "克隆 tmux-continuum..."
        if git clone --quiet "https://github.com/tmux-plugins/tmux-continuum" "$continuum_dir" 2>/dev/null; then
            log_success "tmux-continuum 安装成功"
            install_count=$((install_count + 1))
        else
            log_error "tmux-continuum 克隆失败"
        fi
    fi

    # 配置插件自动加载（添加到 .tmux.conf.local）
    configure_tmux_plugin_loader

    # 显示插件快捷键
    if [ $install_count -gt 0 ]; then
        show_tmux_resurrect_bindings
    fi

    return 0
}

# 配置 tmux 插件加载器
configure_tmux_plugin_loader() {
    local tmux_conf_local="$HOME/.tmux.conf.local"
    local plugins_dir="$HOME/.tmux/plugins"

    # 检查是否已配置插件加载
    if grep -q "run-shell.*resurrect.tmux" "$tmux_conf_local" 2>/dev/null; then
        log_debug "插件加载器已配置"
        return 0
    fi

    log_info "配置插件自动加载..."

    cat >> "$tmux_conf_local" << 'EOF'

# ==============================================
# 插件加载配置
# ==============================================
EOF

    # 添加 tmux-resurrect 加载
    if [ -f "$plugins_dir/tmux-resurrect/resurrect.tmux" ]; then
        echo "run-shell $plugins_dir/tmux-resurrect/resurrect.tmux" >> "$tmux_conf_local"
        log_info "tmux-resurrect 加载配置已添加"
    fi

    # 添加 tmux-continuum 加载
    if [ -f "$plugins_dir/tmux-continuum/continuum.tmux" ]; then
        echo "run-shell $plugins_dir/tmux-continuum/continuum.tmux" >> "$tmux_conf_local"
        log_info "tmux-continuum 加载配置已添加"
    fi

    log_info "插件将在下次启动 tmux 时生效"
    log_info "当前 tmux 会话请运行: tmux source-file ~/.tmux.conf.local"
}

# 显示 tmux-resurrect 快捷键
show_tmux_resurrect_bindings() {
    echo
    echo -e "${CYAN}Tmux Resurrect & Continuum 快捷键:${RESET}"
    echo
    echo -e "${GREEN}手动操作:${RESET}"
    echo -e "  ${YELLOW}<prefix> Ctrl-s${RESET}    - 保存当前 tmux 会话"
    echo -e "  ${YELLOW}<prefix> Ctrl-r${RESET}    - 恢复上次保存的会话"
    echo
    echo -e "${GREEN}自动功能:${RESET}"
    echo -e "  ${YELLOW}自动保存${RESET}        - 每 15 分钟自动保存一次"
    echo -e "  ${YELLOW}自动恢复${RESET}        - 启动 tmux 时自动恢复上次会话"
    echo
    echo -e "${GREEN}保存内容:${RESET}"
    echo -e "  • 所有会话、窗口、窗格及其布局"
    echo -e "  • 当前工作目录"
    echo -e "  • 运行的程序 (vim, htop, docker, ssh 等)"
    echo -e "  • 活动窗格和窗口状态"
    echo
    echo -e "${YELLOW}提示:${RESET} 重新启动 tmux 或运行 ${CYAN}tmux source-file ~/.tmux.conf.local${RESET} 使插件生效"
    echo
}

# 显示tmux快捷键帮助
show_tmux_key_bindings() {
    log_info "tmux快捷键说明:"
    echo
    echo -e "${CYAN}前缀键:${RESET} Ctrl+a 或 Ctrl+b (按两次发送给程序)"
    echo
    echo -e "${CYAN}会话管理 (Session):${RESET}"
    echo -e "  ${GREEN}tmux new -s <name>${RESET}     - 新建命名会话"
    echo -e "  ${GREEN}tmux ls${RESET}                - 列出所有会话"
    echo -e "  ${GREEN}tmux attach -t <name>${RESET}  - 连接到指定会话"
    echo -e "  ${GREEN}<prefix> d${RESET}             - 分离当前会话(后台运行)"
    echo -e "  ${GREEN}<prefix> s${RESET}             - 切换会话(列表选择)"
    echo -e "  ${GREEN}<prefix> (${RESET}             - 切换到上一个会话"
    echo -e "  ${GREEN}<prefix> )${RESET}             - 切换到下一个会话"
    echo -e "  ${GREEN}<prefix> C-c${RESET}           - 创建新会话"
    echo -e "  ${GREEN}<prefix> C-f${RESET}           - 按名称查找会话"
    echo -e "  ${GREEN}<prefix> $${RESET}             - 重命名当前会话"
    echo -e "  ${GREEN}<prefix> X${RESET}             - 关闭当前会话"
    echo
    echo -e "${CYAN}窗口管理 (Window):${RESET}"
    echo -e "  ${GREEN}<prefix> c${RESET}             - 创建新窗口"
    echo -e "  ${GREEN}<prefix> ,${RESET}             - 重命名当前窗口"
    echo -e "  ${GREEN}<prefix> &${RESET}             - 关闭当前窗口"
    echo -e "  ${GREEN}<prefix> n${RESET}             - 切换到下一个窗口"
    echo -e "  ${GREEN}<prefix> p${RESET}             - 切换到上一个窗口"
    echo -e "  ${GREEN}<prefix> <number>${RESET}     - 切换到指定窗口(0-9)"
    echo -e "  ${GREEN}<prefix> w${RESET}             - 窗口列表(可视化选择)"
    echo -e "  ${GREEN}<prefix> .${RESET}             - 移动窗口到指定编号"
    echo -e "  ${GREEN}<prefix> f${RESET}             - 按名称查找窗口"
    echo -e "  ${GREEN}<prefix> Tab${RESET}          - 切换到上一个活动窗口"
    echo
    echo -e "${CYAN}窗格管理 (Pane):${RESET}"
    echo -e "  ${GREEN}<prefix> -${RESET}             - 垂直分割窗格(上下分)"
    echo -e "  ${GREEN}<prefix> _${RESET}             - 水平分割窗格(左右分)"
    echo -e "  ${GREEN}<prefix> h/j/k/l${RESET}       - 在窗格间导航(Vim风格)"
    echo -e "  ${GREEN}<prefix> H/J/K/L${RESET}       - 调整窗格大小"
    echo -e "  ${GREEN}<prefix> z${RESET}             - 最大化/恢复当前窗格"
    echo -e "  ${GREEN}<prefix> +${RESET}             - 最大化窗格到新窗口(Oh My Tmux)"
    echo -e "  ${GREEN}<prefix> x${RESET}             - 关闭当前窗格"
    echo -e "  ${GREEN}<prefix> q${RESET}             - 显示窗格编号"
    echo -e "  ${GREEN}<prefix> <number>${RESET}     - 切换到指定窗格"
    echo -e "  ${GREEN}<prefix> { / }${RESET}        - 交换窗格位置"
    echo -e "  ${GREEN}<prefix> !${RESET}             - 将窗格移动到新窗口"
    echo -e "  ${GREEN}<prefix> ;${RESET}             - 切换到上一个活动窗格"
    echo
    echo -e "${CYAN}复制模式:${RESET}"
    echo -e "  ${GREEN}<prefix> [${RESET}             - 进入复制模式"
    echo -e "  ${GREEN}<prefix> ]${RESET}             - 粘贴缓冲区内容"
    echo -e "  ${GREEN}v${RESET}                     - 开始选择(可视模式)"
    echo -e "  ${GREEN}C-v${RESET}                   - 块选择模式"
    echo -e "  ${GREEN}y${RESET}                     - 复制到剪贴板"
    echo -e "  ${GREEN}Escape${RESET}              - 取消选择"
    echo -e "  ${GREEN}H / L${RESET}                 - 跳到行首/行尾"
    echo -e "  ${GREEN}Space${RESET}                 - 开始选择(另一种方式)"
    echo -e "  ${GREEN}Enter${RESET}                 - 复制并退出"
    echo
    echo -e "${CYAN}其他功能:${RESET}"
    echo -e "  ${GREEN}<prefix> m${RESET}             - 切换鼠标模式(开/关)"
    echo -e "  ${GREEN}<prefix> t${RESET}             - 显示当前时间"
    echo -e "  ${GREEN}<prefix> ?${RESET}             - 显示所有快捷键"
    echo -e "  ${GREEN}<prefix> :${RESET}             - 进入命令模式"
    echo -e "  ${GREEN}<prefix> ~${RESET}             - 显示消息历史"
    echo -e "  ${GREEN}<prefix> r${RESET}             - 重新加载配置"
    echo -e "  ${GREEN}<prefix> e${RESET}             - 编辑.tmux.conf.local"
    echo -e "  ${GREEN}<prefix> U${RESET}             - 启动Urlscan(链接选择)"
    echo -e "  ${GREEN}<prefix> F${RESET}             - 启动PathPicker(路径选择)"
    echo
    echo -e "${CYAN}常用命令:${RESET}"
    echo -e "  ${YELLOW}tmux new -s work${RESET}      - 新建名为work的会话"
    echo -e "  ${YELLOW}tmux attach -t work${RESET}   - 连接到work会话"
    echo -e "  ${YELLOW}tmux kill-session -t work${RESET} - 关闭work会话"
    echo -e "  ${YELLOW}tmux ls${RESET}               - 列出所有会话"
    echo -e "  ${YELLOW}exit${RESET} 或 ${YELLOW}Ctrl+d${RESET}       - 退出当前窗格/窗口/会话"
    echo
    echo -e "${YELLOW}提示:${RESET}"
    echo -e "  - 按 ${GREEN}<prefix> ?${RESET} 查看完整快捷键列表"
    echo -e "  - 按 ${GREEN}<prefix> e${RESET} 编辑配置，${GREEN}<prefix> r${RESET} 重新加载"
    echo -e "  - 鼠标模式开启后可用鼠标点击切换窗格、调整大小"
    echo -e "  - 推荐安装 Powerline 或 Nerd Fonts 获得最佳显示效果"
    echo
    echo -e "${CYAN}会话保存/恢复 (需安装 tmux-resurrect/continuum 插件):${RESET}"
    echo -e "  ${GREEN}<prefix> Ctrl-s${RESET}         - 保存当前会话状态"
    echo -e "  ${GREEN}<prefix> Ctrl-r${RESET}         - 恢复上次保存的会话"
    echo -e "  ${YELLOW}自动保存${RESET}               - 每 15 分钟自动保存"
    echo -e "  ${YELLOW}自动恢复${RESET}               - 启动 tmux 时自动恢复"
    echo
}

# =============================================================================
# 智能配置管理功能
# =============================================================================

# 智能插件配置管理
# 参数: $1 - .zshrc文件路径
smart_plugin_config_management() {
    local zshrc_file="$1"
    local temp_file=$(mktemp)

    log_info "智能插件配置管理..."

    # 备份原配置
    create_backup "$zshrc_file"

    # 复制原配置
    cp "$zshrc_file" "$temp_file"

    # 检查是否存在 plugins=() 配置行
    if grep -q "^plugins=" "$temp_file"; then
        log_info "发现现有插件配置，进行智能合并..."

        # 提取现有插件列表
        local current_line=$(grep "^plugins=" "$temp_file")
        log_debug "当前插件配置行: $current_line"

        # 提取括号内的插件列表
        local current_plugins=$(echo "$current_line" | sed 's/^plugins=(//' | sed 's/)$//' | tr -s ' ' | sed 's/^ *//;s/ *$//')
        log_debug "当前插件列表: $current_plugins"

        # 将现有插件转换为数组
        local existing_array=()
        if [ -n "$current_plugins" ]; then
            IFS=' ' read -ra existing_array <<< "$current_plugins"
        fi

        # 将完整插件列表转换为数组
        local complete_array=()
        IFS=' ' read -ra complete_array <<< "$COMPLETE_PLUGINS"

        # 合并插件列表，避免重复
        local merged_plugins=()
        local plugin_exists

        # 先添加现有插件
        for plugin in "${existing_array[@]}"; do
            [ -n "$plugin" ] && merged_plugins+=("$plugin")
        done

        # 添加新插件（如果不存在）
        for new_plugin in "${complete_array[@]}"; do
            plugin_exists=false
            for existing_plugin in "${merged_plugins[@]}"; do
                if [ "$existing_plugin" = "$new_plugin" ]; then
                    plugin_exists=true
                    break
                fi
            done

            if [ "$plugin_exists" = false ]; then
                merged_plugins+=("$new_plugin")
                log_debug "添加新插件: $new_plugin"
            fi
        done

        # 生成新的插件配置行
        local new_plugins_line="plugins=(${merged_plugins[*]})"
        log_debug "新插件配置行: $new_plugins_line"

        # 替换插件配置行
        sed -i "s/^plugins=.*/$new_plugins_line/" "$temp_file"
        log_info "插件配置已更新，包含 ${#merged_plugins[@]} 个插件"

    else
        log_info "未找到插件配置，创建新的插件配置..."

        # 在 Oh My Zsh 源之前添加插件配置
        if grep -q "source.*oh-my-zsh.sh" "$temp_file"; then
            sed -i "/source.*oh-my-zsh.sh/i\\plugins=($COMPLETE_PLUGINS)" "$temp_file"
            log_info "已添加完整插件配置"
        else
            # 如果没有找到 source 行，在文件开头添加
            sed -i "1i\\plugins=($COMPLETE_PLUGINS)" "$temp_file"
            log_info "已在文件开头添加插件配置"
        fi
    fi

    # 应用更改
    mv "$temp_file" "$zshrc_file"
    return 0
}

# 确保Powerlevel10k配置
# 参数: $1 - .zshrc文件路径
ensure_p10k_config() {
    local zshrc_file="$1"
    local temp_file=$(mktemp)

    log_info "确保Powerlevel10k配置..."

    # 复制原配置
    cp "$zshrc_file" "$temp_file"

    # 检查是否已有p10k.zsh源配置
    if ! grep -q "\[.*-f.*\.p10k\.zsh.*\].*source.*\.p10k\.zsh" "$temp_file"; then
        log_info "添加Powerlevel10k配置源..."

        # 在文件末尾添加p10k配置
        cat >> "$temp_file" << 'EOF'

# Powerlevel10k 配置
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
        log_info "已添加Powerlevel10k配置源"
    else
        log_info "Powerlevel10k配置源已存在"
    fi

    # 应用更改
    mv "$temp_file" "$zshrc_file"
    return 0
}

# 添加增强配置
# 参数: $1 - .zshrc文件路径
add_enhanced_config() {
    local zshrc_file="$1"
    local temp_file=$(mktemp)

    log_info "添加增强配置..."

    # 复制原配置
    cp "$zshrc_file" "$temp_file"

    # 检查是否已有增强配置
    if ! grep -q "# Enhanced configurations" "$temp_file"; then
        cat >> "$temp_file" << 'EOF'

# =============================================================================
# Enhanced configurations added by zsh-plugins-install.sh
# =============================================================================

# Powerlevel10k instant prompt 配置
# 必须在 instant prompt 启动前设置，避免与 ssh-agent 等插件的冲突
# 可选值: verbose/quiet/off
# - verbose: 显示警告（默认）
# - quiet: 静默模式，不显示警告但 prompt 可能跳动
# - off: 禁用 instant prompt
# 推荐使用 quiet，因为 ssh-agent 插件会在启动时输出信息
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# 现代化工具别名
command -v bat >/dev/null && alias cat='bat --style=plain'
command -v fd >/dev/null && alias find='fd'
command -v eza >/dev/null && alias ls='eza --color=always --group-directories-first'



# 插件特定配置
# you-should-use 插件配置
export YSU_MESSAGE_POSITION="after"
#export YSU_HARDCORE=1

# zsh-autosuggestions 插件配置
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ssh-agent 插件配置
# 启用代理转发支持
#zstyle :omz:plugins:ssh-agent agent-forwarding yes

# 延迟加载（首次使用时加载密钥，推荐与 AddKeysToAgent 配合使用）
zstyle :omz:plugins:ssh-agent lazy yes

# 静默模式（不显示加载信息）
zstyle :omz:plugins:ssh-agent quiet yes

# 加载特定身份（默认加载 ~/.ssh/id_rsa 等）
#zstyle :omz:plugins:ssh-agent identities id_rsa id_github

# 设置密钥有效期（例如 4小时）
#zstyle :omz:plugins:ssh-agent lifetime 4h

EOF
        log_info "已添加增强配置"
    else
        log_info "增强配置已存在"
    fi

    # 应用更改
    mv "$temp_file" "$zshrc_file"
    return 0
}

# 更新.zshrc配置文件
update_zshrc_config() {
    log_info "更新.zshrc配置文件..."
    set_install_state "UPDATING_CONFIG"

    local zshrc_file="$HOME/.zshrc"

    # 检查文件是否存在
    if [ ! -f "$zshrc_file" ]; then
        log_error ".zshrc文件不存在，请先运行 zsh-core-install.sh"
        return 1
    fi

    # 应用智能插件配置管理
    smart_plugin_config_management "$zshrc_file"

    # 确保Powerlevel10k配置
    ensure_p10k_config "$zshrc_file"

    # 添加增强配置
    add_enhanced_config "$zshrc_file"

    log_info ".zshrc配置文件更新完成"
    return 0
}

# 验证配置文件
verify_zshrc_config() {
    log_info "验证ZSH配置文件..."

    local zshrc_file="$HOME/.zshrc"

    # 检查文件是否存在
    if [ ! -f "$zshrc_file" ]; then
        log_error ".zshrc文件不存在"
        return 1
    fi

    # 检查配置语法
    if zsh -n "$zshrc_file" 2>/dev/null; then
        log_info ".zshrc语法检查通过"
    else
        log_error ".zshrc语法检查失败"
        return 1
    fi

    # 检查插件配置是否存在
    if grep -q "plugins=.*zsh-autosuggestions.*zsh-syntax-highlighting" "$zshrc_file"; then
        log_info "插件配置验证通过"
    else
        log_warn "插件配置可能不完整"
    fi

    # 测试配置加载
    if echo 'source ~/.zshrc && echo "Config test successful"' | zsh 2>/dev/null | grep -q "Config test successful"; then
        log_info ".zshrc配置加载测试通过"
        return 0
    else
        log_error ".zshrc配置加载测试失败"
        return 1
    fi
}

# =============================================================================
# 主安装流程
# =============================================================================

# 显示脚本头部信息
show_header() {
    clear
    # 安全地使用颜色变量，如果未定义则使用空字符串
    local blue_color="${BLUE:-}"
    local cyan_color="${CYAN:-}"
    local yellow_color="${YELLOW:-}"
    local reset_color="${RESET:-}"

    echo -e "${blue_color}================================================================${reset_color}"
    echo -e "${blue_color}ZSH插件和工具安装脚本${reset_color}"
    echo -e "${blue_color}版本: $ZSH_PLUGINS_VERSION${reset_color}"
    echo -e "${blue_color}作者: saul${reset_color}"
    echo -e "${blue_color}邮箱: sau1amaranth@gmail.com${reset_color}"
    echo -e "${blue_color}================================================================${reset_color}"
    echo
    echo -e "${cyan_color}本脚本将安装和配置ZSH插件和工具：${reset_color}"
    echo -e "${cyan_color}• ZSH插件: zsh-autosuggestions, zsh-syntax-highlighting, you-should-use${reset_color}"
    echo -e "${cyan_color}• 额外工具: tmux配置${reset_color}"
    echo -e "${cyan_color}• 智能配置管理和优化${reset_color}"
    echo
    echo -e "${yellow_color}⚠️  前置要求：需要先运行 zsh-core-install.sh 安装核心环境${reset_color}"
    echo -e "${yellow_color}   本脚本不会自动安装任何软件，需要您的明确确认${reset_color}"
    echo
}

# 显示安装总结
show_installation_summary() {
    local status="$1"

    echo
    echo -e "${CYAN}================================================================${RESET}"

    case "$status" in
        "success")
            echo -e "${GREEN}🎉 ZSH插件和工具安装成功！${RESET}"
            echo
            echo -e "${CYAN}已安装的组件：${RESET}"

            # 检查插件安装状态
            local installed_plugins=()
            for plugin_info in "${ZSH_PLUGINS[@]}"; do
                IFS=':' read -r plugin_name plugin_repo <<< "$plugin_info"
                local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
                if [ -d "$plugin_dir" ]; then
                    installed_plugins+=("$plugin_name")
                fi
            done

            echo -e "  ✅ ZSH插件: ${installed_plugins[*]}"
            echo -e "  ✅ tmux配置: $([ -f "$HOME/.tmux.conf" ] && echo '已配置' || echo '未配置')"
            echo -e "  ✅ 智能配置: 已更新"
            echo
            echo -e "${YELLOW}下一步操作：${RESET}"
            echo -e "  1. 运行 ${CYAN}chsh -s \$(which zsh)${RESET} 设置为默认shell"
            echo -e "  2. 重新登录或运行 ${CYAN}zsh${RESET} 开始使用"
            echo -e "  3. 首次启动时配置 Powerlevel10k 主题"
            ;;
        "failed")
            echo -e "${RED}❌ ZSH插件和工具安装失败${RESET}"
            echo
            echo -e "${YELLOW}故障排除建议：${RESET}"
            echo -e "  • 确保已运行 zsh-core-install.sh 安装核心环境"
            echo -e "  • 检查网络连接是否正常"
            echo -e "  • 确保有足够的磁盘空间"
            echo -e "  • 查看安装日志: ${CYAN}$INSTALL_LOG_FILE${RESET}"
            ;;
    esac

    echo -e "${CYAN}================================================================${RESET}"
    echo
}

# 主安装函数
main() {
    # 显示头部信息
    show_header

    # 初始化环境
    init_environment

    # 检查前置条件
    log_info "检查前置条件..."
    if ! check_zsh_core_installed || ! check_system_dependencies; then
        log_error "前置条件检查失败"
        show_installation_summary "failed"
        exit 1
    fi

    # 使用标准化的交互式确认
    if [ "$ZSH_INSTALL_MODE" = "interactive" ]; then
        if interactive_ask_confirmation "是否继续安装ZSH插件和工具？" "true"; then
            log_info "用户确认继续安装"
        else
            log_info "用户取消安装"
            exit 0
        fi
        echo
    fi

    log_info "开始ZSH插件和工具安装..."
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始安装" >> "$INSTALL_LOG_FILE"

    # 执行安装步骤
    local install_success=true

    # 步骤1: 安装ZSH插件
    log_info "步骤1: 安装ZSH插件..."
    if ! install_zsh_plugins; then
        log_warn "部分ZSH插件安装失败，但不影响主要功能"
        # 插件安装失败不应该阻止整个流程
    fi
    verify_plugins_installation

    # 步骤2: 安装额外工具
    log_info "步骤2: 安装额外工具..."

    # 安装tmux配置
    log_info "2.1 安装tmux配置..."
    install_tmux_config

    # 步骤3: 更新配置文件
    log_info "步骤3: 更新配置文件..."
    if ! update_zshrc_config || ! verify_zshrc_config; then
        log_error "配置文件更新失败"
        install_success=false
    fi

    # 显示安装结果
    if [ "$install_success" = true ]; then
        set_install_state "COMPLETED"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - 安装成功" >> "$INSTALL_LOG_FILE"
        show_installation_summary "success"

        # 清理临时文件
        rm -f "$INSTALL_LOG_FILE" 2>/dev/null || true

        return 0
    else
        set_install_state "FAILED"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - 安装失败" >> "$INSTALL_LOG_FILE"
        show_installation_summary "failed"

        # 执行回滚
        execute_rollback

        return 1
    fi
}

# =============================================================================
# 脚本入口点
# =============================================================================

# 检查是否被其他脚本调用
is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ -z "${BASH_SOURCE[0]:-}" ]]; then
    # 检查参数
    case "${1:-}" in
        --tmux-help|-t)
            # 只显示tmux快捷键帮助
            show_header
            show_tmux_key_bindings
            exit 0
            ;;
        --help|-h)
            # 显示帮助信息
            show_header
            echo -e "${CYAN}用法: $0 [选项]${RESET}"
            echo
            echo -e "${CYAN}选项:${RESET}"
            echo -e "  ${GREEN}--help, -h${RESET}       显示此帮助信息"
            echo -e "  ${GREEN}--tmux-help, -t${RESET}  显示tmux快捷键帮助"
            echo -e "  ${GREEN}(无参数)${RESET}         运行完整安装流程"
            echo
            echo -e "${CYAN}示例:${RESET}"
            echo -e "  $0                   # 运行安装"
            echo -e "  $0 --tmux-help       # 显示tmux快捷键"
            echo
            exit 0
            ;;
        *)
            # 正常运行
            main "$@"
            ;;
    esac
fi
