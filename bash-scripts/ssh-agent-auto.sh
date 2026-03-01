#!/bin/bash

# 命令行参数解析
ARG_IP=""
ARG_PORT=""
ARG_USER=""
ARG_KEY=""
ARG_QUICK=false
ARG_QUIET=false
ARG_HELP=false

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ip)
                ARG_IP="$2"
                shift 2
                ;;
            --port)
                ARG_PORT="$2"
                shift 2
                ;;
            --user)
                ARG_USER="$2"
                shift 2
                ;;
            --key-file)
                ARG_KEY="$2"
                shift 2
                ;;
            --quick)
                ARG_QUICK=true
                shift
                ;;
            --quiet)
                ARG_QUIET=true
                QUIET_MODE=true
                shift
                ;;
            --help|-h)
                ARG_HELP=true
                shift
                ;;
            *)
                echo "未知参数: $1"
                echo "使用 --help 查看帮助"
                exit 1
                ;;
        esac
    done
}

# 显示帮助信息
show_help() {
    cat << EOF
🚀 ssh-agent-auto.sh - SSH 密钥自动配置脚本

用法:
    bash ssh-agent-auto.sh [选项]

选项:
    --ip <地址>       指定服务器 IP 地址
    --port <端口>     指定 SSH 端口 (默认: 22)
    --user <用户名>   指定用户名 (默认: root)
    --key-file <路径> 指定密钥文件路径
    --quick           使用上次保存的配置快速部署
    --quiet           静默模式，减少输出
    --help, -h        显示此帮助信息

示例:
    # 交互式运行
    bash ssh-agent-auto.sh

    # 使用命令行参数部署
    bash ssh-agent-auto.sh --ip 192.168.1.100 --port 2222 --user admin

    # 快速部署（使用上次配置）
    bash ssh-agent-auto.sh --quick

    # 静默模式
    bash ssh-agent-auto.sh --ip 192.168.1.100 --quiet

功能:
    1. 生成 SSH 密钥对
    2. 将公钥部署到远程服务器
    3. 自动添加到 ~/.ssh/config
    4. 快速部署模式（复用上次的配置）

EOF
}

# 使用命令行参数执行部署
run_with_args() {
    local ip="${ARG_IP:-}"
    local port="${ARG_PORT:-22}"
    local user="${ARG_USER:-root}"
    local key="${ARG_KEY:-id_rsa}"

    # 如果缺少必要参数，进入交互模式
    if [ -z "$ip" ]; then
        echo -e "\e[1;31m错误: 缺少 --ip 参数\e[0m"
        echo -e "\e[1;36m将启动交互模式...\e[0m"
        echo ""
        return 1
    fi

    add_sshkey_with_config "$ip" "$port" "$user" "$key"
    return $?
}

# 主程序入口
parse_arguments "$@"

# 显示帮助
if [ "$ARG_HELP" = true ]; then
    show_help
    exit 0
fi

# 检查是否需要静默模式
if [ "$ARG_QUIET" = true ]; then
    QUIET_MODE=true
fi

# 如果不是静默模式，显示欢迎信息
if [ "$QUIET_MODE" = false ]; then
    clear
    echo ""
    echo -e "\e[1;36m🚀  欢迎使用 SSH-Agent 自动配置脚本\e[0m"
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo -e "\e[1;37m生成密钥 · 部署公钥 · 管理配置\e[0m"
    echo ""
fi

# 如果指定了 --quick，执行快速部署
if [ "$ARG_QUICK" = true ]; then
    if load_last_deploy; then
        add_sshkey_with_config "$LAST_DEPLOY_IP" "$LAST_DEPLOY_PORT" "$LAST_DEPLOY_USER" "$LAST_DEPLOY_KEY"
        exit $?
    else
        echo -e "\e[1;31m错误: 没有找到上次部署的配置\e[0m"
        exit 1
    fi
fi

# 如果指定了其他参数，尝试使用参数部署
if [ -n "$ARG_IP" ] || [ -n "$ARG_PORT" ] || [ -n "$ARG_USER" ] || [ -n "$ARG_KEY" ]; then
    if run_with_args; then
        exit 0
    fi
    # 如果参数不完整，继续进入交互模式
