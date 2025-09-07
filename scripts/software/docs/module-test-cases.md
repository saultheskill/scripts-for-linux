# Shell工具配置模块详细测试用例

## 🔧 模块00：PATH配置测试

### 功能描述
配置系统PATH环境变量，确保核心命令路径正确设置。

### 测试用例

#### TC-00-001：PATH基础配置测试
```bash
# 测试目标：验证PATH中包含必要路径
test_path_configuration() {
    source templates/00-path-config.zsh

    # 验证关键路径存在
    echo "$PATH" | grep -q "/bin" || return 1
    echo "$PATH" | grep -q "/usr/bin" || return 1
    echo "$PATH" | grep -q "/usr/local/bin" || return 1

    echo "✅ PATH配置正确"
}
```

#### TC-00-002：PATH重复添加测试
```bash
# 测试目标：验证重复加载不会重复添加PATH
test_path_duplication() {
    # 记录初始PATH
    local initial_path="$PATH"

    # 多次加载模块
    source templates/00-path-config.zsh
    source templates/00-path-config.zsh

    # 验证PATH长度没有异常增长
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    [[ $path_count -lt 20 ]] || return 1

    echo "✅ PATH重复添加防护正常"
}
```

## 🔍 模块01：工具检测测试

### 功能描述
检测并设置bat和fd工具的别名，处理Ubuntu/Debian系统的命名差异。

### 测试用例

#### TC-01-001：bat工具检测测试
```bash
test_bat_detection() {
    source templates/01-tool-detection.zsh

    # 检查bat别名设置
    if command -v batcat >/dev/null 2>&1; then
        alias bat | grep -q "batcat" || return 1
        echo "✅ bat别名设置正确 (batcat)"
    elif command -v bat >/dev/null 2>&1; then
        echo "✅ bat命令直接可用"
    else
        echo "⚠️  bat工具未安装"
        return 2  # 跳过测试
    fi
}
```

#### TC-01-002：fd工具检测测试
```bash
test_fd_detection() {
    source templates/01-tool-detection.zsh

    # 检查fd别名设置
    if command -v fdfind >/dev/null 2>&1; then
        alias fd | grep -q "fdfind" || return 1
        # 验证别名功能
        fd --version >/dev/null 2>&1 || return 1
        echo "✅ fd别名设置正确 (fdfind)"
    elif command -v fd >/dev/null 2>&1; then
        echo "✅ fd命令直接可用"
    else
        echo "⚠️  fd工具未安装"
        return 2
    fi
}
```

#### TC-01-003：工具缺失处理测试
```bash
test_missing_tools_handling() {
    # 临时隐藏工具
    local original_path="$PATH"
    export PATH="/tmp"

    source templates/01-tool-detection.zsh 2>&1 | grep -q "提示：未找到"
    local result=$?

    # 恢复PATH
    export PATH="$original_path"

    [[ $result -eq 0 ]] && echo "✅ 工具缺失提示正常"
}
```

## 🦇 模块02：bat配置测试

### 功能描述
配置bat工具的环境变量、主题和别名。

### 测试用例

#### TC-02-001：bat环境变量测试
```bash
test_bat_environment() {
    source templates/02-bat-config.zsh

    # 检查环境变量设置
    [[ "$BAT_STYLE" == "numbers,changes,header,grid" ]] || return 1
    [[ "$BAT_THEME" == "OneHalfDark" ]] || return 1
    [[ "$BAT_PAGER" == "less -RFK" ]] || return 1

    echo "✅ bat环境变量配置正确"
}
```

#### TC-02-002：bat别名功能测试
```bash
test_bat_aliases() {
    source templates/02-bat-config.zsh

    # 测试主要别名
    local expected_aliases=("cat" "less" "more" "batl" "batn" "batp")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ 别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ bat别名设置完整"
}
```

## 📁 模块03：fd配置测试

### 功能描述
配置fd工具的基础别名和与bat的集成功能。

### 测试用例

