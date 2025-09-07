# PATH和基础环境配置 - 必须在所有工具检测之前执行

# 修复Ubuntu/Debian系统PATH问题 - 确保/bin和/usr/bin在PATH中
# 这对于fd/fdfind等工具的正确检测至关重要
if [[ ":$PATH:" != *":/bin:"* ]]; then
    export PATH="/bin:$PATH"
fi

if [[ ":$PATH:" != *":/usr/bin:"* ]]; then
    export PATH="/usr/bin:$PATH"
fi

# 确保/usr/local/bin也在PATH中（某些系统可能需要）
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    export PATH="/usr/local/bin:$PATH"
fi

# 刷新命令哈希表以确保新的PATH生效
hash -r 2>/dev/null || true
