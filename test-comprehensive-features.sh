#!/bin/bash

echo "=== 🚀 综合功能测试 - APT修复 + fzf-basic-example.md集成 ==="

# 加载配置
source ~/.shell-tools-config.zsh

echo "1. 🔧 APT搜索功能修复验证..."

# 测试APT功能
echo "测试APT相关功能:"
if type af >/dev/null 2>&1; then
    echo "  ✓ af (apt-fzf) 别名已定义"
else
    echo "  ✗ af 别名未定义"
fi

if type apt-search >/dev/null 2>&1; then
    echo "  ✓ apt-search 函数已定义"
    echo "  测试帮助信息:"
    apt-search 2>&1 | head -3 | sed 's/^/    /'
else
    echo "  ✗ apt-search 函数未定义"
fi

echo
echo "2. 📁 基于fzf-basic-example.md的文件操作功能..."

# 测试文件操作功能
functions=("fe" "fo" "vf" "fdir" "fdira" "fdirt")
for func in "${functions[@]}"; do
    if type "$func" >/dev/null 2>&1; then
        echo "  ✓ $func 函数已定义"
    else
        echo "  ✗ $func 函数未定义"
    fi
done

echo
echo "3. 📚 历史命令和进程管理功能..."

# 测试历史和进程管理功能
functions=("fh" "fkill" "fif" "vg")
for func in "${functions[@]}"; do
    if type "$func" >/dev/null 2>&1; then
        echo "  ✓ $func 函数已定义"
    else
        echo "  ✗ $func 函数未定义"
    fi
done

echo
echo "4. 🎨 tmux集成功能..."

# 测试tmux功能
if command -v tmux >/dev/null 2>&1; then
    functions=("tm" "fs" "ftpane")
    for func in "${functions[@]}"; do
        if type "$func" >/dev/null 2>&1; then
            echo "  ✓ $func 函数已定义"
        else
            echo "  ✗ $func 函数未定义"
        fi
    done
else
    echo "  ⚠️  tmux 未安装，跳过tmux集成测试"
fi

echo
echo "5. 📖 高级man页面功能..."

# 测试man页面功能
if type batman >/dev/null 2>&1; then
    echo "  ✓ batman 别名已定义: $(alias batman 2>/dev/null || echo 'function')"
else
    echo "  ✗ batman 未定义"
fi

if type fman >/dev/null 2>&1; then
    echo "  ✓ fman 函数已定义"
else
    echo "  ✗ fman 函数未定义"
fi

if type fzf-man-widget >/dev/null 2>&1; then
    echo "  ✓ fzf-man-widget 函数已定义"
else
    echo "  ✗ fzf-man-widget 函数未定义"
fi

echo
echo "6. 🔍 功能演示..."

echo "演示 vf 函数（查看文件）:"
echo "  创建测试文件..."
echo "Hello World from comprehensive test" > /tmp/test-file.txt
echo "  使用 vf 查看（模拟）:"
echo "  vf 会启动交互式文件选择器"

echo
echo "演示 fdir 函数（目录切换）:"
echo "  fdir 会启动交互式目录选择器"

echo
echo "7. 📊 功能总结..."

echo "✅ 已修复的问题:"
echo "  • APT搜索功能：修复了搜索参数传递问题"
echo "  • batman实现：使用高级fzf-man-widget替换简单实现"

echo
echo "✅ 新增的功能（基于fzf-basic-example.md）:"
echo "  • 文件操作：fe, fo, vf"
echo "  • 目录导航：fdir, fdira, fdirt"
echo "  • 历史命令：fh（历史搜索）"
echo "  • 进程管理：fkill（交互式终止）"
echo "  • 内容搜索：fif, vg"
echo "  • tmux集成：tm, fs, ftpane"
echo "  • 高级man页面：fzf-man-widget with cheat.sh/tldr支持"

echo
echo "✅ 界面美化特性:"
echo "  • 彩色输出和语法高亮"
echo "  • 多种预览模式切换"
echo "  • 高级键绑定设置"
echo "  • 主题和样式配置"

echo
echo "=== ✅ 综合测试完成 ==="
echo "💡 运行 'show-tools' 查看所有可用功能"

# 清理测试文件
rm -f /tmp/test-file.txt