fi
generate_sshkey() {
    echo "请输入rsa密钥的名称："
    echo "默认键入enter为id_rsa"
    echo "如果不是，请输入rsa密钥的名称："
    read keyName
    keyName=${keyName:-id_rsa}  # 优化默认值赋值方式

    # 使用环境变量和命令获取当前的用户和主机名作为注释的默认值
    default_comment="${USER}@$(hostname)"
    echo -e "\e[1;36m请输入密钥的注释（例如你的邮箱），默认为${default_comment}：\e[0m"
    read comment
    comment=${comment:-$default_comment}

    # 直接使用-C参数指定注释，无需判断comment是否为空
    ssh-keygen -t rsa -b 4096 -C "$comment" -f $HOME/.ssh/$keyName
    echo -e "\033[32m密钥已生成，文件保存在 $HOME/.ssh/$keyName\033[0m"
}
# 添加所选择的公钥到服务器
# 注意：此脚本与 Oh My Zsh ssh-agent 插件配合使用
# 密钥将由 ssh-agent 插件自动管理，无需手动 ssh-add
# 全局变量，用于存储最后一次部署的信息
LAST_DEPLOY_IP=""
LAST_DEPLOY_PORT=""
LAST_DEPLOY_USER=""
LAST_DEPLOY_KEY=""
LAST_DEPLOY_TIME=""

# 保存最后一次部署信息到文件
save_last_deploy() {
    local last_deploy_file="$HOME/.ssh/.last_deploy"
    {
        echo "IP=$LAST_DEPLOY_IP"
        echo "PORT=$LAST_DEPLOY_PORT"
        echo "USER=$LAST_DEPLOY_USER"
        echo "KEY=$LAST_DEPLOY_KEY"
        echo "TIME=$(date +%s)"
    } > "$last_deploy_file"
    chmod 600 "$last_deploy_file"
}

# 从文件加载最后一次部署信息
load_last_deploy() {
    local last_deploy_file="$HOME/.ssh/.last_deploy"
    if [ -f "$last_deploy_file" ]; then
        source "$last_deploy_file"
        LAST_DEPLOY_IP="${IP:-}"
        LAST_DEPLOY_PORT="${PORT:-}"
        LAST_DEPLOY_USER="${USER:-}"
        LAST_DEPLOY_KEY="${KEY:-}"
        LAST_DEPLOY_TIME="${TIME:-}"
        return 0
    fi
    return 1
}

# 检查是否存在上次部署信息
has_last_deploy() {
    [ -f "$HOME/.ssh/.last_deploy" ]
}

# 进度指示器变量
CURRENT_STEP=0
TOTAL_STEPS=7
QUIET_MODE=false

# 显示步骤
show_step() {
    if [ "$QUIET_MODE" = false ]; then
        local step_desc="$1"
        echo ""
        echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo -e "\e[1;33m  步骤 $CURRENT_STEP/$TOTAL_STEPS: $step_desc\e[0m"
        echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    fi
}

# 显示步骤状态
show_step_status() {
    if [ "$QUIET_MODE" = false ]; then
        local status="$1"
        if [ "$status" = "success" ]; then
            echo -e "\e[1;32m  ✓ 完成\e[0m"
        elif [ "$status" = "error" ]; then
            echo -e "\e[1;31m  ✗ 失败\e[0m"
        fi
    fi
}

# 增加步骤计数
next_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

# 检查 SSH config 中是否已存在指定的 Host 别名
check_duplicate_host() {
    local host_alias="$1"
    local config_file="$HOME/.ssh/config"

    if [ -f "$config_file" ] && grep -q "^Host $host_alias$" "$config_file" 2>/dev/null; then
        return 0  # 找到重复项
    fi
    return 1  # 无重复
}

# 备份 SSH config 文件
backup_ssh_config() {
    local config_file="$HOME/.ssh/config"
    if [ -f "$config_file" ]; then
        local backup_file="$HOME/.ssh/config.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file"
        echo -e "\e[1;32m✓ 已备份现有配置到: $backup_file\e[0m"
    fi
}

