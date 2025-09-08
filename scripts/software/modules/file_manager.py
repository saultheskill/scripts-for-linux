#!/usr/bin/env python3

"""
安全文件管理器模块
负责配置文件的创建、备份、更新、恢复等安全操作
版本: 2.0 - 增强安全性和备份机制
"""

import os
import sys
import shutil
import stat
import hashlib
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Dict, Tuple, Any

# 添加父目录到路径以导入common模块
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    from common import log_info, log_warn, log_error, log_success, log_debug
except ImportError:
    # 如果无法导入，提供简单的日志函数
    def log_info(msg): print(f"[INFO] {msg}")
    def log_warn(msg): print(f"[WARN] {msg}")
    def log_error(msg): print(f"[ERROR] {msg}")
    def log_success(msg): print(f"[SUCCESS] {msg}")
    def log_debug(msg): print(f"[DEBUG] {msg}")


class BackupManager:
    """备份管理器 - 处理文件和目录的安全备份与恢复"""

    def __init__(self):
        self.backup_root = Path.home() / ".shell-tools-backups"
        self.backup_root.mkdir(parents=True, exist_ok=True)
        self.backup_registry = self.backup_root / "backup_registry.txt"

    def create_backup(self, target_path: Path, backup_name: Optional[str] = None) -> Optional[Path]:
        """
        创建文件或目录的完整备份

        Args:
            target_path: 要备份的文件或目录路径
            backup_name: 自定义备份名称，如果为None则自动生成

        Returns:
            备份路径，如果失败返回None
        """
        if not target_path.exists():
            log_debug(f"目标路径不存在，跳过备份: {target_path}")
            return None

        try:
            # 生成备份名称
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            if backup_name:
                backup_filename = f"{backup_name}.backup.{timestamp}"
            else:
                backup_filename = f"{target_path.name}.backup.{timestamp}"

            backup_path = self.backup_root / backup_filename

            # 检查磁盘空间
            if not self._check_disk_space(target_path, backup_path.parent):
                log_error("磁盘空间不足，无法创建备份")
                return None

            # 执行备份
            if target_path.is_file():
                shutil.copy2(target_path, backup_path)
                log_info(f"文件备份完成: {target_path} -> {backup_path}")
            elif target_path.is_dir():
                shutil.copytree(target_path, backup_path, symlinks=True)
                log_info(f"目录备份完成: {target_path} -> {backup_path}")
            else:
                log_warn(f"不支持的文件类型: {target_path}")
                return None

            # 验证备份完整性
            if not self._verify_backup_integrity(target_path, backup_path):
                log_error("备份完整性验证失败")
                self._cleanup_failed_backup(backup_path)
                return None

            # 记录备份信息
            self._register_backup(target_path, backup_path)
            log_success(f"备份创建成功: {backup_path}")
            return backup_path

        except Exception as e:
            log_error(f"创建备份失败: {str(e)}")
            return None

    def restore_from_backup(self, backup_path: Path, target_path: Path) -> bool:
        """
        从备份恢复文件或目录

        Args:
            backup_path: 备份文件路径
            target_path: 恢复目标路径

        Returns:
            恢复是否成功
        """
        if not backup_path.exists():
            log_error(f"备份文件不存在: {backup_path}")
            return False

        try:
            # 如果目标存在，先创建临时备份
            temp_backup = None
            if target_path.exists():
                temp_backup = self.create_backup(target_path, f"temp_before_restore")
                if temp_backup is None:
                    log_error("无法创建临时备份，恢复操作中止")
                    return False

                # 安全删除目标
                self._safe_remove(target_path)

            # 执行恢复
            if backup_path.is_file():
                shutil.copy2(backup_path, target_path)
            elif backup_path.is_dir():
                shutil.copytree(backup_path, target_path, symlinks=True)
            else:
                log_error(f"不支持的备份类型: {backup_path}")
                return False

            log_success(f"从备份恢复成功: {backup_path} -> {target_path}")

            # 清理临时备份
            if temp_backup and temp_backup.exists():
                self._safe_remove(temp_backup)

            return True

        except Exception as e:
            log_error(f"从备份恢复失败: {str(e)}")
            # 如果恢复失败且有临时备份，尝试恢复原状态
            if temp_backup and temp_backup.exists():
                try:
                    if target_path.exists():
                        self._safe_remove(target_path)
                    shutil.move(str(temp_backup), str(target_path))
                    log_info("已恢复到操作前状态")
                except Exception as restore_error:
                    log_error(f"恢复原状态失败: {str(restore_error)}")
            return False

    def _check_disk_space(self, source_path: Path, backup_dir: Path) -> bool:
        """检查磁盘空间是否足够"""
        try:
            if source_path.is_file():
                required_space = source_path.stat().st_size
            else:
                required_space = sum(f.stat().st_size for f in source_path.rglob('*') if f.is_file())

            # 获取备份目录的可用空间
            statvfs = os.statvfs(backup_dir)
            available_space = statvfs.f_frsize * statvfs.f_bavail

            # 预留20%的缓冲空间
            return available_space > required_space * 1.2

        except Exception as e:
            log_warn(f"检查磁盘空间失败: {str(e)}")
            return True  # 如果检查失败，假设空间足够

    def _verify_backup_integrity(self, original_path: Path, backup_path: Path) -> bool:
        """验证备份完整性"""
        try:
            if original_path.is_file() and backup_path.is_file():
                return self._calculate_file_hash(original_path) == self._calculate_file_hash(backup_path)
            elif original_path.is_dir() and backup_path.is_dir():
                return self._compare_directory_structure(original_path, backup_path)
            return False
        except Exception as e:
            log_warn(f"备份完整性验证失败: {str(e)}")
            return False

    def _calculate_file_hash(self, file_path: Path) -> str:
        """计算文件的SHA256哈希值"""
        hash_sha256 = hashlib.sha256()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_sha256.update(chunk)
        return hash_sha256.hexdigest()

    def _compare_directory_structure(self, dir1: Path, dir2: Path) -> bool:
        """比较两个目录的结构和文件"""
        try:
            files1 = set(f.relative_to(dir1) for f in dir1.rglob('*') if f.is_file())
            files2 = set(f.relative_to(dir2) for f in dir2.rglob('*') if f.is_file())

            if files1 != files2:
                return False

            # 比较文件内容（采样检查）
            for rel_path in list(files1)[:10]:  # 只检查前10个文件以提高性能
                file1 = dir1 / rel_path
                file2 = dir2 / rel_path
                if self._calculate_file_hash(file1) != self._calculate_file_hash(file2):
                    return False

            return True
        except Exception:
            return False

    def _register_backup(self, original_path: Path, backup_path: Path) -> None:
        """注册备份信息到备份注册表"""
        try:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            with open(self.backup_registry, 'a', encoding='utf-8') as f:
                f.write(f"{timestamp}|{original_path}|{backup_path}\n")
        except Exception as e:
            log_warn(f"注册备份信息失败: {str(e)}")

    def _cleanup_failed_backup(self, backup_path: Path) -> None:
        """清理失败的备份"""
        try:
            if backup_path.exists():
                self._safe_remove(backup_path)
                log_info(f"已清理失败的备份: {backup_path}")
        except Exception as e:
            log_warn(f"清理失败备份时出错: {str(e)}")

    def _safe_remove(self, path: Path) -> bool:
        """安全删除文件或目录"""
        try:
            if path.is_file() or path.is_symlink():
                path.unlink()
            elif path.is_dir():
                shutil.rmtree(path)
            return True
        except Exception as e:
            log_error(f"删除失败 {path}: {str(e)}")
            return False

    def list_backups(self, original_path: Optional[Path] = None) -> List[Dict[str, Any]]:
        """列出备份信息"""
        backups = []
        if not self.backup_registry.exists():
            return backups

        try:
            with open(self.backup_registry, 'r', encoding='utf-8') as f:
                for line in f:
                    parts = line.strip().split('|')
                    if len(parts) == 3:
                        timestamp, orig_path, backup_path = parts
                        backup_info = {
                            'timestamp': timestamp,
                            'original_path': Path(orig_path),
                            'backup_path': Path(backup_path),
                            'exists': Path(backup_path).exists()
                        }

                        if original_path is None or Path(orig_path) == original_path:
                            backups.append(backup_info)

            return sorted(backups, key=lambda x: x['timestamp'], reverse=True)
        except Exception as e:
            log_warn(f"读取备份注册表失败: {str(e)}")
            return []

    def cleanup_old_backups(self, days_to_keep: int = 30) -> None:
        """清理旧备份文件"""
        try:
            cutoff_time = datetime.now().timestamp() - (days_to_keep * 24 * 3600)

            for backup_file in self.backup_root.glob("*.backup.*"):
                if backup_file.stat().st_mtime < cutoff_time:
                    self._safe_remove(backup_file)
                    log_info(f"已清理旧备份: {backup_file}")

        except Exception as e:
            log_warn(f"清理旧备份失败: {str(e)}")


