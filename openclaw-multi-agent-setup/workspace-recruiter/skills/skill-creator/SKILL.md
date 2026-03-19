------





















































































































































































































































































































































































































```}  }    ]      }        "label": "Install Python dependencies"        "packages": ["package-name"],        "bins": ["python3"],        "kind": "node",        "id": "pip",      {    "install": [    },      "env": []      "bins": ["python3"],    "requires": {    "emoji": "🔧",  "openclaw": {{```json### 常用 metadata 模板```read ~/.openclaw/workspace-<agent>/skills/<skill-name>/SKILL.md# 智能体可以读取技能文件验证```bash### 检查技能是否加载```mkdir -p ~/.openclaw/workspace-<agent>/skills/<skill-name>/{scripts,references,assets}```bash### 创建空技能结构## 快速参考- [ ] 包含错误处理说明- [ ] 提供完整的使用示例- [ ] Bash 脚本有可执行权限- [ ] Python 脚本有 requirements.txt（如有依赖）- [ ] 脚本文件有正确的 shebang- [ ] 使用 {baseDir} 引用技能目录下的文件- [ ] metadata.openclaw.requires 声明所有依赖- [ ] description 清晰描述功能- [ ] name 字段使用 kebab-case- [ ] SKILL.md 包含有效的 YAML frontmatter创建技能后，检查以下项目：## 技能验证清单```\```  --output filled.docx  --data data.json \  --template template.docx \python {baseDir}/scripts/fill_doc.py \\```bash使用方式：# Document Filler---metadata: {"openclaw": {"requires": {"bins": ["python3"]}, "install": [{"id": "pip", "kind": "node", "packages": ["python-docx"]}]}}description: 根据 JSON 数据填充 Word 文档模板name: doc-filler---```markdown### 模式3：文档处理技能```\```python {baseDir}/scripts/api_call.py --endpoint "/users" --method GET\```bash使用方式：# API Client---metadata: {"openclaw": {"requires": {"env": ["API_KEY"]}, "install": [{"id": "pip", "kind": "node", "packages": ["requests"]}]}}description: 调用外部 API 并格式化结果name: api-client---```markdown### 模式2：API 集成技能```\```python {baseDir}/scripts/analyze.py --input data.csv --output report.html\```bash使用方式：# Data Processor---metadata: {"openclaw": {"requires": {"bins": ["python3"]}, "install": [{"id": "pip", "kind": "node", "packages": ["pandas", "matplotlib"]}]}}description: 读取 CSV/JSON 数据并生成分析报告name: data-processor---```markdown### 模式1：数据处理技能## 常见技能模式```python {baseDir}/scripts/process.py --input "$input_file" --output "$output_file"# 好：使用参数python /Users/user/scripts/process.py# 不好：硬编码路径```bash避免硬编码路径和配置：### 5. 脚本参数化- 配置要求（config）- 环境变量（env）- 命令行工具（bins）在 metadata.openclaw.requires 中声明所有依赖：### 4. 依赖声明完整- 列出常见错误和解决方法- 说明每个参数的作用- 提供完整的示例命令### 3. 详细的使用说明```    sys.exit(1)    print(f"处理失败：{str(e)}", file=sys.stderr)except Exception as e:    sys.exit(1)    print(f"错误：文件 {input_path} 不存在", file=sys.stderr)except FileNotFoundError:    result = process_file(input_path)try:```python### 2. 完善的错误处理- 明确输入输出- 避免功能重叠- 一个技能只做一件事（单一职责原则）### 1. 清晰的功能边界## 技能编写最佳实践```read <workspace>/skills/<skill-name>/SKILL.md# 或者让智能体读取技能文件验证格式openclaw gateway restart# 重启 Gateway 重新加载技能```bash提示用户：### 步骤 6: 测试技能加载- 常见问题解答- 使用示例- API 文档摘要在 `references/` 目录下添加：### 步骤 5: 添加参考文档（可选）- 创建 requirements.txt（如有 Python 依赖）- Bash 脚本：添加 shebang、参数验证、错误处理- Python 脚本：添加 shebang、argparse、错误处理### 步骤 4: 创建脚本文件（如需要）5. 错误处理指导4. 参数说明和示例3. 详细的使用步骤2. 功能说明和使用场景1. YAML frontmatter（name, description, metadata）根据用户需求，生成包含以下内容的 SKILL.md：### 步骤 3: 生成 SKILL.md```mkdir -p <workspace>/skills/<skill-name>/{scripts,references,assets}```bash### 步骤 2: 创建技能目录5. 目标智能体的工作空间路径4. 是否需要脚本（Python/Bash）3. 需要的依赖（CLI 工具、Python 库、环境变量）2. 功能描述1. 技能名称（kebab-case）询问用户：### 步骤 1: 确定技能需求## 技能创建完整流程````\```fi  pip install -r {baseDir}/scripts/requirements.txtif ! python -c "import docx" 2>/dev/null; then\```bash或在技能中自动检查和安装：\```pip install -r {baseDir}/scripts/requirements.txt\```bash安装 Python 依赖：## 首次使用前````markdown### 在 SKILL.md 中说明安装```pydantic>=2.0.0openai>=1.0.0requests>=2.28.0python-docx==0.8.11```txt### requirements.txt## Python 依赖管理- 图标、字体等资源- 配置文件模板- Word/Excel 模板存放模板文件、配置文件、静态资源：### assets/ 目录- 第三方 API 文档摘要- JSON 格式的示例数据- Markdown 格式文档存放 API 文档、使用示例、参考资料：### references/ 目录  - 确保可执行权限：`chmod +x scripts/helper.sh`  - 使用 `set -euo pipefail` 增强错误处理  - 添加 shebang：`#!/usr/bin/env bash`    ```  # 处理逻辑...    output_file="$2"  input_file="$1"    set -euo pipefail  # scripts/helper.sh  #!/usr/bin/env bash  ```bash- **Bash 脚本**：  - 创建 `requirements.txt` 列出依赖  - 使用 argparse 处理参数  - 添加 shebang：`#!/usr/bin/env python3`    ```      main()  if __name__ == '__main__':        # 处理逻辑...      args = parser.parse_args()      parser.add_argument('--output', required=True)      parser.add_argument('--input', required=True)      parser = argparse.ArgumentParser()  def main():    import argparse  # scripts/processor.py  #!/usr/bin/env python3  ```python- **Python 脚本**：### scripts/ 目录```    └── config.json    ├── template.docx└── assets/            # 模板、配置、资源文件（可选）│   └── examples.json│   ├── api-docs.md├── references/         # 参考文档和 API 说明（可选）│   └── requirements.txt│   ├── helper.sh│   ├── main.py├── scripts/            # 可执行脚本（可选）├── README.md           # 可选的用户文档├── SKILL.md            # 技能说明文件（必需）<workspace>/skills/<skill-name>/```## 技能目录结构OpenClaw 会自动将 `{baseDir}` 替换为技能目录的绝对路径。```\```cat {baseDir}/references/api-docs.md\```bash读取参考文档：\```python {baseDir}/scripts/processor.py --input file.txt\```bash执行脚本：```markdown在 SKILL.md 中引用技能目录下的文件时，使用 `{baseDir}` 占位符：## 使用 {baseDir} 引用文件```"os": ["darwin", "linux", "win32"]  // 限制操作系统"always": true,    // 总是加载（跳过其他门控）"homepage": "https://example.com",  // 技能主页"emoji": "🔧",     // 技能图标（macOS UI 使用）```json#### 其他字段```]  }    "label": "Install via Homebrew"    "bins": ["tool-name"],    "formula": "tool-name",    "kind": "brew",    "id": "brew",  {  },    "label": "Install Python dependencies"    "packages": ["python-docx", "openai"],    "bins": ["python3"],    "manager": "pip",    "kind": "node",  // "node", "brew", "go", "download"    "id": "pip",  {"install": [```json#### install（安装器配置）```}  "config": ["tools.exec.enabled"]  // 必需的配置项  "env": ["API_KEY", "TOKEN"],      // 必需的环境变量  "anyBins": ["brew", "apt-get"],   // 至少需要其中一个  "bins": ["python3", "node"],      // 必需的命令行工具"requires": {```json#### requires（依赖要求）### metadata.openclaw（可选但推荐）- 清晰说明输入和输出- 用于 LLM 决定何时使用这个技能- 简短的功能描述（1-2句话）### description（必需）- 与目录名匹配- 使用 kebab-case：`word-doc-filler`, `data-analyzer`- 技能的唯一标识符### name（必需）## YAML Frontmatter 字段```错误处理和边界情况...## 注意事项具体使用示例...## 示例- `--arg`: 参数说明## 参数说明\```command {baseDir}/scripts/script.sh --arg value\```bash使用 bash 工具调用：### 步骤 2: 执行说明前置条件...### 步骤 1: 准备## 使用方法详细描述技能的用途和使用场景。## 功能说明# Skill Title---metadata: {"openclaw": {"requires": {"bins": ["required-binary"], "env": ["ENV_VAR"]}, "emoji": "🔧", "install": [...]}}description: 技能的简短描述（一句话说明功能，用于 LLM 识别）name: skill-name---```markdown## SKILL.md 标准结构- 技能测试和验证- 脚本文件组织- metadata.openclaw 配置（依赖、安装器）- SKILL.md 文件结构和语法这个技能提供创建 OpenClaw Skills 的完整指导，包括：## 功能说明# Skill Creator---metadata: {"openclaw": {"emoji": "📚", "homepage": "https://docs.openclaw.ai/tools/creating-skills"}}description: 为智能体创建自定义 SKILL.md 文件和相关脚本的指导工具name: skill-creatorname: skill-creator
description: 为智能体创建自定义 SKILL.md 文件和相关脚本的指导工具
metadata: {"openclaw": {"emoji": "📚", "homepage": "https://docs.openclaw.ai/tools/creating-skills"}}
---

