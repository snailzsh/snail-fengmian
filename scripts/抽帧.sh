#!/bin/bash
# 用法：抽帧.sh <成片.mp4> <输出目录> [间隔秒=6]   → 输出目录/总览.jpg（6 列网格）
#      抽帧.sh <成片.mp4> <输出目录> -t 30 36 …   → 输出目录/f30.png f36.png（全分辨率单帧）
set -e; V="$1"; O="$2"; shift 2; mkdir -p "$O"
if [ "$1" = "-t" ]; then shift; for t in "$@"; do ffmpeg -v error -ss "$t" -i "$V" -frames:v 1 "$O/f$t.png" -y; echo "$O/f$t.png"; done; exit; fi
N="${1:-6}"; D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$V"); R=$(python3 -c "import math;print(max(1,math.ceil($D/$N/6)))")
ffmpeg -v error -i "$V" -vf "fps=1/$N,scale=384:-1,drawtext=text='%{pts\:hms}':x=6:y=6:fontsize=18:fontcolor=yellow:box=1:boxcolor=black@0.6,tile=6x$R" -frames:v 1 "$O/总览.jpg" -y 2>/dev/null \
 || ffmpeg -v error -i "$V" -vf "fps=1/$N,scale=384:-1,tile=6x$R" -frames:v 1 "$O/总览.jpg" -y
echo "$O/总览.jpg （每格间隔 ${N}s，从左到右、从上到下）"
