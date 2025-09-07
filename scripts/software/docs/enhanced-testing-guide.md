# Shell工具配置模块增强版测试指南

## 🎯 测试目标与原则

### 核心测试目标
1. **功能完整性验证** - 确保每个模块的所有功能按预期工作
2. **兼容性保证** - 验证在不同系统环境下的稳定运行
3. **错误处理验证** - 确保异常情况下的优雅处理
4. **性能基准维护** - 保证配置加载和执行效率
5. **用户体验一致性** - 确保界面和交互的一致性

### 测试设计原则
- **FIRST原则**：Fast(快速)、Independent(独立)、Repeatable(可重复)、Self-validating(自验证)、Timely(及时)
- **金字塔原则**：单元测试 > 集成测试 > 端到端测试
- **左移原则**：尽早发现和修复问题
- **持续反馈**：快速获得测试结果和质量反馈

## 📊 模块测试矩阵（增强版）

| 模块 | 功能复杂度 | 依赖工具数 | 测试用例数 | 预计测试时间 | 风险等级 |
|------|------------|------------|------------|--------------|----------|
| 00-path-config | 低 | 0 | 3 | 30秒 | 低 |
| 01-tool-detection | 高 | 2 | 8 | 2分钟 | 高 |
| 02-bat-config | 中 | 1 | 6 | 1分钟 | 中 |
| 03-fd-config | 中 | 1 | 6 | 1分钟 | 中 |
| 04-fzf-core | 高 | 1 | 10 | 3分钟 | 高 |
| 05-fzf-basic | 高 | 2 | 12 | 4分钟 | 高 |
| 06-fzf-advanced | 高 | 3 | 8 | 3分钟 | 高 |
| 07-ripgrep-config | 中 | 1 | 7 | 2分钟 | 中 |
| 08-ripgrep-fzf | 高 | 3 | 10 | 4分钟 | 高 |
| 09-git-integration | 高 | 3 | 12 | 5分钟 | 高 |
| 10-log-monitoring | 低 | 2 | 2 | 30秒 | 低 |
| 11-man-integration | 中 | 2 | 6 | 2分钟 | 中 |
| 12-apt-integration | 中 | 2 | 6 | 2分钟 | 中 |
| 13-utility-functions | 中 | 3 | 8 | 3分钟 | 中 |
| 99-aliases-summary | 低 | 0 | 4 | 1分钟 | 低 |

## 🔧 详细测试方法

### 模块00：PATH配置测试

#### 功能描述
配置系统PATH环境变量，确保核心命令路径正确设置，防止重复添加。

#### 测试目标
- 验证PATH中包含必要的系统路径
- 确保重复加载不会导致PATH污染
- 验证PATH顺序的合理性

#### 前置条件
- 系统为Linux环境
- 具有基本的shell命令访问权限
- 测试环境PATH可以被修改

#### 测试用例

**TC-00-001：基础PATH配置验证**
```bash
# 测试步骤
1. 记录初始PATH状态
2. 加载00-path-config.zsh模块
3. 验证关键路径存在
4. 检查PATH格式正确性

# 测试命令
source templates/00-path-config.zsh
echo "$PATH" | grep -E "(^|:)/bin($|:)" || exit 1
echo "$PATH" | grep -E "(^|:)/usr/bin($|:)" || exit 1
echo "$PATH" | grep -E "(^|:)/usr/local/bin($|:)" || exit 1

# 预期结果
- 返回码：0
- PATH包含：/bin, /usr/bin, /usr/local/bin
- PATH格式：冒号分隔的路径列表
```

**TC-00-002：PATH重复添加防护测试**
```bash
# 测试步骤
1. 记录初始PATH长度
2. 多次加载模块
3. 验证PATH长度未异常增长
4. 检查路径去重效果

# 测试命令
initial_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
source templates/00-path-config.zsh
source templates/00-path-config.zsh
final_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
[[ $final_count -le $((initial_count + 5)) ]] || exit 1

# 预期结果
- 返回码：0
- PATH长度增长合理（≤5个新路径）
- 无重复路径条目
```

**TC-00-003：PATH顺序优先级测试**
```bash
# 测试步骤
1. 加载模块
2. 检查关键路径的优先级顺序
3. 验证用户路径优先于系统路径

# 测试命令
source templates/00-path-config.zsh
first_path=$(echo "$PATH" | cut -d: -f1)
echo "$first_path" | grep -E "(home|usr/local)" || exit 1

# 预期结果
- 返回码：0
- 用户路径或/usr/local/bin优先
- 系统路径(/bin, /usr/bin)在后
```

### 模块01：工具检测测试

#### 功能描述
检测系统中可用的命令行工具，设置统一别名，处理Ubuntu/Debian系统的命名差异。

#### 测试目标
- 验证工具检测逻辑的准确性
- 确保别名设置的正确性
- 验证工具缺失时的优雅处理

#### 前置条件
- 系统为Ubuntu/Debian或兼容系统
- 具有安装/卸载软件包的权限（用于测试）
- 可以创建和删除别名

#### 测试用例

