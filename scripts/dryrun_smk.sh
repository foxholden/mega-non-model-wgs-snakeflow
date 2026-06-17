#!/bin/bash
#SBATCH --job-name=dryrun-smk
#SBATCH --account=csu96_alpine1
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --time=08:00:00
#SBATCH --mem=8G
#SBATCH --output=logs/dryrun-smk-%j.out
#SBATCH --error=logs/dryrun-smk-%j.err


# ---- trap: forward signals to Snakemake ----
#trap "echo 'Received signal, stopping Snakemake...'; kill -INT $SNK_PID; wait $SNK_PID" INT TERM

eval "$(mamba shell hook --shell=bash)"
mamba activate /projects/foxhol@colostate.edu/miniforge3/envs/snakemake-8.20.4

CONDA_CHANNEL_PRIORITY=flexible snakemake --use-conda \
	  --conda-frontend conda \
	  --profile /scratch/alpine/foxhol@colostate.edu/losh-captive/mega-non-model-wgs-snakeflow/hpcc-profiles/slurm/alpine/ \
	  --configfile /scratch/alpine/foxhol@colostate.edu/losh-captive/mega-non-model-wgs-snakeflow/example-configs/losh-captive/config.yaml \
	  -np


#SNK_PID=$!
# wait for snakemake to finish
#wait $SNK_PID
