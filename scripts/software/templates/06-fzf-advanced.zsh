# fzf高级功能（动态重载、模式切换等）

if command -v fzf >/dev/null 2>&1; then
    # 高级文件搜索 - 支持多种搜索模式切换
    fzf-multi-search() {
        local initial_query=""
        local search_mode="files"
        
        while true; do
            case "$search_mode" in
                "files")
                    if command -v fd >/dev/null 2>&1; then
                        result=$(fd --type f --hidden --follow --exclude .git | \
                            fzf --query="$initial_query" \
                                --header="文件搜索模式 | F1:内容搜索 F2:目录搜索 F3:Git文件" \
                                --bind="f1:execute-silent(echo content)+abort" \
                                --bind="f2:execute-silent(echo dirs)+abort" \
                                --bind="f3:execute-silent(echo git)+abort" \
                                --preview="bat --color=always --style=numbers --line-range=:500 {}")
                    else
                        result=$(find . -type f -not -path '*/\.git/*' | \
                            fzf --query="$initial_query" \
                                --header="文件搜索模式 | F1:内容搜索 F2:目录搜索" \
                                --bind="f1:execute-silent(echo content)+abort" \
                                --bind="f2:execute-silent(echo dirs)+abort" \
                                --preview="cat {}")
                    fi
                    ;;
                "content")
                    if command -v rg >/dev/null 2>&1; then
                        result=$(rg --line-number --no-heading --color=always --smart-case "$initial_query" | \
                            fzf --ansi \
                                --header="内容搜索模式 | F1:文件搜索 F2:目录搜索" \
                                --bind="f1:execute-silent(echo files)+abort" \
                                --bind="f2:execute-silent(echo dirs)+abort" \
                                --delimiter : \
                                --preview 'bat --color=always --line-range {2}: {1}')
                    else
                        result=$(grep -r -n --color=always "$initial_query" . | \
                            fzf --ansi \
                                --header="内容搜索模式 | F1:文件搜索 F2:目录搜索" \
                                --bind="f1:execute-silent(echo files)+abort" \
                                --bind="f2:execute-silent(echo dirs)+abort")
                    fi
                    ;;
                "dirs")
                    if command -v fd >/dev/null 2>&1; then
                        result=$(fd --type d --hidden --follow --exclude .git | \
                            fzf --query="$initial_query" \
                                --header="目录搜索模式 | F1:文件搜索 F2:内容搜索" \
                                --bind="f1:execute-silent(echo files)+abort" \
                                --bind="f2:execute-silent(echo content)+abort")
                    else
                        result=$(find . -type d -not -path '*/\.git/*' | \
                            fzf --query="$initial_query" \
                                --header="目录搜索模式 | F1:文件搜索 F2:内容搜索" \
                                --bind="f1:execute-silent(echo files)+abort" \
                                --bind="f2:execute-silent(echo content)+abort")
                    fi
                    ;;
                "git")
                    if command -v git >/dev/null 2>&1; then
                        result=$(git ls-files | \
                            fzf --query="$initial_query" \
                                --header="Git文件搜索模式 | F1:文件搜索 F2:内容搜索" \
                                --bind="f1:execute-silent(echo files)+abort" \
                                --bind="f2:execute-silent(echo content)+abort" \
                                --preview="bat --color=always --style=numbers --line-range=:500 {}")
                    fi
                    ;;
            esac
            
            # 检查结果并决定下一步
            if [[ "$result" == "files" ]]; then
                search_mode="files"
                continue
            elif [[ "$result" == "content" ]]; then
                search_mode="content"
                continue
            elif [[ "$result" == "dirs" ]]; then
                search_mode="dirs"
                continue
            elif [[ "$result" == "git" ]]; then
                search_mode="git"
                continue
            elif [[ -n "$result" ]]; then
                echo "$result"
                break
            else
                break
            fi
        done
    }

    # 动态重载搜索
    fzf-reload() {
        local reload_command="find . -type f -not -path '*/\.git/*'"
        if command -v fd >/dev/null 2>&1; then
            reload_command="fd --type f --hidden --follow --exclude .git"
        fi
        
        $reload_command | fzf --bind "ctrl-r:reload($reload_command)" \
                             --header "CTRL-R: 重新加载文件列表" \
                             --preview "bat --color=always --style=numbers --line-range=:500 {}"
    }

    # 别名
    alias fms='fzf-multi-search'    # 多模式搜索
    alias frl='fzf-reload'          # 动态重载搜索
fi
