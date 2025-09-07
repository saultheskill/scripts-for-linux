#!/usr/bin/env python3

"""
Shell工具配置生成器模块包
基于模板的配置生成系统
"""

from .tool_detector import get_tool_detector, ToolDetector
from .file_manager import get_file_manager, FileManager
from .template_coordinator import get_template_coordinator, TemplateCoordinator

__all__ = [
    'get_tool_detector',
    'ToolDetector',
    'get_file_manager',
    'FileManager',
    'get_template_coordinator',
    'TemplateCoordinator'
]

__version__ = "2.1.0"
__author__ = "saul"
__description__ = "基于模板的Shell工具配置生成器"