#### TC-03-001：fd基础别名测试
```bash
test_fd_basic_aliases() {
    source templates/03-fd-config.zsh

    local expected_aliases=("fdf" "fdd" "fda" "fdx" "fds")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ fd别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ fd基础别名设置完整"
}
```

#### TC-03-002：fd+bat集成函数测试
```bash
test_fd_bat_integration() {
    source templates/03-fd-config.zsh

    # 检查集成函数定义
    declare -f fdbat >/dev/null 2>&1 || return 1
    declare -f fdpreview >/dev/null 2>&1 || return 1

    # 测试函数帮助信息
    fdbat 2>&1 | grep -q "用法:" || return 1
    fdpreview 2>&1 | grep -q "用法:" || return 1

    echo "✅ fd+bat集成函数正常"
}
```

## 🔍 模块04：fzf核心配置测试

### 功能描述
配置fzf的核心选项、主题和tmux集成。

### 测试用例

#### TC-04-001：fzf环境变量测试
```bash
test_fzf_environment() {
    source templates/04-fzf-core.zsh

    # 检查FZF_DEFAULT_OPTS设置
    [[ -n "$FZF_DEFAULT_OPTS" ]] || return 1
    echo "$FZF_DEFAULT_OPTS" | grep -q "height=70%" || return 1
    echo "$FZF_DEFAULT_OPTS" | grep -q "layout=reverse" || return 1

    echo "✅ fzf环境变量配置正确"
}
```

#### TC-04-002：fzf搜索命令配置测试
```bash
test_fzf_search_commands() {
    source templates/04-fzf-core.zsh

    # 检查搜索命令设置
    if command -v fdfind >/dev/null 2>&1 || command -v fd >/dev/null 2>&1; then
        [[ -n "$FZF_DEFAULT_COMMAND" ]] || return 1
        [[ -n "$FZF_CTRL_T_COMMAND" ]] || return 1
        [[ -n "$FZF_ALT_C_COMMAND" ]] || return 1
        echo "✅ fzf搜索命令配置正确"
    else
        echo "⚠️  fd工具未安装，跳过搜索命令测试"
        return 2
    fi
}
```

#### TC-04-003：tmux集成测试
```bash
test_fzf_tmux_integration() {
    if [[ -n "$TMUX" ]]; then
        source templates/04-fzf-core.zsh

        # 检查tmux相关配置
        [[ -n "$FZF_TMUX_OPTS" ]] || return 1

        # 检查tmux popup函数
        if command -v tmux >/dev/null 2>&1; then
            declare -f fzf-tmux-center >/dev/null 2>&1 || return 1
            echo "✅ fzf tmux集成配置正确"
        fi
    else
        echo "⚠️  非tmux环境，跳过tmux集成测试"
        return 2
    fi
}
```

## 📋 模块05：fzf基础功能测试

### 功能描述
提供fzf的基础文件操作功能，如搜索、编辑、目录跳转等。

### 测试用例

#### TC-05-001：fzf基础函数定义测试
```bash
test_fzf_basic_functions() {
    source templates/05-fzf-basic.zsh

    local expected_functions=("fe" "fp" "fif" "fcd" "fh" "fkill")

    for func_name in "${expected_functions[@]}"; do
        declare -f "$func_name" >/dev/null 2>&1 || {
            echo "❌ 函数 $func_name 未定义"
            return 1
        }
    done

    echo "✅ fzf基础函数定义完整"
}
```

#### TC-05-002：fzf基础别名测试
```bash
test_fzf_basic_aliases() {
    source templates/05-fzf-basic.zsh

    local expected_aliases=("ff" "fed" "fdir" "fhist")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ 别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ fzf基础别名设置完整"
}
```

#### TC-05-003：函数帮助信息测试
```bash
test_function_help() {
    source templates/05-fzf-basic.zsh

    # 测试函数帮助信息
    fif 2>&1 | grep -q "用法:" || return 1

    echo "✅ 函数帮助信息正常"
}
```

## 🚀 模块06：fzf高级功能测试

### 功能描述
提供fzf的高级功能，如多模式搜索和动态重载。

### 测试用例

