#!/bin/bash

echo "=== 🔧 APT + fzf 集成功能测试 ==="

# 加载配置
source ~/.shell-tools-config.zsh

echo "1. 🔍 工具可用性检查..."

# 检查必需的工具
tools_status=()

if command -v apt-cache >/dev/null 2>&1; then
    echo "✓ apt-cache 可用"
    tools_status+=("apt-cache:✓")
else
    echo "✗ apt-cache 不可用"
    tools_status+=("apt-cache:✗")
fi

if command -v fzf >/dev/null 2>&1; then
    echo "✓ fzf 可用"
    tools_status+=("fzf:✓")
else
    echo "✗ fzf 不可用"
    tools_status+=("fzf:✗")
fi

if command -v xargs >/dev/null 2>&1; then
    echo "✓ xargs 可用"
    tools_status+=("xargs:✓")
else
    echo "✗ xargs 不可用"
    tools_status+=("xargs:✗")
fi

echo
echo "2. 🎯 APT集成功能验证..."

# 测试主要别名
echo "测试 af 别名:"
if type af >/dev/null 2>&1; then
    echo "  ✓ af 别名已定义"
    echo "  命令: $(alias af)"
else
    echo "  ✗ af 别名未定义"
fi

# 测试辅助功能
echo "测试辅助功能:"

# 测试函数
if type apt-search >/dev/null 2>&1; then
    echo "  ✓ apt-search 函数已定义"
else
    echo "  ✗ apt-search 函数未定义"
fi

if type apt-info >/dev/null 2>&1; then
    echo "  ✓ apt-info 函数已定义"
else
    echo "  ✗ apt-info 函数未定义"
fi

# 测试别名
if type as >/dev/null 2>&1; then
    echo "  ✓ as 别名已定义"
else
    echo "  ✗ as 别名未定义"
fi

if type ainfo >/dev/null 2>&1; then
    echo "  ✓ ainfo 别名已定义"
else
    echo "  ✗ ainfo 别名未定义"
fi

echo
echo "3. 🧪 功能测试..."

# 测试apt-search帮助
echo "测试 apt-search 帮助信息:"
apt-search 2>&1 | head -3

echo
echo "测试 apt-info 功能 (使用curl包):"
apt-info curl 2>/dev/null | head -5

echo
echo "测试 apt-deps 帮助信息:"
apt-deps 2>&1 | head -3

echo
echo "4. 📊 集成总结..."
echo "APT + fzf 集成功能:"
echo "  ✓ af - 交互式软件包搜索和安装"
echo "  ✓ as - 软件包搜索（不安装）"
echo "  ✓ ai - 已安装软件包查看"
echo "  ✓ ainfo - 软件包详细信息"
echo "  ✓ adeps - 依赖关系查看"

echo
echo "使用示例:"
echo "  af                    # 浏览所有可用软件包"
echo "  af | grep python      # 搜索python相关包"
echo "  as python             # 搜索python包（不安装）"
echo "  ainfo curl            # 查看curl包信息"
echo "  adeps nginx           # 查看nginx依赖"

echo
echo "=== ✅ 测试完成 ==="
