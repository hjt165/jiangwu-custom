"""Prompt 模板 - 中文物种/技法/材料"""
from loguru import logger


class PromptTemplates:
    """Prompt 模板管理"""

    # 图片分析 Prompt
    IMAGE_ANALYSIS = """你是一位专业的手作艺术品分析师。
请分析这张图片，识别以下信息：
1. 主要颜色及其占比
2. 艺术风格（如：古典、现代、简约、华丽等）
3. 设计元素（如：纹样、图案、造型等）
4. 整体氛围和情绪
5. 可能的材质和工艺

请以 JSON 格式返回分析结果。"""

    # 需求理解 Prompt
    REQUIREMENT_UNDERSTANDING = """你是一位手作定制需求分析专家。
用户的需求描述如下：
{user_input}

请分析并提取：
1. 品类（珠宝/皮具/陶瓷/木雕/绘画/其他）
2. 风格偏好
3. 材质要求
4. 预算范围
5. 交付时间期望
6. 特殊要求

请以结构化格式返回。"""

    # 方案生成 Prompt
    SOLUTION_GENERATION = """你是一位手作定制方案设计专家。
基于以下需求，生成定制方案：

需求信息：
{requirement_sheet}

类似案例：
{similar_cases}

请生成包含以下内容的方案：
1. 推荐材料及理由
2. 推荐工艺及理由
3. 设计思路
4. 预估价格和工期
5. 注意事项"""

    # 手作人匹配 Prompt
    ARTISAN_MATCHING = """你是一位手作人匹配专家。
基于用户需求和手作人特点，推荐最合适的手作人。

用户需求：
{requirement}

手作人列表：
{artisans}

请从以下维度评估匹配度：
1. 风格契合度（40%）
2. 技术能力（30%）
3. 交付能力（20%）
4. 价格匹配（10%）

请返回匹配度排序和推荐理由。"""

    @classmethod
    def get_template(cls, name: str) -> str:
        """获取模板"""
        template = getattr(cls, name, None)
        if template is None:
            logger.warning(f"模板不存在: {name}")
            return ""
        return template

    @classmethod
    def format_template(cls, name: str, **kwargs) -> str:
        """格式化模板"""
        template = cls.get_template(name)
        if not template:
            return ""
        try:
            return template.format(**kwargs)
        except KeyError as e:
            logger.error(f"模板格式化错误: {e}")
            return template