#### TC-06-001：高级函数定义测试
```bash
test_fzf_advanced_functions() {
    source templates/06-fzf-advanced.zsh

    local expected_functions=("fzf-multi-search" "fzf-reload")

    for func_name in "${expected_functions[@]}"; do
        declare -f "$func_name" >/dev/null 2>&1 || {
            echo "❌ 高级函数 $func_name 未定义"
            return 1
        }
    done

    echo "✅ fzf高级函数定义完整"
}
```

#### TC-06-002：高级别名测试
```bash
test_fzf_advanced_aliases() {
    source templates/06-fzf-advanced.zsh

    local expected_aliases=("fms" "frl")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ 高级别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ fzf高级别名设置完整"
}

## 🔎 模块07：ripgrep配置测试

### 功能描述
配置ripgrep工具的基础设置和别名。

### 测试用例

#### TC-07-001：ripgrep配置文件测试
```bash
test_ripgrep_config_file() {
    source templates/07-ripgrep-config.zsh

    # 检查配置文件是否创建
    [[ -f "$HOME/.ripgreprc" ]] || return 1

    # 检查配置内容
    grep -q "smart-case" "$HOME/.ripgreprc" || return 1
    grep -q "hidden" "$HOME/.ripgreprc" || return 1

    echo "✅ ripgrep配置文件创建正确"
}
```

#### TC-07-002：ripgrep基础别名测试
```bash
test_ripgrep_basic_aliases() {
    source templates/07-ripgrep-config.zsh

    local expected_aliases=("rgi" "rgf" "rgl" "rgL" "rgv" "rgw" "rgA" "rgB" "rgC")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ ripgrep别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ ripgrep基础别名设置完整"
}
```

#### TC-07-003：ripgrep文件类型函数测试
```bash
test_ripgrep_filetype_functions() {
    source templates/07-ripgrep-config.zsh

    local expected_functions=("rg-py" "rg-js" "rg-css" "rg-html" "rg-md" "rg-json" "rg-yaml" "rg-sh" "rg-stats")

    for func_name in "${expected_functions[@]}"; do
        declare -f "$func_name" >/dev/null 2>&1 || {
            echo "❌ ripgrep函数 $func_name 未定义"
            return 1
        }
    done

    echo "✅ ripgrep文件类型函数定义完整"
}
```

## 🔍📋 模块08：ripgrep+fzf集成测试

### 功能描述
提供ripgrep与fzf的高级集成功能。

### 测试用例

#### TC-08-001：ripgrep+fzf集成函数测试
```bash
test_ripgrep_fzf_functions() {
    source templates/08-ripgrep-fzf.zsh

    local expected_functions=("rgf" "rge" "rgc" "rgm" "rgs")

    for func_name in "${expected_functions[@]}"; do
        declare -f "$func_name" >/dev/null 2>&1 || {
            echo "❌ ripgrep+fzf函数 $func_name 未定义"
            return 1
        }
    done

    echo "✅ ripgrep+fzf集成函数定义完整"
}
```

#### TC-08-002：ripgrep+fzf别名测试
```bash
test_ripgrep_fzf_aliases() {
    source templates/08-ripgrep-fzf.zsh

    local expected_aliases=("rgfzf" "rged" "rgctx" "rgmulti" "rgreplace")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ ripgrep+fzf别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ ripgrep+fzf别名设置完整"
}
```

## 🌿 模块09：git集成测试

### 功能描述
提供git与fzf、bat的集成功能。

### 测试用例

#### TC-09-001：git集成函数测试
```bash
test_git_integration_functions() {
    source templates/09-git-integration.zsh

    local expected_functions=("gco" "glog" "gst" "gstash" "gremote" "gfh" "gblame" "gdiff")

    for func_name in "${expected_functions[@]}"; do
        declare -f "$func_name" >/dev/null 2>&1 || {
            echo "❌ git集成函数 $func_name 未定义"
            return 1
        }
    done

    echo "✅ git集成函数定义完整"
}
```

#### TC-09-002：git集成别名测试
```bash
test_git_integration_aliases() {
    source templates/09-git-integration.zsh

    local expected_aliases=("gbr" "glg" "gstat" "gsh" "grm" "gfhist" "gbl" "gdf")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ git集成别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ git集成别名设置完整"
}
```

## 📖 模块11：man页面集成测试

### 功能描述
提供man页面与bat、fzf的集成功能。

### 测试用例

#### TC-11-001：MANPAGER配置测试
```bash
test_manpager_configuration() {
    source templates/11-man-integration.zsh

    # 检查MANPAGER环境变量设置
    [[ -n "$MANPAGER" ]] || return 1
    echo "$MANPAGER" | grep -q "bat\|col" || return 1

    echo "✅ MANPAGER配置正确"
}
```

#### TC-11-002：man集成函数测试
```bash
test_man_integration_functions() {
    source templates/11-man-integration.zsh

    local expected_functions=("fman" "batman" "man-search")

    for func_name in "${expected_functions[@]}"; do
        declare -f "$func_name" >/dev/null 2>&1 || {
            echo "❌ man集成函数 $func_name 未定义"
            return 1
        }
    done

    echo "✅ man集成函数定义完整"
}
```

## 📦 模块12：APT集成测试

### 功能描述
提供APT包管理与fzf的集成功能。

### 测试用例

#### TC-12-001：APT集成别名测试
```bash
test_apt_integration_aliases() {
    source templates/12-apt-integration.zsh

    # 检查主要别名
    alias af >/dev/null 2>&1 || return 1
    alias as >/dev/null 2>&1 || return 1
    alias ai >/dev/null 2>&1 || return 1
    alias ainfo >/dev/null 2>&1 || return 1

    echo "✅ APT集成别名设置完整"
}
```

#### TC-12-002：APT集成函数测试
```bash
test_apt_integration_functions() {
    source templates/12-apt-integration.zsh

    local expected_functions=("apt-search" "apt-installed" "apt-info")

    for func_name in "${expected_functions[@]}"; do
        declare -f "$func_name" >/dev/null 2>&1 || {
            echo "❌ APT集成函数 $func_name 未定义"
            return 1
        }
    done

    echo "✅ APT集成函数定义完整"
}
```

## 🛠️ 模块13：工具函数测试

### 功能描述
提供通用的工具函数，如综合搜索、文件分析等。

### 测试用例

#### TC-13-001：工具函数定义测试
```bash
test_utility_functions() {
    source templates/13-utility-functions.zsh

    local expected_functions=("search-all" "quick-view" "file-sizes" "find-duplicates" "clean-empty")

    for func_name in "${expected_functions[@]}"; do
        declare -f "$func_name" >/dev/null 2>&1 || {
            echo "❌ 工具函数 $func_name 未定义"
            return 1
        }
    done

    echo "✅ 工具函数定义完整"
}
```

#### TC-13-002：工具函数别名测试
```bash
test_utility_aliases() {
    source templates/13-utility-functions.zsh

    local expected_aliases=("sa" "qv" "fs" "fd-dup" "clean")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ 工具别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ 工具函数别名设置完整"
}
```

## 📋 模块99：别名汇总测试

### 功能描述
提供show-tools功能和最终的别名汇总。

### 测试用例

#### TC-99-001：show-tools函数测试
```bash
test_show_tools_function() {
    source templates/99-aliases-summary.zsh

    # 检查show-tools函数定义
    declare -f show-tools >/dev/null 2>&1 || return 1

    # 测试函数输出
    show-tools | grep -q "Shell Tools 功能概览" || return 1
    show-tools | grep -q "核心工具状态" || return 1

    echo "✅ show-tools函数正常"
}
```

#### TC-99-002：帮助别名测试
```bash
test_help_aliases() {
    source templates/99-aliases-summary.zsh

    local expected_aliases=("tools" "help-tools" "st")

    for alias_name in "${expected_aliases[@]}"; do
        alias "$alias_name" >/dev/null 2>&1 || {
            echo "❌ 帮助别名 $alias_name 未设置"
            return 1
        }
    done

    echo "✅ 帮助别名设置完整"
}
```
```
