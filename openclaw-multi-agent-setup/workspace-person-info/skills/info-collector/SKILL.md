---
name: info-collector
description: 引导式个人信息收集，验证格式并保存为 JSON
metadata: { "openclaw": { "emoji": "📋" } }
---

# Info Collector

## 功能说明

这个技能提供结构化的个人信息收集流程：

- 提供标准化的问题模板
- 验证输入格式（手机号、邮箱、身份证等）
- 生成 JSON 格式的数据文件
- 支持信息更新和修改

## 信息收集模板

### 基本信息

```
1. 姓名（中文全名）：
2. 英文姓名（可选）：
3. 性别：
4. 年龄（或出生日期 YYYY-MM-DD）：
5. 身份证号（可选）：
6. 联系电话：
7. 电子邮箱：
8. 求职意向（可选）：
```

### 地址信息

```
9. 现居地址：
10. 户籍地址（如与现居地址相同可跳过）：
11. 邮政编码：
```

### 教育背景（可以有多条：本科、硕士、博士等）

```
对于每段教育经历：
- 入学时间（YYYY.MM）：
- 毕业时间（YYYY.MM）：
- 学校名称：
- 专业：
- 学历层次（本科/硕士/博士）：
- GPA（可选）：
```

### 工作经历（可以有多条）

```
对于每份工作经历：
- 入职时间（YYYY.MM）：
- 离职时间（YYYY.MM 或"至今"）：
- 公司名称：
- 职位：
- 工作描述（详细描述工作职责和成果）：
```

### 技能与证书

```
12. 技能证书（多个用逗号分隔）：
13. 技能掌握（详细描述专业技能）：
```

### 自我评价

```
14. 自我评价（简要总结个人特点和优势）：
```

## 使用流程

### 步骤 1: 启动收集

```
用户说："我想填写个人信息" 或 "收集我的信息"

智能体响应：
"好的，我来帮你收集个人信息。我会逐步询问，你可以选择跳过某些可选字段。

首先，基本信息：
1. 请告诉我你的姓名（中文全名）"
```

### 步骤 2: 逐项收集并验证

```
收集每个字段时：
1. 显示问题
2. 等待用户输入
3. 验证格式（如果有验证规则）
4. 如果格式错误，友好提示并要求重新输入
5. 继续下一个字段
```

### 步骤 3: 确认和保存

```
收集完成后，显示完整信息：
"请确认以下信息是否正确：

【基本信息】
姓名：张三
性别：男
...

【地址信息】
现居地址：...

【教育背景】
...

【工作经历】
1. XX公司 - 软件工程师 (2012-07 ~ 2015-08)
   ...

信息正确吗？（是/否/修改）"
```

### 步骤 4: 生成 JSON 文件

```
用户确认后，生成 JSON 文件：
文件名：persons/<姓名>-<YYYYMMDD>.json
格式：见下方 JSON 模板
```

## JSON 数据模板（完整版）

```json
{
  "basic": {
    "name": "陈宇",
    "nameEn": "Chen Yu",
    "gender": "男",
    "age": "28岁",
    "birthDate": "1995-03-10",
    "idCard": "110101199503100011",
    "phone": "13987654321",
    "email": "chenyu@qq.com",
    "jobIntention": "后端开发工程师"
  },
  "address": {
    "current": "北京市朝阳区XX路XX号",
    "registered": "河北省石家庄市XX区XX路XX号",
    "postalCode": "100000"
  },
  "education": [
    {
      "startDate": "2016.09",
      "endDate": "2020.06",
      "university": "XX理工大学",
      "major": "计算机科学与技术",
      "degree": "本科",
      "gpa": "3.6/4.0"
    },
    {
      "startDate": "2020.09",
      "endDate": "2023.06",
      "university": "XX大学",
      "major": "计算机应用技术",
      "degree": "硕士",
      "gpa": ""
    }
  ],
  "experience": [
    {
      "startDate": "2023.07",
      "endDate": "至今",
      "company": "XX科技有限公司",
      "position": "后端开发工程师",
      "description": "1. 参与公司核心业务系统开发，基于Java、SpringBoot框架进行接口开发和功能迭代，负责用户模块、订单模块的代码编写和优化；\n2. 对接数据库（MySQL、Redis），优化SQL语句，提升系统响应速度，将接口响应时间从500ms优化至100ms以内；\n3. 参与系统测试和bug修复，配合测试团队完成回归测试，确保系统稳定运行，上线后系统故障率低于0.5%；\n4. 参与技术文档编写，整理接口文档、开发手册，协助新人快速熟悉业务和代码逻辑。"
    }
  ],
  "skills": {
    "certificates": ["计算机软件水平考试（中级）", "MySQL数据库工程师证书", "英语六级证书"],
    "professional": "熟练掌握Java、Python编程语言，熟悉SpringBoot、SpringCloud框架，精通MySQL、Redis数据库，了解微服务架构和分布式系统，具备良好的代码规范和问题排查能力。"
  },
  "selfEvaluation": "具备扎实的计算机专业基础和3年后端开发经验，善于思考和解决技术难题，工作严谨细致，注重代码质量和系统性能，具备良好的团队协作能力和学习能力，能快速掌握新技术并应用于实际工作。",
  "createdAt": "2026-03-15T10:30:00Z",
  "updatedAt": "2026-03-15T10:30:00Z"
}
```

## 格式验证规则

### 手机号验证

