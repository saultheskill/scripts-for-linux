#!/usr/bin/env python3

"""
SSH代理管理器 - Python版本
作者: saul
版本: 1.0
描述: 管理SSH代理的启动、配置和密钥加载
"""

import os
import sys
import subprocess
import socket
from pathlib import Path

# 添加scripts目录到Python路径
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir.parent))

try:
    from common import *
except ImportError:
    print("错误：无法导入common模块")
    print("请确保common.py文件存在于scripts目录中")
    sys.exit(1)

# =============================================================================
# SSH代理管理函数
# =============================================================================

def get_ssh_agent_config_path():
    """获取SSH代理配置文件路径"""
    return Path.home() / ".ssh-agent-ohmyzsh"

def is_ssh_agent_running():
    """检查SSH代理是否正在运行"""
    ssh_auth_sock = os.environ.get('SSH_AUTH_SOCK')

    if not ssh_auth_sock:
        return False

    # 检查socket文件是否存在且有效
    try:
        sock_path = Path(ssh_auth_sock)
        if sock_path.exists() and sock_path.is_socket():
            # 尝试连接到socket以验证代理是否响应
            sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            sock.settimeout(1)
            sock.connect(ssh_auth_sock)
            sock.close()
            return True
    except (OSError, socket.error, socket.timeout):
        pass

    return False

def load_ssh_agent_config():
    """从配置文件加载SSH代理环境变量"""
    config_path = get_ssh_agent_config_path()

    if not config_path.exists():
        return False

    try:
        with open(config_path, 'r') as f:
            content = f.read().strip()

        # 解析并设置环境变量
        for line in content.split('\n'):
            if line.startswith('SSH_AUTH_SOCK='):
                os.environ['SSH_AUTH_SOCK'] = line.split('=', 1)[1].strip(';')
            elif line.startswith('SSH_AGENT_PID='):
                os.environ['SSH_AGENT_PID'] = line.split('=', 1)[1].strip(';')
            elif line.startswith('export SSH_AUTH_SOCK='):
                os.environ['SSH_AUTH_SOCK'] = line.split('=', 1)[1].strip(';')
            elif line.startswith('export SSH_AGENT_PID='):
                os.environ['SSH_AGENT_PID'] = line.split('=', 1)[1].strip(';')

        return True

    except Exception as e:
        log_error(f"加载SSH代理配置失败: {e}")
        return False

def start_ssh_agent():
    """启动新的SSH代理"""
    log_info("启动新的SSH代理...")

    config_path = get_ssh_agent_config_path()

    try:
        # 启动ssh-agent，设置12小时超时
        result = subprocess.run(['ssh-agent', '-t', '12h'],
                              capture_output=True, text=True, check=True)

        # 保存配置到文件
        with open(config_path, 'w') as f:
            f.write(result.stdout)

        # 设置正确的权限
        config_path.chmod(0o600)

        # 加载环境变量
        load_ssh_agent_config()

        log_success("SSH代理启动成功")
        return True

    except subprocess.CalledProcessError as e:
        log_error(f"启动SSH代理失败: {e}")
        return False
    except Exception as e:
        log_error(f"SSH代理配置失败: {e}")
        return False

def add_ssh_keys_to_agent():
    """将SSH密钥添加到代理"""
    ssh_dir = Path.home() / ".ssh"

    if not ssh_dir.exists():
        log_warn("SSH目录不存在，跳过密钥加载")
        return True

    # 查找所有私钥文件
    private_keys = []
    for key_file in ssh_dir.glob("*"):
        if (key_file.is_file() and
            not key_file.name.endswith('.pub') and
            not key_file.name in ['config', 'known_hosts', 'authorized_keys']):
            private_keys.append(key_file)

    if not private_keys:
        log_info("未找到SSH私钥文件")
        return True

    try:
        # 添加所有私钥到代理
        for key_file in private_keys:
            try:
                subprocess.run(['ssh-add', str(key_file)],
                             capture_output=True, check=True)
                log_debug(f"已添加密钥: {key_file.name}")
            except subprocess.CalledProcessError:
                # 忽略单个密钥添加失败
                pass

        log_info("SSH密钥已添加到代理")
        return True

    except Exception as e:
        log_error(f"添加SSH密钥到代理失败: {e}")
        return False

def ensure_ssh_agent():
    """确保SSH代理正在运行并加载了密钥"""
    log_info("检查SSH代理状态...")

    # 创建配置文件（如果不存在）
    config_path = get_ssh_agent_config_path()
    config_path.touch(mode=0o600, exist_ok=True)

    # 检查当前代理是否有效
    if not is_ssh_agent_running():
        log_info("SSH代理未运行，尝试从配置文件加载...")

        # 尝试从配置文件加载
        if load_ssh_agent_config():
            if is_ssh_agent_running():
                log_info("SSH代理已从配置文件恢复")
            else:
                log_info("配置文件中的代理已失效，启动新代理...")
                if not start_ssh_agent():
                    return False
        else:
            log_info("启动新的SSH代理...")
            if not start_ssh_agent():
                return False
    else:
        log_info("SSH代理正在运行")

    # 添加SSH密钥到代理
    add_ssh_keys_to_agent()

    return True

