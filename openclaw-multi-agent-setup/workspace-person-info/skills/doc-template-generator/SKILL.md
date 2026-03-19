---
name: doc-template-generator
description: |
  Intelligent document analysis and template generation skill.
  Extracts text from Word documents, uses LLM to identify fields, and generates templates with placeholders.

metadata:
  openclaw:
    requires:
      - python3
      - python-docx>=0.8.11
    install: |
      pip install -r {baseDir}/scripts/requirements.txt
---

# Doc Template Generator Skill

## Overview

This skill provides intelligent document processing capabilities:

1. **Text Extraction**: Extract all text content from Word (.docx) documents
2. **Field Identification**: Use Minimax AI to identify fields that need to be filled
3. **Field Mapping**: Map identified fields to standard personal information schema
4. **Template Generation**: Generate a template with `{{placeholder}}` markers

## Workflow

### Step 1: Extract Document Text

**Command**:

```bash
python {baseDir}/scripts/template_generator.py \
  --action extract \
  --input <input_docx_path> \
  --output <output_text_path>
```

**Parameters**:

- `--action extract`: Specify extraction mode
- `--input`: Path to input .docx file
- `--output`: Path to save extracted text

**Example**:

```bash
python {baseDir}/scripts/template_generator.py \
  --action extract \
  --input ~/.openclaw/workspace-person-info/uploads/入职申请表.docx \
  --output ~/.openclaw/workspace-person-info/temp/extracted_text.txt
```

**Output**:
A text file containing all paragraph text from the document.

---

### Step 2: Identify Fields with LLM

**Process**:

1. Read the extracted text file
2. Send to Minimax API with a structured prompt
3. Parse JSON response containing field information

**Prompt Template**:

```
你是一个文档字段识别专家。请分析以下 Word 文档内容，识别出所有需要填写个人信息的字段。

文档内容：
"""
{extracted_text}
"""

标准个人信息字段类别：
1. 基本信息：姓名、性别、出生日期、身份证号、联系电话、电子邮箱
2. 地址信息：现居地址、户籍地址、邮政编码
3. 教育背景：学历、毕业院校、专业、毕业时间
4. 工作经历：公司名称、职位、入职时间、离职时间、工作描述
5. 技能特长：专业技能、语言能力、证书资质

请以 JSON 格式返回识别结果，包括：
- location: 字段在文档中的位置描述（如"第2段"、"表格第1行"）
- fieldName: 字段名称（使用文档中的原始名称）
- standardPath: 映射到标准字段的 JSON 路径（如 basic.name）
- required: 是否必填（true/false）

输出格式：
{
  "fields": [
    {"location": "第1段，'姓名：'后面", "fieldName": "姓名", "standardPath": "basic.name", "required": true},
    {"location": "第3段，'电话：'后面", "fieldName": "电话", "standardPath": "basic.phone", "required": true}
  ]
}

只返回 JSON，不要包含其他解释文字。
```

**Expected Response**:

```json
{
  "fields": [
    {
      "location": "第1段，'姓名：'后面",
      "fieldName": "姓名",
      "standardPath": "basic.name",
      "required": true
    },
    {
      "location": "第2段，'性别：'后面",
      "fieldName": "性别",
      "standardPath": "basic.gender",
      "required": true
    },
    {
      "location": "第3段，'联系电话：'后面",
      "fieldName": "联系电话",
      "standardPath": "basic.phone",
      "required": true
    },
    {
      "location": "第5段，'毕业院校：'后面",
      "fieldName": "毕业院校",
      "standardPath": "education.university",
      "required": false
    }
  ]
}
```

**Save to File**:
Save the parsed JSON response to a file (e.g., `temp/fields.json`) for the next step.

---

### Step 3: Generate Template Document

**Command**:

```bash
python {baseDir}/scripts/template_generator.py \
  --action generate \
  --input <original_docx> \
  --fields <fields_json> \
  --output <template_docx>
```

**Parameters**:

- `--action generate`: Specify template generation mode
- `--input`: Path to original input .docx file
- `--fields`: Path to fields.json (from Step 2)
- `--output`: Path to save generated template

**Example**:

```bash
python {baseDir}/scripts/template_generator.py \
  --action generate \
  --input ~/.openclaw/workspace-person-info/uploads/入职申请表.docx \
  --fields ~/.openclaw/workspace-person-info/temp/fields.json \
  --output ~/.openclaw/workspace-person-info/templates/入职申请表-模板.docx
```

**Processing Logic**:

1. Load original .docx document
2. Read fields.json to get field locations and names
3. Search for field names in document paragraphs
4. Insert `{{standardPath}}` placeholder after field names
5. Save as new template document

**Example Transformation**:

**Original Document**:

```
姓名：
性别：
联系电话：
```