```python
import re

def validate_phone(phone):
    pattern = r'^1[3-9]\d{9}$'
    return bool(re.match(pattern, phone))

# 示例
validate_phone("13800138000")  # True
validate_phone("12345678901")  # False（第二位不是3-9）
```

### 身份证号验证

```python
def validate_id_card(id_card):
    if len(id_card) != 18:
        return False

    # 简化验证：检查前17位是否为数字
    if not id_card[:17].isdigit():
        return False

    # 最后一位可以是数字或 X
    if not (id_card[17].isdigit() or id_card[17] == 'X'):
        return False

    return True

# 更严格的验证可以包括：
# - 地区码验证
# - 出生日期验证
# - 校验码验证
```

### 邮箱验证

```python
def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

# 示例
validate_email("zhangsan@example.com")  # True
validate_email("invalid-email")  # False
```

### 日期格式验证

```python
from datetime import datetime

def validate_date(date_str):
    try:
        datetime.strptime(date_str, '%Y-%m-%d')
        return True
    except ValueError:
        return False

# 示例
validate_date("1990-01-15")  # True
validate_date("90-01-15")    # False
```

## 信息更新流程

### 更新单个字段

```
用户："我的手机号换了，改成 13900139000"

智能体：
1. 读取现有 JSON 文件
2. 找到 basic.phone 字段
3. 验证新手机号格式
4. 更新字段值
5. 更新 updatedAt 时间戳
6. 保存文件
7. 确认："手机号已更新为 13900139000"
```

### 添加工作经历

```
用户："添加一份新的工作经历"

智能体：
"好的，请告诉我：
1. 公司名称：
2. 职位：
3. 入职时间（YYYY-MM）：
4. 离职时间（YYYY-MM 或'至今'）：
5. 工作描述：

（收集完成后）
已添加新的工作经历到你的信息中。"
```

## 文件命名规则

```
格式：<姓名拼音>-<YYYYMMDD>.json

示例：
- zhangsan-20260315.json
- lisi-20260316.json
- wangwu-20260317.json

如果同一天创建多个，添加序号：
- zhangsan-20260315-1.json
- zhangsan-20260315-2.json
```

## 错误处理

### 格式错误

```
用户输入：12345678901（手机号第二位不是3-9）

智能体响应：
"抱歉，这个手机号格式不正确。手机号应该是11位数字，以1开头，第二位是3-9。
请重新输入你的联系电话："
```

### 必填字段为空

```
用户跳过姓名字段

智能体响应：
"姓名是必填字段，我需要这个信息才能继续。
请告诉我你的姓名（中文全名）："
```

### 文件已存在

```
保存时发现文件已存在

智能体询问：
"我发现已经有你的信息文件了：zhangsan-20260315.json
你想要：
1. 更新这个文件
2. 创建新的文件（会添加序号）

请选择 1 或 2："
```

## 可选字段说明

以下字段可以跳过（用户说"跳过"或"没有"）：

- 英文姓名
- 身份证号
- 户籍地址（如与现居地址相同）
- 邮政编码
- 工作经历（如果是应届毕业生）

必填字段：

- 姓名
- 性别
- 出生日期
- 联系电话
- 电子邮箱
- 现居地址

## 最佳实践

1. **逐步询问**：不要一次问多个问题，让用户逐个回答
2. **友好提示**：告诉用户哪些是必填、哪些可跳过
3. **及时验证**：输入后立即验证格式，避免最后才发现错误
4. **清晰确认**：收集完成后，整理显示所有信息供用户确认
5. **灵活修改**：如果用户想修改某个字段，允许单独修改而不是重新填写全部

## 示例对话

```
用户："我想填写个人信息"

智能体："好的，我来帮你收集个人信息。我会逐步询问，某些可选字段你可以选择跳过。

首先，基本信息：
1. 请告诉我你的姓名（中文全名）"

用户："张三"

智能体："好的，姓名：张三
2. 英文姓名（可选，可以说'跳过'）："

用户："Zhang San"

智能体："好的，英文姓名：Zhang San
3. 你的性别是？"

用户："男"

智能体："好的，性别：男
4. 请告诉我你的出生日期（格式：YYYY-MM-DD，例如 1990-01-15）："

用户："1990-01-15"

智能体："好的，出生日期：1990-01-15
5. 身份证号（可选，可以说'跳过'）："

用户："跳过"

智能体："好的，跳过身份证号。
6. 请告诉我你的联系电话（11位手机号）："

用户："13800138000"

智能体："好的，联系电话：13800138000
7. 请告诉我你的电子邮箱："

用户："zhangsan@example.com"

智能体："好的，电子邮箱：zhangsan@example.com

接下来是地址信息...
```

## 快速参考

### 保存 JSON 文件

```python
import json
from datetime import datetime

data = {
    "basic": {...},
    "address": {...},
    "education": {...},
    "experience": [...],
    "createdAt": datetime.now().isoformat() + "Z",
    "updatedAt": datetime.now().isoformat() + "Z"
}

filename = f"persons/{name_pinyin}-{datetime.now().strftime('%Y%m%d')}.json"

with open(filename, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
```

### 读取 JSON 文件

```python
import json

with open('persons/zhangsan-20260315.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(data['basic']['name'])  # 张三
```

### 更新字段

```python
# 更新手机号
data['basic']['phone'] = '13900139000'
data['updatedAt'] = datetime.now().isoformat() + "Z"

# 保存
with open('persons/zhangsan-20260315.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
```
