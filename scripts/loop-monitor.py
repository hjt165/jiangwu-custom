#!/usr/bin/env python3
"""
loop-monitor.py - Loop Engineering 测试失败分析器

解析 JUnit XML 测试报告，分类错误，生成修复建议，输出 TODO.md

用法:
  python scripts/loop-monitor.py --report-dir ci-reports/ --output .github/TODO.md
"""

import xml.etree.ElementTree as ET
import os
import re
import sys
import json
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, field
from enum import Enum
from typing import List, Dict, Optional
from collections import defaultdict


class ErrorCategory(Enum):
    COMPILATION_ERROR = "compilation"
    ASSERTION_FAILURE = "assertion"
    TIMEOUT = "timeout"
    DEPENDENCY_MISSING = "dependency"
    FLAKY_TEST = "flaky"
    CONFIGURATION_ERROR = "config"
    UNKNOWN = "unknown"


class Severity(Enum):
    BLOCKER = "blocker"
    CRITICAL = "critical"
    MAJOR = "major"
    MINOR = "minor"


@dataclass
class TestFailure:
    test_class: str
    test_method: str
    module: str
    error_category: ErrorCategory
    severity: Severity
    error_message: str
    stack_trace: str = ""
    fix_suggestion: str = ""
    affected_files: List[str] = field(default_factory=list)
    is_auto_fixable: bool = True


# 错误分类关键词映射
ERROR_PATTERNS = {
    ErrorCategory.COMPILATION_ERROR: [
        "compilation error", "cannot find symbol", "syntax error",
        "package .* does not exist", "method .* cannot be applied",
        "incompatible types", "missing symbol", "unresolved reference",
    ],
    ErrorCategory.ASSERTION_FAILURE: [
        "assertionerror", "expected:", "actual:", "assertequals",
        "expected:<", "but was:<", "assertion failed",
    ],
    ErrorCategory.TIMEOUT: [
        "timeout", "timed out", "deadlineexceeded", "timeoutexception",
    ],
    ErrorCategory.DEPENDENCY_MISSING: [
        "nosuchbeandefinition", "beannotfound", "could not autowire",
        "dependency.*not found", "module.*not found",
        "import .* could not be resolved",
    ],
    ErrorCategory.FLAKY_TEST: [
        "intermittent", "flaky", "race condition", "timing",
    ],
    ErrorCategory.CONFIGURATION_ERROR: [
        "configuration", "config", "property.*not found",
        " datasource ", "connection refused", "access denied",
    ],
}

# 模块识别路径映射
MODULE_PATHS = {
    "server": ["server/"],
    "flutter": ["jiangwu_custom/"],
    "ai-service": ["ai-service/"],
    "admin": ["admin/"],
}

# 严重程度评估规则
SEVERITY_RULES = {
    ErrorCategory.COMPILATION_ERROR: Severity.BLOCKER,
    ErrorCategory.DEPENDENCY_MISSING: Severity.CRITICAL,
    ErrorCategory.CONFIGURATION_ERROR: Severity.CRITICAL,
    ErrorCategory.ASSERTION_FAILURE: Severity.MAJOR,
    ErrorCategory.TIMEOUT: Severity.MAJOR,
    ErrorCategory.FLAKY_TEST: Severity.MINOR,
    ErrorCategory.UNKNOWN: Severity.MAJOR,
}

# 修复建议模板
FIX_SUGGESTIONS = {
    ErrorCategory.COMPILATION_ERROR: "检查代码语法和依赖导入，确认类/方法名拼写正确",
    ErrorCategory.ASSERTION_FAILURE: "检查测试期望值与实际实现是否一致，确认业务逻辑正确",
    ErrorCategory.TIMEOUT: "检查是否有死循环或耗时操作，考虑增加超时时间或优化性能",
    ErrorCategory.DEPENDENCY_MISSING: "检查 Spring/Python 依赖注入配置，确认 Bean 已正确注册",
    ErrorCategory.FLAKY_TEST: "此测试可能受并发/时序影响，考虑增加重试或修复竞态条件",
    ErrorCategory.CONFIGURATION_ERROR: "检查配置文件和环境变量，确认数据库/Redis 连接正确",
    ErrorCategory.UNKNOWN: "需要人工分析错误堆栈确定根因",
}

# 不允许自动修复的模块/文件
PROTECTED_PATTERNS = [
    r"docker-compose\.yml",
    r"\.env.*",
    r"Dockerfile",
    r"pom\.xml",
    r"pubspec\.yaml",
    r"requirements\.txt",
    r"package\.json",
]


