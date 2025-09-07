# 最终别名汇总和show-tools功能

# show-tools 函数 - 显示所有可用的工具和别名
show-tools() {
    echo "🚀 Shell Tools 功能概览"
    echo "=========================="
    echo
    
    # 核心工具状态
    echo "🔧 核心工具状态:"
    local tools=("bat" "fd" "fzf" "rg" "git")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf "  ✅ %-8s %s\n" "$tool" "$(command -v "$tool")"
        else
            printf "  ❌ %-8s %s\n" "$tool" "未安装"
        fi
    done
    echo
    
    # 文件操作
    echo "📁 文件操作:"
    echo "  fe/fed     - 用fzf搜索并编辑文件"
    echo "  fp/ff      - 用fzf搜索并预览文件"
    echo "  fcd/fdir   - 用fzf搜索并跳转目录"
    echo "  fif        - 搜索文件内容并编辑"
    echo "  fdbat      - 用fd搜索文件并用bat查看"
    echo "  fdpreview  - 用fd搜索文件并预览"
    echo
    
    # 搜索功能
    echo "🔍 搜索功能:"
    echo "  rgf/rgfzf  - ripgrep + fzf交互搜索"
    echo "  rge/rged   - 搜索并编辑文件"
    echo "  rgc/rgctx  - 搜索并显示上下文"
    echo "  search-all/sa - 综合搜索（文件名+内容）"
    echo "  fms        - fzf多模式搜索"
    echo
    
    # Git集成
    if command -v git >/dev/null 2>&1; then
        echo "🌿 Git集成:"
        echo "  gco/gbr    - 分支选择和切换"
        echo "  glog/glg   - 提交历史浏览"
        echo "  gst/gstat  - 文件状态查看"
        echo "  gstash/gsh - stash管理"
        echo "  gdiff/gdf  - 差异查看"
        echo
    fi
    
    # 系统工具
    echo "⚙️ 系统工具:"
    echo "  fh/fhist   - 历史命令搜索"
    echo "  fkill      - 进程查看和终止"
    echo "  batman     - man页面搜索"
    echo "  fman       - fzf + man页面"
    echo "  af         - APT包搜索和安装"
    echo
    
    # 工具函数
    echo "🛠️ 工具函数:"
    echo "  quick-view/qv    - 快速文件查看"
    echo "  file-sizes/fs    - 文件大小分析"
    echo "  find-duplicates  - 查找重复文件"
    echo "  clean-empty      - 清理空文件和目录"
    echo
    
    # 调试和状态
    echo "🔧 调试和状态:"
    echo "  shell-tools-debug   - 显示详细调试信息"
    echo "  shell-tools-status  - 显示模块状态"
    echo "  shell-tools-reload  - 重新加载配置"
    echo
    
    # 使用提示
    echo "💡 使用提示:"
    echo "  - 大多数fzf功能支持多选（TAB键）"
    echo "  - 使用CTRL-C退出fzf界面"
    echo "  - 在fzf中使用CTRL-/切换预览"
    echo "  - 运行 'shell-tools-debug' 查看详细状态"
    echo
    
    echo "📚 更多信息: https://github.com/junegunn/fzf"
}

# 快速帮助别名
alias tools='show-tools'
alias help-tools='show-tools'
alias st='show-tools'

# 最终状态显示
echo "✨ Shell Tools 模块化配置加载完成"
echo "💡 运行 'show-tools' 或 'tools' 查看所有功能"