# 添加配置到 ~/.ssh/config
add_to_config() {
    local use_last=false

    # 检查是否使用最后一次部署的信息
    if [ "$1" = "--use-last" ]; then
        use_last=true
    fi

    echo ""
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo -e "\e[1;33m  添加 SSH 配置到 ~/.ssh/config\e[0m"
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo ""

    # 确保 ~/.ssh 目录存在并设置正确权限
    if [ ! -d "$HOME/.ssh" ]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        echo -e "\e[1;32m✓ 创建 ~/.ssh 目录\e[0m"
    fi

    local host_alias hostname port user identity_file

    if [ "$use_last" = true ] && [ -n "$LAST_DEPLOY_IP" ]; then
        # 使用最后一次部署的信息
        echo -e "\e[1;36m使用上一次部署的信息：\e[0m"
        echo -e "  IP: $LAST_DEPLOY_IP"
        echo -e "  端口: $LAST_DEPLOY_PORT"
        echo -e "  用户名: $LAST_DEPLOY_USER"
        echo -e "  密钥: $LAST_DEPLOY_KEY"
        echo ""

        hostname="$LAST_DEPLOY_IP"
        port="$LAST_DEPLOY_PORT"
        user="$LAST_DEPLOY_USER"
        identity_file="$LAST_DEPLOY_KEY"

        echo -e "\e[1;36m请输入 Host 别名（用于 ssh <别名> 快速连接，默认为 $hostname）：\e[0m"
        read host_alias
        host_alias=${host_alias:-$hostname}
    else
        # 手动输入模式
        echo -e "\e[1;36m请输入 Host 别名（用于 ssh <别名> 快速连接）：\e[0m"
        read host_alias
        while [ -z "$host_alias" ]; do
            echo -e "\e[1;31mHost 别名不能为空，请重新输入：\e[0m"
            read host_alias
        done

        if [ "$use_last" = true ] && [ -z "$LAST_DEPLOY_IP" ]; then
            echo -e "\e[1;33m⚠ 没有找到上一次部署的信息，将使用手动输入模式\e[0m"
        fi

        echo -e "\e[1;36m请输入服务器 IP 地址：\e[0m"
        read hostname
        while [ -z "$hostname" ]; do
            echo -e "\e[1;31mIP 地址不能为空，请重新输入：\e[0m"
            read hostname
        done

        echo -e "\e[1;36m请输入服务器端口（默认为 22）：\e[0m"
        read port
        port=${port:-22}

        # 验证端口号是否为数字
        while ! [[ "$port" =~ ^[0-9]+$ ]]; do
            echo -e "\e[1;31m端口号必须是数字，请重新输入：\e[0m"
            read port
            port=${port:-22}
        done

        echo -e "\e[1;36m请输入用户名（默认为 root）：\e[0m"
        read user
        user=${user:-root}

        # 列出可用的私钥文件
        echo ""
        echo "以下是可用的私钥文件："
        local priv_keys=($HOME/.ssh/id_*)
        local valid_keys=()
        local idx=1

        for key in "${priv_keys[@]}"; do
            # 排除 .pub 文件
            if [[ -f "$key" && "$key" != *.pub ]]; then
                valid_keys+=("$key")
                echo -e "\e[1;32m$idx) ${key##*/}\e[0m"
                ((idx++))
            fi
        done

        if [ ${#valid_keys[@]} -eq 0 ]; then
            echo -e "\e[1;33m⚠ 未找到私钥文件，将使用默认路径 ~/.ssh/id_rsa\e[0m"
            identity_file="id_rsa"
        else
            echo ""
            echo -e "\e[1;36m请选择私钥文件（默认为 1）：\e[0m"
            local key_index
            read key_index
            key_index=${key_index:-1}

            if [[ "$key_index" =~ ^[0-9]+$ ]] && [ "$key_index" -ge 1 ] && [ "$key_index" -le ${#valid_keys[@]} ]; then
                identity_file="${valid_keys[$((key_index-1))]##*/}"
            else
                echo -e "\e[1;33m⚠ 无效的选择，将使用默认私钥\e[0m"
                identity_file="id_rsa"
            fi
        fi
    fi

    # 检查重复项
    if check_duplicate_host "$host_alias"; then
        echo ""
        echo -e "\e[1;33m⚠ 检测到已存在的 Host 别名 '$host_alias'\e[0m"
        echo -e "\e[1;36m请选择操作：\e[0m"
        echo -e "  \e[1;32m1)\e[0m 覆盖现有配置"
        echo -e "  \e[1;32m2)\e[0m 使用新的别名"
        echo -e "  \e[1;31m3)\e[0m 取消操作"
        read -p "请输入选项 (1-3，默认为 1): " choice
        choice=${choice:-1}

        case "$choice" in
            1)
                # 删除现有配置
                local config_file="$HOME/.ssh/config"
                # 使用 sed 删除从 "Host $host_alias" 到下一个 "Host " 或文件结束之间的内容
                sed -i "/^Host $host_alias$/,/^Host /{ /^Host $host_alias$/d; /^Host /!d; }" "$config_file"
                echo -e "\e[1;32m✓ 已删除现有配置\e[0m"
                ;;
            2)
                echo -e "\e[1;36m请输入新的 Host 别名：\e[0m"
                read host_alias
                while [ -z "$host_alias" ] || check_duplicate_host "$host_alias"; do
                    if [ -z "$host_alias" ]; then
                        echo -e "\e[1;31mHost 别名不能为空，请重新输入：\e[0m"
                    else
                        echo -e "\e[1;31m该别名已存在，请输入其他别名：\e[0m"
                    fi
                    read host_alias
                done
                ;;
            3|*)
                echo -e "\e[1;33m已取消操作\e[0m"
                return 1
                ;;
        esac
    fi

    # 备份现有配置
    backup_ssh_config

    # 写入新配置
    local config_file="$HOME/.ssh/config"
    {
        echo ""
        echo "# Added by ssh-agent-auto.sh on $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Host $host_alias"
        echo "    HostName $hostname"
        echo "    Port $port"
        echo "    User $user"
        echo "    IdentityFile ~/.ssh/$identity_file"
        echo "    AddKeysToAgent yes"
    } >> "$config_file"

    # 设置正确的权限
    chmod 600 "$config_file"

    echo ""
    echo -e "\e[1;32m✓ SSH 配置已添加到 ~/.ssh/config\e[0m"
    echo ""
    echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo -e "\e[1;33m  配置详情：\e[0m"
    echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo ""
    echo -e "\e[1;37mHost $host_alias\e[0m"
    echo -e "\e[1;37m    HostName $hostname\e[0m"
    echo -e "\e[1;37m    Port $port\e[0m"
    echo -e "\e[1;37m    User $user\e[0m"
    echo -e "\e[1;37m    IdentityFile ~/.ssh/$identity_file\e[0m"
    echo -e "\e[1;37m    AddKeysToAgent yes\e[0m"
    echo ""
    echo -e "\e[1;32m现在可以使用以下命令快速连接：\e[0m"
    echo -e "\e[1;36m  ssh $host_alias\e[0m"
    echo ""
}

add_sshkey() {
    # 初始化步骤计数
    CURRENT_STEP=0

    sudo apt install sshpass -y &> /dev/null

    # 检查 Oh My Zsh ssh-agent 插件是否配置
    if [ "$QUIET_MODE" = false ]; then
        if [ -f "$HOME/.zshrc" ] && grep -q "ssh-agent" "$HOME/.zshrc" 2>/dev/null; then
            echo -e "\e[1;32m✓ 检测到 Oh My Zsh ssh-agent 插件已配置\e[0m"
            echo -e "\e[1;36m  密钥将由插件自动管理，无需手动 ssh-add\e[0m"
        else
            echo -e "\e[1;33m⚠ 提示：建议安装 Oh My Zsh 并启用 ssh-agent 插件\e[0m"
            echo -e "\e[1;36m  在 ~/.zshrc 中添加: plugins=(... ssh-agent)\e[0m"
        fi
        echo ""
    fi

    # 步骤 1/7: 连接服务器
    next_step
    show_step "连接服务器"

    prompt="$(whoami)@$(hostname) > "
    echo -e "\e[1;36m请输入服务器ip地址：\e[0m"
    read ip
    if [ "$QUIET_MODE" = false ]; then
        echo "输入的IP为: $ip"
    fi

    echo -e "\e[1;36m请输入服务器端口：(默认为22)\e[0m"
    if [ "$QUIET_MODE" = false ]; then
        echo -e "\e[1;37m  常用端口: 22, 2222, 8022\e[0m"
    fi
    read port
    port=${port:-22}
    if [ "$QUIET_MODE" = false ]; then
        echo -e "\e[1;36m输入的端口为: $port\e[0m"
    fi

    echo -e "\e[1;36m请输入服务器用户名：(默认为root)\e[0m"
    read username
    username=${username:-root}
    if [ "$QUIET_MODE" = false ]; then
        echo -e "\e[1;36m输入的用户名为: $username\e[0m"
    fi

    # 步骤 2/7: 验证密码
    next_step
    show_step "验证密码"
    local max_attempts=3
    local attempt=0
    local password_valid=false

    while [ $attempt -lt $max_attempts ] && [ "$password_valid" = false ]; do
        echo -e "\e[1;36m请输入服务器密码：\e[0m"
        read -s password
        echo -e "\e[1;36m密码已输入，正在验证...\e[0m"

        # 先检查服务器是否可达
        if ! timeout 5 bash -c "exec 3<>/dev/tcp/$ip/$port" 2>/dev/null; then
            echo ""
            echo -e "\e[1;31m✗ 无法连接到服务器 $ip:$port\e[0m"
            echo -e "\e[1;33m  请检查：\e[0m"
            echo -e "  1. IP地址是否正确"
            echo -e "  2. 端口号是否正确"
            echo -e "  3. 服务器是否开启SSH服务"
            echo -e "  4. 防火墙是否允许连接"
            echo ""
            echo -e "\e[1;36m请选择：\e[0m"
            echo -e "  \e[1;32m1)\e[0m 重新输入连接信息"
            echo -e "  \e[1;31m2)\e[0m 返回主菜单"
            read retry_choice
            if [ "$retry_choice" = "1" ]; then
                return 1  # 返回让调用者重新执行
            else
                return 1
            fi
        fi

        # 使用 sshpass 测试密码是否正确
        if sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$port" "$username@$ip" "echo 'PASSWORD_OK'" 2>/dev/null | grep -q "PASSWORD_OK"; then
            password_valid=true
            echo -e "\e[1;32m✓ 密码验证成功\e[0m"
        else
            attempt=$((attempt + 1))
            if [ $attempt -lt $max_attempts ]; then
                echo ""
                echo -e "\e[1;31m✗ 密码错误或连接失败，还剩 $((max_attempts - attempt)) 次尝试\e[0m"
                echo ""
            else
                echo ""
                echo -e "\e[1;31m✗ 密码验证失败次数过多\e[0m"
                echo ""
                echo -e "\e[1;36m请选择：\e[0m"
                echo -e "  \e[1;32m1)\e[0m 重新输入连接信息"
                echo -e "  \e[1;31m2)\e[0m 返回主菜单"
                read retry_choice
                if [ "$retry_choice" = "1" ]; then
                    return 1  # 返回让调用者可以重新执行
                else
                    return 1
                fi
            fi
        fi
    done

    show_step_status "success"

    # 步骤 3/7: 添加主机指纹
    next_step
    show_step "添加主机指纹"

    # 自动添加远程主机的SSH公钥到known_hosts以避免手动确认
    ssh-keyscan -H -p $port $ip >> ~/.ssh/known_hosts 2>/dev/null
    if [ "$QUIET_MODE" = false ]; then
        echo -e "\033[32m已添加远程主机的SSH公钥到known_hosts。\033[0m"
    fi
    show_step_status "success"

    # 步骤 4/7: 选择公钥
    next_step
    show_step "选择公钥"

        echo "以下是可用的公钥文件："
        pub_keys=($HOME/.ssh/*.pub) # 将公钥文件名存储到数组
        #彩色字体显示公钥文件
        Color='\033[32m'  # 绿色
        for i in "${!pub_keys[@]}"; do
            echo -e "$Color$((i + 1))) ${pub_keys[$i]##*/}\033[0m" # 显示序号和文件名
    done

        echo "请输入公钥文件对应的序号（默认为1）："
        read key_index
        key_index=${key_index:-1}  # 默认选择第一个公钥文件

        # 验证输入的序号是否有效
        if [[ $key_index -le 0 || $key_index -gt ${#pub_keys[@]} ]]; then
            echo "输入的序号无效，将使用默认的公钥文件。"
            keyName="${pub_keys[0]##*/}" # 如果输入无效，默认使用数组中的第一个公钥文件
    else
            keyName="${pub_keys[$key_index - 1]##*/}" # 从数组中获取选择的公钥文件名
    fi

    echo -e "\033[32m选择的公钥文件为: $keyName\033[0m"
    show_step_status "success"

    # 步骤 5/7: 部署公钥
    next_step
    show_step "部署公钥"

    if ! sshpass -p "$password" ssh-copy-id -i "$HOME/.ssh/$keyName" -p "$port" "$username@$ip"; then
        echo "sshpass的命令为: sshpass -p $password ssh-copy-id -i $HOME/.ssh/$keyName -p $port $username@$ip "
        echo -e "\033[31m公钥添加失败，请检查以下可能的原因：\033[0m"
        echo "1. 服务器IP地址或端口号输入错误。"
        echo "2. 服务器用户名或密码错误。"
        echo "3. 指定的公钥文件不存在。"
        echo "4. ssh-copy-id命令未正确执行，可能是因为sshpass未安装，或远程服务器不允许密码认证。"
        echo "请根据上述提示检查您的输入或配置，然后重试。"
        return 1  # 返回一个非零值表示失败

    else
        show_step_status "success"

        # 步骤 6/7: 设置权限
        next_step
        show_step "设置权限"

        # 设置密钥权限（让 ssh-agent 插件可以正确读取）
        chmod 600 $HOME/.ssh/${keyName%.pub} 2>/dev/null || true
        chmod 644 $HOME/.ssh/$keyName 2>/dev/null || true
        show_step_status "success"

        # 保存部署信息供后续使用
        LAST_DEPLOY_IP="$ip"
        LAST_DEPLOY_PORT="$port"
        LAST_DEPLOY_USER="$username"
        LAST_DEPLOY_KEY="${keyName%.pub}"

        # 保存到文件以供快速部署使用
        save_last_deploy

        # 步骤 7/7: 完成配置
        next_step
        show_step "完成配置"

        echo -e "\033[32m公钥 $HOME/.ssh/$keyName 部署成功\033[0m"
        show_step_status "success"
        echo ""
        echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo -e "\e[1;33m  后续步骤：\e[0m"
        echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo ""
        echo -e "\e[1;32m1. 确保 Oh My Zsh ssh-agent 插件已启用：\e[0m"
        echo -e "   grep 'plugins=.*ssh-agent' ~/.zshrc"
        echo ""
        echo -e "\e[1;32m2. 重新加载 ZSH 配置：\e[0m"
        echo -e "   source ~/.zshrc"
        echo ""
        echo -e "\e[1;32m3. 首次连接时输入密码，之后自动使用 ssh-agent：\e[0m"
        echo -e "   ssh $username@$ip -p $port"
        echo ""
        echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo -e "\e[1;33m  推荐配置 ~/.ssh/config：\e[0m"
        echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        echo ""
        echo -e "\e[1;37mHost $ip\e[0m"
        echo -e "\e[1;37m    HostName $ip\e[0m"
        echo -e "\e[1;37m    Port $port\e[0m"
        echo -e "\e[1;37m    User $username\e[0m"
        echo -e "\e[1;37m    IdentityFile ~/.ssh/${keyName%.pub}\e[0m"
        echo -e "\e[1;37m    AddKeysToAgent yes\e[0m"
        echo ""

        # 询问是否添加到 config
        echo -e "\e[1;36m是否将此配置添加到 ~/.ssh/config？(y/n，默认为 y)：\e[0m"
        read add_config
        add_config=${add_config:-y}

        if [[ "$add_config" =~ ^[Yy]$ ]]; then
            add_to_config --use-last
        fi
    fi
}

# 快速部署菜单
quick_deploy_menu() {
    if ! load_last_deploy; then
        echo -e "\e[1;31m✗ 没有找到上次的部署信息\e[0m"
        echo -e "\e[1;36m请先使用 '添加公钥到服务器' 功能进行首次部署。\e[0m"
        return 1
    fi

    # 检查配置是否超过24小时
    local current_time=$(date +%s)
    local time_diff=$((current_time - LAST_DEPLOY_TIME))
    local hours_diff=$((time_diff / 3600))

    echo ""
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo -e "\e[1;33m  快速部署（使用上次配置）\e[0m"
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo ""
    echo -e "\e[1;36m上次配置信息：\e[0m"
    echo -e "  IP地址:   \e[1;37m$LAST_DEPLOY_IP\e[0m"
    echo -e "  端口:     \e[1;37m$LAST_DEPLOY_PORT\e[0m"
    echo -e "  用户名:   \e[1;37m$LAST_DEPLOY_USER\e[0m"
    echo -e "  密钥文件: \e[1;37m$LAST_DEPLOY_KEY\e[0m"
    if [ -n "$LAST_DEPLOY_TIME" ]; then
        echo -e "  保存时间: \e[1;37m$(date -d @$LAST_DEPLOY_TIME '+%Y-%m-%d %H:%M:%S')\e[0m"
    fi

    if [ $hours_diff -gt 24 ]; then
        echo ""
        echo -e "\e[1;33m⚠ 警告：该配置已保存超过 $hours_diff 小时，请确认信息是否仍然有效。\e[0m"
    fi

    echo ""
    echo -e "\e[1;36m请选择操作：\e[0m"
    echo -e "  \e[1;32m1)\e[0m 使用以上配置直接部署"
    echo -e "  \e[1;33m2)\e[0m 修改配置"
    echo -e "  \e[1;31m3)\e[0m 取消"
    echo ""
    read -p "请输入选项 (1-3，默认为 1): " quick_choice
    quick_choice=${quick_choice:-1}

    case "$quick_choice" in
        1)
            # 直接使用上次配置
            add_sshkey_with_config "$LAST_DEPLOY_IP" "$LAST_DEPLOY_PORT" "$LAST_DEPLOY_USER" "$LAST_DEPLOY_KEY"
            ;;
        2)
            # 修改配置
            modify_and_deploy
            ;;
        3|*)
            echo -e "\e[1;33m已取消操作\e[0m"
            return 1
            ;;
    esac
}

# 使用指定配置部署
add_sshkey_with_config() {
    local ip="$1"
    local port="$2"
    local username="$3"
    local key_file="$4"

    sudo apt install sshpass -y &> /dev/null

    # 初始化步骤计数
    CURRENT_STEP=0

    # 步骤 1/7: 连接服务器
    next_step
    show_step "连接服务器"

    echo -e "\e[1;36m使用配置: $username@$ip:$port\e[0m"

    # 步骤 2/7: 验证密码
    next_step
    show_step "验证密码"

    # 密码验证循环
    local max_attempts=3
    local attempt=0
    local password_valid=false

    while [ $attempt -lt $max_attempts ] && [ "$password_valid" = false ]; do
        echo -e "\e[1;36m请输入服务器密码：\e[0m"
        read -s password
        echo -e "\e[1;36m密码已输入，正在验证...\e[0m"

        # 检查服务器是否可达
        if ! timeout 5 bash -c "exec 3<>/dev/tcp/$ip/$port" 2>/dev/null; then
            echo ""
            echo -e "\e[1;31m✗ 无法连接到服务器 $ip:$port\e[0m"
            return 1
        fi

        # 验证密码
        if sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$port" "$username@$ip" "echo 'PASSWORD_OK'" 2>/dev/null | grep -q "PASSWORD_OK"; then
            password_valid=true
            echo -e "\e[1;32m✓ 密码验证成功\e[0m"
        else
            attempt=$((attempt + 1))
            if [ $attempt -lt $max_attempts ]; then
                echo ""
                echo -e "\e[1;31m✗ 密码错误或连接失败，还剩 $((max_attempts - attempt)) 次尝试\e[0m"
                echo ""
            else
                echo ""
                echo -e "\e[1;31m✗ 密码验证失败次数过多\e[0m"
                return 1
            fi
        fi
    done

    show_step_status "success"

    # 步骤 3/7: 添加主机指纹
    next_step
    show_step "添加主机指纹"
    ssh-keyscan -H -p $port $ip >> ~/.ssh/known_hosts 2>/dev/null
    show_step_status "success"

    # 步骤 4/7: 选择公钥
    next_step
    show_step "选择公钥"
    local keyName="${key_file}.pub"
    echo -e "\e[1;36m使用密钥: $keyName\e[0m"
    show_step_status "success"

    # 步骤 5/7: 部署公钥
    next_step
    show_step "部署公钥"

    if ! sshpass -p "$password" ssh-copy-id -i "$HOME/.ssh/$keyName" -p "$port" "$username@$ip"; then
        echo "sshpass的命令为: sshpass -p $password ssh-copy-id -i $HOME/.ssh/$keyName -p $port $username@$ip "
        echo -e "\033[31m公钥添加失败，请检查以下可能的原因：\033[0m"
        echo "1. 服务器IP地址或端口号输入错误。"
        echo "2. 服务器用户名或密码错误。"
        echo "3. 指定的公钥文件不存在。"
        echo "4. ssh-copy-id命令未正确执行，可能是因为sshpass未安装，或远程服务器不允许密码认证。"
        echo "请根据上述提示检查您的输入或配置，然后重试。"
        return 1
    fi

    show_step_status "success"

    # 步骤 6/7: 设置权限
    next_step
    show_step "设置权限"
    chmod 600 $HOME/.ssh/$key_file 2>/dev/null || true
    chmod 644 $HOME/.ssh/$keyName 2>/dev/null || true
    show_step_status "success"

    # 步骤 7/7: 完成配置
    next_step
    show_step "完成配置"

    # 更新保存的信息
    LAST_DEPLOY_IP="$ip"
    LAST_DEPLOY_PORT="$port"
    LAST_DEPLOY_USER="$username"
    LAST_DEPLOY_KEY="$key_file"
    save_last_deploy

    echo -e "\033[32m公钥 $HOME/.ssh/$keyName 部署成功\033[0m"
    show_step_status "success"

    echo ""
    echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo -e "\e[1;33m  部署完成！\e[0m"
    echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo ""
    echo -e "\e[1;32m现在可以使用以下命令连接：\e[0m"
    echo -e "\e[1;36m  ssh $username@$ip -p $port\e[0m"
    echo ""

    return 0
}

# 修改配置并部署
modify_and_deploy() {
    echo ""
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo -e "\e[1;33m  修改配置\e[0m"
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo ""

    local new_ip="$LAST_DEPLOY_IP"
    local new_port="$LAST_DEPLOY_PORT"
    local new_user="$LAST_DEPLOY_USER"
    local new_key="$LAST_DEPLOY_KEY"

    echo -e "\e[1;36m当前 IP: $new_ip\e[0m"
    echo -e "\e[1;36m请输入新的 IP (直接回车保持不变):\e[0m"
    read input_ip
    [ -n "$input_ip" ] && new_ip="$input_ip"

    echo -e "\e[1;36m当前端口: $new_port\e[0m"
    echo -e "\e[1;36m请输入新的端口 (直接回车保持不变):\e[0m"
    read input_port
    [ -n "$input_port" ] && new_port="$input_port"

    echo -e "\e[1;36m当前用户名: $new_user\e[0m"
    echo -e "\e[1;36m请输入新的用户名 (直接回车保持不变):\e[0m"
    read input_user
    [ -n "$input_user" ] && new_user="$input_user"

    echo -e "\e[1;36m当前密钥: $new_key\e[0m"
    echo -e "\e[1;36m请输入新的密钥文件名 (直接回车保持不变):\e[0m"
    read input_key
    [ -n "$input_key" ] && new_key="$input_key"

    echo ""
    echo -e "\e[1;36m修改后的配置：\e[0m"
    echo -e "  IP: $new_ip"
    echo -e "  端口: $new_port"
    echo -e "  用户名: $new_user"
    echo -e "  密钥: $new_key"
    echo ""
    echo -e "\e[1;36m确认使用以上配置？(y/n，默认为 y):\e[0m"
    read confirm
    confirm=${confirm:-y}

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        add_sshkey_with_config "$new_ip" "$new_port" "$new_user" "$new_key"
    else
        echo -e "\e[1;33m已取消操作\e[0m"
        return 1
    fi
}

# 格式化相对时间
format_relative_time() {
    local timestamp="$1"
    local current_time=$(date +%s)
    local diff=$((current_time - timestamp))

    if [ $diff -lt 60 ]; then
        echo "刚刚"
    elif [ $diff -lt 3600 ]; then
        echo "$((diff / 60))分钟前"
    elif [ $diff -lt 86400 ]; then
        echo "$((diff / 3600))小时前"
    else
        echo "$((diff / 86400))天前"
    fi
}

# 显示简洁菜单标题
show_menu_title() {
    echo ""
    echo -e "\e[1;36m🔐  SSH-Agent 自动配置工具  v1.1\e[0m"
    echo ""
}

# 显示简洁菜单
show_modern_menu() {
    # 获取上次部署时间
    local time_info=""
    if has_last_deploy; then
        load_last_deploy
        if [ -n "$LAST_DEPLOY_TIME" ]; then
            time_info="($(format_relative_time $LAST_DEPLOY_TIME))"
        fi
    fi

    show_menu_title

    # 密钥管理
    echo -e "\e[1;33m密钥管理\e[0m    \e[1;37m[1/G]\e[0m 🔑 \e[1;32m生成新密钥\e[0m"
    echo "──────────"

    # 部署操作
    echo -e "\e[1;33m部署操作\e[0m    \e[1;37m[2/D]\e[0m 🚀 \e[1;32m添加公钥到服务器\e[0m"
    if has_last_deploy; then
        echo -e "            \e[1;37m[Q]\e[0m   ⚡ \e[1;33m快速部署\e[0m \e[1;37m$time_info\e[0m"
    else
        echo -e "            \e[1;37m[Q]\e[0m   ⚡ \e[1;33m快速部署\e[0m \e[1;37m(无记录)\e[0m"
    fi
    echo "──────────"

    # 配置管理
    echo -e "\e[1;33m配置管理\e[0m    \e[1;37m[3/C]\e[0m 📝 \e[1;32m添加到 SSH config\e[0m"

    # 退出
    echo ""
    echo -e "\e[1;33m退出\e[0m        \e[1;37m[0/X]\e[0m ❌ \e[1;31m退出\e[0m"
    echo ""
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
}

# 主菜单循环 - 每次显示菜单，让用户清楚看到选项
while true; do
    show_modern_menu
    echo -e "\e[1;36m请选择操作 [0-3] 或 [G/D/Q/C/X]：\e[0m"
    read choice

    # 转换小写到单字母大写
    choice_upper=$(echo "$choice" | tr '[:lower:]' '[:upper:]')

    case "$choice_upper" in
        1|G)
            generate_sshkey
            ;;
        2|D)
            # 如果 add_sshkey 返回失败（密码验证失败等），询问是否重试
            while true; do
                if add_sshkey; then
                    break  # 成功，退出循环
                else
                    echo ""
                    echo -e "\e[1;36m是否重新尝试添加公钥？(y/n，默认为 y)：\e[0m"
                    read retry
                    retry=${retry:-y}
                    if [[ ! "$retry" =~ ^[Yy]$ ]]; then
                        break  # 用户选择不重试
                    fi
                fi
            done
            ;;
        3|C)
            add_to_config
            ;;
        Q)
            if has_last_deploy; then
                quick_deploy_menu
            else
                echo ""
                echo -e "\e[1;33m⚠ 没有可用的快速部署记录\e[0m"
                echo -e "\e[1;36m请先使用 [2/D] 添加公钥到服务器\e[0m"
                echo ""
            fi
            ;;
        0|X)
            break
            ;;
        *)
            echo ""
            echo -e "\e[1;31m✗ 无效的选择，请输入 [0-3] 或 [G/D/Q/C/X]\e[0m"
            ;;
    esac
done

echo ""
echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;32m  感谢使用！\e[0m"
echo ""
