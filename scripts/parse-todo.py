#!/usr/bin/env python3
"""
parse-todo.py - 解析 TODO.md 提取修复任务

从 loop-monitor.py 生成的 TODO.md 中提取结构化数据

用法:
  python scripts/parse-todo.py .github/TODO.md --fixable-only
  python scripts/parse-todo.py .github/TODO.md --tests-only
  python scripts/parse-todo.py .github/TODO.md --json
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import List, Dict


def parse_todo_md(content: str) -> List[Dict]:
    """解析 TODO.md 提取所有 issue"""
    issues = []
    current_severity = ""

    for line in content.split("\n"):
        # 检测严重程度标题
        severity_match = re.match(r"^## (BLOCKER|CRITICAL|MAJOR|MINOR)", line)
        if severity_match:
            current_severity = severity_match.group(1).lower()
            continue

        # 检测 issue 标题
        issue_match = re.match(r"^### \[([^\]]+)\] ([^\n]+)", line)
        if issue_match:
            module = issue_match.group(1)
            test_name = issue_match.group(2)
            issues.append({
                "module": module,
                "test": test_name,
                "severity": current_severity,
                "test_class": test_name.rsplit(".", 1)[0] if "." in test_name else test_name,
                "test_method": test_name.rsplit(".", 1)[1] if "." in test_name else "",
            })
            continue

        # 提取详细信息
        if issues:
            current = issues[-1]

            file_match = re.match(r"- \*\*文件\*\*: `?([^`\n]+)`?", line)
            if file_match:
                current["file"] = file_match.group(1).strip()

            type_match = re.match(r"- \*\*类型\*\*: (\w+)", line)
            if type_match:
                current["error_type"] = type_match.group(1)

            msg_match = re.match(r"- \*\*消息\*\*: `?([^`\n]+)`?", line)
            if msg_match:
                current["message"] = msg_match.group(1).strip()

            suggestion_match = re.match(r"- \*\*修复建议\*\*: (.+)", line)
            if suggestion_match:
                current["suggestion"] = suggestion_match.group(1).strip()

            auto_match = re.match(r"- \*\*状态\*\*: (.+)", line)
            if auto_match:
                status_text = auto_match.group(1)
                current["auto_fixable"] = "可自动修复" in status_text

    return issues


def main():
    parser = argparse.ArgumentParser(description="Parse TODO.md")
    parser.add_argument("todo_file", help="Path to TODO.md")
    parser.add_argument("--fixable-only", action="store_true",
                        help="Only output auto-fixable issues")
    parser.add_argument("--tests-only", action="store_true",
                        help="Only output module|test_class pairs")
    parser.add_argument("--json", action="store_true",
                        help="Output as JSON")
    args = parser.parse_args()

    content = Path(args.todo_file).read_text(encoding="utf-8")
    issues = parse_todo_md(content)

    if args.fixable_only:
        issues = [i for i in issues if i.get("auto_fixable", True)]

    if args.json:
        print(json.dumps(issues, indent=2, ensure_ascii=False))
    elif args.tests_only:
        for issue in issues:
            print(f"{issue['module']}|{issue['test_class']}")
    else:
        for issue in issues:
            file_path = issue.get("file", "unknown")
            suggestion = issue.get("suggestion", "No suggestion")
            print(f"{issue['module']}|{issue['test_class']}|{issue['test_method']}|{file_path}|{suggestion}")


if __name__ == "__main__":
    main()
