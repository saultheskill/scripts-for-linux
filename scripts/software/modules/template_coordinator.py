#!/usr/bin/env python3

"""
基于模板的配置协调器
使用静态模板文件生成shell配置，替代复杂的字符串生成逻辑
"""

import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

# 尝试导入yaml，如果失败则安装
try:
    import yaml
except ImportError:
    print("[WARN] PyYAML未安装，尝试安装...")
    try:
        import subprocess
        import os

        # 尝试使用apt安装
        result = subprocess.run(['apt', 'install', '-y', 'python3-yaml'],
                              capture_output=True, text=True, timeout=60)
        if result.returncode == 0:
            import yaml
            print("[SUCCESS] PyYAML安装成功")
        else:
            # 如果apt失败，尝试pip
            result = subprocess.run([sys.executable, '-m', 'pip', 'install', 'PyYAML'],
                                  capture_output=True, text=True, timeout=60)
            if result.returncode == 0:
                import yaml
                print("[SUCCESS] PyYAML通过pip安装成功")
            else:
                raise ImportError("无法安装PyYAML")
    except Exception as e:
        print(f"[ERROR] 无法安装PyYAML: {e}")
        # 提供一个简单的YAML解析器作为fallback
        class SimpleYAML:
            @staticmethod
            def safe_load(content):
                # 这是一个非常简单的YAML解析器，仅用于紧急情况
                return {"modules": [], "config": {}}
        yaml = SimpleYAML()

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


