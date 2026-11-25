#!/usr/bin/env bash
# Usage: generate.sh <task_dir containing prompt.txt> [reference images...]
# 用 Codex CLI 的内置生图出 cover.png。agent 自带生图工具的话，可以不用这个脚本。
# 环境变量（可选）：FENGMIAN_CODEX_MODEL（模型名）、FENGMIAN_CODEX_EFFORT（默认 low）
set -u
command -v codex >/dev/null || { echo "需要 Codex CLI：npm i -g @openai/codex，然后 codex login"; exit 2; }
D="$(cd "$1" && pwd)"; shift
[ -f "$D/prompt.txt" ] || { echo "缺少 $D/prompt.txt"; exit 1; }
if [ -f "$D/cover.png" ]; then n=1; while [ -f "$D/cover-v$n.png" ]; do n=$((n+1)); done; mv "$D/cover.png" "$D/cover-v$n.png"; fi
ARGS=(exec --skip-git-repo-check -s workspace-write -C "$D" -c "model_reasoning_effort=\"${FENGMIAN_CODEX_EFFORT:-low}\"")
[ -n "${FENGMIAN_CODEX_MODEL:-}" ] && ARGS+=(-m "$FENGMIAN_CODEX_MODEL")
ARGS+=(-)
IMGS=(); for f in "$@"; do IMGS+=("$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"); done
[ ${#IMGS[@]} -gt 0 ] && ARGS+=(-i "${IMGS[@]}")   # -i 必须放最后
( cd "$D" && codex "${ARGS[@]}" < prompt.txt > codex.log 2>&1 )
if [ -f "$D/cover.png" ]; then
  python3 -c "from PIL import Image;im=Image.open('$D/cover.png');print('$D/cover.png',im.size)" 2>/dev/null || echo "$D/cover.png"
else
  echo "没生成 cover.png，最后几行日志："; tail -5 "$D/codex.log"; exit 1
fi
