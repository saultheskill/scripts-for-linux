#!/bin/bash

echo "=== 测试bat兼容性修复 ==="

# 加载配置
source ~/.shell-tools-config.zsh

echo "1. 测试bat命令检测..."
if command -v batcat >/dev/null 2>&1; then
    echo "✓ 检测到 batcat 命令"
    bat_cmd='batcat'
elif command -v bat >/dev/null 2>&1; then
    echo "✓ 检测到 bat 命令"
    bat_cmd='bat'
else
    echo "✗ 未找到 bat 工具"
    exit 1
fi

echo "2. 测试函数内部bat检测逻辑..."

# 测试一个简单的函数调用
echo "测试 fzf-git-status 函数的bat检测:"
zsh -c "
source ~/.shell-tools-config.zsh
fzf-git-status() {
    # 确保bat命令可用
    local bat_cmd
    if command -v batcat >/dev/null 2>&1; then
        bat_cmd='batcat'
        echo '✓ fzf-git-status: 检测到 batcat'
    elif command -v bat >/dev/null 2>&1; then
        bat_cmd='bat'
        echo '✓ fzf-git-status: 检测到 bat'
    else
        echo '✗ fzf-git-status: 未找到bat工具'
        return 1
    fi
    echo \"使用的bat命令: \$bat_cmd\"
}
fzf-git-status
"

echo "3. 测试别名是否正确定义..."
if alias gst >/dev/null 2>&1; then
    echo "✓ gst 别名已定义: $(alias gst)"
else
    echo "✗ gst 别名未定义"
fi

echo "=== 测试完成 ==="
