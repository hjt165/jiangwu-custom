#!/usr/bin/env bash
# loop-verify.sh - Loop Engineering 修复验证器
#
# 修复后只运行受影响的测试子集，快速验证修复是否有效
#
# 用法:
#   bash scripts/loop-verify.sh [--full]

set -euo pipefail

TODO_FILE="${TODO_FILE:-.github/TODO.md}"
VERIFY_RESULTS="${VERIFY_RESULTS:-.github/verify-results.md}"
MODE="${1:---subset}"

echo "=========================================="
echo "Loop Engineering Verify"
echo "Mode: $MODE"
echo "Time: $(date -Iseconds)"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 解析 TODO.md 提取需要验证的测试
tests_to_verify=$(python3 "$SCRIPT_DIR/parse-todo.py" "$TODO_FILE" --tests-only 2>/dev/null || echo "")

if [ -z "$tests_to_verify" ] && [ "$MODE" = "--subset" ]; then
    echo "No specific tests to verify. Running full suite..."
    MODE="--full"
fi

results=()
pass_count=0
fail_count=0

if [ "$MODE" = "--full" ]; then
    echo ""
    echo "--- Running Full Test Suite ---"

    # Spring Boot
    echo "[server] Running mvn test..."
    if cd server && mvn test -B -q 2>/dev/null; then
        echo "[server] PASS"
        results+=("PASS:server:full")
        pass_count=$((pass_count + 1))
    else
        echo "[server] FAIL"
        results+=("FAIL:server:full")
        fail_count=$((fail_count + 1))
    fi
    cd - > /dev/null

    # Flutter
    echo "[flutter] Running flutter test..."
    if cd jiangwu_custom && flutter test -q 2>/dev/null; then
        echo "[flutter] PASS"
        results+=("PASS:flutter:full")
        pass_count=$((pass_count + 1))
    else
        echo "[flutter] FAIL"
        results+=("FAIL:flutter:full")
        fail_count=$((fail_count + 1))
    fi
    cd - > /dev/null

    # AI Service
    echo "[ai-service] Running pytest..."
    if cd ai-service && python -m pytest tests/ -q 2>/dev/null; then
        echo "[ai-service] PASS"
        results+=("PASS:ai-service:full")
        pass_count=$((pass_count + 1))
    else
        echo "[ai-service] FAIL"
        results+=("FAIL:ai-service:full")
        fail_count=$((fail_count + 1))
    fi
    cd - > /dev/null

else
    echo ""
    echo "--- Running Subset Tests ---"

    while IFS='|' read -r module test_class; do
        echo ""
        echo "[$module] Testing: $test_class"

        case "$module" in
            server)
                class_name=$(echo "$test_class" | sed 's/.*\.//')
                if cd server && mvn test -Dtest="$class_name" -B -q 2>/dev/null; then
                    echo "  PASS"
                    results+=("PASS:$module:$test_class")
                    pass_count=$((pass_count + 1))
                else
                    echo "  FAIL"
                    results+=("FAIL:$module:$test_class")
                    fail_count=$((fail_count + 1))
                fi
                cd - > /dev/null
                ;;
            flutter)
                if cd jiangwu_custom && flutter test --name "$test_class" -q 2>/dev/null; then
                    echo "  PASS"
                    results+=("PASS:$module:$test_class")
                    pass_count=$((pass_count + 1))
                else
                    echo "  FAIL"
                    results+=("FAIL:$module:$test_class")
                    fail_count=$((fail_count + 1))
                fi
                cd - > /dev/null
                ;;
            ai-service|ai)
                if cd ai-service && python -m pytest tests/ -k "$test_class" -q 2>/dev/null; then
                    echo "  PASS"
                    results+=("PASS:$module:$test_class")
                    pass_count=$((pass_count + 1))
                else
                    echo "  FAIL"
                    results+=("FAIL:$module:$test_class")
                    fail_count=$((fail_count + 1))
                fi
                cd - > /dev/null
                ;;
            *)
                echo "  SKIP: Unknown module"
                results+=("SKIP:$module:$test_class")
                ;;
        esac
    done <<< "$tests_to_verify"
fi

# 生成验证报告
echo ""
echo "=========================================="
echo "Verification Results"
echo "=========================================="

cat > "$VERIFY_RESULTS" << EOF
# Loop Verify Report
> Time: $(date -Iseconds)
> Mode: $MODE

| Status | Module | Test |
|--------|--------|------|
EOF

for result in "${results[@]}"; do
    IFS=':' read -r status module test <<< "$result"
    emoji="✅" && [ "$status" = "FAIL" ] && emoji="❌" && [ "$status" = "SKIP" ] && emoji="⏭️"
    echo "| $emoji $status | $module | $test |" >> "$VERIFY_RESULTS"
done

echo "" >> "$VERIFY_RESULTS"
echo "**Pass: $pass_count | Fail: $fail_count | Total: $((pass_count + fail_count))**" >> "$VERIFY_RESULTS"

cat "$VERIFY_RESULTS"

# 输出到 GitHub Actions
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "verify_pass=$pass_count" >> "$GITHUB_OUTPUT"
    echo "verify_fail=$fail_count" >> "$GITHUB_OUTPUT"
    echo "all_passed=$([ $fail_count -eq 0 ] && echo true || echo false)" >> "$GITHUB_OUTPUT"
fi

if [ "$fail_count" -gt 0 ]; then
    echo ""
    echo "Some tests still failing."
    exit 1
fi

echo ""
echo "All verification tests passed!"
exit 0
