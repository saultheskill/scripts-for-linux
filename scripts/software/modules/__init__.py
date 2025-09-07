#!/usr/bin/env python3

"""
Shell工具配置生成器模块包
提供模块化的配置生成功能
"""

from .tool_detector import get_tool_detector, ToolDetector
from .file_manager import get_file_manager, FileManager
from .module_generators import ModuleGenerators
from .advanced_modules import AdvancedModuleGenerators
from .extended_modules import ExtendedModuleGenerators
from .config_coordinator import get_config_coordinator, ConfigCoordinator
from .template_coordinator import get_template_coordinator, TemplateCoordinator

__all__ = [
    'get_tool_detector',
    'ToolDetector',
    'get_file_manager',
    'FileManager',
    'ModuleGenerators',
    'AdvancedModuleGenerators',
    'ExtendedModuleGenerators',
    'get_config_coordinator',
    'ConfigCoordinator',
    'get_template_coordinator',
    'TemplateCoordinator'
]

__version__ = "2.1.0"
__author__ = "saul"
__description__ = "模块化Shell工具配置生成器"
