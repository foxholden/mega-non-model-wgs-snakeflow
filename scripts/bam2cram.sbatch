#!/bin/bash
#SBATCH --job-name=bam2cram
#SBATCH --partition=amilan
#SBACTH --qos=normal
#SBATCH --csu96_alpine1
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --array=1-436
#SBATCH --output=logs/bam2cram_%A_%a.out
#SBATCH --error=logs/bam2cram_%A_%a.err

set -euo pipefail

eval "$(mamba shell hook --shell=bash)"
USERNAME="foxhol@colostate.edu"
mamba activate /projects/${USERNAME}/miniforge3/envs/samtools_mnm

REF="../../resources/genome.fasta"

# grab a bam for each task
BAM_LIST=($(ls ../mkdup/*.bam | sort))
BAM=${BAM_LIST[$SLURM_ARRAY_TASK_ID-1]}

# tell me what dir you want them to be in
OUTDIR="../rmdup-crams"
mkdir -p "$OUTDIR"

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
