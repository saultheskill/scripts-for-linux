#!/usr/bin/env python3

"""
APT源配置修复脚本
解决重复配置和混合格式问题
"""

import os
import sys
import shutil
from pathlib import Path
from datetime import datetime

# 添加scripts目录到Python路径
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir / 'scripts'))

try:
    from common import show_header, log_info, log_success, log_error, log_warn, check_root
except ImportError:
    print("错误：无法导入common模块")
    sys.exit(1)


def backup_apt_config():
    """备份当前APT配置"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = f"/etc/apt/backup_{timestamp}"

    try:
        os.makedirs(backup_dir, exist_ok=True)

        # 备份sources.list
        if os.path.exists("/etc/apt/sources.list"):
            shutil.copy2("/etc/apt/sources.list", f"{backup_dir}/sources.list")
            log_info(f"已备份 sources.list 到 {backup_dir}")

        # 备份sources.list.d目录
        if os.path.exists("/etc/apt/sources.list.d"):
            shutil.copytree("/etc/apt/sources.list.d", f"{backup_dir}/sources.list.d")
            log_info(f"已备份 sources.list.d 到 {backup_dir}")

        return backup_dir
    except Exception as e:
        log_error(f"备份失败: {e}")
        return None


def fix_duplicate_sources():
    """修复重复的APT源配置"""
    log_info("开始修复重复的APT源配置...")

    # 检查是否存在重复配置
    sources_list_exists = os.path.exists("/etc/apt/sources.list")
    ubuntu_sources_exists = os.path.exists("/etc/apt/sources.list.d/ubuntu.sources")

    if not sources_list_exists and not ubuntu_sources_exists:
        log_error("未找到APT源配置文件")
        return False

    # 如果两个文件都存在，优先使用新格式（ubuntu.sources）
    if sources_list_exists and ubuntu_sources_exists:
        log_info("检测到重复配置，将禁用传统格式的sources.list")

        # 重命名sources.list为.bak
        try:
            shutil.move("/etc/apt/sources.list", "/etc/apt/sources.list.bak")
            log_success("已禁用重复的sources.list配置")
        except Exception as e:
            log_error(f"禁用sources.list失败: {e}")
            return False

    return True


def optimize_apt_config():
    """优化APT配置"""
    log_info("优化APT配置...")

    # 创建APT配置优化文件
    apt_conf_content = """# APT配置优化
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
Acquire::ftp::Timeout "30";
Acquire::Retries "3";
Acquire::Queue-Mode "host";
APT::Get::Show-Progress "true";
APT::Color "true";
"""

    try:
        with open("/etc/apt/apt.conf.d/99-timeout-optimization", "w") as f:
            f.write(apt_conf_content)
        log_success("已创建APT超时优化配置")
        return True
    except Exception as e:
        log_error(f"创建APT优化配置失败: {e}")
        return False


def test_apt_update():
    """测试APT更新"""
    log_info("测试APT更新...")

    import subprocess
    try:
        # 使用超时测试APT更新
        result = subprocess.run(
            ["timeout", "60", "apt", "update"],
            capture_output=True,
            text=True,
            check=False
        )

        if result.returncode == 0:
            log_success("APT更新测试成功")
            return True
        elif result.returncode == 124:  # timeout exit code
            log_warn("APT更新超时，但这可能是网络问题")
            return False
        else:
            log_error(f"APT更新失败，退出码: {result.returncode}")
            if result.stderr:
                log_error(f"错误信息: {result.stderr[:200]}")
            return False

    except Exception as e:
        log_error(f"测试APT更新时出错: {e}")
        return False


def main():
    """主函数"""
    show_header("APT源配置修复工具", "1.0", "修复APT重复配置和超时问题")

    # 检查root权限
    if os.geteuid() != 0:
        log_error("此脚本需要root权限运行")
        log_info("请使用: sudo python3 fix-apt-sources.py")
        return False

    try:
        # 1. 备份当前配置
        backup_dir = backup_apt_config()
        if not backup_dir:
            log_error("备份失败，停止修复")
            return False

        # 2. 修复重复源配置
        if not fix_duplicate_sources():
            log_error("修复重复配置失败")
            return False

        # 3. 优化APT配置
        if not optimize_apt_config():
            log_warn("APT配置优化失败，但可以继续")

        # 4. 测试APT更新
        if test_apt_update():
            log_success("APT配置修复完成！")
            log_info(f"配置备份位置: {backup_dir}")
            log_info("现在可以正常使用 apt update 命令")
            return True
        else:
            log_warn("APT更新测试未完全成功，但配置已优化")
            log_info("如果仍有问题，请检查网络连接或镜像源状态")
            return True

    except Exception as e:
        log_error(f"修复过程中出现错误: {e}")
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
