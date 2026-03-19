# Person-Info v2.0 智能文档处理指南

## 🎉 新功能：AI 智能文档处理

### 核心创新

不再需要手动创建带占位符的模板！只需：

1. **上传任意 Word 文档**（如空白表单、申请表等）
2. **AI 自动分析**字段和结构
3. **智能生成模板**带占位符
4. **一键填充**个人信息

---

## 🚀 快速开始

### 第一步：部署新版本

```powershell
cd E:\Project\openclaw\openclaw-multi-agent-setup
.\deploy-person-info-v2.ps1
```

### 第二步：重启 Gateway

```powershell
cd E:\Project\openclaw
pnpm openclaw gateway restart
```

### 第三步：准备测试文档

创建一个测试文档 `测试简历.docx`，内容如下：

```
个人简历

姓名：
性别：
出生日期：
联系电话：
电子邮箱：

教育背景
毕业院校：
专业：
学历：
```

将文档放到：`C:\Users\Sora\.openclaw\workspace-person-info\uploads\测试简历.docx`

### 第四步：测试智能处理

向 **Main 智能体**发送消息（通过 WhatsApp/Telegram）：

```
我有一份简历表格需要填写，文档名是 测试简历.docx
```

**期望流程**：

1. Person-Info 提取文档文本
2. 调用 Minimax AI 识别字段
3. 生成模板：`templates/测试简历-模板.docx`
4. 列出可用的个人信息
5. 选择信息后自动填充
6. 输出完整文档：`output/测试简历-张三-filled.docx`

---

## 📋 完整工作流

### 场景 1：首次使用，收集信息

```
用户："我想填写个人信息"

Person-Info：
"好的，我来帮你收集。首先是基本信息：

1️⃣ 你的姓名是？"

[逐步收集...]

"信息收集完成！已保存为：
persons/zhangsan-20260315.json"
```

### 场景 2：智能处理新文档

```
用户："我有一份入职申请表需要填写，文档是 入职申请表.docx"

Person-Info：
"收到！开始智能分析文档...

--[步骤 1] 提取文本--
[执行 template_generator.py --action extract]

--[步骤 2] AI 字段识别--
[调用 Minimax API 分析]

✅ 识别到 8 个字段：
1. 姓名 → basic.name
2. 性别 → basic.gender
3. 出生日期 → basic.birthDate
4. 身份证号 → basic.idCard
5. 联系电话 → basic.phone
6. 电子邮箱 → basic.email
7. 毕业院校 → education.university
8. 专业 → education.major

--[步骤 3] 生成模板--
[执行 template_generator.py --action generate]

模板已生成：templates/入职申请表-模板.docx

---

现在选择要使用的个人信息：
1. 张三 (persons/zhangsan-20260315.json)
2. 李四 (persons/lisi-20260316.json)

请选择序号："

---

用户："1"

Person-Info：
"开始填充...

[执行 word_processor.py]

🎉 完成！文档已保存到：
~/.openclaw/workspace-person-info/output/入职申请表-张三-filled.docx

所有字段已自动填写完毕，可以直接使用了！"
```

### 场景 3：使用已有模板快速填充

```
用户："用我的信息填写这个模板：templates/标准简历-模板.docx"

Person-Info：
"要使用哪份信息？
1. 张三 (persons/zhangsan-20260315.json)"

用户："1"

Person-Info：
"填充中...

完成！文档已保存到：
output/标准简历-张三-filled.docx"
```

---

## 🗂️ 目录结构

```
~/.openclaw/workspace-person-info/
├── AGENTS.md              # v2.0 操作手册（已更新）
├── uploads/               # 🆕 用户上传的原始文档
│   └── 入职申请表.docx
├── temp/                  # 🆕 临时分析文件
│   ├── extracted_text.txt
│   └── fields.json
├── templates/             # 🆕 生成的模板
│   └── 入职申请表-模板.docx
├── persons/               # 个人信息存储
│   └── zhangsan-20260315.json
├── output/                # 🆕 填充后文档输出
│   └── 入职申请表-张三-filled.docx
└── skills/
    ├── info-collector/
    │   └── SKILL.md
    ├── doc-template-generator/  # 🆕 智能模板生成
    │   ├── SKILL.md
    │   └── scripts/
    │       ├── template_generator.py
    │       └── requirements.txt
    └── word-doc-filler/
        ├── SKILL.md
        └── scripts/
            ├── word_processor.py
            └── requirements.txt
```

---

## 🔧 Minimax API 配置

Person-Info 使用系统配置的 Minimax API 进行字段识别：

**检查配置**：

```powershell
Get-Content "$env:USERPROFILE\.openclaw\openclaw.json" | ConvertFrom-Json | Select-Object -ExpandProperty agents | Where-Object {$_.id -eq "person-info"} | Select-Object -ExpandProperty model
```

