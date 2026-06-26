#!/usr/bin/env bash
# loop-fix.sh - Loop Engineering AI 自动修复脚本
#
# 读取 .github/TODO.md，逐条调用 AI API 生成修复代码
#
# 环境变量:
#   AI_API_ENDPOINT - AI API 地址 (默认 https://api.openai.com/v1/chat/completions)
#   AI_API_KEY      - API 密钥
#   AI_MODEL        - 模型名称 (默认 gpt-4)

set -euo pipefail

TODO_FILE="${TODO_FILE:-.github/TODO.md}"
MEMORY_FILE="${MEMORY_FILE:-.github/LOOP_MEMORY.md}"
FIX_LOG="${FIX_LOG:-.github/fix-log.md}"
AI_API_ENDPOINT="${AI_API_ENDPOINT:-https://api.openai.com/v1/chat/completions}"
AI_MODEL="${AI_MODEL:-gpt-4}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Loop Engineering Auto-Fix"
echo "Time: $(date -Iseconds)"
echo "=========================================="

if [ ! -f "$TODO_FILE" ]; then
    echo "ERROR: $TODO_FILE not found"
    exit 1
fi

# 提取可修复的问题
echo "Parsing TODO.md for fixable issues..."
issues=$(python3 "$SCRIPT_DIR/parse-todo.py" "$TODO_FILE" --fixable-only 2>/dev/null || echo "")

if [ -z "$issues" ]; then
    echo "No fixable issues found."
    echo "## Auto-Fix Run $(date -Iseconds)" > "$FIX_LOG"
    echo "No fixable issues." >> "$FIX_LOG"
    exit 0
fi

fix_count=0
success_count=0
fail_count=0

while IFS='|' read -r module test_class test_method file suggestion; do
    fix_count=$((fix_count + 1))
    echo ""
    echo "=== Fix #$fix_count: $module/$test_class.$test_method ==="
    echo "File: $file"
    echo "Suggestion: $suggestion"

    # 读取相关源文件内容
    source_content=""
    if [ -f "$file" ]; then
        source_content=$(cat "$file" | head -200)
    fi

    # 读取历史修复记忆
    memory_context=""
    if [ -f "$MEMORY_FILE" ]; then
        memory_context=$(grep -A5 "$module" "$MEMORY_FILE" 2>/dev/null | head -20 || echo "")
    fi

    # 构造 AI prompt
    prompt="You are a senior developer fixing a test failure in the Jiangwu Custom project.

Module: $module
Test: $test_class.$test_method
File to fix: $file
Issue: $suggestion

Source code (first 200 lines):
\`\`\`
$source_content
\`\`\`

History from LOOP_MEMORY:
$memory_context

Rules:
1. Only modify the minimum necessary code to fix the test
2. Follow existing code conventions in the project
3. Do not add new dependencies
4. Do not delete existing functionality
5. If the issue is in test code, fix the test. If in source code, fix the source.
6. Return ONLY the fixed file content, no explanation needed.

Respond in this exact format:
--- FILE: $file ---
<complete fixed file content>
--- END FILE ---
"

    # 检查是否有 API Key
    if [ -z "${AI_API_KEY:-}" ]; then
        echo "WARNING: AI_API_KEY not set, skipping AI fix"
        echo "## Skipped: $module/$test_class.$test_method" >> "$FIX_LOG"
        echo "- Reason: No API key" >> "$FIX_LOG"
        continue
    fi

    # 调用 AI API
    echo "Calling AI API..."
    response=$(curl -s --max-time 60 "$AI_API_ENDPOINT" \
        -H "Authorization: Bearer $AI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg model "$AI_MODEL" --arg prompt "$prompt" \
            '{model: $model, messages: [{role: "user", content: $prompt}], temperature: 0.1, max_tokens: 4000}')" \
        2>/dev/null || echo '{"error": "API call failed"}')

    # 解析响应
    ai_content=$(echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null)

    if [ -z "$ai_content" ]; then
        echo "WARNING: AI returned empty response"
        echo "## Failed: $module/$test_class.$test_method" >> "$FIX_LOG"
        echo "- Reason: Empty AI response" >> "$FIX_LOG"
        fail_count=$((fail_count + 1))
        continue
    fi

    # 应用修复
    echo "Applying fix..."
    apply_result=$(python3 "$SCRIPT_DIR/apply-fix.py" \
        --response "$ai_content" \
        --dry-run false 2>&1)

    if echo "$apply_result" | grep -q "APPLIED"; then
        echo "SUCCESS: Fix applied"
        echo "## Fixed: $module/$test_class.$test_method" >> "$FIX_LOG"
        echo "- File: $file" >> "$FIX_LOG"
        echo "- Time: $(date -Iseconds)" >> "$FIX_LOG"
        success_count=$((success_count + 1))
    else
        echo "FAILED: Could not apply fix"
        echo "## Failed: $module/$test_class.$test_method" >> "$FIX_LOG"
        echo "- Reason: apply-fix.py failed" >> "$FIX_LOG"
        fail_count=$((fail_count + 1))
    fi

done <<< "$issues"

echo ""
echo "=========================================="
echo "Auto-Fix Summary"
echo "Total attempted: $fix_count"
echo "Succeeded: $success_count"
echo "Failed: $fail_count"
echo "=========================================="

# 输出统计到 GitHub Actions
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "fixes_attempted=$fix_count" >> "$GITHUB_OUTPUT"
    echo "fixes_succeeded=$success_count" >> "$GITHUB_OUTPUT"
    echo "fixes_failed=$fail_count" >> "$GITHUB_OUTPUT"
fi