# Skill Creator

## 功能说明

这个技能提供创建 OpenClaw Skills 的完整指导，包括：

- SKILL.md 文件结构和语法
- metadata.openclaw 配置（依赖、安装器）
- 脚本文件组织
- 技能测试和验证

## SKILL.md 标准结构

````markdown
---
name: skill-name
description: 技能的简短描述（一句话说明功能，用于 LLM 识别）
metadata:
  {
    "openclaw":
      {
        "requires": { "bins": ["required-binary"], "env": ["ENV_VAR"] },
        "emoji": "🔧",
        "install": [...],
      },
  }
---

# Skill Title

## 功能说明

详细描述技能的用途和使用场景。

## 使用方法

### 步骤 1: 准备

说明前置条件...

### 步骤 2: 执行

使用 bash 工具调用：
\```bash
command {baseDir}/scripts/script.sh --arg value
\```

## 参数说明

- `--arg`: 参数说明

## 示例

具体使用示例...

## 注意事项

错误处理和边界情况...
````

## YAML Frontmatter 字段

### name（必需）

- 技能的唯一标识符
- 使用 kebab-case：`word-doc-filler`, `data-analyzer`
- 与目录名匹配

### description（必需）

- 简短的功能描述（1-2句话）
- 用于 LLM 决定何时使用这个技能
- 清晰说明输入和输出

### metadata.openclaw（可选但推荐）

#### requires（依赖要求）

```json
"requires": {
  "bins": ["python3", "node"],      // 必需的命令行工具
  "anyBins": ["brew", "apt-get"],   // 至少需要其中一个
  "env": ["API_KEY", "TOKEN"],      // 必需的环境变量
  "config": ["tools.exec.enabled"]  // 必需的配置项
}
```

#### install（安装器配置）

```json
"install": [
  {
    "id": "pip",
    "kind": "node",  // "node", "brew", "go", "download"
    "manager": "pip",
    "bins": ["python3"],
    "packages": ["python-docx", "openai"],
    "label": "Install Python dependencies"
  },
  {
    "id": "brew",
    "kind": "brew",
    "formula": "tool-name",
    "bins": ["tool-name"],
    "label": "Install via Homebrew"
  }
]
```

#### 其他字段

```json
"emoji": "🔧",     // 技能图标（macOS UI 使用）
"homepage": "https://example.com",  // 技能主页
"always": true,    // 总是加载（跳过其他门控）
"os": ["darwin", "linux", "win32"]  // 限制操作系统
```

## 使用 {baseDir} 引用文件

在 SKILL.md 中引用技能目录下的文件时，使用 `{baseDir}` 占位符：

````markdown
执行脚本：
\```bash
python {baseDir}/scripts/processor.py --input file.txt
\```

读取参考文档：
\```bash
cat {baseDir}/references/api-docs.md
\```
````

OpenClaw 会自动将 `{baseDir}` 替换为技能目录的绝对路径。

## 技能目录结构

```
<workspace>/skills/<skill-name>/
├── SKILL.md            # 技能说明文件（必需）
├── README.md           # 可选的用户文档
├── scripts/            # 可执行脚本（可选）
│   ├── main.py
│   ├── helper.sh
│   └── requirements.txt
├── references/         # 参考文档和 API 说明（可选）
│   ├── api-docs.md
│   └── examples.json
└── assets/            # 模板、配置、资源文件（可选）
    ├── template.docx
    └── config.json
