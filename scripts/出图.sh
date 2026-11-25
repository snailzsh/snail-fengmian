#!/bin/bash
# 用法：出图.sh <任务目录（里面有 prompt.txt）> [参考图...]
# Codex 内置生图，gpt-6-astra；提示词走 stdin，-i 放最后。一张 1–2 分钟，放后台跑，多张按顺序跑。
D="$(cd "$1" && pwd)"; shift
[ -f "$D/prompt.txt" ] || { echo "缺 $D/prompt.txt"; exit 1; }
[ -f "$D/cover.png" ] && mv "$D/cover.png" "$D/cover-v$(ls "$D"/cover-v*.png 2>/dev/null | wc -l | tr -d ' ' | awk '{print $1+1}').png"
IMG=(); [ $# -gt 0 ] && IMG=(-i "$@")
cd "$D" && codex exec --skip-git-repo-check -s workspace-write -m gpt-6-astra -C "$D" -c model_reasoning_effort='"low"' - "${IMG[@]}" < prompt.txt > codex.log 2>&1
[ -f "$D/cover.png" ] && python3 -c "from PIL import Image;im=Image.open('$D/cover.png');print('$D/cover.png',im.size)" || { echo "没出图，看 $D/codex.log"; tail -5 "$D/codex.log"; exit 1; }
