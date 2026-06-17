#!/bin/bash
#SBATCH --job-name=mosdepth_windows
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --account=csu96_alpine1
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --array=1-143
#SBATCH --output=logs/mosdepth_%A_%a.out
#SBATCH --error=logs/mosdepth_%A_%a.err

set -euo pipefail

eval "$(mamba shell hook --shell=bash)"
USERNAME="foxhol@colostate.edu"
mamba activate /projects/${USERNAME}/miniforge3/envs/mosdepth

INDIR="results/bqsr-round-0/overlap_clipped/"
OUTDIR="results/bqsr-round-0/mosdepth_windows/"
mkdir -p "$OUTDIR"

BAM_LIST=(${INDIR}*.bam)
INDEX=$((SLURM_ARRAY_TASK_ID - 1))
BAM=${BAM_LIST[$INDEX]}
BASE=$(basename "$BAM" .bam)
BAM_ABS=$(realpath "$BAM")

echo "Processing: $BAM_ABS"

cd "$OUTDIR"
mosdepth --threads "$SLURM_CPUS_PER_TASK" \
  --by 100000 \
  --no-per-base \
  "$BASE" \
  "$BAM_ABS"

echo "Done: $BASE"
