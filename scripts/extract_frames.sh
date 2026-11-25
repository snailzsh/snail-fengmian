#!/usr/bin/env bash
# Usage:
#   extract_frames.sh <video> <out_dir> [interval_sec=6]   -> out_dir/contact.jpg（6 列网格，带时间码）
#   extract_frames.sh <video> <out_dir> -t 30 36 ...       -> out_dir/f30.png f36.png（全分辨率单帧）
set -e
V="$1"; O="$2"; shift 2 || { echo "usage: $0 <video> <out_dir> [interval|-t sec...]"; exit 1; }
mkdir -p "$O"
if [ "${1:-}" = "-t" ]; then shift; for t in "$@"; do ffmpeg -v error -ss "$t" -i "$V" -frames:v 1 "$O/f$t.png" -y; echo "$O/f$t.png"; done; exit 0; fi
N="${1:-6}"
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$V")
R=$(python3 -c "import math;print(max(1,math.ceil(float('$D')/$N/6)))")
# drawtext 需要 ffmpeg 带 freetype；没有就退回不带时间码
ffmpeg -v error -i "$V" -vf "fps=1/$N,scale=384:-1,drawtext=text='%{pts\:hms}':x=6:y=6:fontsize=18:fontcolor=yellow:box=1:boxcolor=black@0.6,tile=6x$R" -frames:v 1 "$O/contact.jpg" -y 2>/dev/null \
 || ffmpeg -v error -i "$V" -vf "fps=1/$N,scale=384:-1,tile=6x$R" -frames:v 1 "$O/contact.jpg" -y
echo "$O/contact.jpg  (every ${N}s, left→right, top→bottom)"
