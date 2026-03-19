---
name: word-doc-filler
description: 读取 Word 模板，识别字段占位符，使用个人信息 JSON 自动填充
metadata:
  {
    "openclaw":
      {
        "emoji": "📝",
        "requires": { "bins": ["python3"] },
        "install":
          [
            {
              "id": "pip",
              "kind": "node",
              "bins": ["python3"],
              "packages": ["python-docx"],
              "label": "安装 Python 依赖 python-docx",
            },
          ],
      },
  }
---

# Word Document Filler

## 功能说明

这个技能自动将个人信息填充到 Word 文档模板中：

- 读取 Word 模板文件（`.docx` 格式）
- 识别模板中的字段占位符（格式：`${字段名}`）
- 使用个人信息 JSON 数据填充这些字段
- 生成填充后的 Word 文档

## 前置条件

### 1. 安装 Python 依赖

首次使用前，安装 python-docx 库：

```bash
pip install -r {baseDir}/scripts/requirements.txt
```

或直接安装：

```bash
pip install python-docx
```

### 2. 准备目录结构

确保以下目录存在：

```bash
mkdir -p ~/Documents/openclaw-templates  # 用户放置模板的目录
mkdir -p ~/Documents/openclaw-filled     # 填充后文档的输出目录
```

## 使用流程

### 步骤 1: 准备 Word 模板

创建 Word 模板，使用 `${字段名}` 格式作为占位符：

**模板示例**（resume-template.docx）：

```
个人简历

姓名：${姓名}
性别：${性别}
出生日期：${出生日期}
联系电话：${联系电话}
电子邮箱：${电子邮箱}

教育背景：
${学历} | ${毕业院校} | ${专业} | ${毕业时间}

工作经历：
${工作经历}

现居地址：${现居地址}
```

将模板保存到 `~/Documents/openclaw-templates/` 目录。

### 步骤 2: 准备个人信息 JSON

确保有可用的个人信息 JSON 文件（<workspace>/persons/<name>-<date>.json），格式参考 info-collector 技能。

### 步骤 3: 执行填充

使用 bash 工具调用 Python 脚本：

```bash
python {baseDir}/scripts/word_processor.py \
  --template ~/Documents/openclaw-templates/resume-template.docx \
  --person-data persons/zhangsan-20260315.json \
  --output ~/Documents/openclaw-filled/resume-zhangsan-filled.docx
```

### 步骤 4: 确认结果

告知用户填充后的文档位置：

```
"填充完成！文档已保存到：
~/Documents/openclaw-filled/resume-zhangsan-filled.docx

你可以打开查看。"
```

## 字段映射规则

### 简单字段映射

| 模板占位符    | JSON 路径                  | 示例值                     |
| ------------- | -------------------------- | -------------------------- |
| `${姓名}`     | `basic.name`               | 张三                       |
| `${性别}`     | `basic.gender`             | 男                         |
| `${出生日期}` | `basic.birthDate`          | 1990-01-15                 |
| `${联系电话}` | `basic.phone`              | 13800138000                |
| `${电子邮箱}` | `basic.email`              | zhangsan@example.com       |
| `${身份证号}` | `basic.idCard`             | 110101199001150011         |
| `${现居地址}` | `address.current`          | 北京市朝阳区XX路XX号       |
| `${户籍地址}` | `address.registered`       | 河北省石家庄市XX区XX路XX号 |
| `${邮政编码}` | `address.postalCode`       | 100000                     |
| `${学历}`     | `education.degree`         | 本科                       |
| `${毕业院校}` | `education.university`     | 北京大学                   |
| `${专业}`     | `education.major`          | 计算机科学与技术           |
| `${毕业时间}` | `education.graduationDate` | 2012-06                    |

### 复杂字段：工作经历

工作经历是数组类型，需要特殊处理。在模板中使用 `${工作经历}` 占位符，脚本会自动格式化为列表：

**JSON 数据**：

```json
"experience": [
  {
    "company": "XX科技有限公司",
    "position": "软件工程师",
    "startDate": "2012-07",
    "endDate": "2015-08",
    "description": "负责后端开发和系统维护"
  },
  {
    "company": "YY互联网公司",
    "position": "高级工程师",
    "startDate": "2015-09",
    "endDate": "至今",
    "description": "负责架构设计和团队管理"
  }
]
```

**填充后的格式**：

```
1. XX科技有限公司 | 软件工程师 | 2012-07 ~ 2015-08
   负责后端开发和系统维护

2. YY互联网公司 | 高级工程师 | 2015-09 ~ 至今
   负责架构设计和团队管理
```

## Python 脚本说明

脚本位置：`{baseDir}/scripts/word_processor.py`

### 命令行参数

```
--template: Word 模板文件路径（必需）
--person-data: 个人信息 JSON 文件路径（必需）
--output: 输出文件路径（必需）
```

### 脚本逻辑

1. 读取模板文件
2. 读取个人信息 JSON
3. 遍历文档中的所有段落
4. 查找 `${字段名}` 占位符
5. 使用 JSON 数据替换占位符
6. 特殊处理工作经历（数组格式化）
7. 保存填充后的文档

### 依赖说明

- `python-docx`：用于读写 Word 文档
- Python 3.7+

## 示例场景

### 场景 1：填充简历模板