**应该显示**：

```
primary: minimax-codeplan/MiniMax-M2.5
```

如果没有配置 Minimax API，请更新 `openclaw.json`：

```json
{
  "agents": {
    "list": [
      {
        "id": "person-info",
        "model": {
          "primary": "minimax-codeplan/MiniMax-M2.5"
        }
      }
    ]
  }
}
```

---

## 🧪 测试 Python 脚本

### 测试文本提取

```powershell
python "$env:USERPROFILE\.openclaw\workspace-person-info\skills\doc-template-generator\scripts\template_generator.py" `
  --action extract `
  --input "$env:USERPROFILE\.openclaw\workspace-person-info\uploads\测试简历.docx" `
  --output "$env:USERPROFILE\.openclaw\workspace-person-info\temp\extracted_text.txt"
```

**预期输出**：

```
✓ Text extracted successfully
  Input:  C:\Users\Sora\.openclaw\workspace-person-info\uploads\测试简历.docx
  Output: C:\Users\Sora\.openclaw\workspace-person-info\temp\extracted_text.txt
  Total paragraphs: 10
  Total tables: 0
```

### 测试模板生成

首先手动创建 `temp/fields.json`：

```json
{
  "fields": [
    { "location": "第3段", "fieldName": "姓名", "standardPath": "basic.name", "required": true },
    { "location": "第4段", "fieldName": "性别", "standardPath": "basic.gender", "required": true },
    {
      "location": "第5段",
      "fieldName": "出生日期",
      "standardPath": "basic.birthDate",
      "required": true
    },
    {
      "location": "第6段",
      "fieldName": "联系电话",
      "standardPath": "basic.phone",
      "required": true
    },
    {
      "location": "第7段",
      "fieldName": "电子邮箱",
      "standardPath": "basic.email",
      "required": true
    }
  ]
}
```

然后运行：

```powershell
python "$env:USERPROFILE\.openclaw\workspace-person-info\skills\doc-template-generator\scripts\template_generator.py" `
  --action generate `
  --input "$env:USERPROFILE\.openclaw\workspace-person-info\uploads\测试简历.docx" `
  --fields "$env:USERPROFILE\.openclaw\workspace-person-info\temp\fields.json" `
  --output "$env:USERPROFILE\.openclaw\workspace-person-info\templates\测试简历-模板.docx"
```

**预期输出**：

```
Field mapping loaded: 5 fields
  姓名 → {{basic.name}}
  性别 → {{basic.gender}}
  出生日期 → {{basic.birthDate}}
  联系电话 → {{basic.phone}}
  电子邮箱 → {{basic.email}}
  ✓ Inserted {{ basic.name }} after '姓名'
  ✓ Inserted {{ basic.gender }} after '性别'
  ✓ Inserted {{ basic.birthDate }} after '出生日期'
  ✓ Inserted {{ basic.phone }} after '联系电话'
  ✓ Inserted {{ basic.email }} after '电子邮箱'

✓ Template generated successfully
  Placeholders inserted: 5
```

打开生成的模板文档，应该看到：

```
姓名：{{basic.name}}
性别：{{basic.gender}}
出生日期：{{basic.birthDate}}
联系电话：{{basic.phone}}
电子邮箱：{{basic.email}}
```

---

## ❓ 常见问题

### Q1: Python 依赖安装失败？

```powershell
pip install python-docx --user
```

### Q2: 无法找到 python 命令？

确保 Python 在 PATH 中：

```powershell
python --version
```

如果失败，从 https://www.python.org/downloads/ 安装 Python 3.7+

### Q3: Minimax API 调用失败？

- 检查 API Key 配置
- 确认账户余额充足
- 验证网络连接

### Q4: 字段识别不准确？

手动编辑 `temp/fields.json`，调整字段映射后重新生成模板。

### Q5: 填充后格式错乱？

python-docx 只替换文本，不修改格式。确保原文档使用简单的文本样式。

---

## 📚 更多资源

- **完整操作手册**：`~/.openclaw/workspace-person-info/AGENTS.md`
- **技能文档**：
  - `skills/doc-template-generator/SKILL.md`
  - `skills/word-doc-filler/SKILL.md`
  - `skills/info-collector/SKILL.md`

---

## 🎯 下一步计划

- [ ] 支持 Excel 表格填充
- [ ] 支持 PDF 文档处理
- [ ] 添加模板库（常用模板预设）
- [ ] 支持批量文档处理
- [ ] Web UI 管理界面

---

## 💬 反馈与支持

遇到问题？向 Person-Info 智能体反馈：

```
"我在使用智能文档处理时遇到了问题..."
```

Person-Info 会帮你排查并解决问题！🦞
