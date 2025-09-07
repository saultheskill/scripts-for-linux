#!/usr/bin/env python3

"""
配置协调器
负责协调各个模块的生成和管理整个配置生成流程
"""

import sys
from pathlib import Path
from typing import List, Tuple, Dict, Optional

# 添加父目录到路径以导入common模块
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    from common import log_info, log_warn, log_error, log_success, show_header
except ImportError:
    # 如果无法导入，提供简单的日志函数
    def log_info(msg): print(f"[INFO] {msg}")
    def log_warn(msg): print(f"[WARN] {msg}")
    def log_error(msg): print(f"[ERROR] {msg}")
    def log_success(msg): print(f"[SUCCESS] {msg}")
    def show_header(title, version, desc): print(f"=== {title} v{version} ===\n{desc}")

from .tool_detector import get_tool_detector
from .file_manager import get_file_manager
from .module_generators import ModuleGenerators
from .advanced_modules import AdvancedModuleGenerators
from .extended_modules import ExtendedModuleGenerators


class ConfigCoordinator:
    """配置生成协调器"""

    # 模块定义：(文件名, 描述, 依赖工具, 依赖模块)
    MODULES_CONFIG = [
        ("00-path-config.zsh", "PATH和基础环境配置", [], []),
        ("01-tool-detection.zsh", "工具可用性检测和别名统一化", ["bat", "fd"], ["00-path-config"]),
        ("02-bat-config.zsh", "bat工具核心配置和基础功能", ["bat"], ["01-tool-detection"]),
        ("03-fd-config.zsh", "fd/fdfind工具配置和基础功能", ["fd"], ["01-tool-detection"]),
        ("04-fzf-core.zsh", "fzf核心配置和显示设置", ["fzf"], ["01-tool-detection"]),
        ("05-fzf-basic.zsh", "fzf基础功能（文件搜索、编辑等）", ["fzf", "bat"], ["04-fzf-core", "02-bat-config"]),
        ("06-fzf-advanced.zsh", "fzf高级功能（动态重载、模式切换等）", ["fzf", "bat", "fd"], ["05-fzf-basic", "03-fd-config"]),
        ("07-ripgrep-config.zsh", "ripgrep配置和基础集成", ["rg"], ["01-tool-detection"]),
        ("08-ripgrep-fzf.zsh", "ripgrep + fzf高级集成功能", ["rg", "fzf", "bat"], ["07-ripgrep-config", "05-fzf-basic"]),
        ("09-git-integration.zsh", "git + fzf + bat集成功能", ["git", "fzf", "bat"], ["05-fzf-basic"]),
        ("10-log-monitoring.zsh", "日志监控和tail集成功能", ["bat", "fzf"], ["02-bat-config", "04-fzf-core"]),
        ("11-man-integration.zsh", "man页面集成（修复batman搜索功能）", ["bat", "fzf"], ["02-bat-config", "04-fzf-core"]),
        ("12-apt-integration.zsh", "APT包管理集成功能", ["fzf", "bat"], ["04-fzf-core", "02-bat-config"]),
        ("13-utility-functions.zsh", "通用工具函数（search-all等）", ["bat", "fd", "rg"], ["02-bat-config", "03-fd-config", "07-ripgrep-config"]),
        ("99-aliases-summary.zsh", "最终别名汇总和show-tools功能", [], ["*"]),
    ]

    def __init__(self):
        self.tool_detector = get_tool_detector()
        self.file_manager = get_file_manager()
        self.basic_generators = ModuleGenerators()
        self.advanced_generators = AdvancedModuleGenerators()
        self.extended_generators = ExtendedModuleGenerators()

    def generate_all_configs(self) -> bool:
        """生成所有配置文件"""
        log_info("开始生成Shell工具模块化配置...")

        # 处理旧版配置文件
        if not self.file_manager.handle_legacy_config():
            log_error("处理旧版配置失败")
            return False

        # 创建目录结构
        if not self.file_manager.create_directories():
            return False

        # 生成主配置文件
        if not self._generate_main_config():
            return False

        # 生成各个模块
        success_count = 0
        total_count = len(self.MODULES_CONFIG)

        for module_file, description, required_tools, dependencies in self.MODULES_CONFIG:
            # 检查工具可用性
            if self.tool_detector.check_module_dependencies(required_tools):
                if self._generate_single_module(module_file, description, required_tools, dependencies):
                    success_count += 1
                else:
                    log_warn(f"模块 {module_file} 生成失败")
            else:
                missing_tools = self.tool_detector.get_missing_tools(required_tools)
                log_info(f"跳过模块 {module_file}（缺少必需工具: {', '.join(missing_tools)}）")

        # 生成调试模块
        if self._generate_debug_module():
            log_success("调试模块已生成")

        # 更新.zshrc文件
        if not self.file_manager.update_zshrc_for_modular_config():
            log_error(".zshrc文件更新失败")
            return False

        log_success(f"模块化配置生成完成！成功生成 {success_count}/{total_count} 个模块")
        return success_count > 0

    def _generate_main_config(self) -> bool:
        """生成主配置文件"""
        content = self.basic_generators.generate_main_config_content()
        return self.file_manager.write_main_config(content)

    def _generate_debug_module(self) -> bool:
        """生成调试模块"""
        content = self.basic_generators.generate_debug_module_content()
        return self.file_manager.write_debug_file(content)

    def _generate_single_module(self, module_file: str, description: str,
                               required_tools: List[str], dependencies: List[str]) -> bool:
        """生成单个模块文件"""
        try:
            # 根据模块名称生成对应的内容
            content = self._get_module_content(module_file)

            if content:
                return self.file_manager.write_module_file(
                    module_file, description, required_tools, dependencies, content
                )
            else:
                log_warn(f"未知模块类型: {module_file}")
                return False

        except Exception as e:
            log_error(f"生成模块 {module_file} 失败: {str(e)}")
            return False

    def _get_module_content(self, module_file: str) -> Optional[str]:
        """根据模块文件名获取对应的内容"""
        if module_file.startswith("00-path-config"):
            return self.basic_generators.generate_path_config_module()
        elif module_file.startswith("01-tool-detection"):
            return self.basic_generators.generate_tool_detection_module()
        elif module_file.startswith("02-bat-config"):
            return self.basic_generators.generate_bat_config_module()
        elif module_file.startswith("03-fd-config"):
            return self.basic_generators.generate_fd_config_module()
        elif module_file.startswith("04-fzf-core"):
            return self.advanced_generators.generate_fzf_core_module()
        elif module_file.startswith("11-man-integration"):
            return self.advanced_generators.generate_man_integration_module()
        elif module_file.startswith("12-apt-integration"):
            return self.advanced_generators.generate_apt_integration_module()
        # 实现的模块
        elif module_file.startswith("05-fzf-basic"):
            return self.basic_generators.generate_fzf_basic_module()
        elif module_file.startswith("06-fzf-advanced"):
            return self.basic_generators.generate_fzf_advanced_module()
        elif module_file.startswith("07-ripgrep-config"):
            return self.basic_generators.generate_ripgrep_config_module()
        elif module_file.startswith("08-ripgrep-fzf"):
            return self.basic_generators.generate_ripgrep_fzf_module()
        elif module_file.startswith("09-git-integration"):
            return self.extended_generators.generate_git_integration_module()
        elif module_file.startswith("13-utility-functions"):
            return self.extended_generators.generate_utility_functions_module()
        elif module_file.startswith("99-aliases-summary"):
            return self.extended_generators.generate_aliases_summary_module()
        # 对于未实现的模块，返回基本的占位符内容
        elif module_file.startswith("10-log-monitoring"):
            return self._generate_placeholder_module("日志监控", "此模块包含日志监控和tail集成功能")
        else:
            return None

    def _generate_placeholder_module(self, title: str, description: str) -> str:
        """生成占位符模块内容"""
        return f'''# {title}

# {description}
# 此模块正在开发中，将在后续版本中完善

echo "模块 {title} 已加载（占位符版本）"
'''

    def get_generation_summary(self) -> Dict[str, any]:
        """获取生成摘要信息"""
        stats = self.file_manager.get_file_stats()
        tool_summary = self.tool_detector.get_available_tools_summary()

        return {
            'file_stats': stats,
            'tool_summary': tool_summary,
            'modules_config': self.MODULES_CONFIG
        }


# 全局配置协调器实例
_config_coordinator = None

def get_config_coordinator() -> ConfigCoordinator:
    """获取全局配置协调器实例"""
    global _config_coordinator
    if _config_coordinator is None:
        _config_coordinator = ConfigCoordinator()
    return _config_coordinator