**Generated Template**:

```
姓名：{{basic.name}}
性别：{{basic.gender}}
联系电话：{{basic.phone}}
```

---

## Standard Personal Information Schema

The skill maps document fields to a standardized JSON schema:

### Schema Structure

```json
{
  "basic": {
    "name": "string", // 姓名
    "nameEn": "string", // 英文名
    "gender": "string", // 性别
    "age": "string", // 年龄（如"28岁"）
    "birthDate": "string", // 出生日期 (YYYY-MM-DD)
    "idCard": "string", // 身份证号
    "phone": "string", // 联系电话
    "email": "string", // 电子邮箱
    "jobIntention": "string" // 求职意向
  },
  "address": {
    "current": "string", // 现居地址
    "registered": "string", // 户籍地址
    "postalCode": "string" // 邮政编码
  },
  "education": [
    {
      "startDate": "string", // 入学时间 (YYYY.MM)
      "endDate": "string", // 毕业时间 (YYYY.MM)
      "university": "string", // 学校名称
      "major": "string", // 专业
      "degree": "string", // 学历层次
      "gpa": "string" // GPA（可选）
    }
  ],
  "experience": [
    {
      "startDate": "string", // 入职时间 (YYYY.MM)
      "endDate": "string", // 离职时间 (YYYY.MM 或 "至今")
      "company": "string", // 公司名称
      "position": "string", // 职位
      "description": "string" // 工作描述
    }
  ],
  "skills": {
    "certificates": ["string"], // 技能证书列表
    "professional": "string" // 专业技能描述
  },
  "selfEvaluation": "string" // 自我评价
}
```

### Common Field Mappings

| Document Field Name          | Standard Path             | Description        |
| ---------------------------- | ------------------------- | ------------------ |
| 姓名 / 姓氏名字 / 申请人姓名 | `basic.name`              | 中文全名           |
| 性别 / 男女                  | `basic.gender`            | 性别（男/女/其他） |
| 年龄                         | `basic.age`               | 年龄（如"28岁"）   |
| 出生日期 / 生日              | `basic.birthDate`         | 出生日期           |
| 身份证号 / 身份证号码        | `basic.idCard`            | 18位身份证号       |
| 联系电话 / 手机号 / 电话     | `basic.phone`             | 11位手机号         |
| 电子邮箱 / 邮箱 / Email      | `basic.email`             | 电子邮箱地址       |
| 求职意向 / 应聘岗位          | `basic.jobIntention`      | 求职意向           |
| 现居地址 / 联系地址          | `address.current`         | 现居住地址         |
| 户籍地址 / 户口所在地        | `address.registered`      | 户籍地址           |
| 学历 / 最高学历              | `education[0].degree`     | 学历层次           |
| 毕业院校 / 学校              | `education[0].university` | 毕业学校名称       |
| 专业 / 所学专业              | `education[0].major`      | 专业名称           |
| 毕业时间 / 毕业日期          | `education[0].endDate`    | 毕业年月           |
| GPA / 绩点                   | `education[0].gpa`        | GPA成绩            |
| 公司 / 工作单位              | `experience[0].company`   | 公司名称           |
| 职位 / 岗位                  | `experience[0].position`  | 职位名称           |
| 技能证书 / 资格证书          | `skills.certificates`     | 证书列表           |
| 专业技能 / 技能掌握          | `skills.professional`     | 技能描述           |
| 自我评价 / 个人评价          | `selfEvaluation`          | 自我评价           |

---

## Usage Example

### Complete Workflow

**User Request**:

```
"我有一份入职申请表需要填写，文档名是 入职申请表.docx"
```

**Agent Actions**:

**1. Extract Text**

```bash
python {baseDir}/scripts/template_generator.py \
  --action extract \
  --input ~/.openclaw/workspace-person-info/uploads/入职申请表.docx \
  --output ~/.openclaw/workspace-person-info/temp/extracted_text.txt
```

**2. Identify Fields (Call LLM)**

Read `temp/extracted_text.txt`, send to Minimax API with the prompt template, parse response:

```json
{
  "fields": [
    { "location": "第1段", "fieldName": "姓名", "standardPath": "basic.name", "required": true },
    { "location": "第2段", "fieldName": "性别", "standardPath": "basic.gender", "required": true },
    {
      "location": "第3段",
      "fieldName": "出生日期",
      "standardPath": "basic.birthDate",
      "required": true
    },
    {
      "location": "第4段",
      "fieldName": "身份证号",
      "standardPath": "basic.idCard",
      "required": true
    },
    {
      "location": "第5段",
      "fieldName": "联系电话",
      "standardPath": "basic.phone",
      "required": true
    },
    {
      "location": "第6段",
      "fieldName": "毕业院校",
      "standardPath": "education.university",
      "required": false
    }
  ]
}
```