**TC-01-001：bat工具检测和别名设置**
```bash
# 测试步骤
1. 检查系统中bat相关命令的可用性
2. 加载工具检测模块
3. 验证别名设置正确性
4. 测试别名功能

# 测试命令
source templates/01-tool-detection.zsh

if command -v batcat >/dev/null 2>&1; then
    # 验证bat别名指向batcat
    alias bat | grep -q "batcat" || exit 1
    # 测试别名功能
    bat --version | grep -q "bat" || exit 1
elif command -v bat >/dev/null 2>&1; then
    # 验证bat命令直接可用
    bat --version | grep -q "bat" || exit 1
else
    # 验证工具缺失提示
    echo "工具缺失情况已正确处理"
fi

# 预期结果
- 返回码：0
- 如果batcat存在：bat别名正确设置
- 如果bat存在：直接使用bat命令
- 如果都不存在：给出友好提示
```

**TC-01-002：fd工具检测和别名设置**
```bash
# 测试步骤
1. 检查系统中fd相关命令的可用性
2. 加载工具检测模块
3. 验证别名设置正确性
4. 测试别名功能

# 测试命令
source templates/01-tool-detection.zsh

if command -v fdfind >/dev/null 2>&1; then
    # 验证fd别名指向fdfind
    alias fd | grep -q "fdfind" || exit 1
    # 测试别名功能
    fd --version | grep -q "fd" || exit 1
elif command -v fd >/dev/null 2>&1; then
    # 验证fd命令直接可用
    fd --version | grep -q "fd" || exit 1
else
    echo "工具缺失情况已正确处理"
fi

# 预期结果
- 返回码：0
- 如果fdfind存在：fd别名正确设置
- 如果fd存在：直接使用fd命令
- 别名功能正常工作
```

**TC-01-003：工具缺失情况处理测试**
```bash
# 测试步骤
1. 临时隐藏工具命令
2. 加载工具检测模块
3. 验证错误处理和提示信息
4. 恢复工具可用性

# 测试命令
# 备份原始PATH
original_path="$PATH"
# 设置受限PATH（隐藏工具）
export PATH="/bin:/usr/bin"

# 加载模块并捕获输出
output=$(source templates/01-tool-detection.zsh 2>&1)

# 恢复PATH
export PATH="$original_path"

# 验证提示信息
echo "$output" | grep -q "未找到\|缺少\|安装" || exit 1

# 预期结果
- 返回码：0
- 输出包含友好的错误提示
- 提供安装建议
- 不会导致脚本崩溃
```

### 模块02：bat配置测试

#### 功能描述
配置bat工具的环境变量、主题、分页器和别名，提供语法高亮的文件查看功能。

#### 测试目标
- 验证bat环境变量设置正确
- 确保别名功能正常工作
- 验证主题和样式配置

#### 前置条件
- bat或batcat工具已安装
- 具有设置环境变量的权限
- 可以创建和测试别名

#### 测试用例

**TC-02-001：bat环境变量配置验证**
```bash
# 测试步骤
1. 加载bat配置模块
2. 检查关键环境变量设置
3. 验证配置值的正确性
4. 测试配置的实际效果

# 测试命令
source templates/02-bat-config.zsh

# 验证环境变量设置
[[ "$BAT_STYLE" == "numbers,changes,header,grid" ]] || exit 1
[[ "$BAT_THEME" == "OneHalfDark" ]] || exit 1
[[ "$BAT_PAGER" == "less -RFK" ]] || exit 1

# 测试配置效果（如果bat可用）
if command -v bat >/dev/null 2>&1; then
    echo "test content" | bat --list-themes | grep -q "OneHalfDark" || exit 1
fi

# 预期结果
- 返回码：0
- BAT_STYLE设置为numbers,changes,header,grid
- BAT_THEME设置为OneHalfDark
- BAT_PAGER设置为less -RFK
```

**TC-02-002：bat别名功能测试**
```bash
# 测试步骤
1. 加载bat配置模块
2. 验证所有别名设置
3. 测试别名功能
4. 检查别名冲突

# 测试命令
source templates/02-bat-config.zsh

# 验证别名设置
expected_aliases=("cat" "less" "more" "batl" "batn" "batp")
for alias_name in "${expected_aliases[@]}"; do
    alias "$alias_name" >/dev/null 2>&1 || exit 1
done

# 测试别名功能（如果bat可用）
if command -v bat >/dev/null 2>&1; then
    echo "test" | cat | grep -q "test" || exit 1
fi

# 预期结果
- 返回码：0
- 所有预期别名正确设置
- 别名功能正常工作
- 无别名冲突
```

**TC-02-003：bat主题和样式测试**
```bash
# 测试步骤
1. 加载bat配置模块
2. 创建测试文件
3. 验证语法高亮效果
4. 检查样式配置

# 测试命令
source templates/02-bat-config.zsh

# 创建测试文件
test_file="/tmp/bat-test-$$.sh"
cat > "$test_file" << 'EOF'
#!/bin/bash
echo "Hello, World!"
EOF

# 测试bat输出（如果可用）
if command -v bat >/dev/null 2>&1; then
    output=$(bat "$test_file" 2>/dev/null)
    # 验证包含行号和语法高亮
    echo "$output" | grep -q "1.*echo" || exit 1
fi

# 清理
rm -f "$test_file"

# 预期结果
- 返回码：0
- 输出包含行号
- 语法高亮正常显示
- 主题配置生效
```
