# 测试环境文档

## 测试服务器信息

| 项目 | 详情 |
|------|------|
| **IP 地址** | 192.168.2.153 |
| **用户名** | root |
| **连接方式** | SSH 密钥登录 |
| **操作系统** | Ubuntu 24.04 LTS (Noble Numbat) |
| **内核版本** | 6.17.4-2-pve |
| **架构** | x86_64 |

## 项目部署路径

```
/root/scripts-for-linux/
├── install.sh              # 主安装脚本
├── scripts/                # 核心脚本目录
│   ├── common.sh          # 通用函数库
│   ├── shell/             # ZSH 环境脚本
│   ├── containers/        # Docker 相关
│   ├── development/       # 开发工具
│   ├── security/          # 安全配置
│   ├── system/            # 系统配置
│   └── utilities/         # 实用工具
├── bash-scripts/          # 高级独立工具
└── themes/                # 主题配置
```

## 快速连接命令

```bash
# SSH 连接到测试环境
ssh root@192.168.2.153

# 进入项目目录
cd /root/scripts-for-linux

# 运行安装脚本
bash install.sh
```

## 测试检查清单

### 基础功能测试
- [ ] 脚本语法检查通过 (`bash -n install.sh`)
- [ ] 主菜单正常显示
- [ ] 键盘导航菜单正常工作
- [ ] 系统要求检查通过

### 模块测试
- [ ] 常用软件安装
- [ ] 系统配置（时间同步）
- [ ] ZSH 环境安装（核心 + 插件）
- [ ] Docker 环境安装
- [ ] 开发工具（Neovim）
- [ ] 安全配置（SSH）

### 错误处理测试
- [ ] 脚本执行失败时正确返回错误码
- [ ] 用户取消（Ctrl+C）处理正常
- [ ] 网络连接失败提示正确

## 日志查看

```bash
# 查看脚本执行日志（如果配置了日志文件）
tail -f /var/log/scripts-for-linux.log

# 查看系统日志
journalctl -xe
```

## 注意事项

1. **root 用户**：测试环境使用 root 用户，无需 sudo
2. **网络访问**：测试服务器可以访问外网（GitHub、apt 源等）
3. **快照恢复**：测试前建议创建 Proxmox 快照以便快速恢复
4. **清理**：测试完成后可运行 `bash uninstall.sh` 清理安装

## 已知问题与修复

### 问题 1：`常用软件安装` 模块执行时跳出

**现象**：选择"常用软件安装"后，脚本直接退出，没有执行安装。

**原因**：`common-software-install.sh` 脚本在被 `install.sh` 调用时，会再次显示确认对话框，但子 shell 中的交互式 `read` 命令在特定环境下会失败。

**修复方案**：修改 `scripts/software/common-software-install.sh`，使其在被其他脚本调用时跳过确认对话框，直接执行安装：

```bash
# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
else
    # 被其他脚本调用时，直接执行安装（跳过确认）
    install_common_software
fi
```

## 最近更新

- 修复了 `execute_local_script` 返回值问题
- 修复了 ARM 架构分支的 `install_success` 状态检查
- 修复了 `common-software-install.sh` 被调用时的重复确认问题
- 创建了 CLAUDE.md 开发文档
