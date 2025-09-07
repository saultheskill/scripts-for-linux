#!/usr/bin/env python3

"""
Shell工具配置生成器 - 模块化重构版本
作者: saul
版本: 2.1
描述: 生成模块化的现代shell工具最佳实践配置
"""

import os
import sys
from pathlib import Path

# 添加scripts目录到Python路径
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir.parent))

try:
    from common import show_header, log_info, log_success, log_error
except ImportError:
    print("错误：无法导入common模块")
    sys.exit(1)

# 导入模块化组件
try:
    from modules import get_template_coordinator
except ImportError as e:
    print(f"错误：无法导入模块化组件: {e}")
    sys.exit(1)


def main():
    """主函数 - 基于模板的重构版本"""
    show_header("Shell工具配置生成器", "2.1", "生成模块化的现代shell工具最佳实践配置（基于模板重构版）")

    try:
        # 获取模板协调器并生成所有配置
        coordinator = get_template_coordinator()

        if coordinator.generate_all_configs():
            log_success("Shell工具模块化配置生成完成！")
            log_info("请运行 'source ~/.zshrc' 或重新启动终端以应用配置")
            log_info("运行 'shell-tools-debug' 查看模块加载状态")
            log_info("运行 'show-tools' 查看所有可用功能")

            # 显示生成摘要
            summary = coordinator.get_generation_summary()
            template_info = "（基于模板）" if summary.get('template_based') else ""
            log_info(f"生成摘要: 主配置文件已创建，{summary['file_stats']['modules_count']} 个模块文件已生成 {template_info}")

            return True
        else:
            log_error("配置生成过程中出现错误")
            return False

    except Exception as e:
        log_error(f"配置生成失败: {str(e)}")
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
