#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
=============================================================================
常用软件安装脚本
作者: saul
版本: 2.0
描述: 独立的常用软件包安装脚本，使用标准化的交互界面
支持平台: Ubuntu 20-24, Debian 10-12, x64/ARM64
=============================================================================
"""

import os
import sys
import subprocess
import tempfile
import time
import threading
from pathlib import Path
from typing import List, Dict, Tuple, Optional

# 添加父目录到Python路径以导入common模块
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir.parent))

try:
    from common import *
except ImportError:
    print("错误：找不到 common.py 文件")
    print("请确保在项目根目录中运行此脚本")
    sys.exit(1)

# =============================================================================
# 调用环境检测
# =============================================================================

def detect_calling_environment() -> bool:
    """
    检测是否被主菜单调用（通过环境变量）

    Returns:
        bool: True表示被主菜单调用，False表示直接运行
    """
    return os.environ.get('CALLED_FROM_INSTALL_SH') is not None

# 全局变量：标记是否为自动模式
AUTO_MODE = detect_calling_environment()
if AUTO_MODE:
    print("[DEBUG] 检测到通过主菜单调用，启用自动模式", file=sys.stderr)
else:
    print("[DEBUG] 检测到直接运行，保持交互模式", file=sys.stderr)

# =============================================================================
# 软件包安装辅助函数
# =============================================================================

class SpinnerThread(threading.Thread):
    """旋转进度指示器线程"""

    def __init__(self, message: str):
        super().__init__(daemon=True)
        self.message = message
        self.spinner_chars = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        self.running = True
        self.i = 0

    def run(self):
        """运行旋转指示器"""
        print(f"{self.message} ", end='', flush=True)
        while self.running:
            print(f"\r{self.message} {CYAN}{self.spinner_chars[self.i]}{RESET}", end='', flush=True)
            self.i = (self.i + 1) % len(self.spinner_chars)
            time.sleep(0.1)
        print(f"\r{self.message} {GREEN}✓{RESET}")

    def stop(self):
        """停止旋转指示器"""
        self.running = False

def show_spinner(process: subprocess.Popen, message: str) -> None:
    """
    显示旋转进度指示器

    Args:
        process: 子进程对象
        message: 显示消息
    """
    spinner = SpinnerThread(message)
    spinner.start()

    process.wait()
    spinner.stop()
    spinner.join()

def check_network_status() -> bool:
    """
    检查网络连接状态

    Returns:
        bool: 网络是否正常
    """
    try:
        result = subprocess.run(['ping', '-c', '1', '-W', '3', '8.8.8.8'],
                              capture_output=True, timeout=5)
        return result.returncode == 0
    except:
        return False

def analyze_install_error(package_name: str, error_log: str) -> str:
    """
    分析安装错误类型

    Args:
        package_name: 包名
        error_log: 错误日志内容

    Returns:
        str: 错误类型描述
    """
    if "Unable to locate package" in error_log:
        return "软件包不存在或软件源未更新"
    elif "Could not get lock" in error_log:
        return "软件包管理器被其他进程占用"
    elif "Failed to fetch" in error_log:
        return "网络连接问题，无法下载软件包"
    elif "dpkg: error processing" in error_log:
        return "软件包配置错误或依赖问题"
    elif "Permission denied" in error_log:
        return "权限不足，需要管理员权限"
    else:
        return "未知错误"

def install_fd_find_special() -> bool:
    """
    特殊安装fd-find工具并创建fd别名

    Returns:
        bool: 安装是否成功
    """
    from common import log_info, log_success, log_warn

    # 检查是否已安装
    try:
        result = subprocess.run(['which', 'fdfind'], capture_output=True, text=True)
        if result.returncode == 0:
            log_success("fd-find 已安装，跳过")
            return True
    except:
        pass

    sudo_cmd = check_root()

    try:
        # 安装fd-find包
        log_info("安装fd-find...")
        cmd = f"{sudo_cmd} apt install -y fd-find".strip()
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

        if result.returncode != 0:
            log_warn(f"fd-find安装失败: {result.stderr}")
            return False

        # 创建fd别名到.zshrc
        log_info("配置fd别名...")
        zshrc_path = os.path.expanduser("~/.zshrc")
        alias_line = "alias fd='fdfind'"

        if os.path.exists(zshrc_path):
            with open(zshrc_path, 'r') as f:
                content = f.read()

            if alias_line not in content:
                with open(zshrc_path, 'a') as f:
                    f.write(f"\n# fd-find alias\n{alias_line}\n")
                log_info("已添加fd别名到.zshrc")
            else:
                log_info("fd别名已存在")

        log_success("fd-find安装和配置完成")
        return True

    except Exception as e:
        log_warn(f"fd-find安装过程中发生错误: {str(e)}")
        return False


def install_tshark_special() -> bool:
    """
    特殊安装tshark工具，避免交互式界面

    Returns:
        bool: 安装是否成功
    """
    from common import log_info, log_success, log_error

    # 检查是否已安装
    try:
        result = subprocess.run(['which', 'tshark'], capture_output=True, text=True)
        if result.returncode == 0:
            log_success("tshark 已安装，跳过")
            return True
    except:
        pass

    sudo_cmd = check_root()

    try:
        # 预配置debconf以避免交互式提示
        log_info("配置tshark安装选项...")
        debconf_cmd = f'echo "wireshark-common wireshark-common/install-setuid boolean true" | {sudo_cmd} debconf-set-selections'.strip()
        result1 = subprocess.run(debconf_cmd, shell=True, capture_output=True, text=True)

        if result1.returncode != 0:
            log_error(f"debconf配置失败: {result1.stderr}")
            # 继续安装，不中断流程

        # 使用非交互式方式安装tshark
        log_info("安装tshark...")
        env = os.environ.copy()
        env['DEBIAN_FRONTEND'] = 'noninteractive'

        cmd = f"{sudo_cmd} apt install -y --no-install-recommends tshark".strip()
        result2 = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

        if result2.returncode != 0:
            log_error(f"tshark安装失败: {result2.stderr}")
            return False

        log_success("tshark安装完成")
        return True

    except Exception as e:
        log_error(f"tshark安装过程中发生错误: {str(e)}")
        return False


def install_thefuck_special() -> bool:
    """
    特殊安装thefuck工具
    由于thefuck在Python 3.12中存在兼容性问题，暂时跳过安装

    Returns:
        bool: 安装是否成功
    """
    from common import log_info, log_success, log_warn

    log_warn("thefuck工具在Python 3.12中存在兼容性问题")
    log_info("建议手动安装或等待官方修复")
    log_info("可以使用以下命令尝试手动安装:")
    log_info("  sudo apt install python3-distutils")
    log_info("  pipx install thefuck")
    log_success("跳过thefuck安装")
    return True


def install_package_with_progress(package_name: str, package_desc: str,
                                current: int, total: int) -> bool:
    """
    显示安装进度的实时输出

    Args:
        package_name: 包名
        package_desc: 包描述
        current: 当前序号
        total: 总数

    Returns:
        bool: 安装是否成功
    """
    log_info(f"安装 ({current}/{total}): {package_desc} ({package_name})")

    # 检查是否已安装
    if check_package_installed(package_name):
        print(f"  {GREEN}✓{RESET} {package_desc} 已安装，跳过")
        return True

    # 显示安装提示
    print(f"  {CYAN}↓{RESET} 正在下载 {package_desc}...")
    print(f"  {YELLOW}ℹ{RESET} 提示：按 Ctrl+C 可取消安装")

    # 检查网络状态
    if not check_network_status():
        print(f"  {YELLOW}⚠{RESET} 网络连接较慢，请耐心等待...")

    # 执行安装并显示实时输出
    print(f"  {CYAN}📦{RESET} 开始安装 {package_desc}...")

    sudo_cmd = check_root()
    cmd = f"{sudo_cmd} apt install -y --no-install-recommends {package_name}".strip()

    try:
        with tempfile.NamedTemporaryFile(mode='w+', delete=False) as error_log:
            process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,
                                     stderr=error_log, text=True, bufsize=1,
                                     universal_newlines=True)

            # 跟踪已显示的状态，避免重复输出
            shown_states = {
                'reading': False,
                'building': False,
                'preparing': False,
                'downloading': False,
                'unpacking': False,
                'configuring': False,
                'triggers': False
            }

            download_count = 0
            unpack_count = 0
            config_count = 0
            trigger_count = 0

            # 实时显示输出
            for line in process.stdout:
                line = line.strip()
                # 跳过空行和进度条相关的行
                if not line or line.startswith('\r') or '%' in line and '[' in line:
                    continue

                if "Reading package lists" in line and not shown_states['reading']:
                    print(f"  {CYAN}[INFO]{RESET} 读取软件包列表...")
                    sys.stdout.flush()
                    shown_states['reading'] = True
                elif "Building dependency tree" in line and not shown_states['building']:
                    print(f"  {CYAN}[INFO]{RESET} 分析依赖关系...")
                    sys.stdout.flush()
                    shown_states['building'] = True
                elif "The following NEW packages will be installed" in line and not shown_states['preparing']:
                    print(f"  {CYAN}[INFO]{RESET} 准备安装新软件包...")
                    sys.stdout.flush()
                    shown_states['preparing'] = True
                elif "Need to get" in line and not shown_states['downloading']:
                    import re
                    size_match = re.search(r'[\d,.]+ [kMG]B', line)
                    size = size_match.group() if size_match else "未知大小"
                    print(f"  {CYAN}↓{RESET} 需要下载: {size}")
                    sys.stdout.flush()
                    shown_states['downloading'] = True
                elif "Get:" in line:
                    download_count += 1
                    if download_count <= 3:  # 只显示前3个下载项
                        # 解析Get行格式: Get:1 http://archive.ubuntu.com/ubuntu noble/main amd64 package_name amd64 version [size]
                        parts = line.split()
                        if len(parts) >= 4:
                            # 尝试从URL中提取包名，或者从parts中找到包名
                            package_file = None
                            for part in parts:
                                if '.deb' in part or '_' in part:
                                    package_file = part
                                    break

                            if not package_file and len(parts) >= 5:
                                # 如果没找到.deb文件，尝试构造包名
                                package_file = f"{parts[4]}"

                            if package_file:
                                print(f"  {CYAN}↓{RESET} 下载中: {package_file}")
                                sys.stdout.flush()
                            else:
                                print(f"  {CYAN}↓{RESET} 下载软件包...")
                                sys.stdout.flush()
                    elif download_count == 4:
                        print(f"  {CYAN}↓{RESET} 继续下载其他包...")
                        sys.stdout.flush()
                elif "Unpacking" in line:
                    unpack_count += 1
                    if unpack_count == 1:
                        print(f"  {CYAN}[INFO]{RESET} 解包中...")
                        sys.stdout.flush()
                elif "Setting up" in line:
                    config_count += 1
                    if config_count == 1:
                        print(f"  {CYAN}[INFO]{RESET} 配置中...")
                        sys.stdout.flush()
                elif "Processing triggers" in line:
                    trigger_count += 1
                    if trigger_count == 1:
                        print(f"  {CYAN}[INFO]{RESET} 处理触发器...")
                        sys.stdout.flush()

            process.wait()

            if process.returncode == 0:
                print(f"  {GREEN}[SUCCESS]{RESET} {package_desc} 安装成功")
                return True
            else:
                print(f"  {RED}[FAILED]{RESET} {package_desc} 安装失败")

                # 分析错误原因
                error_log.seek(0)
                error_content = error_log.read()

                if error_content.strip():
                    error_type = analyze_install_error(package_name, error_content)
                    print(f"  {RED}[ERROR]{RESET} 错误原因: {error_type}")

                    # 显示详细错误信息（前3行）
                    print(f"  {YELLOW}[INFO]{RESET} 详细错误:")
                    error_lines = error_content.strip().split('\n')[:3]
                    for line in error_lines:
                        print(f"    {line}")

                    # 提供解决建议
                    if "软件包不存在" in error_type:
                        print(f"  {CYAN}[TIP]{RESET} 建议: 运行 'sudo apt update' 更新软件源")
                    elif "网络连接问题" in error_type:
                        print(f"  {CYAN}[TIP]{RESET} 建议: 检查网络连接或稍后重试")
                    elif "被其他进程占用" in error_type:
                        print(f"  {CYAN}[TIP]{RESET} 建议: 等待其他安装进程完成或重启系统")
                    elif "权限不足" in error_type:
                        print(f"  {CYAN}[TIP]{RESET} 建议: 确保以管理员权限运行脚本")

                return False

    except Exception as e:
        print(f"  {RED}[FAILED]{RESET} {package_desc} 安装失败: {e}")
        return False
    finally:
        try:
            os.unlink(error_log.name)
        except:
            pass

# =============================================================================
# 触发器优化函数
# =============================================================================

def configure_apt_for_speed() -> None:
    """配置 APT 以优化安装速度"""
    log_info("配置 APT 以优化安装速度...")

    apt_config_content = '''# 优化触发器处理
DPkg::Options {
    "--force-confdef";
    "--force-confold";
}

# 延迟触发器处理
DPkg::TriggersPending "true";
DPkg::ConfigurePending "true";

# 减少不必要的同步
DPkg::Post-Invoke {
    "if [ -d /var/lib/update-notifier ]; then touch /var/lib/update-notifier/dpkg-run-stamp; fi";
};

# 优化 man-db 触发器
DPkg::Pre-Install-Pkgs {
    "/bin/sh -c 'if [ \\"$1\\" = \\"configure\\" ] && [ -n \\"$2\\" ]; then /usr/bin/dpkg-trigger --no-await man-db 2>/dev/null || true; fi' sh";
};
'''

    try:
        with open("/tmp/apt-speed-config", "w") as f:
            f.write(apt_config_content)
        os.environ["APT_CONFIG"] = "/tmp/apt-speed-config"
        log_info("APT 优化配置已应用")
    except Exception as e:
        log_warn(f"无法配置APT优化: {e}")

def process_triggers_batch() -> None:
    """批量处理触发器"""
    log_info("批量处理待处理的触发器...")

    try:
        # 检查是否有待处理的触发器
        result = subprocess.run(['dpkg', '--audit'], capture_output=True, text=True)
        if result.returncode == 0 and ('triggers-awaited' in result.stdout or 'triggers-pending' in result.stdout):
            print(f"  {CYAN}🔄{RESET} 处理待处理的触发器...")

            # 批量处理所有待处理的触发器
            sudo_cmd = check_root()
            cmd = f"{sudo_cmd} dpkg --configure --pending".strip()
            result = subprocess.run(cmd, shell=True, capture_output=True)

            if result.returncode == 0:
                print(f"  {GREEN}[SUCCESS]{RESET} 触发器处理完成")
            else:
                print(f"  {YELLOW}[WARN]{RESET} 部分触发器处理失败，但不影响安装")
        else:
            print(f"  {GREEN}[SUCCESS]{RESET} 无待处理的触发器")
    except Exception as e:
        print(f"  {YELLOW}[WARN]{RESET} 触发器处理失败: {e}")

def cleanup_apt_config() -> None:
    """清理 APT 配置"""
    apt_config = os.environ.get("APT_CONFIG")
    if apt_config and os.path.exists(apt_config):
        try:
            os.unlink(apt_config)
            del os.environ["APT_CONFIG"]
            log_debug("APT 优化配置已清理")
        except:
            pass

# =============================================================================
# 主要安装函数
# =============================================================================

def install_common_software() -> bool:
    """
    安装常用软件（改进版，带详细进度显示和触发器优化）

    Returns:
        bool: 安装是否成功
    """
    log_info("开始安装常用软件...")
    print(f"{CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}")

    # 配置 APT 优化
    configure_apt_for_speed()

    # 定义常用软件包列表（扩展版本）
    common_packages = [
        ("curl", "网络请求工具"),
        ("wget", "文件下载工具"),
        ("git", "版本控制系统"),
        ("vim", "文本编辑器"),
        ("htop", "系统监控工具"),
        ("unzip", "解压缩工具"),
        ("tmux", "终端工具"),
        ("thefuck", "改错工具"),
        ("zip", "压缩工具"),
        ("fzf", "模糊查找工具"),
        ("bat", "cat的增强版"),
        ("btop", "系统监控工具"),
        ("net-tools", "网络工具"),
        ("ncdu", "磁盘使用分析"),
        ("traceroute", "网络路由跟踪"),
        ("netcat-traditional", "网络连接工具"),
        ("mtr", "网络诊断工具"),
        ("tshark", "网络包分析"),
        ("nmap", "网络扫描工具"),
        ("fd-find", "find的现代替代品")
    ]

    success_count = 0
    failed_count = 0
    skipped_count = 0
    total_count = len(common_packages)
    failed_packages = []

    # 显示安装概览
    print(f"{BLUE}📦 软件包安装概览{RESET}")
    print(f"  {CYAN}总数量:{RESET} {total_count} 个软件包")
    print(f"  {CYAN}预计时间:{RESET} 根据网络速度而定")
    print(f"  {YELLOW}提示:{RESET} 整个过程中可以按 Ctrl+C 取消安装")
    print()

    # 更新软件包列表（带进度显示）
    log_info("第一步：更新软件包列表")
    print(f"  {CYAN}🔄{RESET} 正在更新软件包列表，请稍候...")

    try:
        sudo_cmd = check_root()
        cmd = f"{sudo_cmd} apt update".strip()

        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE, text=True, bufsize=1)

        for line in process.stdout:
            line = line.strip()
            if "Hit:" in line:
                parts = line.split()
                if len(parts) > 1:
                    repo = parts[1]
                    print(f"  {GREEN}✓{RESET} 检查: {repo}")
            elif "Get:" in line:
                parts = line.split()
                if len(parts) > 1:
                    repo = parts[1]
                    print(f"  {CYAN}↓{RESET} 获取: {repo}")
            elif "Reading package lists" in line:
                print(f"  {CYAN}[INFO]{RESET} 读取软件包列表...")

        process.wait()

        if process.returncode == 0:
            print(f"  {GREEN}[SUCCESS]{RESET} 软件包列表更新成功")
        else:
            print(f"  {YELLOW}[WARN]{RESET} 软件包列表更新失败，但将继续安装")
            stderr_content = process.stderr.read()
            if stderr_content.strip():
                print(f"  {YELLOW}[INFO]{RESET} 错误信息:")
                error_lines = stderr_content.strip().split('\n')[:2]
                for line in error_lines:
                    print(f"    {line}")

    except Exception as e:
        print(f"  {YELLOW}⚠{RESET} 软件包列表更新失败: {e}")

    print()
    log_info("第二步：开始安装软件包")
    print()

    # 安装每个软件包
    for current_num, (package_name, package_desc) in enumerate(common_packages, 1):
        print(f"{BLUE}━━━ 软件包 {current_num}/{total_count} ━━━{RESET}")

        try:
            # 特殊处理某些软件包的安装
            if package_name == "thefuck":
                log_info(f"安装 ({current_num}/{total_count}): {package_desc} ({package_name})")
                if install_thefuck_special():
                    success_count += 1
                else:
                    failed_count += 1
                    failed_packages.append((package_name, package_desc))
            elif package_name == "fd-find":
                log_info(f"安装 ({current_num}/{total_count}): {package_desc} ({package_name})")
                if install_fd_find_special():
                    success_count += 1
                else:
                    failed_count += 1
                    failed_packages.append((package_name, package_desc))
            elif package_name == "tshark":
                log_info(f"安装 ({current_num}/{total_count}): {package_desc} ({package_name})")
                if install_tshark_special():
                    success_count += 1
                else:
                    failed_count += 1
                    failed_packages.append((package_name, package_desc))
            else:
                if install_package_with_progress(package_name, package_desc, current_num, total_count):
                    success_count += 1
                else:
                    failed_count += 1
                    failed_packages.append((package_name, package_desc))
        except KeyboardInterrupt:
            print(f"\n{YELLOW}安装被用户中断{RESET}")
            break
        except Exception as e:
            log_error(f"安装 {package_name} 时发生异常: {e}")
            failed_count += 1
            failed_packages.append((package_name, package_desc))

        print()
        time.sleep(0.2)  # 减少等待时间以加速安装

    # 批量处理触发器
    print()
    process_triggers_batch()

    # 显示安装总结
    print(f"{CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}")
    log_info("第三步：安装总结")
    print()

    print(f"{BLUE}安装统计{RESET}")
    print(f"{BLUE}{'─'*64}{RESET}")
    print(f"  {GREEN}成功安装:{RESET} {success_count} 个")
    print(f"  {RED}安装失败:{RESET} {failed_count} 个")
    print(f"  {YELLOW}已跳过:{RESET} {skipped_count} 个")
    print(f"  {CYAN}总计:{RESET} {total_count} 个")

    # 显示安装进度条
    progress = (success_count * 100) // total_count if total_count > 0 else 0
    bar_length = 50
    filled_length = (progress * bar_length) // 100
    bar = "█" * filled_length + "░" * (bar_length - filled_length)

    print(f"  {CYAN}进度:{RESET} [{bar}] {progress}%")
    print()

    # 如果有失败的软件包，显示详细信息
    if failed_count > 0:
        print(f"{RED}安装失败的软件包:{RESET}")
        print(f"{RED}{'─'*64}{RESET}")
        for pkg_name, pkg_desc in failed_packages:
            print(f"  {RED}•{RESET} {pkg_desc} ({pkg_name})")
        print()
        print(f"{YELLOW}建议:{RESET}")
        print(f"{YELLOW}{'─'*64}{RESET}")
        print("  • 检查网络连接是否正常")
        print("  • 运行 'sudo apt update' 更新软件源")
        print("  • 稍后重新运行安装脚本")
        print()

    # 清理 APT 配置
    cleanup_apt_config()

    # 返回结果
    if success_count == total_count:
        print(f"{GREEN}常用软件安装完成！所有 {total_count} 个软件包都已成功安装。{RESET}")
        return True
    elif success_count > 0:
        print(f"{YELLOW}常用软件部分完成。成功安装 {success_count}/{total_count} 个软件包。{RESET}")
        return False
    else:
        print(f"{RED}常用软件安装失败。没有成功安装任何软件包。{RESET}")
        return False

# =============================================================================
# 系统检查函数
# =============================================================================

def check_system_requirements() -> bool:
    """
    检查系统要求

    Returns:
        bool: 系统要求是否满足
    """
    log_info("检查系统要求...")

    # 检查操作系统
    os_name, os_version = detect_os()

    if "ubuntu" in os_name.lower():
        if os_version in ["20.04", "22.04", "22.10", "24.04"]:
            log_info(f"检测到支持的Ubuntu版本: {os_version}")
        else:
            log_warn(f"检测到Ubuntu版本: {os_version}，可能不完全兼容")
    elif "debian" in os_name.lower():
        if os_version in ["10", "11", "12"]:
            log_info(f"检测到支持的Debian版本: {os_version}")
        else:
            log_warn(f"检测到Debian版本: {os_version}，可能不完全兼容")
    else:
        log_error(f"不支持的操作系统: {os_name}")
        log_error("本脚本仅支持Ubuntu 20-24和Debian 10-12")
        return False

    # 检查架构
    arch = detect_arch()
    if arch in ["x64", "arm64", "arm"]:
        log_info(f"检测到支持的架构: {arch}")
    else:
        log_warn(f"检测到架构: {arch}，可能不完全兼容")

    log_info("系统要求检查通过")
    return True

# =============================================================================
# 显示函数
# =============================================================================

def show_software_header() -> None:
    """显示常用软件安装脚本头部信息"""
    os.system('clear' if os.name == 'posix' else 'cls')

    show_header(
        "常用软件安装脚本",
        "2.0",
        "独立的常用软件包安装脚本，使用标准化的交互界面"
    )

    print(f"{CYAN}本脚本将安装常用的开发工具和实用软件{RESET}")
    print(f"{CYAN}支持Ubuntu 20-24和Debian 10-12，x64和ARM64架构{RESET}")
    print(f"{BLUE}{'─'*64}{RESET}")
    print()
    print(f"{YELLOW}功能说明：{RESET}")
    print(f"{BLUE}{'─'*64}{RESET}")
    print(f"  {GREEN}•{RESET} 安装20个常用工具包（curl, git, vim, htop, fzf, bat等）")
    print(f"  {GREEN}•{RESET} 智能检测已安装软件，避免重复安装")
    print(f"  {GREEN}•{RESET} 详细的安装进度显示和错误处理")
    print(f"{BLUE}{'─'*64}{RESET}")
    print()

# =============================================================================
# 主函数
# =============================================================================

def main() -> int:
    """
    主函数

    Returns:
        int: 退出码
    """
    try:
        # 显示头部信息
        show_software_header()

        # 检查系统要求
        if not check_system_requirements():
            log_error("系统要求检查失败，安装终止")
            return 1

        # 根据调用环境决定是否需要用户确认
        if AUTO_MODE:
            # 自动模式：被主菜单调用，跳过用户确认
            log_info("检测到通过主菜单调用，自动开始安装常用软件")
            print(f"{CYAN}自动模式：{RESET}正在安装常用的开发工具和实用软件")
            print(f"{CYAN}安装过程中会自动跳过已安装的软件包{RESET}")
            print()
        else:
            # 交互模式：直接运行，需要用户确认
            print(f"{YELLOW}注意：本脚本将安装常用的开发工具和实用软件{RESET}")
            print(f"{YELLOW}   安装过程中会自动跳过已安装的软件包{RESET}")
            print()

            if not interactive_ask_confirmation("是否继续安装常用软件？", "true"):
                log_info("用户取消安装")
                return 0

            log_info("用户确认继续安装")

        # 开始安装
        install_result = install_common_software()

        # 如果安装成功，配置shell工具
        if install_result:
            log_info("配置现代shell工具...")
            try:
                shell_tools_config_script = script_dir / "shell-tools-config-generator.py"
                if shell_tools_config_script.exists():
                    result = subprocess.run([sys.executable, str(shell_tools_config_script)],
                                          capture_output=True, text=True)
                    if result.returncode == 0:
                        log_success("Shell工具配置完成")
                    else:
                        log_warn("Shell工具配置失败，但不影响软件使用")
                else:
                    log_warn("Shell工具配置生成器不存在")
            except Exception as e:
                log_warn(f"Shell工具配置过程中发生错误: {e}")

        # 显示完成信息
        print()
        if install_result:
            print(f"{GREEN}================================================================{RESET}")
            print(f"{GREEN}常用软件安装完成！{RESET}")
            print(f"{GREEN}================================================================{RESET}")
        else:
            print(f"{YELLOW}================================================================{RESET}")
            print(f"{YELLOW}常用软件安装部分完成{RESET}")
            print(f"{YELLOW}================================================================{RESET}")

        print()
        print(f"{CYAN}后续步骤：{RESET}")
        print("1. 运行 'source ~/.zshrc' 或重新启动终端以应用新配置")
        print("2. 运行相应命令验证安装结果")
        print("3. 查看安装日志了解详细信息")
        print("4. 如有问题，请检查网络连接和系统权限")
        print()

        return 0 if install_result else 1

    except KeyboardInterrupt:
        print(f"\n{YELLOW}安装被用户中断{RESET}")
        return 130
    except Exception as e:
        log_error(f"脚本执行过程中发生错误: {e}")
        return 1

# =============================================================================
# 脚本入口点
# =============================================================================

if __name__ == "__main__":
    # 设置信号处理
    import signal

    def signal_handler(signum, frame):
        print(f"\n{RED}[ERROR] 脚本执行被中断{RESET}")
        sys.exit(1)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # 执行主函数
    exit_code = main()
    sys.exit(exit_code)
