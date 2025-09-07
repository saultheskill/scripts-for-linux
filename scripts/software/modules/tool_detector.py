#!/usr/bin/env python3

"""
工具检测器模块
负责检测系统中可用的工具和管理依赖关系
"""

import subprocess
from typing import List, Dict, Set
from pathlib import Path


class ToolDetector:
    """工具可用性检测和依赖管理"""
    
    def __init__(self):
        self.available_tools: Set[str] = set()
        self.tool_aliases: Dict[str, str] = {}
        self._detect_all_tools()
    
    def _detect_all_tools(self):
        """检测所有相关工具的可用性"""
        tools_to_check = [
            'bat', 'batcat', 'fd', 'fdfind', 'fzf', 'rg', 'git', 
            'tmux', 'curl', 'tldr', 'tree', 'apt-cache', 'xargs'
        ]
        
        for tool in tools_to_check:
            if self.check_tool_availability(tool):
                self.available_tools.add(tool)
        
        # 设置工具别名映射
        self._setup_tool_aliases()
    
    def check_tool_availability(self, tool: str) -> bool:
        """检查单个工具是否可用"""
        try:
            subprocess.run([tool, "--version"], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            # 特殊处理一些工具
            if tool == "bat" and "batcat" in self.available_tools:
                return True
            elif tool == "fd" and "fdfind" in self.available_tools:
                return True
            return False
    
    def _setup_tool_aliases(self):
        """设置工具别名映射"""
        # bat/batcat 别名处理
        if "batcat" in self.available_tools:
            self.tool_aliases["bat"] = "batcat"
            self.available_tools.add("bat")
        
        # fd/fdfind 别名处理
        if "fdfind" in self.available_tools:
            self.tool_aliases["fd"] = "fdfind"
            self.available_tools.add("fd")
    
    def is_tool_available(self, tool: str) -> bool:
        """检查工具是否可用（考虑别名）"""
        return tool in self.available_tools
    
    def get_tool_command(self, tool: str) -> str:
        """获取工具的实际命令（考虑别名）"""
        return self.tool_aliases.get(tool, tool)
    
    def check_module_dependencies(self, required_tools: List[str]) -> bool:
        """检查模块的工具依赖是否满足"""
        if not required_tools:
            return True
        return all(self.is_tool_available(tool) for tool in required_tools)
    
    def get_missing_tools(self, required_tools: List[str]) -> List[str]:
        """获取缺失的工具列表"""
        return [tool for tool in required_tools if not self.is_tool_available(tool)]
    
    def get_available_tools_summary(self) -> Dict[str, str]:
        """获取可用工具的摘要信息"""
        summary = {}
        
        # 核心工具
        core_tools = ['bat', 'fd', 'fzf', 'rg', 'git']
        for tool in core_tools:
            if self.is_tool_available(tool):
                actual_cmd = self.get_tool_command(tool)
                if actual_cmd != tool:
                    summary[tool] = f"alias {tool}={actual_cmd}"
                else:
                    try:
                        result = subprocess.run([tool, "--version"], 
                                              capture_output=True, text=True)
                        if result.returncode == 0:
                            version_line = result.stdout.split('\n')[0]
                            summary[tool] = version_line
                        else:
                            summary[tool] = "available"
                    except:
                        summary[tool] = "available"
            else:
                summary[tool] = "not found"
        
        return summary
    
    def get_installation_suggestions(self, missing_tools: List[str]) -> Dict[str, str]:
        """获取缺失工具的安装建议"""
        suggestions = {
            'bat': 'sudo apt install bat',
            'fd': 'sudo apt install fd-find',
            'fzf': 'sudo apt install fzf',
            'rg': 'sudo apt install ripgrep',
            'git': 'sudo apt install git',
            'tmux': 'sudo apt install tmux',
            'curl': 'sudo apt install curl',
            'tldr': 'sudo apt install tldr',
            'tree': 'sudo apt install tree'
        }
        
        return {tool: suggestions.get(tool, f'请手动安装 {tool}') 
                for tool in missing_tools if tool in suggestions}


# 全局工具检测器实例
_tool_detector = None

def get_tool_detector() -> ToolDetector:
    """获取全局工具检测器实例"""
    global _tool_detector
    if _tool_detector is None:
        _tool_detector = ToolDetector()
    return _tool_detector
