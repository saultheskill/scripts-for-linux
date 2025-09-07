#!/bin/bash

# =============================================================================
# Git 别名覆盖演示脚本
# =============================================================================
# 
# 此脚本演示如何验证 Git 别名覆盖是否成功
# 
# 作者: Shell Tools 配置系统
# 版本: 1.0
# =============================================================================

echo "🔍 Git 别名覆盖验证演示"
echo "======================================"
echo

# 检查是否在 Git 仓库中
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ 当前目录不是 Git 仓库，请在 Git 仓库中运行此脚本"
    exit 1
fi

# 加载 Git 集成模块
echo "📦 加载 Git 集成模块..."
if [[ -f "/root/.oh-my-zsh/custom/modules/09-git-integration.zsh" ]]; then
    source "/root/.oh-my-zsh/custom/modules/09-git-integration.zsh"
    echo "✅ Git 集成模块已加载"
else
    echo "❌ Git 集成模块未找到"
    exit 1
fi

echo
echo "🔍 验证别名覆盖状态:"
echo "======================================"

# 检查主要别名
echo "📋 主要别名检查:"
aliases_to_check=("gco" "glog" "gst" "gbl")
for alias_name in "${aliases_to_check[@]}"; do
    alias_def=$(alias "$alias_name" 2>/dev/null)
    if [[ -n "$alias_def" ]]; then
        echo "  ✅ $alias_name: $alias_def"
    else
        echo "  ❌ $alias_name: 未定义"
    fi
done

echo
echo "🔙 原始功能别名检查:"
orig_aliases=("gco-orig" "glog-orig" "gst-orig" "gbl-orig")
for alias_name in "${orig_aliases[@]}"; do
    alias_def=$(alias "$alias_name" 2>/dev/null)
    if [[ -n "$alias_def" ]]; then
        echo "  ✅ $alias_name: $alias_def"
    else
        echo "  ❌ $alias_name: 未定义"
    fi
done

echo
echo "🚀 函数定义检查:"
functions_to_check=("_git_checkout_interactive" "_git_log_interactive" "_git_status_interactive" "git-alias-status")
for func_name in "${functions_to_check[@]}"; do
    if declare -f "$func_name" >/dev/null 2>&1; then
        echo "  ✅ $func_name: 已定义"
    else
        echo "  ❌ $func_name: 未定义"
    fi
done

echo
echo "🎯 功能测试:"
echo "======================================"

echo "📊 运行 git-alias-status 命令:"
if declare -f git-alias-status >/dev/null 2>&1; then
    git-alias-status
else
    echo "❌ git-alias-status 函数未定义"
fi

echo
echo "🔍 对比测试 (如果可用):"
echo "======================================"

echo "📝 原始 git status vs 交互式 gst:"
echo "  原始命令: gst-orig"
echo "  交互式:   gst (需要在有文件变更时测试)"

echo
echo "📜 原始 git log vs 交互式 glog:"
echo "  原始命令: glog-orig"
echo "  交互式:   glog (需要在有提交历史时测试)"

echo
echo "🌿 原始 git checkout vs 交互式 gco:"
echo "  原始命令: gco-orig <branch>"
echo "  交互式:   gco (显示分支选择界面)"

echo
echo "✅ 验证完成！"
echo "======================================"
echo "💡 提示:"
echo "  - 运行 'git-alias-status' 查看详细状态"
echo "  - 运行 'gco' 体验交互式分支切换"
echo "  - 运行 'glog' 体验交互式提交历史"
echo "  - 运行 'gst' 体验交互式文件状态"
echo "  - 使用 '*-orig' 别名访问原始 Git 命令"
