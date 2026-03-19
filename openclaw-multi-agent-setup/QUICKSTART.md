# 快速部署指南

## 一键安装

在 PowerShell 中运行：

```powershell
cd E:\Project\openclaw\openclaw-multi-agent-setup
.\install.ps1
```

脚本会自动：

- ✓ 备份现有 OpenClaw 配置
- ✓ 复制配置文件和工作空间
- ✓ 创建必要目录
- ✓ 安装 Python 依赖（python-docx）
- ✓ 验证配置文件

## 手动安装（如果需要）

### 1. 复制配置

```powershell
Copy-Item "openclaw.json" "$env:USERPROFILE\.openclaw\openclaw.json"
```

### 2. 复制工作空间

```powershell
Copy-Item "workspace-main" "$env:USERPROFILE\.openclaw\workspace-main" -Recurse
Copy-Item "workspace-recruiter" "$env:USERPROFILE\.openclaw\workspace-recruiter" -Recurse
Copy-Item "workspace-person-info" "$env:USERPROFILE\.openclaw\workspace-person-info" -Recurse
```

### 3. 创建目录

```powershell
New-Item -Path "$env:USERPROFILE\.openclaw\workspace-person-info\persons" -ItemType Directory -Force
New-Item -Path "$env:USERPROFILE\Documents\openclaw-templates" -ItemType Directory -Force
New-Item -Path "$env:USERPROFILE\Documents\openclaw-filled" -ItemType Directory -Force
```

### 4. 安装依赖

```powershell
pip install python-docx
```

### 5. 重启 Gateway

```powershell
openclaw gateway restart
```

## 验证安装

### 检查智能体

```powershell
openclaw agents list --bindings
```

应该看到：

```
main
recruiter
person-info
```

### 检查配置

```powershell
openclaw config validate
```

应该显示："配置文件验证通过"

### 检查 Python 依赖

```powershell
python -c "import docx; print('python-docx OK')"
```

应该输出："python-docx OK"

## 测试场景

### 测试 1：查询系统智能体

向 Main 发送消息："现在有哪些智能体？"

**预期响应**：列出 main, recruiter, person-info 三个智能体

### 测试 2：创建新智能体

向 Main 发送："创建一个叫 test-bot 的智能体"

**预期响应**：Main 调度 Recruiter，Recruiter 引导创建流程

### 测试 3：收集个人信息

向 Main 发送："我想填写个人信息"

**预期响应**：Main 调度 Person-Info，Person-Info 开始逐项询问

### 测试 4：填充 Word 文档

1. 准备模板：创建 `~/Documents/openclaw-templates/test-template.docx`，内容包含 `${姓名}`, `${联系电话}` 等占位符
2. 向 Main 发送："用我的信息填写 test-template.docx"

**预期响应**：Person-Info 读取信息，填充模板，输出到 `~/Documents/openclaw-filled/`

## 故障排查

### 问题：智能体未出现

```powershell
# 检查配置
openclaw config get agents.list

# 重启
openclaw gateway restart
```

### 问题：无法调度子智能体

检查 openclaw.json 中 `agents.defaults.subagents.allowAgents` 包含 `["recruiter", "person-info"]`

### 问题：Python 脚本报错

```powershell
# 重新安装依赖
pip install --upgrade python-docx
```

### 问题：找不到模板文件

确认模板在 `$env:USERPROFILE\Documents\openclaw-templates\` 目录

## 下一步

安装完成后，查看 [README.md](README.md) 获取：

- 详细的系统架构说明
- 更多使用场景
- 扩展指南
