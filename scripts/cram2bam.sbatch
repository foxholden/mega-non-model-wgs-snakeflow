#!/bin/bash
#SBATCH --job-name=cram2bam
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --account=csu96_alpine1
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --array=1-422
#SBATCH --output=logs/cram2bam_%A_%a.out
#SBATCH --error=logs/cram2bam_%A_%a.err

set -euo pipefail

# my samtools version from mnm-smk is called samtools_mnm (see my fork of mnm-smk on github for .yaml)
eval "$(mamba shell hook --shell=bash)"
USERNAME="foxhol@colostate.edu"
mamba activate /projects/${USERNAME}/miniforge3/envs/samtools_mnm

# specify reference genome
REF="resources/genome.fasta"
INDIR="results/bqsr-round-0/downsample-5.0X/overlap_clipped/"

# grab a cram for each array task
CRAM_LIST=(${INDIR}*.cram)
INDEX=$((SLURM_ARRAY_TASK_ID - 1))
CRAM=${CRAM_LIST[$INDEX]}

OUTDIR="results/bqsr-round-0/downsample-5.0X/overlap_clipped/"
mkdir -p "$OUTDIR"


BASE=$(basename "$CRAM" .cram)
BAM="${OUTDIR}/${BASE}.bam"

echo "Processing: $CRAM"
echo "Output: $BAM"

# convert to BAM
samtools view -@ "$SLURM_CPUS_PER_TASK" -b \
  -T "$REF" \
  -o "$BAM" \
  "$CRAM"

# index it
samtools index "$BAM"
echo "Done: $BASE"