def identify_module(file_path: str) -> str:
    """根据文件路径识别所属模块"""
    for module, prefixes in MODULE_PATHS.items():
        for prefix in prefixes:
            if file_path.startswith(prefix) or f"/{prefix}" in file_path:
                return module
    return "unknown"


def classify_error(error_message: str, stack_trace: str) -> ErrorCategory:
    """根据错误信息和堆栈分类错误类型"""
    combined = f"{error_message} {stack_trace}".lower()
    for category, patterns in ERROR_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, combined):
                return category
    return ErrorCategory.UNKNOWN


def assess_severity(category: ErrorCategory, module: str) -> Severity:
    """评估错误严重程度"""
    return SEVERITY_RULES.get(category, Severity.MAJOR)


def is_auto_fixable(failure: TestFailure) -> bool:
    """判断是否可以自动修复"""
    # 检查是否涉及受保护的文件
    for affected in failure.affected_files:
        for pattern in PROTECTED_PATTERNS:
            if re.search(pattern, affected):
                return False
    # 编译错误和配置错误通常需要人工
    if failure.error_category in (ErrorCategory.COMPILATION_ERROR,):
        return False
    return True


def parse_junit_xml(xml_path: str) -> List[TestFailure]:
    """解析 JUnit XML 报告"""
    failures = []
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
    except (ET.ParseError, FileNotFoundError):
        return failures

    # 处理不同格式的 JUnit XML
    # 格式1: <testsuites><testsuite><testcase>...</testcase></testsuite></testsuites>
    # 格式2: <testsuite><testcase>...</testcase></testsuite>
    testcases = []

    if root.tag == "testsuites":
        for testsuite in root.findall("testsuite"):
            for testcase in testsuite.findall("testcase"):
                testcases.append(testcase)
    elif root.tag == "testsuite":
        for testcase in root.findall("testcase"):
            testcases.append(testcase)

    for tc in testcases:
        failure = tc.find("failure")
        error = tc.find("error")
        skipped = tc.find("skipped")

        if failure is not None or error is not None:
            elem = failure if failure is not None else error
            classname = tc.get("classname", "Unknown")
            methodname = tc.get("name", "unknown_test")
            message = elem.get("message", "No message")
            text = elem.text or ""

            # 识别模块
            module = identify_module(classname)

            # 分类错误
            category = classify_error(message, text)
            severity = assess_severity(category, module)

            # 生成文件路径
            class_path = classname.replace(".", "/")
            affected = []
            for ext, prefix in [(".java", "server/src/"), (".dart", "jiangwu_custom/lib/"), (".py", "ai-service/")]:
                if ext in classname or module == "server":
                    affected.append(f"{prefix}{class_path}{ext}")
                    break

            fix_suggestion = FIX_SUGGESTIONS.get(category, "")

            test_fail = TestFailure(
                test_class=classname,
                test_method=methodname,
                module=module,
                error_category=category,
                severity=severity,
                error_message=message[:500],
                stack_trace=text[:1000],
                fix_suggestion=fix_suggestion,
                affected_files=affected,
                is_auto_fixable=True,
            )
            test_fail.is_auto_fixable = is_auto_fixable(test_fail)
            failures.append(test_fail)

    return failures


def load_memory(memory_path: str) -> Dict:
    """加载历史修复记忆"""
    memory = {"patterns": [], "stats": {"total_fixes": 0, "success_rate": 0}}
    if not os.path.exists(memory_path):
        return memory

    content = Path(memory_path).read_text(encoding="utf-8")
    # 简单解析 #FIX-XXX 模式
    fixes = re.findall(r"### #FIX-(\d+): (.+?)\n", content)
    for fix_id, desc in fixes:
        memory["patterns"].append({"id": int(fix_id), "description": desc})

    return memory


def match_history(failure: TestFailure, memory: Dict) -> Optional[str]:
    """匹配历史修复模式"""
    for pattern in memory.get("patterns", []):
        # 简单关键词匹配
        keywords = pattern["description"].lower().split()
        if any(kw in failure.error_message.lower() for kw in keywords if len(kw) > 3):
            return f"#FIX-{pattern['id']:03d}"
    return None


