---
name: agent-lifecycle
description: 管理智能体的删除、备份和生命周期维护
metadata: { "openclaw": { "emoji": "♻️" } }
---

# Agent Lifecycle Management

## 功能说明

这个技能提供智能体生命周期管理功能：

- 安全删除智能体（包含确认和备份步骤）
- 备份智能体工作空间和配置
- 归档不活跃的智能体
- 清理 main 智能体的记忆记录

## 删除智能体完整流程

### 步骤 1: 确认删除意图

在删除前，务必向用户确认：

1. 确认要删除的智能体 ID
2. 了解删除原因（记录到 MEMORY.md）
3. 询问是否需要备份工作空间

**重要：删除操作不可逆，必须谨慎操作！**

### 步骤 2: 备份工作空间（可选但推荐）

如果用户同意备份，执行：

```bash
# 创建完整备份（包含配置、工作空间、会话）
openclaw backup create --output ~/backups/<agent-id>-<timestamp>.tar.gz

# 或只备份工作空间（排除会话和配置）
tar -czf ~/backups/<agent-id>-workspace-<timestamp>.tar.gz \
  ~/.openclaw/workspace-<agent-id>
```

备份内容说明：

- **完整备份**：包含配置、工作空间、会话记录、认证信息
- **工作空间备份**：只包含工作空间文件（AGENTS.md, skills等）

### 步骤 3: 执行删除命令

```bash
# 删除智能体（同时删除配置、工作空间、会话、认证）
openclaw agents delete <agent-id>
```

此命令会：

1. 从 `agents.list` 中移除该智能体
2. 删除所有相关的 bindings
3. 移动工作空间到回收站
4. 移动 agentDir 到回收站
5. 移动会话记录到回收站

### 步骤 4: 更新 Main 智能体记忆

在 `~/.openclaw/workspace/MEMORY.md` 中标记智能体已删除：

```markdown
### Agent: <agent-id> (DELETED)

- Created: YYYY-MM-DD
- Deleted: YYYY-MM-DD
- Reason: <删除原因>
- Backup: <备份文件路径（如果有）>
- Notes: <任何额外说明>
```

### 步骤 5: 验证删除完成

```bash
# 确认智能体不再存在
openclaw agents list | grep <agent-id>

# 检查 bindings 已清理
openclaw agents bindings
```

提示用户重启 Gateway：

```bash
openclaw gateway restart
```

## 备份策略

### 定期备份（推荐）

建议用户设置定期备份 cron 任务：

```bash
# 每周备份一次（周日凌晨 2 点）
# crontab -e
0 2 * * 0 openclaw backup create --output ~/backups/weekly-$(date +\%Y\%m\%d).tar.gz
```

### 按需备份

在以下情况建议备份：

1. 删除智能体前
2. 重要配置修改前
3. 升级 OpenClaw 前
4. 迁移到新机器前

### 备份命令选项

```bash
# 完整备份（推荐）
openclaw backup create --output ~/backups/backup.tar.gz

# 排除工作空间（快速备份）
openclaw backup create --no-include-workspace --output ~/backups/config-only.tar.gz

# 只备份配置文件
openclaw backup create --only-config --output ~/backups/config.tar.gz
```

## 归档不活跃的智能体

对于长期不使用但不想删除的智能体，可以"归档"：

### 步骤 1: 备份工作空间

```bash
tar -czf ~/archives/<agent-id>-$(date +%Y%m%d).tar.gz \
  ~/.openclaw/workspace-<agent-id>
```

### 步骤 2: 解除所有 bindings

```bash
openclaw agents unbind --agent <agent-id> --all
```

### 步骤 3: 在 Main 记忆中标记为归档

```markdown
### Agent: <agent-id> (ARCHIVED)

- Created: YYYY-MM-DD
- Archived: YYYY-MM-DD
- Reason: <归档原因，如"长期未使用">
- Archive Location: ~/archives/<agent-id>-YYYYMMDD.tar.gz
- Status: Inactive (可以重新激活)
```

### 步骤 4: 可选：移动工作空间

```bash
# 将工作空间移到归档目录
mv ~/.openclaw/workspace-<agent-id> ~/openclaw-archives/workspace-<agent-id>
```

## 恢复归档的智能体

### 步骤 1: 恢复工作空间

```bash
# 解压归档
tar -xzf ~/archives/<agent-id>-YYYYMMDD.tar.gz -C ~/.openclaw/

# 或移动回来
mv ~/openclaw-archives/workspace-<agent-id> ~/.openclaw/workspace-<agent-id>
```

### 步骤 2: 添加 bindings

```bash
openclaw agents bind --agent <agent-id> --bind <channel>
```

### 步骤 3: 更新 Main 记忆

```markdown
### Agent: <agent-id>

- Created: YYYY-MM-DD
- Archived: YYYY-MM-DD
- Reactivated: YYYY-MM-DD
- Status: Active
```

