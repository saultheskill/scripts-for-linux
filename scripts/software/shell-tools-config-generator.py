#!/usr/bin/env python3

"""
Shell工具配置生成器
作者: saul
版本: 1.0
描述: 生成fd、fzf等现代shell工具的最佳实践配置
"""

import os
import sys
from pathlib import Path

# 添加scripts目录到Python路径
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir.parent))

try:
    from common import *
except ImportError:
    print("错误：无法导入common模块")
    sys.exit(1)

def generate_shell_tools_config():
    """
    生成shell工具配置文件

    Returns:
        bool: 生成是否成功
    """
    config_path = Path.home() / ".shell-tools-config.zsh"

    config_content = '''# =============================================================================
# Shell Tools Configuration - 现代shell工具最佳实践配置
# 由 shell-tools-config-generator.py 自动生成
# =============================================================================

# =============================================================================
# fd (find的现代替代品) 配置
# =============================================================================

# fd别名和环境变量
if command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
elif command -v fd >/dev/null 2>&1; then
    # fd已经可用，无需别名
    :
fi

# fd的常用别名
if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
    # 搜索文件（忽略隐藏文件和.gitignore）
    alias fdf='fd --type f'
    # 搜索目录
    alias fdd='fd --type d'
    # 搜索所有文件（包括隐藏文件）
    alias fda='fd --hidden --no-ignore'
    # 搜索可执行文件
    alias fdx='fd --type f --executable'
fi

# =============================================================================
# fzf (模糊查找工具) 配置
# =============================================================================

if command -v fzf >/dev/null 2>&1; then
    # fzf默认选项
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

    # 如果fd可用，使用fd作为fzf的默认命令
    if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    # fzf键绑定（如果可用）
    if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    elif [[ -f ~/.fzf.zsh ]]; then
        source ~/.fzf.zsh
    fi

    # fzf自动补全（如果可用）
    if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
        source /usr/share/doc/fzf/examples/completion.zsh
    fi

    # 自定义fzf函数
    # 使用fzf搜索并编辑文件
    fzf-edit() {
        local file
        file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' 2>/dev/null)
        if [[ -n "$file" ]]; then
            ${EDITOR:-vim} "$file"
        fi
    }

    # 使用fzf搜索并cd到目录
    fzf-cd() {
        local dir
        dir=$(fd --type d | fzf --preview 'tree -C {} | head -200' 2>/dev/null)
        if [[ -n "$dir" ]]; then
            cd "$dir"
        fi
    }

    # 别名
    alias fe='fzf-edit'
    alias fcd='fzf-cd'
fi

# =============================================================================
# bat (cat的增强版) 配置
# =============================================================================

# 检查 batcat 是否安装（Ubuntu 中 bat 工具的实际命令）
if command -v batcat >/dev/null 2>&1; then
    # 1. 配置分页器（pager）：优先使用 less 并添加优化参数
    # -R: 支持原始控制字符（确保颜色显示正常）
    # -F: 若内容少于一屏，自动退出分页器（类似 cat 的即时显示）
    # -K: 按 Ctrl+C 时立即退出分页器，不显示 "Terminated" 提示
    export BAT_PAGER="less -RFK"

    # 2. 核心别名配置（覆盖系统默认的 cat/less/more）
    # --style: 显示行号（numbers）、Git 变更（changes）、文件头（header）
    # --theme: 语法高亮主题（可替换为你喜欢的主题，如 TwoDark、Monokai Extended）
    # --italic-text: 始终斜体文本（需要终端支持）
    # --paging: 分页策略（never：从不分页；always：强制分页）
    alias cat='batcat --style="numbers,changes,header" --theme="OneHalfDark" --italic-text=always --paging=never'
    alias less='batcat --paging=always'  # 强制分页时用 batcat的分页器
    alias more='batcat --paging=always'  # 兼容 more 兼容

    # 3. 额外实用命令：快速查看主题列表并预览（依赖 fzf）
    if command -v fzf >/dev/null 2>&1; then
        alias bat-themes='batcat --list-themes | fzf --preview="batcat --theme={} --color=always ~/.bashrc"'
    fi
fi

# =============================================================================
# btop (系统监控工具) 配置
# =============================================================================

if command -v btop >/dev/null 2>&1; then
    alias top='btop'
    alias htop='btop'
fi

# =============================================================================
# 网络工具别名
# =============================================================================

# 网络诊断工具的便捷别名
if command -v mtr >/dev/null 2>&1; then
    alias mtr='mtr --show-ips'
fi

if command -v nmap >/dev/null 2>&1; then
    # 快速端口扫描
    alias nmap-quick='nmap -T4 -F'
    # 详细扫描
    alias nmap-detail='nmap -T4 -A -v'
fi

# =============================================================================
# 磁盘使用分析
# =============================================================================

if command -v ncdu >/dev/null 2>&1; then
    alias du='ncdu'
fi

# =============================================================================
# 实用函数
# =============================================================================

# 快速查找大文件
find-large-files() {
    local size=${1:-100M}
    find . -type f -size +$size -exec ls -lh {} \\; | awk '{ print $9 ": " $5 }'
}

# 快速查找最近修改的文件
find-recent() {
    local days=${1:-7}
    find . -type f -mtime -$days -exec ls -lt {} \\;
}

# 端口占用检查
port-check() {
    local port=$1
    if [[ -z "$port" ]]; then
        echo "用法: port-check <端口号>"
        return 1
    fi

    if command -v netstat >/dev/null 2>&1; then
        netstat -tlnp | grep ":$port "
    elif command -v ss >/dev/null 2>&1; then
        ss -tlnp | grep ":$port "
    else
        echo "需要安装 net-tools 或 iproute2"
    fi
}

# 快速HTTP服务器
serve() {
    local port=${1:-8000}
    echo "在端口 $port 启动HTTP服务器..."
    echo "访问: http://localhost:$port"
    python3 -m http.server $port
}
'''

    try:
        with open(config_path, 'w') as f:
            f.write(config_content)

        log_success(f"Shell工具配置文件已生成: {config_path}")
        return True

    except Exception as e:
        log_error(f"生成Shell工具配置文件失败: {str(e)}")
        return False