```

### scripts/ 目录

- **Python 脚本**：

  ```python
  #!/usr/bin/env python3
  # scripts/processor.py
  import argparse

  def main():
      parser = argparse.ArgumentParser()
      parser.add_argument('--input', required=True)
      parser.add_argument('--output', required=True)
      args = parser.parse_args()
      # 处理逻辑...

  if __name__ == '__main__':
      main()
  ```

  - 添加 shebang：`#!/usr/bin/env python3`
  - 使用 argparse 处理参数
  - 创建 `requirements.txt` 列出依赖

- **Bash 脚本**：

  ```bash
  #!/usr/bin/env bash
  # scripts/helper.sh
  set -euo pipefail

  input_file="$1"
  output_file="$2"

  # 处理逻辑...
  ```

  - 添加 shebang：`#!/usr/bin/env bash`
  - 使用 `set -euo pipefail` 增强错误处理
  - 确保可执行权限：`chmod +x scripts/helper.sh`

### references/ 目录

存放 API 文档、使用示例、参考资料：

- Markdown 格式文档
- JSON 格式的示例数据
- 第三方 API 文档摘要

### assets/ 目录

存放模板文件、配置文件、静态资源：

- Word/Excel 模板
- 配置文件模板
- 图标、字体等资源

## Python 依赖管理