def generate_todo_md(failures: List[TestFailure], iteration: int, memory: Dict) -> str:
    """生成 TODO.md 内容"""
    now = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")

    # 按严重程度分组
    by_severity = defaultdict(list)
    for f in failures:
        by_severity[f.severity].append(f)

    # 统计
    total = len(failures)
    fixable = sum(1 for f in failures if f.is_auto_fixable)

    lines = [
        "# Loop Engineering TODO",
        f"> 自动生成 | 迭代: {iteration} | 时间: {now} | 状态: 待修复",
        "",
        "## 统计",
        "| 严重程度 | 数量 | 可自动修复 |",
        "|---------|------|-----------|",
    ]

    for sev in [Severity.BLOCKER, Severity.CRITICAL, Severity.MAJOR, Severity.MINOR]:
        items = by_severity.get(sev, [])
        auto_count = sum(1 for f in items if f.is_auto_fixable)
        if items:
            lines.append(f"| {sev.value.upper()} | {len(items)} | {auto_count} |")

    lines.append(f"| **总计** | **{total}** | **{fixable}** |")
    lines.append("")

    # 按严重程度输出详情
    for sev in [Severity.BLOCKER, Severity.CRITICAL, Severity.MAJOR, Severity.MINOR]:
        items = by_severity.get(sev, [])
        if not items:
            continue

        lines.append(f"## {sev.value.upper()}")
        lines.append("")

        for f in items:
            # 检查历史匹配
            history_match = match_history(f, memory)
            history_note = f" (类似 {history_match})" if history_match else ""

            lines.append(f"### [{f.module}] {f.test_class}.{f.test_method}")
            lines.append(f"- **类型**: {f.error_category.value.upper()}")
            lines.append(f"- **消息**: `{f.error_message[:200]}`")

            if f.stack_trace:
                # 取堆栈前3行
                stack_lines = f.stack_trace.strip().split("\n")[:3]
                lines.append(f"- **堆栈**:")
                for sl in stack_lines:
                    lines.append(f"  ```\n  {sl.strip()}\n  ```")

            if f.fix_suggestion:
                lines.append(f"- **修复建议**: {f.fix_suggestion}{history_note}")

            if f.affected_files:
                lines.append(f"- **影响文件**: {', '.join(f'`{p}`' for p in f.affected_files)}")

            auto_tag = "✅ 可自动修复" if f.is_auto_fixable else "⚠️ 需人工处理"
            lines.append(f"- **状态**: {auto_tag}")
            lines.append("")

    # 已知修复模式参考
    if memory.get("patterns"):
        lines.append("---")
        lines.append("## 已知修复模式 (来自 LOOP_MEMORY)")
        lines.append("")
        for p in memory["patterns"][:10]:
            lines.append(f"- #FIX-{p['id']:03d}: {p['description']}")
        lines.append("")

    return "\n".join(lines)


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Loop Engineering Monitor")
    parser.add_argument("--report-dir", required=True, help="测试报告目录")
    parser.add_argument("--output", default=".github/TODO.md", help="输出 TODO.md 路径")
    parser.add_argument("--memory", default=".github/LOOP_MEMORY.md", help="记忆库路径")
    parser.add_argument("--iteration", type=int, default=1, help="当前迭代次数")
    args = parser.parse_args()

    report_dir = Path(args.report_dir)
    if not report_dir.exists():
        print(f"Report directory not found: {report_dir}")
        sys.exit(1)

    # 加载记忆
    memory = load_memory(args.memory)

    # 解析所有测试报告
    all_failures = []
    xml_files = list(report_dir.rglob("*.xml"))
    print(f"Found {len(xml_files)} XML report files")

    for xml_file in xml_files:
        failures = parse_junit_xml(str(xml_file))
        all_failures.extend(failures)
        print(f"  {xml_file.name}: {len(failures)} failures")

    # 也解析 JSON 格式 (Flutter --machine)
    json_files = list(report_dir.rglob("*.json"))
    for json_file in json_files:
        try:
            data = json.loads(json_file.read_text(encoding="utf-8"))
            if isinstance(data, dict) and "test" in data:
                # Flutter machine output
                for test_result in data.get("tests", []):
                    if test_result.get("result") == "error":
                        all_failures.append(TestFailure(
                            test_class=test_result.get("suite", "unknown"),
                            test_method=test_result.get("name", "unknown"),
                            module="flutter",
                            error_category=ErrorCategory.ASSERTION_FAILURE,
                            severity=Severity.MAJOR,
                            error_message=str(test_result.get("message", "")),
                            fix_suggestion=FIX_SUGGESTIONS[ErrorCategory.ASSERTION_FAILURE],
                            is_auto_fixable=True,
                        ))
        except (json.JSONDecodeError, KeyError):
            pass

    print(f"\nTotal failures found: {len(all_failures)}")

    # 生成 TODO.md
    todo_content = generate_todo_md(all_failures, args.iteration, memory)
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(todo_content, encoding="utf-8")
    print(f"Generated: {output_path}")

    # 输出 GitHub Actions outputs
    fixable_count = sum(1 for f in all_failures if f.is_auto_fixable)
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            f.write(f"has_fixable={fixable_count > 0}\n")
            f.write(f"fixable_count={fixable_count}\n")
            f.write(f"total_failures={len(all_failures)}\n")


if __name__ == "__main__":
    main()