class TemplateCoordinator:
    """基于模板的配置生成协调器"""

    def __init__(self):
        self.tool_detector = get_tool_detector()
        self.file_manager = get_file_manager()
        self.script_dir = Path(__file__).parent.parent
        self.templates_dir = self.script_dir / "templates"
        self.modules_config = self._load_modules_config()

    def _load_modules_config(self) -> Dict:
        """加载模块配置文件"""
        config_file = self.templates_dir / "modules.yaml"

        if not config_file.exists():
            log_error(f"模块配置文件不存在: {config_file}")
            return {"modules": [], "config": {}}

        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                config = yaml.safe_load(f)
            log_info(f"已加载模块配置: {len(config.get('modules', []))} 个模块")
            return config
        except Exception as e:
            log_error(f"加载模块配置失败: {str(e)}")
            return {"modules": [], "config": {}}

    def generate_all_configs(self) -> bool:
        """生成所有配置文件"""
        log_info("开始生成Shell工具模块化配置（基于模板）...")

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
        total_count = len(self.modules_config.get("modules", []))

        for module_info in self.modules_config.get("modules", []):
            module_name = module_info["name"]
            description = module_info["description"]
            required_tools = module_info.get("required_tools", [])
            dependencies = module_info.get("dependencies", [])
            template_file = module_info.get("template_file", module_name)

            # 检查工具可用性
            if self.tool_detector.check_module_dependencies(required_tools):
                if self._generate_module_from_template(
                    module_name, description, required_tools,
                    dependencies, template_file
                ):
                    success_count += 1
                else:
                    log_warn(f"模块 {module_name} 生成失败")
            else:
                missing_tools = self.tool_detector.get_missing_tools(required_tools)
                log_info(f"跳过模块 {module_name}（缺少必需工具: {', '.join(missing_tools)}）")

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
        """
        从模板文件生成主配置文件
        使用模板文件方式替代硬编码，提高可维护性和架构一致性
        """
        template_path = self.templates_dir / "shell-tools-main.zsh"

        if not template_path.exists():
            log_error(f"主配置模板文件不存在: {template_path}")
            return False

        try:
            # 读取模板内容
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()

            # 准备变量替换
            variables = {
                "{{GENERATOR_VERSION}}": "shell-tools-config-generator.py v2.1",
                "{{GENERATION_TIME}}": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "{{MODULES_DIR}}": "$HOME/.oh-my-zsh/custom/modules",
            }

            # 执行变量替换
            config_content = template_content
            for placeholder, value in variables.items():
                config_content = config_content.replace(placeholder, value)

            # 写入配置文件
            return self.file_manager.write_main_config(config_content)

        except Exception as e:
            log_error(f"从模板生成主配置失败: {str(e)}")
            return False

    def _generate_module_from_template(self, module_name: str, description: str,
                                     required_tools: List[str], dependencies: List[str],
                                     template_file: str) -> bool:
        """从模板文件生成模块"""
        template_path = self.templates_dir / template_file

        if not template_path.exists():
            log_error(f"模板文件不存在: {template_path}")
            return False

        try:
            # 读取模板内容
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()

            # 生成模块文件
            return self.file_manager.write_module_file(
                module_name, description, required_tools,
                dependencies, template_content
            )

        except Exception as e:
            log_error(f"从模板生成模块 {module_name} 失败: {str(e)}")
            return False

    def _generate_debug_module(self) -> bool:
        """生成调试模块"""
        debug_content = '''# =============================================================================
# Shell Tools Debug Module - 调试和诊断功能
# =============================================================================

# 增强的调试函数：检查工具安装状态和模块加载情况
shell-tools-debug() {
    echo "=== Shell Tools Debug Information ==="
    echo "版本: 2.1 (模块化重构版 - 基于模板)"
    echo "配置目录: $HOME/.oh-my-zsh/custom/"
    echo

    echo "PATH配置:"
    echo "  PATH: $PATH"
    echo

    echo "工具检测:"
    echo "  bat: $(command -v bat 2>/dev/null || echo 'not found')"
    echo "  batcat: $(command -v batcat 2>/dev/null || echo 'not found')"
    echo "  fd: $(command -v fd 2>/dev/null || echo 'not found')"
    echo "  fdfind: $(command -v fdfind 2>/dev/null || echo 'not found')"
    echo "  fzf: $(command -v fzf 2>/dev/null || echo 'not found')"
    echo "  rg: $(command -v rg 2>/dev/null || echo 'not found')"
    echo "  git: $(command -v git 2>/dev/null || echo 'not found')"
    echo

    echo "别名状态:"
    alias | grep -E '^(bat|fd)=' || echo "  无相关别名"
    echo

    echo "模块加载状态:"
    if [[ -n "${!SHELL_TOOLS_MODULES_LOADED[@]}" ]]; then
        for module in "${!SHELL_TOOLS_MODULES_LOADED[@]}"; do
            echo "  ✓ $module"
        done
    else
        echo "  无已加载模块"
    fi

    if [[ -n "${!SHELL_TOOLS_MODULES_FAILED[@]}" ]]; then
        echo
        echo "模块加载失败:"
        for module in "${!SHELL_TOOLS_MODULES_FAILED[@]}"; do
            echo "  ✗ $module"
        done
    fi

    echo
    echo "配置文件状态:"
    local modules_dir="$HOME/.oh-my-zsh/custom/modules"
    if [[ -d "$modules_dir" ]]; then
        echo "  模块目录: $modules_dir"
        local module_count=$(ls -1 "$modules_dir"/*.zsh 2>/dev/null | wc -l)
        echo "  模块文件数量: $module_count"
    else
        echo "  ⚠️  模块目录不存在"
    fi

    echo "=========================="
}

# 模块重新加载函数
shell-tools-reload() {
    echo "重新加载 Shell Tools 模块..."

    # 清除加载状态
    unset SHELL_TOOLS_MODULES_LOADED
    unset SHELL_TOOLS_MODULES_FAILED
    unset SHELL_TOOLS_MAIN_LOADED

    # 重新加载主配置
    local main_config="$HOME/.oh-my-zsh/custom/shell-tools-main.zsh"
    if [[ -f "$main_config" ]]; then
        source "$main_config"
        echo "✓ 重新加载完成"
    else
        echo "✗ 主配置文件不存在: $main_config"
    fi
}

# 模块状态检查函数
shell-tools-status() {
    local loaded_count=${#SHELL_TOOLS_MODULES_LOADED[@]}
    local failed_count=${#SHELL_TOOLS_MODULES_FAILED[@]}

    echo "Shell Tools 状态:"
    echo "  已加载模块: $loaded_count"
    echo "  失败模块: $failed_count"

    if [[ $failed_count -gt 0 ]]; then
        echo "  建议运行 'shell-tools-debug' 查看详细信息"
    fi
}
'''
        return self.file_manager.write_debug_file(debug_content)

    def get_generation_summary(self) -> Dict[str, any]:
        """获取生成摘要信息"""
        stats = self.file_manager.get_file_stats()
        tool_summary = self.tool_detector.get_available_tools_summary()

        return {
            'file_stats': stats,
            'tool_summary': tool_summary,
            'modules_config': self.modules_config.get("modules", []),
            'template_based': True
        }


# 全局模板协调器实例
_template_coordinator = None

def get_template_coordinator() -> TemplateCoordinator:
    """获取全局模板协调器实例"""
    global _template_coordinator
    if _template_coordinator is None:
        _template_coordinator = TemplateCoordinator()
    return _template_coordinator
