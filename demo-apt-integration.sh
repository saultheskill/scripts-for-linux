#!/bin/bash

echo "=== 🚀 APT + fzf 集成功能演示 ==="

# 加载配置
source ~/.shell-tools-config.zsh

echo "📦 新增的APT集成功能："
echo
echo "1. 🔍 af (apt-fzf) - 交互式软件包搜索和安装"
echo "   命令: af"
echo "   功能: 浏览所有可用软件包，支持多选安装"
echo "   特性: 70%预览窗口显示包详情，Tab键多选"
echo
echo "2. 🔎 as (apt-search) - 软件包搜索（不安装）"
echo "   命令: as <搜索词>"
echo "   功能: 搜索特定软件包，仅查看不安装"
echo "   示例: as python"
echo
echo "3. 📋 ai (apt-installed) - 已安装软件包查看"
echo "   命令: ai"
echo "   功能: 浏览已安装的软件包"
echo
echo "4. ℹ️  ainfo (apt-info) - 软件包详细信息"
echo "   命令: ainfo <包名>"
echo "   功能: 查看软件包详细信息（使用bat高亮）"
echo "   示例: ainfo curl"
echo
echo "5. 🔗 adeps (apt-deps) - 依赖关系查看"
echo "   命令: adeps <包名>"
echo "   功能: 查看软件包依赖关系"
echo "   示例: adeps nginx"

echo
echo "=== 🧪 功能演示 ==="

echo
echo "1. 演示 ainfo 功能 - 查看curl包信息:"
echo "----------------------------------------"
ainfo curl | head -15

echo
echo "2. 演示 apt-search 帮助信息:"
echo "----------------------------------------"
apt-search

echo
echo "3. 演示 apt-deps 帮助信息:"
echo "----------------------------------------"
apt-deps

echo
echo "=== 💡 使用建议 ==="
echo
echo "🎯 常用场景："
echo "• 安装开发工具: af，然后搜索 'python3-dev'"
echo "• 查找编辑器: as editor"
echo "• 检查已安装: ai | grep python"
echo "• 了解包信息: ainfo package-name"
echo "• 查看依赖: adeps complex-package"

echo
echo "⚠️  安全提示："
echo "• af 命令会直接安装选中的软件包"
echo "• 使用 as 命令先搜索，确认后再用 af 安装"
echo "• 安装前请仔细查看包信息和依赖关系"

echo
echo "🔧 技术特性："
echo "• 自动检测 apt-cache、fzf、xargs 可用性"
echo "• 兼容 bat/batcat 命令用于语法高亮"
echo "• 支持多选安装（Tab键选择）"
echo "• 70%预览窗口显示详细包信息"
echo "• 智能错误处理和用户提示"

echo
echo "=== ✅ 演示完成 ==="
echo "💡 运行 'show-tools' 查看所有可用功能"
