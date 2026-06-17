#!/bin/bash
# Usage: ./check_benchmark.sh <rule_name>
# Example: ./check_benchmark.sh clip_overlaps
# Quickly checks average and maximum wall time and memory usage for any rule's benchmark files

if [ -z "$1" ]; then
    echo "Usage: $0 <rule_name>"
    echo "Example: $0 clip_overlaps"
    exit 1
fi

RULE="$1"
BMK_DIR="results/bqsr-round-0/benchmarks/${RULE}"

if [ ! -d "$BMK_DIR" ]; then
    echo "Error: directory not found: $BMK_DIR"
    exit 1
fi

shopt -s nullglob
files=("$BMK_DIR"/*.bmk)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "Error: no .bmk files found in $BMK_DIR"
    exit 1
fi

awk 'FNR>1 {n++; s+=$1; if($1>maxs||n==1)maxs=$1; rss+=$3; if($3>maxrss||n==1)maxrss=$3} END {
    printf "Runtime (s): avg=%.1f max=%.1f (avg=%.1f min, max=%.1f min)\n", s/n, maxs, s/n/60, maxs/60
    printf "Max RSS (MB): avg=%.1f max=%.1f\n", rss/n, maxrss
    printf "n=%d\n", n
}' "${files[@]}"
