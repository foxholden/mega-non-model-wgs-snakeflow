#!/bin/bash
#SBATCH --job-name=bam2cram
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --account=csu96_alpine1
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --array=1-422
#SBATCH --output=logs/bam2cram_%A_%a.out
#SBATCH --error=logs/bam2cram_%A_%a.err

set -euo pipefail

eval "$(mamba shell hook --shell=bash)"
USERNAME="foxhol@colostate.edu"
mamba activate /projects/${USERNAME}/miniforge3/envs/samtools_mnm

REF="resources/genome.fasta"
INDIR="results/bqsr-round-0/downsample-5.0X/overlap_clipped/"

# grab a bam for each task
BAM_LIST=(${INDIR}*.bam)
BAM=${BAM_LIST[$((SLURM_ARRAY_TASK_ID - 1))]}

# tell me what dir you want them to be in
OUTDIR="results/bqsr-round-0/downsample-5.0X/overlap_clipped/"
#mkdir -p "$OUTDIR"

BASE=$(basename "$BAM" .bam)
CRAM="${OUTDIR}/${BASE}.cram"

echo "Processing: $BAM"
echo "Output: $CRAM"

samtools view -@ $SLURM_CPUS_PER_TASK -C \
  -T "$REF" \
  -o "$CRAM" \
  "$BAM"

# index it
samtools index "$CRAM"
echo "Done: $BASE"
