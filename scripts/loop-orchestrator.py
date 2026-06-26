#!/usr/bin/env python3
"""
loop-orchestrator.py - Loop Engineering 主编排器

控制 CI → Monitor → Fix → Verify 的完整循环

状态机:
  IDLE → CI_RUNNING → MONITORING → FIXING → VERIFYING → (回到 CI_RUNNING 或 DONE)

用法:
  python scripts/loop-orchestrator.py
  python scripts/loop-orchestrator.py --config .github/loop-config.yml
  python scripts/loop-orchestrator.py --local  # 本地模式，不调用 GitHub API
"""

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime
from enum import Enum
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Optional


class LoopState(Enum):
    IDLE = "idle"
    CI_RUNNING = "ci_running"
    MONITORING = "monitoring"
    FIXING = "fixing"
    VERIFYING = "verifying"
    DONE = "done"
    FAILED = "failed"


@dataclass
class LoopContext:
    iteration: int = 0
    max_iterations: int = 3
    state: LoopState = LoopState.IDLE
    start_time: datetime = field(default_factory=datetime.now)
    history: List[Dict] = field(default_factory=list)
    total_fixes_attempted: int = 0
    total_fixes_succeeded: int = 0


class LoopOrchestrator:
    def __init__(self, config_path: str = ".github/loop-config.yml", local: bool = False):
        self.config = self._load_config(config_path)
        self.local = local
        self.context = LoopContext(
            max_iterations=self.config.get("loop", {}).get("max_iterations", 3),
        )
        self.scripts_dir = Path(__file__).parent

    def _load_config(self, config_path: str) -> Dict:
        """加载配置文件"""
        if not os.path.exists(config_path):
            print(f"Config not found: {config_path}, using defaults")
            return {"loop": {"max_iterations": 3}}

        try:
            import yaml
            with open(config_path, encoding="utf-8") as f:
                return yaml.safe_load(f) or {}
        except ImportError:
            # PyYAML 不可用，用简单解析
            return {"loop": {"max_iterations": 3}}

    def run(self):
        """主循环"""
        print("=" * 60)
        print("  Loop Engineering Orchestrator")
        print(f"  Max iterations: {self.context.max_iterations}")
        print(f"  Start time: {self.context.start_time.isoformat()}")
        print("=" * 60)

        while self.context.state != LoopState.DONE:
            self.context.iteration += 1
            print(f"\n{'=' * 50}")
            print(f"  Loop Iteration {self.context.iteration}/{self.context.max_iterations}")
            print(f"{'=' * 50}")

            if self.context.iteration > self.context.max_iterations:
                print("\nMax iterations reached. Stopping.")
                self.context.state = LoopState.DONE
                break

            # Step 1: Run CI
            self.context.state = LoopState.CI_RUNNING
            ci_result = self._run_ci()

            if ci_result.get("success", False):
                print("\nAll tests passed! Loop complete.")
                self.context.state = LoopState.DONE
                break

            # Step 2: Monitor - 分析失败
            self.context.state = LoopState.MONITORING
            analysis = self._run_monitor()

            if not analysis.get("has_fixable", False):
                print("\nNo auto-fixable issues found. Stopping.")
                self.context.state = LoopState.DONE
                break

            # Step 3: Fix - 生成修复
            self.context.state = LoopState.FIXING
            fix_result = self._run_fix()

            # Step 4: Verify - 验证修复
            self.context.state = LoopState.VERIFYING
            verify_result = self._run_verify()

            # Step 5: 更新记忆
            self._update_memory(verify_result)

            # 记录本轮结果
            iteration_record = {
                "iteration": self.context.iteration,
                "failures_found": analysis.get("total_failures", 0),
                "fixes_attempted": fix_result.get("attempted", 0),
                "fixes_succeeded": verify_result.get("passed", 0),
                "timestamp": datetime.now().isoformat(),
            }
            self.context.history.append(iteration_record)
            self.context.total_fixes_attempted += fix_result.get("attempted", 0)
            self.context.total_fixes_succeeded += verify_result.get("passed", 0)

            # 如果没有成功修复任何问题，停止
            if verify_result.get("passed", 0) == 0 and fix_result.get("attempted", 0) > 0:
                print("\nNo fixes succeeded this iteration. Stopping.")
                self.context.state = LoopState.DONE
                break

        self._generate_final_report()

    def _run_ci(self) -> Dict:
        """运行 CI 测试"""
        print("\n[CI] Running test suite...")

        if self.local:
            return self._run_ci_local()
        else:
            return self._run_ci_github()

    def _run_ci_local(self) -> Dict:
        """本地模式: 直接运行测试"""
        results = {"success": True, "modules": {}}

        # Spring Boot
        print("  [server] Running mvn test...")
        ret = subprocess.run(
            ["mvn", "test", "-B", "-q"],
            cwd="server", capture_output=True, text=True, timeout=300,
        )
        results["modules"]["server"] = ret.returncode == 0
        if ret.returncode != 0:
            results["success"] = False
            print("  [server] FAIL")

        # Flutter
        print("  [flutter] Running flutter test...")
        ret = subprocess.run(
            ["flutter", "test"],
            cwd="jiangwu_custom", capture_output=True, text=True, timeout=300,
        )
        results["modules"]["flutter"] = ret.returncode == 0
        if ret.returncode != 0:
            results["success"] = False
            print("  [flutter] FAIL")

        # AI Service
        print("  [ai-service] Running pytest...")
        ret = subprocess.run(
            ["python", "-m", "pytest", "tests/", "-v"],
            cwd="ai-service", capture_output=True, text=True, timeout=120,
        )
        results["modules"]["ai-service"] = ret.returncode == 0
        if ret.returncode != 0:
            results["success"] = False
            print("  [ai-service] FAIL")

        return results

    def _run_ci_github(self) -> Dict:
        """GitHub 模式: 触发 CI workflow 并等待"""
        print("  Triggering CI workflow via GitHub API...")
        # 使用 gh CLI 或 GitHub API
        try:
            ret = subprocess.run(
                ["gh", "workflow", "run", "ci.yml", "--ref", "main"],
                capture_output=True, text=True, timeout=30,
            )
            if ret.returncode == 0:
                print("  CI workflow triggered. Waiting for completion...")
                # 轮询等待完成 (简化版)
                time.sleep(60)
                return {"success": False, "modules": {}}
        except FileNotFoundError:
            print("  gh CLI not found, falling back to local mode")
            return self._run_ci_local()

        return {"success": False, "modules": {}}

    def _run_monitor(self) -> Dict:
        """运行 Monitor 分析"""
        print("\n[Monitor] Analyzing test failures...")

        monitor_script = self.scripts_dir / "loop-monitor.py"
        report_dir = "ci-reports"

        # 创建报告目录
        Path(report_dir).mkdir(exist_ok=True)

        try:
            ret = subprocess.run(
                [
                    sys.executable, str(monitor_script),
                    "--report-dir", report_dir,
                    "--output", ".github/TODO.md",
                    "--memory", ".github/LOOP_MEMORY.md",
                    "--iteration", str(self.context.iteration),
                ],
                capture_output=True, text=True, timeout=60,
            )
            print(ret.stdout)

            if ret.returncode != 0:
                print(f"  Monitor error: {ret.stderr}")
                return {"has_fixable": False, "total_failures": 0}

            # 解析输出
            return self._parse_monitor_output(ret.stdout)

        except subprocess.TimeoutExpired:
            print("  Monitor timed out")
            return {"has_fixable": False, "total_failures": 0}

    def _parse_monitor_output(self, output: str) -> Dict:
        """解析 monitor 输出"""
        result = {"has_fixable": False, "total_failures": 0}
        for line in output.split("\n"):
            if "Total failures found:" in line:
                try:
                    result["total_failures"] = int(line.split(":")[-1].strip())
                except ValueError:
                    pass
            if "Generated:" in line:
                result["has_fixable"] = True
        return result

    def _run_fix(self) -> Dict:
        """运行 AI 修复"""
        print("\n[Fix] Generating AI fixes...")

        fix_script = self.scripts_dir / "loop-fix.sh"

        try:
            ret = subprocess.run(
                ["bash", str(fix_script)],
                capture_output=True, text=True, timeout=600,
            )
            print(ret.stdout)

            return self._parse_fix_output(ret.stdout)

        except subprocess.TimeoutExpired:
            print("  Fix timed out")
            return {"attempted": 0, "succeeded": 0}

    def _parse_fix_output(self, output: str) -> Dict:
        """解析 fix 输出"""
        result = {"attempted": 0, "succeeded": 0}
        for line in output.split("\n"):
            if "Total attempted:" in line:
                try:
                    result["attempted"] = int(line.split(":")[-1].strip())
                except ValueError:
                    pass
            if "Succeeded:" in line:
                try:
                    result["succeeded"] = int(line.split(":")[-1].strip())
                except ValueError:
                    pass
        return result

    def _run_verify(self) -> Dict:
        """运行验证"""
        print("\n[Verify] Verifying fixes...")

        verify_script = self.scripts_dir / "loop-verify.sh"

        try:
            ret = subprocess.run(
                ["bash", str(verify_script), "--subset"],
                capture_output=True, text=True, timeout=300,
            )
            print(ret.stdout)

            return self._parse_verify_output(ret.stdout)

        except subprocess.TimeoutExpired:
            print("  Verify timed out")
            return {"passed": 0, "failed": 0}

    def _parse_verify_output(self, output: str) -> Dict:
        """解析 verify 输出"""
        result = {"passed": 0, "failed": 0}
        for line in output.split("\n"):
            if "Pass:" in line:
                try:
                    result["passed"] = int(line.split(":")[-1].strip())
                except ValueError:
                    pass
            if "Fail:" in line:
                try:
                    result["failed"] = int(line.split(":")[-1].strip())
                except ValueError:
                    pass
        return result

    def _update_memory(self, verify_result: Dict):
        """更新 LOOP_MEMORY.md"""
        memory_path = Path(".github/LOOP_MEMORY.md")
        if not memory_path.exists():
            return

        # 简单更新: 在趋势表中追加一行
        content = memory_path.read_text(encoding="utf-8")
        if "（等待首次运行）" in content:
            trend_line = (
                f"| 1 | {self.context.total_fixes_attempted} | "
                f"{self.context.total_fixes_succeeded} | "
                f"{self.context.total_fixes_attempted - self.context.total_fixes_succeeded} | "
                f"{self._calc_success_rate()}% |"
            )
            content = content.replace(
                "| （等待首次运行） | - | - | - | - |",
                trend_line,
            )
            memory_path.write_text(content, encoding="utf-8")

    def _calc_success_rate(self) -> str:
        """计算成功率"""
        if self.context.total_fixes_attempted == 0:
            return "0"
        rate = (self.context.total_fixes_succeeded / self.context.total_fixes_attempted) * 100
        return f"{rate:.1f}"

    def _generate_final_report(self):
        """生成最终报告"""
        duration = (datetime.now() - self.context.start_time).total_seconds()

        report = {
            "project": "匠物定制 - Loop Engineering",
            "total_iterations": self.context.iteration,
            "final_state": self.context.state.value,
            "total_fixes_attempted": self.context.total_fixes_attempted,
            "total_fixes_succeeded": self.context.total_fixes_succeeded,
            "success_rate": self._calc_success_rate() + "%",
            "duration_seconds": round(duration, 1),
            "duration_human": f"{int(duration // 60)}m {int(duration % 60)}s",
            "history": self.context.history,
            "completed_at": datetime.now().isoformat(),
        }

        report_path = Path(".github/loop-report.json")
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")

        print(f"\n{'=' * 60}")
        print("  Loop Engineering Final Report")
        print(f"{'=' * 60}")
        print(f"  Iterations: {self.context.iteration}")
        print(f"  Final state: {self.context.state.value}")
        print(f"  Fixes attempted: {self.context.total_fixes_attempted}")
        print(f"  Fixes succeeded: {self.context.total_fixes_succeeded}")
        print(f"  Success rate: {self._calc_success_rate()}%")
        print(f"  Duration: {int(duration // 60)}m {int(duration % 60)}s")
        print(f"  Report: {report_path}")
        print(f"{'=' * 60}")


def main():
    parser = argparse.ArgumentParser(description="Loop Engineering Orchestrator")
    parser.add_argument("--config", default=".github/loop-config.yml", help="Config file")
    parser.add_argument("--local", action="store_true", help="Local mode (no GitHub API)")
    args = parser.parse_args()

    orchestrator = LoopOrchestrator(config_path=args.config, local=args.local)
    orchestrator.run()


if __name__ == "__main__":
    main()
