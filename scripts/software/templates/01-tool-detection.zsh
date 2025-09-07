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
    # 验证别名是否工作
    if ! fd --version >/dev/null 2>&1; then
        echo "警告：fd别名设置失败，请检查fdfind安装"
    fi
elif command -v fd >/dev/null 2>&1; then
    # fd 已经可用，无需别名
    :
else
    # 如果都没有找到，提供安装提示
    echo "提示：未找到fd工具。在Ubuntu/Debian上请运行: sudo apt install fd-find"
fi