### 步骤 4: 重启 Gateway

```bash
openclaw gateway restart
```

## 清理 Main 智能体记忆

定期清理 MEMORY.md，将已删除智能体的记录移到归档部分：

```markdown
## Managed Agents

### Active Agents

（活跃的智能体列表）

### Archived Agents

（归档的智能体）

### Deleted Agents（历史记录）

（已删除的智能体，保留简短记录）
```

## 工作空间清理

删除智能体后，可能的遗留文件：

- 工作空间：`~/.openclaw/workspace-<agent-id>`
- Agent 目录：`~/.openclaw/agents/<agent-id>`
- 会话记录：`~/.openclaw/agents/<agent-id>/sessions`
- 备份文件：`~/backups/` 或 `~/archives/`

OpenClaw 的 `agents delete` 命令会将工作空间、agentDir 和会话移动到系统回收站，而不是永久删除。如需彻底清理，用户需要手动清空回收站。

## 批量操作

### 删除多个测试智能体

```bash
# 列出所有测试智能体
openclaw agents list | grep "test-"

# 逐个删除
for agent in test-agent-1 test-agent-2 test-agent-3; do
  openclaw agents delete "$agent"
done
```

### 批量备份所有智能体工作空间

```bash
# 获取所有智能体 ID
agent_ids=$(openclaw agents list --json | jq -r '.[].id')

# 逐个备份
for agent_id in $agent_ids; do
  workspace=$(openclaw config get agents.list | grep -A 5 "\"id\": \"$agent_id\"" | grep workspace | cut -d'"' -f4)
  if [ -d "$workspace" ]; then
    tar -czf ~/backups/${agent_id}-$(date +%Y%m%d).tar.gz "$workspace"
  fi
done
```

## 安全检查清单

删除智能体前的检查项：

- [ ] 确认智能体 ID 拼写正确
- [ ] 询问用户是否真的要删除
- [ ] 确认是否需要备份
- [ ] 执行备份（如用户同意）
- [ ] 执行删除命令
- [ ] 更新 Main 的 MEMORY.md
- [ ] 验证删除完成
- [ ] 提示用户重启 Gateway

## 错误处理

### 智能体不存在

```bash
# 验证智能体存在
if ! openclaw agents list | grep -q "<agent-id>"; then
  echo "错误：智能体 <agent-id> 不存在"
  exit 1
fi
```

### 备份失败

```bash
# 检查备份是否成功
if [ ! -f ~/backups/backup.tar.gz ]; then
  echo "错误：备份失败，取消删除操作"
  exit 1
fi
```

### 删除失败

```bash
# openclaw agents delete 返回非零状态码时处理
if ! openclaw agents delete <agent-id>; then
  echo "错误：删除失败，请检查权限和配置"
  exit 1
fi
```

## 最佳实践

1. **删除前必备份**：即使用户说不需要，也建议至少创建一个配置备份
2. **记录删除原因**：在 MEMORY.md 中记录为什么删除，便于日后追溯
3. **分阶段删除**：可以先归档（解除 bindings），观察一段时间再永久删除
4. **保留核心智能体**：main, recruiter, person-info 等核心智能体不应随意删除
5. **验证后重启**：删除后验证配置正确，然后重启 Gateway

## 常见问题

### 问题1：误删智能体怎么办？

- 检查系统回收站，工作空间和 agentDir 可能在那里
- 如有备份，使用 `tar -xzf` 恢复
- 重新运行 `openclaw agents add` 并恢复配置

### 问题2：删除后配置文件还有记录？

- 手动编辑 `~/.openclaw/openclaw.json`
- 从 `agents.list` 和 `bindings` 中移除相关条目
- 运行 `openclaw config validate` 验证

### 问题3：删除后 Gateway 无法启动？

- 检查配置文件语法：`openclaw config validate`
- 查看日志：`openclaw gateway logs`
- 恢复之前的备份配置

## 快速参考

### 安全删除（带备份）

```bash
# 1. 备份
openclaw backup create --output ~/backups/<agent-id>-$(date +%Y%m%d).tar.gz

# 2. 删除
openclaw agents delete <agent-id>

# 3. 验证
openclaw agents list
```

### 批量清理测试智能体

```bash
for agent in $(openclaw agents list | grep "test-" | awk '{print $1}'); do
  echo "Deleting $agent..."
  openclaw agents delete "$agent"
done
```

### 恢复误删的智能体

```bash
# 1. 从备份恢复
tar -xzf ~/backups/<agent-id>-YYYYMMDD.tar.gz -C ~/.openclaw/

# 2. 重新添加到配置
openclaw agents add <agent-id> --workspace ~/.openclaw/workspace-<agent-id>

# 3. 重启
openclaw gateway restart
```
