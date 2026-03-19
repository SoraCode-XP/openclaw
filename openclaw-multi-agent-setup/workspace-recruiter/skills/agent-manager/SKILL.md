---
name: agent-manager
description: 创建、配置和管理 OpenClaw 智能体的完整工具集
metadata:
  { "openclaw": { "emoji": "🤖", "homepage": "https://docs.openclaw.ai/concepts/multi-agent" } }
---

# Agent Manager

## 功能说明

这个技能提供了管理 OpenClaw 智能体的完整工作流程，包括：

- 创建新智能体并生成配置
- 配置智能体的模型、工具权限、身份信息
- 设置路由绑定（将消息渠道路由到特定智能体）
- 管理智能体的工作空间文件结构

## 使用前提

- 必须有 read/write 工具权限以修改配置文件
- 必须有 bash 工具权限以执行 openclaw 命令
- 确保已安装 openclaw CLI

## 创建智能体完整流程

### 步骤 1: 需求分析

询问用户以下信息：

1. 智能体ID（必需）：使用 kebab-case 命名，如 `data-analyst`, `person-info`
2. 显示名称（推荐）：如 "Data Analyst Bot"
3. 用途描述：简短说明智能体的职责
4. 需要的模型：默认 `minimax-codeplan/MiniMax-M2.5`
5. 工具权限：根据职责确定需要哪些工具（read/write/bash/exec 等）
6. 是否需要调度子智能体

### 步骤 2: 执行创建命令

使用 bash 工具执行：

```bash
openclaw agents add <agent-id> --workspace ~/.openclaw/workspace-<agent-id>
```

命令会自动：

- 创建工作空间目录
- 创建 agentDir（`~/.openclaw/agents/<agent-id>/agent`）
- 从 main 智能体复制认证配置
- 在 `agents.list` 中添加基础配置

### 步骤 3: 读取并修改配置

1. 使用 read 工具读取 `~/.openclaw/openclaw.json`
2. 在 `agents.list` 数组中找到新创建的智能体条目
3. 添加完整配置（参考下方模板）
4. 使用 write 工具保存配置

**配置模板示例**：

```json5
{
  id: "data-analyst",
  name: "Data Analyst Bot",
  workspace: "~/.openclaw/workspace-data-analyst",
  agentDir: "~/.openclaw/agents/data-analyst/agent",
  model: {
    primary: "minimax-codeplan/MiniMax-M2.5",
    fallbacks: [],
  },
  identity: {
    name: "Data Bot",
    emoji: "📊",
    theme: "数据分析专家",
  },
  tools: {
    allow: ["read", "write", "bash", "exec", "python"],
    deny: ["gateway", "cron", "browser"],
  },
  sandbox: {
    mode: "off",
  },
  subagents: {
    allowAgents: [], // 如不需要调度子智能体，留空
  },
}
```

### 步骤 4: 设置路由绑定（可选）

如果需要将特定消息渠道路由到这个智能体：

```bash
# 绑定到 WhatsApp 默认账号
openclaw agents bind --agent data-analyst --bind whatsapp

# 绑定到特定 Telegram 账号
openclaw agents bind --agent data-analyst --bind telegram:work-bot

# 解除绑定
openclaw agents unbind --agent data-analyst --bind whatsapp
```

### 步骤 5: 创建工作空间文件

在智能体工作空间（`~/.openclaw/workspace-<agent-id>/`）中创建：

#### AGENTS.md（必需）

定义智能体的职责和操作指南，包括：

- 智能体的角色和身份
- 核心职责列表
- 工作流程和步骤
- 使用的技能和工具
- 重要约束和原则

示例框架：

```markdown
# <Agent Name> 操作手册

## 你的身份

你是 <描述角色>，专门负责 <核心职责>。

## 核心职责

1. <职责1>
2. <职责2>

## 工作流程

### <工作流1>

步骤...

## 使用的工具

- <工具1>: <用途>

## 重要原则

- <原则1>
```

#### SOUL.md（推荐）

定义智能体的个性、语气和边界：

```markdown
# Soul

你应该：

- 保持专业和友好的语气
- 专注于你的专业领域
- 在不确定时主动询问

你不应该：

- 处理超出职责范围的请求
- 做出未经验证的承诺
```

#### USER.md（可选）

用户信息和偏好：

```markdown
# User Profile

- Name: <用户名>
- Preference: <偏好>
```

#### TOOLS.md（可选）

工具使用约定和注意事项：

```markdown
# Tools Notes

## Bash Tool

- 执行脚本前先检查文件是否存在
- 长时间运行的命令使用后台执行

## Write Tool

- 写入文件前先确认路径正确
- 重要文件修改前先备份
```

### 步骤 6: 创建专业技能（如需要）

在 `~/.openclaw/workspace-<agent-id>/skills/` 下创建技能，参考 skill-creator 技能。

### 步骤 7: 更新 Main 智能体记忆

使用 write 工具在 `~/.openclaw/workspace/MEMORY.md` 中添加记录：

```markdown
## Managed Agents

### Agent: <agent-id>

- Created: YYYY-MM-DD
- Purpose: <用途描述>
- Model: <模型名称>
- Tools: <工具列表>
- Skills: <技能列表（如有）>
- Status: Active
```