### requirements.txt

```txt
python-docx==0.8.11
requests>=2.28.0
openai>=1.0.0
pydantic>=2.0.0
```

### 在 SKILL.md 中说明安装

````markdown
## 首次使用前

安装 Python 依赖：
\```bash
pip install -r {baseDir}/scripts/requirements.txt
\```

或在技能中自动检查和安装：
\```bash
if ! python -c "import docx" 2>/dev/null; then
pip install -r {baseDir}/scripts/requirements.txt
fi
\```
````

## 技能创建完整流程

### 步骤 1: 确定技能需求

询问用户：

1. 技能名称（kebab-case）
2. 功能描述
3. 需要的依赖（CLI 工具、Python 库、环境变量）
4. 是否需要脚本（Python/Bash）
5. 目标智能体的工作空间路径

### 步骤 2: 创建技能目录

```bash
mkdir -p <workspace>/skills/<skill-name>/{scripts,references,assets}
```

### 步骤 3: 生成 SKILL.md

根据用户需求，生成包含以下内容的 SKILL.md：

1. YAML frontmatter（name, description, metadata）
2. 功能说明和使用场景
3. 详细的使用步骤
4. 参数说明和示例
5. 错误处理指导

### 步骤 4: 创建脚本文件（如需要）

- Python 脚本：添加 shebang、argparse、错误处理
- Bash 脚本：添加 shebang、参数验证、错误处理
- 创建 requirements.txt（如有 Python 依赖）

### 步骤 5: 添加参考文档（可选）

在 `references/` 目录下添加：

- API 文档摘要
- 使用示例
- 常见问题解答

### 步骤 6: 测试技能加载

提示用户：

```bash
# 重启 Gateway 重新加载技能
openclaw gateway restart

