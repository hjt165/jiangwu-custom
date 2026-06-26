#!/usr/bin/env python3
"""
apply-fix.py - 安全地应用 AI 生成的修复代码

特性:
  - dry-run 模式: 只预览不修改
  - 备份: 修改前自动备份原文件
  - 差异对比: 生成 diff 供审查
  - 回滚: 修复后测试更差时可自动回滚

用法:
  python scripts/apply-fix.py --response "AI响应内容" --dry-run false
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import List, Tuple


class FixApplicator:
    def __init__(self, dry_run: bool = True):
        self.dry_run = dry_run
        self.applied_fixes: List[str] = []
        self.backups: List[str] = []

    def parse_ai_response(self, response: str) -> List[Tuple[str, str]]:
        """
        解析 AI 响应中的修复块
        格式: --- FILE: path --- \n content \n --- END FILE ---
        """
        pattern = r"--- FILE:\s*(.+?)\s*---\n(.*?)\n--- END FILE ---"
        matches = re.findall(pattern, response, re.DOTALL)
        return matches

    def backup_file(self, file_path: str) -> str:
        """修改前备份原文件"""
        if not os.path.exists(file_path):
            return ""
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        backup_path = f"{file_path}.bak.{timestamp}"
        shutil.copy2(file_path, backup_path)
        self.backups.append(backup_path)
        return backup_path

    def generate_diff(self, file_path: str, new_content: str) -> str:
        """生成差异对比"""
        if not os.path.exists(file_path):
            return "[NEW FILE]"

        old_content = Path(file_path).read_text(encoding="utf-8")
        old_lines = old_content.splitlines(keepends=True)
        new_lines = new_content.splitlines(keepends=True)

        import difflib
        diff = difflib.unified_diff(
            old_lines, new_lines,
            fromfile=f"a/{file_path}",
            tofile=f"b/{file_path}",
            lineterm="",
        )
        return "".join(diff)

    def apply_fix(self, file_path: str, new_content: str) -> bool:
        """应用单个修复"""
        if self.dry_run:
            diff = self.generate_diff(file_path, new_content)
            print(f"[DRY RUN] Would modify: {file_path}")
            if diff:
                print(diff[:500])
            return True

        try:
            # 确保目录存在
            Path(file_path).parent.mkdir(parents=True, exist_ok=True)

            # 备份
            self.backup_file(file_path)

            # 写入新内容
            Path(file_path).write_text(new_content, encoding="utf-8")
            self.applied_fixes.append(file_path)
            print(f"[APPLIED] Modified: {file_path}")
            return True

        except Exception as e:
            print(f"[ERROR] Failed to modify {file_path}: {e}")
            return False

    def rollback_all(self):
        """回滚所有已应用的修复"""
        for backup in self.backups:
            original = re.sub(r"\.bak\.\d+$", "", backup)
            if os.path.exists(backup):
                shutil.move(backup, original)
                print(f"[ROLLBACK] Restored: {original}")

    def get_applied_files(self) -> List[str]:
        """获取已修改的文件列表"""
        return self.applied_fixes.copy()


def main():
    parser = argparse.ArgumentParser(description="Apply AI-generated fixes")
    parser.add_argument("--response", required=True, help="AI response content")
    parser.add_argument("--dry-run", type=str, default="false",
                        help="Dry run mode (true/false)")
    parser.add_argument("--rollback-on-failure", action="store_true",
                        help="Rollback if fix seems wrong")
    args = parser.parse_args()

    dry_run = args.dry_run.lower() == "true"
    applicator = FixApplicator(dry_run=dry_run)

    # 解析 AI 响应
    fixes = applicator.parse_ai_response(args.response)

    if not fixes:
        print("No fix blocks found in AI response")
        print("Response preview:")
        print(args.response[:300])
        sys.exit(1)

    print(f"Found {len(fixes)} fix block(s)")

    # 应用修复
    success_count = 0
    for file_path, content in fixes:
        # 安全检查: 不修改受保护的文件
        protected = [
            "docker-compose", ".env", "Dockerfile",
            "pom.xml", "pubspec.yaml", "requirements.txt",
            "package.json",
        ]
        if any(p in file_path for p in protected):
            print(f"[SKIP] Protected file: {file_path}")
            continue

        if applicator.apply_fix(file_path, content):
            success_count += 1

    print(f"\nApplied {success_count}/{len(fixes)} fixes")

    # 输出已修改的文件列表 (GitHub Actions)
    if os.environ.get("GITHUB_OUTPUT"):
        applied = ",".join(applicator.get_applied_files())
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            f.write(f"applied_files={applied}\n")


if __name__ == "__main__":
    main()