Save to `temp/fields.json`.

**3. Generate Template**

```bash
python {baseDir}/scripts/template_generator.py \
  --action generate \
  --input ~/.openclaw/workspace-person-info/uploads/入职申请表.docx \
  --fields ~/.openclaw/workspace-person-info/temp/fields.json \
  --output ~/.openclaw/workspace-person-info/templates/入职申请表-模板.docx
```

**4. Report to User**

```
✅ 文档分析完成！

识别到 6 个字段：
1. 姓名 → basic.name ✓
2. 性别 → basic.gender ✓
3. 出生日期 → basic.birthDate ✓
4. 身份证号 → basic.idCard ✓
5. 联系电话 → basic.phone ✓
6. 毕业院校 → education.university

模板已生成：templates/入职申请表-模板.docx

现在可以选择个人信息进行填充。
```

---

## Requirements

### Python Dependencies

Create `{baseDir}/scripts/requirements.txt`:

```
python-docx==0.8.11
```

### Installation

When the skill is first used, run:

```bash
pip install -r {baseDir}/scripts/requirements.txt
```

---

## Script Reference

### template_generator.py

**Location**: `{baseDir}/scripts/template_generator.py`

**Command Line Interface**:

```
python template_generator.py --help

Usage: template_generator.py [OPTIONS]

Options:
  --action [extract|generate]  Action to perform (required)
  --input PATH                 Input .docx file path (required)
  --output PATH                Output file path (required)
  --fields PATH                Fields JSON file (required for 'generate' action)
  --help                       Show this message and exit
```

**Functions**:

- `extract_text(input_docx, output_text)`: Extract all text from Word document
- `generate_template(input_docx, fields_json, output_docx)`: Generate template with placeholders

---

## Error Handling

### Common Errors

**1. python-docx not installed**

```
ModuleNotFoundError: No module named 'docx'
```

**Solution**:

```bash
pip install python-docx
```

**2. Input file not found**

```
FileNotFoundError: [Errno 2] No such file or directory: '...'
```

**Solution**:

- Check file path is correct
- Ensure file exists in `uploads/` directory
- Use absolute path starting with `~/.openclaw/workspace-person-info/`

**3. Invalid .docx file**

```
BadZipFile: File is not a zip file
```

**Solution**:

- Ensure file is in .docx format (not .doc or .pdf)
- Try opening and re-saving the file in Microsoft Word

**4. Fields JSON parsing error**

```
JSONDecodeError: Expecting value: line 1 column 1 (char 0)
```

**Solution**:

- Verify LLM response is valid JSON
- Check `fields.json` file format
- Manually fix JSON syntax errors if needed

---

## Advanced Usage

### Custom Field Mapping

If the LLM's field identification is incomplete, allow manual adjustments:

**Edit fields.json**:

```json
{
  "fields": [
    // ...existing fields...
    {
      "location": "第10段",
      "fieldName": "紧急联系人",
      "standardPath": "basic.emergencyContact",
      "required": false
    }
  ]
}
```

Then regenerate the template with the updated `fields.json`.

### Batch Processing

Process multiple documents in a loop:

```bash
for doc in uploads/*.docx; do
  basename=$(basename "$doc" .docx)
  python {baseDir}/scripts/template_generator.py \
    --action extract \
    --input "$doc" \
    --output "temp/${basename}_text.txt"

  # [Call LLM to identify fields...]

  python {baseDir}/scripts/template_generator.py \
    --action generate \
    --input "$doc" \
    --fields "temp/${basename}_fields.json" \
    --output "templates/${basename}-模板.docx"
done
```

---

## Best Practices

1. **Document Preparation**:
   - Use well-formatted Word documents with clear field labels
   - Avoid complex nested tables (they're harder to analyze)
   - Use consistent formatting (e.g., "Field Name: \_\_\_\_")

2. **LLM Prompt Optimization**:
   - Provide clear examples of field names in the prompt
   - Include document-specific context if available
   - Use lower temperature (0.1-0.3) for more consistent parsing

3. **Error Recovery**:
   - Always save intermediate results (extracted text, fields JSON)
   - Allow users to manually review and adjust field mappings
   - Provide fallback to manual template creation

4. **Privacy**:
   - Never send actual personal data to LLM APIs
   - Only extract document structure and field names for analysis
   - All personal information stays local

---

## Integration with word-doc-filler

After generating a template with this skill, use the `word-doc-filler` skill to fill it:

```bash
python ~/.openclaw/workspace-person-info/skills/word-doc-filler/scripts/word_processor.py \
  --template templates/入职申请表-模板.docx \
  --person-data persons/zhangsan-20260315.json \
  --output output/入职申请表-张三-filled.docx
```

This completes the end-to-end intelligent document processing workflow.
