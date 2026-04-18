#!/bin/bash
#SBATCH --job-name=cram2bam
#SBATCH --partition=csu96_alpine1
#SBACTH --qos=normal
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --array=1-436
#SBATCH --output=logs/cram2bam_%A_%a.out
#SBATCH --error=logs/cram2bam_%A_%a.err

set -euo pipefail

eval "$(mamba shell hook --shell=bash)"
USERNAME="foxhol@colostate.edu"
mamba activate /projects/${USERNAME}/miniforge3/envs/samtools_mnm

REF="../../resources/genome.fasta"

# list crams and pick one per task
CRAM_LIST=($(ls *.cram | sort))
CRAM=${CRAM_LIST[$SLURM_ARRAY_TASK_ID-1]}

# tell me the directory you want your bams to be in
OUTDIR="../mkdup/"
mkdir -p "$OUTDIR"

# convert bam to cram
BASE=$(basename "$CRAM" .cram)
BAM="${OUTDIR}/${BASE}.bam"

echo "Processing: $CRAM"
echo "Output: $BAM"

samtools view -@ $SLURM_CPUS_PER_TASK \
  -T "$REF" \
  -b \
  -o "$BAM" \
  "$CRAM"

# index the BAM
samtools index "$BAM"
echo "Done: $BASE"
