# OpenClaw Multi-Agent Setup

这是一个使用 OpenClaw 构建的多智能体系统，包含三个专业智能体协作完成任务。

## 系统架构

```
┌─────────────────────────────────────────────┐
│          Main (主调度智能体)                │
│  - 接收用户请求                             │
│  - 分析任务类型                             │
│  - 调度合适的子智能体                       │
│  - 汇总结果并反馈用户                       │
└────────────┬──────────────┬─────────────────┘
             │              │
      ┌──────┴──────┐  ┌───┴───────────┐
      │             │  │               │
      ▼             ▼  ▼               ▼
┌──────────┐   ┌──────────────┐   ┌──────────────┐
│ Recruiter│   │ Person-Info  │   │  未来可扩展   │
│  HR专员  │   │ 信息管理专员  │   │  更多智能体   │
└──────────┘   └──────────────┘   └──────────────┘
```

## 智能体说明

### 1. Main（主调度智能体）

**职责**：协调和调度其他智能体

- 接收用户请求
- 判断任务类型
- 使用 `sessions_spawn` 调度子智能体
- 汇总结果并呈现给用户
- 维护 MEMORY.md 记录系统状态

**工具权限**：

- `sessions_spawn`/`sessions_list`/`sessions_history`/`sessions_send`/`session_status`/`subagents`/`agents_list`
- `read` (只读)

**不能执行**：写入文件、执行命令

### 2. Recruiter（HR 招聘专员）

**职责**：智能体生命周期管理

- 创建新智能体（配置、工作空间、技能）
- 删除智能体（备份、清理）
- 创建自定义技能
- 管理工作空间结构
- 更新 Main 的 MEMORY.md

**技能**：

- `agent-manager`：创建和配置智能体
- `skill-creator`：编写 SKILL.md
- `agent-lifecycle`：安全删除和备份

**工具权限**：

- `read`/`write`/`bash`/`exec`
- 所有 sessions 工具

### 3. Person-Info（个人信息管理专员）

**职责**：个人信息收集和文档自动填充

- 引导式信息收集
- 信息存储（JSON 格式）
- Word 文档模板识别
- 自动填充文档

**技能**：

- `info-collector`：收集和验证个人信息
- `word-doc-filler`：Word 文档自动填充（需要 python-docx）

**工具权限**：

- `read`/`write`/`bash`/`exec`/`python`
- 所有 sessions 工具

## 文件结构

```
openclaw-multi-agent-setup/
├── openclaw.json                    # 三智能体配置文件
├── workspace-main/                  # Main 工作空间
│   ├── AGENTS.md
│   └── MEMORY.md
├── workspace-recruiter/             # Recruiter 工作空间
│   ├── AGENTS.md
│   ├── SOUL.md
│   └── skills/
│       ├── agent-manager/
│       │   └── SKILL.md
│       ├── skill-creator/
│       │   └── SKILL.md
│       └── agent-lifecycle/
│           └── SKILL.md
└── workspace-person-info/           # Person-Info 工作空间
    ├── AGENTS.md
    ├── SOUL.md
    ├── persons/                     # 个人信息存储目录（待创建）
    └── skills/
        ├── info-collector/
        │   └── SKILL.md
        └── word-doc-filler/
            ├── SKILL.md
            └── scripts/
                ├── word_processor.py
                └── requirements.txt
```

## 安装步骤

### 1. 复制配置文件到 OpenClaw 目录

```powershell
# 备份现有配置（如果存在）
Copy-Item "$env:USERPROFILE\.openclaw\openclaw.json" "$env:USERPROFILE\.openclaw\openclaw.json.backup" -ErrorAction SilentlyContinue

# 复制新配置
Copy-Item "E:\Project\openclaw\openclaw-multi-agent-setup\openclaw.json" "$env:USERPROFILE\.openclaw\openclaw.json"
```

### 2. 复制工作空间文件

```powershell
# 复制 Main 工作空间
Copy-Item "E:\Project\openclaw\openclaw-multi-agent-setup\workspace-main" "$env:USERPROFILE\.openclaw\workspace-main" -Recurse -Force

# 复制 Recruiter 工作空间
Copy-Item "E:\Project\openclaw\openclaw-multi-agent-setup\workspace-recruiter" "$env:USERPROFILE\.openclaw\workspace-recruiter" -Recurse -Force

# 复制 Person-Info 工作空间
Copy-Item "E:\Project\openclaw\openclaw-multi-agent-setup\workspace-person-info" "$env:USERPROFILE\.openclaw\workspace-person-info" -Recurse -Force
```

### 3. 创建必要的目录

```powershell
# 创建个人信息存储目录
New-Item -Path "$env:USERPROFILE\.openclaw\workspace-person-info\persons" -ItemType Directory -Force

# 创建模板和输出目录
New-Item -Path "$env:USERPROFILE\Documents\openclaw-templates" -ItemType Directory -Force
New-Item -Path "$env:USERPROFILE\Documents\openclaw-filled" -ItemType Directory -Force
```

### 4. 安装 Python 依赖（Person-Info 需要）

```powershell
# 安装 python-docx
pip install python-docx

# 或使用 requirements.txt
pip install -r "$env:USERPROFILE\.openclaw\workspace-person-info\skills\word-doc-filler\scripts\requirements.txt"
```

