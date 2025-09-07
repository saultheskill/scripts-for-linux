#!/bin/bash

# =============================================================================
# Git 差异预览演示脚本
# =============================================================================
# 
# 此脚本演示 gst 命令的差异预览功能
# 
# 作者: Shell Tools 配置系统
# 版本: 1.0
# =============================================================================

echo "🎯 Git 差异预览功能演示"
echo "======================================"
echo

# 检查是否在 Git 仓库中
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ 当前目录不是 Git 仓库，请在 Git 仓库中运行此脚本"
    exit 1
fi

echo "📝 创建测试文件和不同状态..."

# 1. 创建已修改文件 (M)
echo -e "原始内容第一行\n原始内容第二行\n原始内容第三行" > modified_file.txt
git add modified_file.txt
git commit -m "添加测试文件" >/dev/null 2>&1
echo -e "修改后第一行\n原始内容第二行\n修改后第三行\n新增第四行" > modified_file.txt

# 2. 创建新文件 (??)
echo -e "这是新文件\n包含一些内容\n用于测试预览" > new_file.txt

# 3. 创建暂存区修改文件 ( M)
echo -e "暂存区内容第一行\n暂存区内容第二行" > staged_file.txt
git add staged_file.txt

# 4. 创建同时有暂存区和工作区修改的文件 (MM)
echo -e "基础内容第一行\n基础内容第二行" > mixed_file.txt
git add mixed_file.txt
git commit -m "添加混合测试文件" >/dev/null 2>&1
echo -e "暂存区修改第一行\n基础内容第二行\n暂存区新增行" > mixed_file.txt
git add mixed_file.txt
echo -e "工作区修改第一行\n基础内容第二行\n暂存区新增行\n工作区新增行" > mixed_file.txt

echo "✅ 测试文件创建完成！"
echo
echo "📊 当前 Git 状态:"
git status --porcelain
echo
echo "🎯 现在运行 'gst' 命令体验差异预览功能:"
echo "======================================"
echo "💡 使用说明:"
echo "  - 使用 ↑↓ 键选择不同文件"
echo "  - 右侧预览窗口会显示对应的差异内容"
echo "  - 不同状态文件显示不同类型的差异:"
echo "    • M  (已修改): 显示工作区差异"
echo "    • MM (混合修改): 显示工作区差异"
echo "    • AM (新增+修改): 显示工作区差异"
echo "    •  M (暂存区修改): 显示暂存区差异"
echo "    • ?? (未跟踪): 显示文件内容"
echo "  - 按 ENTER 添加文件到暂存区"
echo "  - 按 CTRL-R 重置文件状态"
echo "  - 按 ESC 或 CTRL-C 退出"
echo
echo "🚀 准备就绪！请运行: gst"