def update_zshrc_for_shell_tools():
    """
    更新.zshrc文件以引用Shell工具配置

    Returns:
        bool: 更新是否成功
    """
    zshrc_path = Path.home() / ".zshrc"
    config_source_line = "# Shell Tools Configuration - Auto-generated by shell-tools-config-generator.py"
    source_line = "[[ -f ~/.shell-tools-config.zsh ]] && source ~/.shell-tools-config.zsh"

    if not zshrc_path.exists():
        log_warn(".zshrc文件不存在，创建新文件")
        with open(zshrc_path, 'w') as f:
            f.write(f"{config_source_line}\n{source_line}\n")
        return True

    try:
        with open(zshrc_path, 'r') as f:
            content = f.read()

        # 检查是否已经包含Shell工具配置引用
        if source_line in content:
            log_info("Shell工具配置引用已存在于.zshrc中")
            return True

        # 添加Shell工具配置引用
        with open(zshrc_path, 'a') as f:
            f.write(f"\n{config_source_line}\n{source_line}\n")

        log_success("已更新.zshrc文件以引用Shell工具配置")
        return True

    except Exception as e:
        log_error(f"更新.zshrc文件失败: {str(e)}")
        return False

def main():
    """主函数"""
    show_header("Shell工具配置生成器", "1.0", "生成fd、fzf等现代shell工具的最佳实践配置")

    log_info("开始生成Shell工具配置...")

    # 生成Shell工具配置文件
    if not generate_shell_tools_config():
        log_error("Shell工具配置文件生成失败")
        return False

    # 更新.zshrc文件
    if not update_zshrc_for_shell_tools():
        log_error(".zshrc文件更新失败")
        return False

    log_success("Shell工具配置生成完成！")
    log_info("请运行 'source ~/.zshrc' 或重新启动终端以应用配置")

    return True

if __name__ == "__main__":
    main()