class SafeFileManager:
    """安全文件管理器 - 集成备份功能的配置文件管理器"""

    def __init__(self):
        # 配置目录和文件路径
        self.custom_dir = Path.home() / ".oh-my-zsh" / "custom"
        self.modules_dir = self.custom_dir / "modules"
        self.debug_dir = self.custom_dir / "debug"
        self.main_config_file = self.custom_dir / "shell-tools-main.zsh"
        self.old_config_file = Path.home() / ".shell-tools-config.zsh"
        self.zshrc_file = Path.home() / ".zshrc"

        # 备份管理器
        self.backup_manager = BackupManager()

        # 操作历史记录
        self.operation_history = []

    def _validate_path_security(self, path: Path) -> bool:
        """验证路径安全性，防止路径遍历攻击"""
        try:
            # 解析绝对路径
            resolved_path = path.resolve()

            # 允许的安全路径前缀
            safe_prefixes = [
                Path.home().resolve(),  # 用户主目录
                Path("/tmp").resolve(),  # 临时目录（用于测试）
                Path("/var/tmp").resolve(),  # 系统临时目录
            ]

            # 检查路径是否在安全前缀下
            is_safe = any(
                str(resolved_path).startswith(str(prefix))
                for prefix in safe_prefixes
            )

            if not is_safe:
                log_error(f"路径安全检查失败: 路径不在允许的安全目录下 {resolved_path}")
                return False

            # 检查路径中是否包含危险的遍历模式
            path_str = str(path)
            dangerous_patterns = ['/../', '\\..\\', '..\\', '../']
            for pattern in dangerous_patterns:
                if pattern in path_str:
                    log_error(f"路径包含危险的遍历模式 '{pattern}': {path}")
                    return False

            # 检查其他潜在危险字符（仅警告）
            warning_patterns = ['~', '$']
            for pattern in warning_patterns:
                if pattern in path_str:
                    log_warn(f"路径包含潜在危险字符 '{pattern}': {path}")

            return True

        except Exception as e:
            log_error(f"路径安全验证失败: {str(e)}")
            return False

    def _check_write_permissions(self, path: Path) -> bool:
        """检查写权限"""
        try:
            # 检查父目录的写权限
            parent_dir = path.parent
            if parent_dir.exists():
                return os.access(parent_dir, os.W_OK)
            else:
                # 递归检查父目录
                return self._check_write_permissions(parent_dir)
        except Exception as e:
            log_error(f"检查写权限失败: {str(e)}")
            return False

    def safe_clear_target(self, target_path: Path, create_backup: bool = True) -> Optional[Path]:
        """
        安全清空目标文件或目录

        Args:
            target_path: 目标路径
            create_backup: 是否创建备份

        Returns:
            备份路径，如果没有创建备份或失败则返回None
        """
        if not self._validate_path_security(target_path):
            return None

        backup_path = None

        try:
            # 如果目标存在且需要备份
            if target_path.exists() and create_backup:
                backup_path = self.backup_manager.create_backup(target_path)
                if backup_path is None:
                    log_error("备份创建失败，操作中止")
                    return None
                log_info(f"备份已创建: {backup_path}")

            # 安全删除目标
            if target_path.exists():
                if not self.backup_manager._safe_remove(target_path):
                    log_error(f"清空目标失败: {target_path}")
                    return None
                log_info(f"目标已清空: {target_path}")

            # 记录操作历史
            self.operation_history.append({
                'action': 'clear_target',
                'target': target_path,
                'backup': backup_path,
                'timestamp': datetime.now()
            })

            return backup_path

        except Exception as e:
            log_error(f"安全清空目标失败: {str(e)}")
            return None

    def create_directories(self) -> bool:
        """安全创建必要的目录结构"""
        directories = [self.custom_dir, self.modules_dir, self.debug_dir]

        for directory in directories:
            if not self._validate_path_security(directory):
                return False

            if not self._check_write_permissions(directory):
                log_error(f"没有写权限: {directory}")
                return False

        try:
            for directory in directories:
                directory.mkdir(parents=True, exist_ok=True)
                log_debug(f"目录已创建: {directory}")

            log_info(f"目录结构创建完成: {self.custom_dir}")
            return True
        except Exception as e:
            log_error(f"创建目录失败: {str(e)}")
            return False

    def handle_legacy_config(self) -> bool:
        """安全处理旧版配置文件的迁移"""
        if not self.old_config_file.exists():
            return True

        log_warn(f"检测到旧版配置文件: {self.old_config_file}")
        log_info("新版本使用模块化配置，旧文件将被安全备份")

        try:
            # 使用备份管理器创建安全备份
            backup_path = self.backup_manager.create_backup(
                self.old_config_file,
                "legacy_config"
            )

            if backup_path:
                # 备份成功后删除原文件
                self.backup_manager._safe_remove(self.old_config_file)
                log_success(f"旧配置文件已安全迁移，备份位置: {backup_path}")

                # 记录操作历史
                self.operation_history.append({
                    'action': 'migrate_legacy_config',
                    'original': self.old_config_file,
                    'backup': backup_path,
                    'timestamp': datetime.now()
                })
            else:
                log_error("旧配置文件备份失败，保留原文件")
                return False

        except Exception as e:
            log_error(f"处理旧版配置文件失败: {str(e)}")
            return False

        return True

    def safe_write_file(self, file_path: Path, content: str, create_backup: bool = True) -> bool:
        """
        安全写入文件内容

        Args:
            file_path: 目标文件路径
            content: 文件内容
            create_backup: 是否在写入前创建备份

        Returns:
            写入是否成功
        """
        if not self._validate_path_security(file_path):
            return False

        if not self._check_write_permissions(file_path):
            log_error(f"没有写权限: {file_path}")
            return False

        backup_path = None

        try:
            # 如果文件存在且需要备份
            if file_path.exists() and create_backup:
                backup_path = self.backup_manager.create_backup(file_path)
                if backup_path is None:
                    log_error("备份创建失败，写入操作中止")
                    return False

            # 写入文件
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)

            # 验证写入结果
            if not file_path.exists():
                log_error(f"文件写入后不存在: {file_path}")
                return False

            # 记录操作历史
            self.operation_history.append({
                'action': 'write_file',
                'target': file_path,
                'backup': backup_path,
                'timestamp': datetime.now()
            })

            log_debug(f"文件写入成功: {file_path}")
            return True

        except Exception as e:
            log_error(f"写入文件 {file_path} 失败: {str(e)}")

            # 如果有备份，尝试恢复
            if backup_path and backup_path.exists():
                try:
                    self.backup_manager.restore_from_backup(backup_path, file_path)
                    log_info("已从备份恢复原文件")
                except Exception as restore_error:
                    log_error(f"恢复备份失败: {str(restore_error)}")

            return False

    def write_file(self, file_path: Path, content: str) -> bool:
        """兼容性方法 - 调用安全写入方法"""
        return self.safe_write_file(file_path, content, create_backup=True)

    def write_module_file(self, module_file: str, description: str,
                         required_tools: List[str], dependencies: List[str],
                         content: str) -> bool:
        """安全写入模块文件"""
        module_path = self.modules_dir / module_file

        # 添加模块头部信息
        header = f'''# =============================================================================
# {description}
# 模块文件: {module_file}
# 依赖工具: {', '.join(required_tools) if required_tools else '无'}
# 依赖模块: {', '.join(dependencies) if dependencies else '无'}
# 由 shell-tools-config-generator.py v2.1 自动生成 (安全版本)
# 生成时间: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
# =============================================================================

'''

        full_content = header + content

        if self.safe_write_file(module_path, full_content):
            log_success(f"模块已安全生成: {module_file}")
            return True
        else:
            log_error(f"生成模块 {module_file} 失败")
            return False

    def write_debug_file(self, content: str) -> bool:
        """安全写入调试文件"""
        debug_path = self.debug_dir / "shell-tools-debug.zsh"

        if self.safe_write_file(debug_path, content):
            log_success("调试模块已安全生成")
            return True
        else:
            log_error("生成调试模块失败")
            return False

    def write_main_config(self, content: str) -> bool:
        """安全写入主配置文件"""
        if self.safe_write_file(self.main_config_file, content):
            log_success(f"主配置文件已安全生成: {self.main_config_file}")
            return True
        else:
            log_error("生成主配置文件失败")
            return False

    def update_zshrc_for_modular_config(self) -> bool:
        """安全更新.zshrc文件以使用模块化配置"""
        # 新的配置行
        new_config_lines = [
            "# Shell Tools Modular Configuration - Auto-generated by shell-tools-config-generator.py v2.1 (安全版本)",
            "[[ -f ~/.oh-my-zsh/custom/shell-tools-main.zsh ]] && source ~/.oh-my-zsh/custom/shell-tools-main.zsh"
        ]

        if not self.zshrc_file.exists():
            log_warn(".zshrc文件不存在，创建新文件")
            content = '\n'.join(new_config_lines) + '\n'
            return self.safe_write_file(self.zshrc_file, content, create_backup=False)

        try:
            # 创建备份
            backup_path = self.backup_manager.create_backup(self.zshrc_file, "zshrc_before_update")
            if backup_path is None:
                log_error(".zshrc备份失败，更新操作中止")
                return False

            # 读取现有内容
            with open(self.zshrc_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            # 检查是否已经有新的配置
            has_new_config = any(new_config_lines[1] in line for line in lines)

            if not has_new_config:
                # 添加新的配置行
                lines.extend([line + '\n' for line in new_config_lines])

                # 安全写入更新后的内容
                updated_content = ''.join(lines)
                if self.safe_write_file(self.zshrc_file, updated_content, create_backup=False):
                    log_success("已安全更新.zshrc文件以使用模块化配置")

                    # 记录操作历史
                    self.operation_history.append({
                        'action': 'update_zshrc',
                        'target': self.zshrc_file,
                        'backup': backup_path,
                        'timestamp': datetime.now()
                    })
                    return True
                else:
                    # 更新失败，恢复备份
                    log_error(".zshrc更新失败，正在恢复备份...")
                    self.backup_manager.restore_from_backup(backup_path, self.zshrc_file)
                    return False
            else:
                log_info("Shell工具模块化配置引用已存在于.zshrc中")
                return True

        except Exception as e:
            log_error(f"更新.zshrc文件失败: {str(e)}")
            return False

    def get_file_stats(self) -> dict:
        """获取文件统计信息"""
        stats = {
            'main_config_exists': self.main_config_file.exists(),
            'modules_count': len(list(self.modules_dir.glob('*.zsh'))) if self.modules_dir.exists() else 0,
            'debug_exists': (self.debug_dir / "shell-tools-debug.zsh").exists(),
            'old_config_exists': self.old_config_file.exists(),
            'zshrc_exists': self.zshrc_file.exists(),
            'backup_count': len(self.backup_manager.list_backups())
        }
        return stats

    def rollback_operation(self, operation_index: int = -1) -> bool:
        """
        回滚指定的操作

        Args:
            operation_index: 操作索引，-1表示最后一个操作

        Returns:
            回滚是否成功
        """
        if not self.operation_history:
            log_warn("没有可回滚的操作")
            return False

        try:
            operation = self.operation_history[operation_index]
            backup_path = operation.get('backup')
            target_path = operation.get('target')

            if not backup_path or not target_path:
                log_error("操作记录不完整，无法回滚")
                return False

            if not backup_path.exists():
                log_error(f"备份文件不存在: {backup_path}")
                return False

            # 执行回滚
            if self.backup_manager.restore_from_backup(backup_path, target_path):
                log_success(f"操作已回滚: {operation['action']} -> {target_path}")

                # 从历史记录中移除已回滚的操作
                self.operation_history.pop(operation_index)
                return True
            else:
                log_error("回滚操作失败")
                return False

        except (IndexError, KeyError) as e:
            log_error(f"回滚操作失败: {str(e)}")
            return False

    def get_operation_history(self) -> List[Dict[str, Any]]:
        """获取操作历史记录"""
        return self.operation_history.copy()

    def cleanup_backups(self, days_to_keep: int = 30) -> None:
        """清理旧备份"""
        self.backup_manager.cleanup_old_backups(days_to_keep)

    def get_backup_info(self) -> Dict[str, Any]:
        """获取备份信息摘要"""
        all_backups = self.backup_manager.list_backups()

        return {
            'total_backups': len(all_backups),
            'backup_directory': str(self.backup_manager.backup_root),
            'recent_backups': all_backups[:5],  # 最近5个备份
            'disk_usage': self._calculate_backup_disk_usage()
        }

    def _calculate_backup_disk_usage(self) -> str:
        """计算备份目录的磁盘使用量"""
        try:
            total_size = 0
            for backup_file in self.backup_manager.backup_root.rglob('*'):
                if backup_file.is_file():
                    total_size += backup_file.stat().st_size

            # 转换为人类可读格式
            for unit in ['B', 'KB', 'MB', 'GB']:
                if total_size < 1024.0:
                    return f"{total_size:.1f} {unit}"
                total_size /= 1024.0
            return f"{total_size:.1f} TB"

        except Exception as e:
            log_warn(f"计算备份磁盘使用量失败: {str(e)}")
            return "未知"


# 为了向后兼容，保留原来的FileManager类名
FileManager = SafeFileManager

# 全局文件管理器实例
_file_manager = None

def get_file_manager() -> SafeFileManager:
    """获取全局安全文件管理器实例"""
    global _file_manager
    if _file_manager is None:
        _file_manager = SafeFileManager()
    return _file_manager
