# 🐧 Ubuntu/Debian 服务器初始化脚本库

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Ubuntu%2020--24%20%7C%20Debian%2010--12-orange.svg)
![Architecture](https://img.shields.io/badge/arch-x64%20%7C%20ARM64-green.svg)
![Shell](https://img.shields.io/badge/shell-bash-lightgrey.svg)

**一键初始化 Ubuntu/Debian 服务器，打造高效开发环境**

[📖 功能特性](#-功能特性) • [🚀 快速开始](#-快速开始) • [📁 项目结构](#-项目结构) • [🔧 使用指南](#-使用指南)

</div>

---

## 📖 功能特性

<table>
<tr>
<td width="50%">

### 🐚 Shell 环境
- **ZSH** + Oh My Zsh 一键安装
- **模块化设计**：核心与插件分离安装
- **Powerlevel10k** 主题（Dracula/Rainbow/Emoji 三种风格）
- **ARM64 专项优化**版本
- 预装 15+ 实用插件（自动补全、语法高亮、zoxide 等）

</td>
<td width="50%">

### 🎨 美化工具集
- **[eza](https://github.com/eza-community/eza)** - 现代化的 `ls` 替代品
- **[fzf](https://github.com/junegunn/fzf)** (v0.67.0) - 模糊查找神器
- **[bat](https://github.com/sharkdp/bat)** - 带语法高亮的 `cat`
- **[tmuxinator](https://github.com/tmuxinator/tmuxinator)** - Tmux 会话管理
- **[Oh My Tmux](https://github.com/gpakosz/.tmux)** - 专业级 Tmux 配置

</td>
</tr>
<tr>
<td width="50%">

### 🐳 容器化工具
- **Docker** + Docker Compose 一键安装
- **国内镜像源**自动配置
- **LazyDocker** TUI 管理工具
- **镜像推送工具**（支持 Docker Hub / Harbor）
- **Harbor 私有仓库**集成支持

</td>
<td width="50%">

### 🛠️ 开发环境
- **Neovim** + 多种配置方案：
  - LazyVim - 高效轻量
  - AstroNvim - 功能丰富
- **LazyGit** 集成
- **常用开发工具**链

</td>
</tr>
</table>

### 🔐 系统与安全
- **SSH** 安全配置与密钥管理
- **NTP** 时间同步
- **软件源**镜像自动切换
- **磁盘格式化**工具

---

## 🚀 快速开始

### 方式一：一键安装（推荐）

```bash
# 克隆仓库
git clone git@github.com:saultheskill/scripts-for-linux.git
cd scripts-for-linux

# 运行交互式安装向导
bash install.sh
```

### 方式二：分模块安装

```bash
# 1. ZSH 核心环境（必须先安装）
bash scripts/shell/zsh-core-install.sh

# 2. ZSH 插件和工具
bash scripts/shell/zsh-plugins-install.sh

# 3. 美化工具（eza, fzf, bat, tmuxinator）
bash scripts/beautify/beautify-install.sh

# 4. Docker 环境
bash scripts/containers/docker-install.sh
```

---

## 📁 项目结构

```
scripts-for-linux/
├── install.sh                      # 主安装程序（交互式菜单）
├── uninstall.sh                    # 卸载脚本
├── CLAUDE.md                       # AI 助手开发指南
│
├── scripts/
│   ├── common.sh                   # 公共函数库（日志、UI、包管理）
│   │
│   ├── shell/                      # ZSH 环境配置
│   │   ├── zsh-core-install.sh     # ZSH + Oh My Zsh + 主题
│   │   ├── zsh-plugins-install.sh  # 插件、tmux、zoxide 等
│   │   └── zsh-arm.sh              # ARM 设备专用版本
│   │
│   ├── beautify/                   # 终端美化工具
│   │   └── beautify-install.sh     # eza, fzf, bat, tmuxinator
│   │
│   ├── containers/                 # 容器化工具
│   │   ├── docker-install.sh       # Docker 安装
│   │   ├── docker-image-manager.sh # 镜像管理
│   │   └── harbor-push.sh          # Harbor 推送
│   │
│   ├── development/                # 开发工具
│   │   └── nvim-setup.sh           # Neovim 配置
│   │
│   ├── security/                   # 安全配置
│   │   ├── ssh-config.sh           # SSH 服务器配置
│   │   └── ssh-keygen.sh           # 密钥生成
│   │
│   ├── system/                     # 系统配置
│   ├── software/                   # 常用软件
│   └── utilities/                  # 实用工具
│
├── tmuxinator/                     # Tmux 项目模板
│   ├── basic.yml                   # 基础模板
│   ├── docker-dev.yml              # Docker 开发环境
│   ├── kubernetes.yml              # K8s 管理
│   ├── monitoring.yml              # 监控面板
│   └── web-dev.yml                 # Web 开发
│
├── themes/                         # ZSH 主题配置
│   └── powerlevel10k/
│       ├── dracula.zsh
│       ├── rainbow.zsh
│       └── emoji.zsh
│
└── bash-scripts/                   # 独立高级工具
    ├── docker-push-auto.sh
    ├── harbor-push-auto.sh
    └── ssh-agent-auto.sh
```

---

## 🔧 使用指南

### ZSH 环境配置

ZSH 安装分为两个独立模块，确保灵活性和兼容性：

```bash
# 第一步：安装核心（必须先执行）
# - ZSH shell
# - Oh My Zsh
# - Powerlevel10k 主题
bash scripts/shell/zsh-core-install.sh

# 第二步：安装插件和工具
# - 15+ ZSH 插件（autosuggestions, syntax-highlighting, zoxide...）
# - Tmux + Oh My Tmux + tmux-resurrect/continuum
# - zoxide（智能目录跳转）
# - ssh-agent 插件
bash scripts/shell/zsh-plugins-install.sh

# ARM 设备专用版本（OpenWrt、树莓派等）
bash scripts/shell/zsh-arm.sh
```

**安装后快捷键：**
- `Alt + C` - fzf 目录跳转
- `Ctrl + T` - fzf 文件选择
- `Ctrl + R` - fzf 历史命令搜索
- `z <关键词>` - zoxide 智能跳转

### Tmux 会话管理

```bash
# 使用 tmuxinator 启动预设项目
tmuxinator start docker-dev    # Docker 开发环境
tmuxinator start kubernetes    # K8s 集群管理
tmuxinator start monitoring    # 监控面板
tmuxinator start web-dev       # Web 开发环境
tmuxinator start basic         # 基础三窗格

# 查看 tmux 快捷键帮助
bash scripts/shell/zsh-plugins-install.sh --tmux-help
```

### Docker 环境

```bash
# 安装 Docker + Compose + LazyDocker
bash scripts/containers/docker-install.sh

# 启动 LazyDocker TUI 管理工具
lazydocker

# 使用镜像推送工具
bash bash-scripts/docker-push-auto.sh
bash bash-scripts/harbor-push-auto.sh
```

### Neovim 配置

```bash
# 安装 Neovim + LazyVim/AstroNvim
bash scripts/development/nvim-setup.sh

# 启动 nvim 后自动下载安装插件
nvim
```

---

## 💻 系统要求

| 项目 | 要求 |
|------|------|
| **操作系统** | Ubuntu 20.04+ / Debian 10+ |
| **架构** | x86_64 (AMD64)、ARM64、ARMv7 |
| **内存** | 建议 2GB+ |
| **存储** | 至少 1GB 可用空间 |
| **权限** | 需要 sudo 权限 |
| **网络** | 需要互联网连接 |

---

## ⚙️ 配置说明

### Tmux 会话持久化

安装后自动启用以下插件：
- **tmux-resurrect** - 保存和恢复会话
- **tmux-continuum** - 自动保存（每 15 分钟）

```bash
# 手动保存会话
Ctrl+b + Ctrl+s

# 手动恢复会话
Ctrl+b + Ctrl+r
```

### 主题切换

```bash
# 重新配置 Powerlevel10k 主题
p10k configure

# 切换预设主题（Dracula/Rainbow/Emoji）
cp themes/powerlevel10k/dracula.zsh ~/.p10k.zsh && source ~/.zshrc
```

---

## 🐛 故障排除

### ZSH 相关问题

```bash
# 完全重置 ZSH
rm -rf ~/.oh-my-zsh ~/.zshrc ~/.p10k.zsh
# 然后重新运行安装脚本

# 修复权限
chsh -s $(which zsh)
```

### Docker 权限问题

```bash
# 将当前用户加入 docker 组
sudo usermod -aG docker $USER
# 重新登录生效
```

### 网络/镜像问题

```bash
# 切换软件源（自动检测最快镜像）
bash scripts/system/mirrors.sh

# Docker 镜像加速
bash scripts/containers/docker-mirrors.sh
```

---

## 🤝 贡献指南

欢迎提交 Issue 和 PR！

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'feat: add amazing feature'`
4. 推送分支：`git push origin feature/amazing-feature`
5. 创建 Pull Request

---

## 📄 许可证

本项目采用 [MIT](LICENSE) 许可证。

---

## 🙏 致谢

- [Oh My Zsh](https://ohmyz.sh/) - ZSH 框架
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - ZSH 主题
- [Oh My Tmux](https://github.com/gpakosz/.tmux) - Tmux 配置
- [LazyVim](https://github.com/LazyVim/LazyVim) - Neovim 配置
- [eza](https://github.com/eza-community/eza)、[fzf](https://github.com/junegunn/fzf)、[bat](https://github.com/sharkdp/bat) - 现代化 CLI 工具

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐ 支持一下！**

</div>