### 步骤 8: 验证和重启

提示用户执行：

```bash
# 验证配置
openclaw config validate

# 查看智能体列表
openclaw agents list --bindings

# 重启 Gateway 使配置生效
openclaw gateway restart
```

## 配置字段详解

### model 配置

```json5
// 简单字符串形式
model: "minimax-codeplan/MiniMax-M2.5"

// 带降级的对象形式
model: {
  primary: "minimax-codeplan/MiniMax-M2.5",
  fallbacks: []
}
```

### tools 配置

```json5
tools: {
  // 白名单：只允许列出的工具
  allow: ["read", "write", "bash", "exec"],

  // 黑名单：拒绝这些工具（与 allow 结合使用）
  deny: ["gateway", "cron"],

  // 基础配置文件（可选）
  profile: "restricted",  // "default", "restricted", "elevated"

  // 按提供商配置（可选）
  byProvider: {
    "minimax-codeplan": {
      allow: ["advanced_reasoning"]
    }
  },

  // 执行工具配置（可选）
  exec: {
    host: "host",      // "host", "gateway", "sandboxed", "elevated"
    security: "full"   // "full", "reader", "writer"
  }
}
```

### sandbox 配置

```json5
sandbox: {
  // 沙箱模式
  mode: "off",  // "off", "all", "non-main", "require"

  // 沙箱作用域（当 mode 不是 off 时）
  scope: "agent",  // "agent", "shared", "session"

  // 自定义沙箱工作空间根目录（可选）
  workspaceRoot: "/tmp/sandboxes"
}
```

### subagents 配置

```json5
subagents: {
  // 允许调度的智能体 ID 列表
  allowAgents: ["worker1", "worker2"],  // 或 ["*"] 允许所有

  // 子智能体默认模型（可选）
  model: "minimax-codeplan/MiniMax-M2.5"
}
```

### identity 配置

```json5
identity: {
  name: "Bot Name",
  emoji: "🤖",
  theme: "helpful assistant",
  avatar: "avatars/bot.png"  // 相对工作空间或 URL
}
```

## 工具权限常用组合

### 只读智能体（信息查询）

```json5
tools: {
  allow: ["read", "sessions_list", "sessions_history"],
  deny: ["write", "exec", "bash", "apply_patch"]
}
```

### 数据处理智能体

```json5
tools: {
  allow: ["read", "write", "bash", "exec", "python"],
  deny: ["gateway", "cron", "browser"]
}
```

### 协调器智能体（可调度子智能体）

```json5
tools: {
  allow: ["sessions_spawn", "sessions_list", "sessions_history", "sessions_send", "subagents"],
  deny: ["write", "exec", "bash"]  // 协调器通常不直接操作文件
}
```

### 受限家庭智能体

```json5
tools: {
  allow: ["read"],
  deny: ["write", "exec", "bash", "browser", "gateway"]
},
sandbox: {
  mode: "all",
  scope: "agent"
}
```

## 常见问题排查

### 问题1：智能体未出现在列表中

```bash
# 检查配置
openclaw config get agents.list

# 验证配置文件
openclaw config validate

# 重启 Gateway
openclaw gateway restart
```

### 问题2：工具权限不生效

- 检查 `tools.allow` 和 `tools.deny` 配置
- 确认工具名称正确（区分大小写）
- 查看是否有全局 `tools.profile` 限制

### 问题3：子智能体无法调度

- 检查主智能体的 `agents.defaults.subagents.allowAgents`
- 确认主智能体有 `sessions_spawn` 工具权限
- 验证目标智能体在 `agents.list` 中存在

### 问题4：路由不生效

```bash
# 查看当前绑定
openclaw agents bindings

# 检查 bindings 配置
openclaw config get bindings
```

## 最佳实践

1. **命名规范**：
   - 智能体 ID 使用 kebab-case：`data-analyst`, `person-info`
   - 显示名称可以更友好：`Data Analyst Bot`, `Person Info Manager`

2. **工作空间隔离**：
   - 每个智能体独立工作空间：`~/.openclaw/workspace-<agent-id>`
   - 避免共享工作空间以防数据混淆

3. **最小权限原则**：
   - 只授予智能体必需的工具权限
   - 高风险工具（exec, gateway, cron）谨慎授予

4. **模型选择**：
   - 日常任务：`minimax-codeplan/MiniMax-M2.5`
   - 复杂推理：根据需要选择更强大的模型
   - 子智能体/快速响应：使用轻量模型

5. **记录管理**：
   - 每次创建智能体，更新 main 的 MEMORY.md
   - 记录创建日期、用途、配置要点

6. **配置备份**：
   - 重要修改前备份配置：
     ```bash
     openclaw backup create --output ~/backups/pre-change-$(date +%Y%m%d).tar.gz
     ```

## 快速参考

### 创建智能体一行命令

```bash
openclaw agents add my-agent --workspace ~/.openclaw/workspace-my-agent
```

### 验证智能体已创建

```bash
openclaw agents list --json | grep "my-agent"
```

### 查看智能体详细信息

```bash
openclaw config get agents.list | grep -A 20 '"id": "my-agent"'
```

### 更新智能体身份

```bash
openclaw agents set-identity --agent my-agent --name "My Agent" --emoji "🎯"
```
