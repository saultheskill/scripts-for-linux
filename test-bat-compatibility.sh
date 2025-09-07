#!/bin/bash

# 测试脚本：验证bat兼容性修复
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

echo "2. 测试基本bat功能..."
echo "Hello World" | $bat_cmd -l txt --paging=never

echo "3. 测试函数是否正确定义..."
echo "检查 rfv 函数:"
type rfv 2>/dev/null && echo "✓ rfv 函数已定义" || echo "✗ rfv 函数未定义"

echo "检查 gst 别名:"
type gst 2>/dev/null && echo "✓ gst 别名已定义" || echo "✗ gst 别名未定义"

echo "检查 fzf-git-status 函数:"
type fzf-git-status 2>/dev/null && echo "✓ fzf-git-status 函数已定义" || echo "✗ fzf-git-status 函数未定义"

echo "4. 测试函数内部bat调用..."
echo "测试 rfv 函数的帮助信息:"
rfv 2>&1 | head -3

echo "=== 测试完成 ==="