```
用户："用我的信息填写简历模板"

智能体响应：
"好的，我看到你已有保存的个人信息：
1. persons/zhangsan-20260315.json

模板文件已准备好吗？请将简历模板放在：
~/Documents/openclaw-templates/

文件名是什么？"

用户："resume-template.docx"

智能体：
"开始填充...

[执行命令]
python ~/.openclaw/workspace-person-info/skills/word-doc-filler/scripts/word_processor.py \
  --template ~/Documents/openclaw-templates/resume-template.docx \
  --person-data persons/zhangsan-20260315.json \
  --output ~/Documents/openclaw-filled/resume-zhangsan-filled.docx

填充完成！文档已保存到：
~/Documents/openclaw-filled/resume-zhangsan-filled.docx"
```

### 场景 2：填充求职申请表

```
用户："帮我填写求职申请表"

智能体：
"好的！

你的个人信息：
- persons/zhangsan-20260315.json

请将求职申请表模板放入以下目录：
~/Documents/openclaw-templates/

模板文件名是？"

用户："job-application.docx"

智能体：
"开始处理...
[执行填充命令]

完成！填充后的求职申请表：
~/Documents/openclaw-filled/job-application-zhangsan-filled.docx"
```

## 错误处理

### 错误 1：模板文件不存在

**症状**：

```
FileNotFoundError: [Errno 2] No such file or directory: '~/Documents/openclaw-templates/template.docx'
```

**解决**：

1. 确认模板文件在正确的目录
2. 检查文件名拼写
3. 确认文件扩展名是 `.docx`

```
智能体响应：
"未找到模板文件。请确认：
1. 文件在 ~/Documents/openclaw-templates/ 目录
2. 文件名是否正确：resume-template.docx
3. 文件格式是否为 .docx"
```

### 错误 2：JSON 数据缺失字段

**症状**：模板中的某些字段未被填充（保留 `${字段名}`）

**解决**：

1. 检查 JSON 文件是否包含对应字段
2. 确认字段路径正确

```
智能体响应：
"填充完成，但以下字段在你的个人信息中未找到：
- ${身份证号}

你想要：
1. 更新个人信息补充这些字段
2. 手动填写这些字段（文档已生成，剩余字段需手动填写）

请选择 1 或 2："
```

### 错误 3：python-docx 未安装

**症状**：

```
ModuleNotFoundError: No module named 'docx'
```

**解决**：

```bash
pip install python-docx
```

```
智能体响应：
"Python 依赖未安装。请运行：
pip install python-docx

或安装所有依赖：
pip install -r ~/.openclaw/workspace-person-info/skills/word-doc-filler/scripts/requirements.txt"
```

## 占位符命名规范

### 推荐的占位符名称

使用清晰、直观的中文名称：

- `${姓名}` ✅
- `${性别}` ✅
- `${联系电话}` ✅
- `${毕业院校}` ✅

避免使用：

- `${name}` ❌（使用英文不直观）
- `${xingming}` ❌（拼音不清晰）
- `${field1}` ❌（无意义的编号）

### 占位符格式规则

- 必须使用 `${...}` 格式
- 字段名不能包含空格
- 字段名区分大小写

正确示例：

- `${姓名}` ✅
- `${联系电话}` ✅
- `${毕业时间}` ✅

错误示例：

- `[姓名]` ❌（格式错误）
- `${姓 名}` ❌（包含空格）
- `$姓名$` ❌（格式错误）
- `{姓名}` ❌（缺少 $）

## 高级用法

### 自定义字段映射

如果需要更复杂的字段映射规则，可以扩展脚本支持映射配置文件：

**mapping.json**：

```json
{
  "${全名}": "basic.name",
  "${邮件}": "basic.email",
  "${学校全称}": "education.university"
}
```

在脚本中添加 `--mapping` 参数支持自定义映射。

### 批量填充

如果需要为多个人填充相同模板：

```bash
# 列出所有个人信息文件
for person_file in persons/*.json; do
  person_name=$(basename "$person_file" .json)
  python {baseDir}/scripts/word_processor.py \
    --template ~/Documents/openclaw-templates/template.docx \
    --person-data "$person_file" \
    --output ~/Documents/openclaw-filled/${person_name}-filled.docx
done
```

## 测试清单

在实际使用前，测试以下场景：

- [ ] 模板文件能正常读取
- [ ] 简单字段（姓名、性别等）正确填充
- [ ] 日期字段格式正确
- [ ] 工作经历（数组）正确展开和格式化
- [ ] 缺失字段不会导致脚本崩溃
- [ ] 输出文件可以正常打开

## 快速参考

### 完整使用示例

```bash
# 1. 准备模板（用户手动操作）
# 将 resume-template.docx 复制到 ~/Documents/openclaw-templates/

# 2. 确保有个人信息 JSON
# persons/zhangsan-20260315.json

# 3. 执行填充
python ~/.openclaw/workspace-person-info/skills/word-doc-filler/scripts/word_processor.py \
  --template ~/Documents/openclaw-templates/resume-template.docx \
  --person-data persons/zhangsan-20260315.json \
  --output ~/Documents/openclaw-filled/resume-zhangsan-filled.docx

# 4. 打开填充后的文档
open ~/Documents/openclaw-filled/resume-zhangsan-filled.docx
```

### 检查依赖安装

```bash
python -c "import docx; print('python-docx 已安装')"
```

### 查看 JSON 数据

```bash
cat persons/zhangsan-20260315.json | python -m json.tool
```

## 注意事项

1. **模板格式**：只支持 `.docx` 格式（Word 2007 及以上），不支持旧版 `.doc` 格式
2. **字段大小写**：占位符名称区分大小写，`${姓名}` 和 `${姓名}` 被视为不同字段
3. **特殊字符**：占位符名称中避免使用特殊字符
4. **文件权限**：确保脚本有读取模板和写入输出目录的权限
5. **编码问题**：JSON 文件应使用 UTF-8 编码