# 或者让智能体读取技能文件验证格式
read <workspace>/skills/<skill-name>/SKILL.md
```

## 技能编写最佳实践

### 1. 清晰的功能边界

- 一个技能只做一件事（单一职责原则）
- 避免功能重叠
- 明确输入输出

### 2. 完善的错误处理

```python
try:
    result = process_file(input_path)
except FileNotFoundError:
    print(f"错误：文件 {input_path} 不存在", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"处理失败：{str(e)}", file=sys.stderr)
    sys.exit(1)
```

### 3. 详细的使用说明

- 提供完整的示例命令
- 说明每个参数的作用
- 列出常见错误和解决方法

### 4. 依赖声明完整

在 metadata.openclaw.requires 中声明所有依赖：

- 命令行工具（bins）
- 环境变量（env）
- 配置要求（config）

### 5. 脚本参数化

避免硬编码路径和配置：

```bash
# 不好：硬编码路径
python /Users/user/scripts/process.py

# 好：使用参数
python {baseDir}/scripts/process.py --input "$input_file" --output "$output_file"
```

## 常见技能模式

### 模式1：数据处理技能

````markdown
---
name: data-processor
description: 读取 CSV/JSON 数据并生成分析报告
metadata:
  {
    "openclaw":
      {
        "requires": { "bins": ["python3"] },
        "install": [{ "id": "pip", "kind": "node", "packages": ["pandas", "matplotlib"] }],
      },
  }
---

# Data Processor

使用方式：
\```bash
python {baseDir}/scripts/analyze.py --input data.csv --output report.html
\```
````

### 模式2：API 集成技能

````markdown
---
name: api-client
description: 调用外部 API 并格式化结果
metadata:
  {
    "openclaw":
      {
        "requires": { "env": ["API_KEY"] },
        "install": [{ "id": "pip", "kind": "node", "packages": ["requests"] }],
      },
  }
---

# API Client

使用方式：
\```bash
python {baseDir}/scripts/api_call.py --endpoint "/users" --method GET
\```
````

### 模式3：文档处理技能

````markdown
---
name: doc-filler
description: 根据 JSON 数据填充 Word 文档模板
metadata:
  {
    "openclaw":
      {
        "requires": { "bins": ["python3"] },
        "install": [{ "id": "pip", "kind": "node", "packages": ["python-docx"] }],
      },
  }
---

# Document Filler

使用方式：
\```bash
python {baseDir}/scripts/fill_doc.py \
 --template template.docx \
 --data data.json \
 --output filled.docx
\```
````

## 技能验证清单

创建技能后，检查以下项目：

- [ ] SKILL.md 包含有效的 YAML frontmatter
- [ ] name 字段使用 kebab-case
- [ ] description 清晰描述功能
- [ ] metadata.openclaw.requires 声明所有依赖
- [ ] 使用 {baseDir} 引用技能目录下的文件
- [ ] 脚本文件有正确的 shebang
- [ ] Python 脚本有 requirements.txt（如有依赖）
- [ ] Bash 脚本有可执行权限
- [ ] 提供完整的使用示例
- [ ] 包含错误处理说明

## 快速参考

### 创建空技能结构

```bash
mkdir -p ~/.openclaw/workspace-<agent>/skills/<skill-name>/{scripts,references,assets}
```

### 检查技能是否加载

```bash
# 智能体可以读取技能文件验证
read ~/.openclaw/workspace-<agent>/skills/<skill-name>/SKILL.md
```

### 常用 metadata 模板

```json
{
  "openclaw": {
    "emoji": "🔧",
    "requires": {
      "bins": ["python3"],
      "env": []
    },
    "install": [
      {
        "id": "pip",
        "kind": "node",
        "bins": ["python3"],
        "packages": ["package-name"],
        "label": "Install Python dependencies"
      }
    ]
  }
}
```
