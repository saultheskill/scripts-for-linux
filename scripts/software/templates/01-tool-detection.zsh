# 工具可用性检测和别名统一化

# 检测并统一 bat 命令（Ubuntu/Debian 使用 batcat）
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
elif command -v bat >/dev/null 2>&1; then
    # bat 已经可用，无需别名
    :
fi

# 检测并统一 fd 命令（Ubuntu/Debian 使用 fdfind）
# 优先检查fdfind，因为在Ubuntu/Debian系统上这是标准安装名称
if command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
    # 验证fdfind是否正常工作
    if fdfind --version >/dev/null 2>&1; then
        echo "✅ fd (fdfind) 已配置"
    else
        echo "⚠️  fdfind 安装异常"
    fi
elif command -v fd >/dev/null 2>&1; then
    # fd 已经可用，无需别名
    echo "✅ fd 已安装"
else
    # 如果都没有找到，提供安装提示
    echo "⚠️  未找到fd工具。在Ubuntu/Debian上请运行: sudo apt install fd-find"
fi

# 检测并设置 eza/exa 别名（现代化文件列表工具）
if command -v eza >/dev/null 2>&1; then
    # eza 是 exa 的现代继任者，优先使用
    if ! command -v exa >/dev/null 2>&1; then
        alias exa='eza'
    fi
    echo "✅ eza 已安装"
elif command -v exa >/dev/null 2>&1; then
    echo "✅ exa 已安装"
else
    # 如果都没有，使用 ls 作为后备
    if command -v ls >/dev/null 2>&1; then
        alias exa='ls --color=auto'
        alias eza='ls --color=auto'
        echo "⚠️  eza/exa 未安装，已设置 ls 别名"
        echo "💡 建议安装 eza: https://github.com/eza-community/eza"
    fi
fi