### 5. 验证配置

```powershell
# 验证配置文件
openclaw config validate

# 列出智能体
openclaw agents list --bindings
```

### 6. 重启 OpenClaw Gateway

```powershell
openclaw gateway restart
```

## 使用示例

### 场景 1：查看系统中的智能体

```
用户："现在有哪些智能体？"

Main 响应：
"目前系统中有以下智能体：
1. main（我）- 主调度器
2. recruiter - HR 招聘专员，管理智能体生命周期
3. person-info - 个人信息管理，处理文档填充

需要我调用某个智能体为你服务吗？"
```

### 场景 2：创建新智能体（通过 Recruiter）

```
用户："创建一个叫 data-analyst 的智能体，用来分析数据"

Main 调度 Recruiter：
sessions_spawn(
  task="创建一个名为 data-analyst 的智能体，用于数据分析和可视化",
  label="Create data-analyst",
  agentId="recruiter"
)

Recruiter 执行：
1. 询问详细需求（模型、工具权限）
2. 执行 openclaw agents add data-analyst
3. 配置 openclaw.json
4. 创建工作空间文件
5. 更新 Main 的 MEMORY.md
6. 返回结果

Main 呈现：
"data-analyst 智能体已创建完成！现在你可以使用它来分析数据了。"
```

### 场景 3：填写个人信息

```
用户："我想填写个人信息"

Main 调度 Person-Info：
sessions_spawn(
  task="收集用户的个人信息并保存",
  label="Info Collection",
  agentId="person-info"
)

Person-Info 执行：
1. 逐项询问个人信息
2. 验证格式（手机号、邮箱等）
3. 保存为 JSON 文件
4. 返回确认

Main 呈现：
"个人信息收集完成！已保存到系统中，下次填表时可以直接使用。"
```

### 场景 4：填充 Word 文档

```
用户："用我的信息填写简历模板"

Main 调度 Person-Info：
sessions_spawn(
  task="使用已保存的个人信息填充简历模板",
  label="Fill Resume",
  agentId="person-info"
)

Person-Info 执行：
1. 检查已保存的信息
2. 询问模板文件名
3. 调用 Python 脚本填充
4. 返回填充后的文档位置

Main 呈现：
"简历填充完成！文档已保存到：
~/Documents/openclaw-filled/resume-zhangsan-filled.docx"
```

## 配置说明

### 模型配置

所有智能体使用 `minimax-codeplan/MiniMax-M2.5` 模型（在 openclaw.json 中配置）。

### 路由绑定

当前配置将 WhatsApp 和 Telegram 消息路由到 Main 智能体：

```json
"bindings": [
  {"channel": "whatsapp", "agent": "main"},
  {"channel": "telegram", "agent": "main"}
]
```

### 子智能体白名单

Main 可以调度的子智能体：

```json
"agents": {
  "defaults": {
    "subagents": {
      "allowAgents": ["recruiter", "person-info"],
      "maxSpawnDepth": 1
    }
  }
}
```

## 扩展系统

### 添加新智能体

通过 Main 调度 Recruiter 创建：

```
用户："创建一个新智能体"
→ Main 调度 Recruiter
→ Recruiter 引导创建流程
```

或手动执行：

```powershell
openclaw agents add <agent-id> --workspace ~/.openclaw/workspace-<agent-id>
```

然后更新配置文件和创建工作空间文件。

### 为智能体添加技能

通过 Recruiter：

```
用户："给 person-info 添加一个 PDF 处理技能"
→ Main 调度 Recruiter
→ Recruiter 创建 SKILL.md 和相关脚本
```

## 故障排查

### 问题 1：智能体未出现在列表中

```powershell
# 检查配置
openclaw config get agents.list

# 验证配置文件
openclaw config validate

# 重启 Gateway
openclaw gateway restart
```

### 问题 2：子智能体无法调度

- 检查 `agents.defaults.subagents.allowAgents` 包含目标智能体 ID
- 确认 Main 有 `sessions_spawn` 工具权限

### 问题 3：Python 脚本执行失败

```powershell
# 检查 python-docx 是否安装
python -c "import docx; print('python-docx 已安装')"

# 安装依赖
pip install python-docx
```

### 问题 4：Word 文档填充失败

- 确认模板在 `~/Documents/openclaw-templates/`
- 检查 JSON 数据是否包含所需字段
- 验证占位符格式 `${字段名}`

## 下一步

### 完成的功能

✅ 三智能体配置文件
✅ Main 调度逻辑
✅ Recruiter 智能体管理
✅ Person-Info 信息收集和文档填充

### 待扩展功能

⏳ 添加更多预定义模板
⏳ 支持 Excel 表格填充
⏳ 支持 PDF 文档处理
⏳ 添加更多智能体（如 data-analyst, email-assistant 等）
⏳ Web UI 管理界面

## 技术支持

- OpenClaw 官方文档：https://docs.openclaw.ai/
- 概念：Multi-Agent：https://docs.openclaw.ai/concepts/multi-agent
- Skills 文档：https://docs.openclaw.ai/tools/creating-skills
- Session Tools：https://docs.openclaw.ai/concepts/session-tool

## 许可

根据 OpenClaw 项目许可使用。
