# Main Agent Memory

## System Information

- Main Agent Workspace: ~/.openclaw/workspace-main/
- Configuration: ~/.openclaw/openclaw.json
- Model: minimax-codeplan/MiniMax-M2.5

## Managed Agents

### Agent: recruiter

- Created: 2026-03-15
- Purpose: HR 招聘专员，负责智能体生命周期管理
- Model: minimax-codeplan/MiniMax-M2.5
- Tools: read, write, bash, exec, sessions tools
- Workspace: ~/.openclaw/workspace-recruiter/
- Status: Active
- Skills:
  - agent-manager: 创建和配置智能体
  - skill-creator: 创建自定义技能
  - agent-lifecycle: 智能体删除和备份

### Agent: person-info

- Created: 2026-03-15
- Purpose: 个人信息管理和 Word 文档填充
- Model: minimax-codeplan/MiniMax-M2.5
- Tools: read, write, bash, exec, python, sessions tools
- Workspace: ~/.openclaw/workspace-person-info/
- Status: Active
- Skills:
  - info-collector: 个人信息收集
  - word-doc-filler: Word 文档自动填充

## Recent Operations

### 2026-03-15: System Initialization

- Created multi-agent system with main orchestrator
- Configured recruiter agent for agent management
- Configured person-info agent for document processing
- Set up bindings for WhatsApp and Telegram routing

## Notes

- All agents use minimax-codeplan/MiniMax-M2.5 model
- Main agent has sessions tools only
- Recruiter and person-info have full file system access
- Max spawn depth: 1 (sub-agents cannot spawn further)