def generate_zsh_agent_script():
    """生成ZSH中使用的SSH代理脚本"""
    script_content = '''# =============================================================================
# SSH Agent Management - 修复版本，确保所有密钥都被加载
# =============================================================================

# 只在交互式shell中初始化SSH Agent
if [[ -o interactive && -z "$_SSH_AGENT_SETUP_COMPLETE" ]]; then
    export _SSH_AGENT_SETUP_COMPLETE=1

    # SSH Agent设置（带错误处理）
    {
        local ssh_agent_started=false

        # 检查现有SSH Agent
        if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
            # 尝试恢复已保存的配置
            if [[ -f ~/.ssh-agent-ohmyzsh ]]; then
                source ~/.ssh-agent-ohmyzsh
            fi
        fi

        # 如果仍然没有有效的SSH Agent，启动新的
        if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
            # 启动SSH Agent并设置环境变量
            local agent_output
            agent_output=$(ssh-agent -s 2>/dev/null)
            if [[ $? -eq 0 ]]; then
                eval "$agent_output"
                echo "$agent_output" > ~/.ssh-agent-ohmyzsh
                ssh_agent_started=true
            fi
        fi

        # 加载所有SSH私钥（如果SSH Agent可用）
        if [[ -d ~/.ssh && -S "$SSH_AUTH_SOCK" ]]; then
            local keys_loaded=0

            # 使用通用模式加载所有私钥文件
            for key_file in ~/.ssh/*; do
                # 检查是否为私钥文件
                if [[ -f "$key_file" && ! "$key_file" =~ \\.(pub|old|bak)$ && ! "$key_file" =~ (known_hosts|authorized_keys|config)$ ]]; then
                    if ssh-add "$key_file" 2>/dev/null; then
                        ((keys_loaded++))
                    fi
                fi
            done

            # 保存加载统计（用于调试）
            echo "SSH_KEYS_LOADED=$keys_loaded" >> ~/.ssh-agent-ohmyzsh
        fi
    } >/dev/null 2>&1
fi

# 添加便捷的SSH Agent管理别名
alias ast='ssh-add -l 2>/dev/null || echo "SSH Agent not running or no keys loaded"'
alias arl='unset _SSH_AGENT_SETUP_COMPLETE && source ~/.zshrc'
alias ssh-status='if [[ -n "$SSH_AGENT_PID" ]]; then key_count=$(ssh-add -l 2>/dev/null | wc -l); echo "SSH_AGENT_PID: $SSH_AGENT_PID ($key_count keys loaded)"; else echo "SSH Agent not running"; fi'
'''

    return script_content

def install_zsh_agent_integration():
    """将SSH代理管理集成到ZSH配置中"""
    log_info("集成SSH代理管理到ZSH配置...")

    zshrc_path = Path.home() / ".zshrc"

    if not zshrc_path.exists():
        log_warn("~/.zshrc 文件不存在，创建新文件")
        zshrc_path.touch()

    script_content = generate_zsh_agent_script()

    try:
        # 读取现有内容
        with open(zshrc_path, 'r') as f:
            existing_content = f.read()

        # 检查是否已存在SSH代理配置，如果存在则替换
        if "SSH Agent Management" in existing_content:
            log_info("发现现有SSH代理配置，正在更新...")

            # 找到SSH Agent Management部分的开始和结束
            start_marker = "# SSH Agent Management"
            lines = existing_content.split('\n')

            # 找到开始行
            start_idx = -1
            for i, line in enumerate(lines):
                if start_marker in line:
                    start_idx = i
                    break

            if start_idx != -1:
                # 移除从SSH Agent Management开始到文件末尾的所有内容
                new_content = '\n'.join(lines[:start_idx])

                # 添加新的SSH代理配置
                with open(zshrc_path, 'w') as f:
                    f.write(f"{new_content}\n\n{script_content}\n")

                log_success("SSH代理管理配置已更新")
                return True

        # 如果没有现有配置，添加到文件末尾
        with open(zshrc_path, 'a') as f:
            f.write(f"\n\n{script_content}\n")

        log_success("SSH代理管理已成功集成到ZSH配置")
        return True

    except Exception as e:
        log_error(f"集成SSH代理管理到ZSH失败: {e}")
        return False

def main():
    """主函数"""
    try:
        show_header("SSH代理管理器", "1.0", "管理SSH代理的启动、配置和密钥加载")

        # 确保SSH代理运行
        if ensure_ssh_agent():
            log_success("SSH代理管理完成")

            # 显示代理状态
            ssh_auth_sock = os.environ.get('SSH_AUTH_SOCK')
            ssh_agent_pid = os.environ.get('SSH_AGENT_PID')

            if ssh_auth_sock:
                log_info(f"SSH_AUTH_SOCK: {ssh_auth_sock}")
            if ssh_agent_pid:
                log_info(f"SSH_AGENT_PID: {ssh_agent_pid}")

            # 集成到ZSH配置
            install_zsh_agent_integration()
        else:
            log_error("SSH代理管理失败")
            return 1

        return 0

    except KeyboardInterrupt:
        log_info("\n用户中断操作")
        return 1
    except Exception as e:
        log_error(f"程序执行过程中发生错误: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
