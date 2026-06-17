#!/bin/bash
#SBATCH --job-name=unlock-mnm-smk
#SBATCH --account=csu96_alpine1
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --mem=8G
#SBATCH --output=logs/unlock-mnm-smk-%j.out
#SBATCH --error=logs/unlock-mnm-smk-%j.err


# ---- trap: forward signals to Snakemake ----
#trap "echo 'Received signal, stopping Snakemake...'; kill -INT $SNK_PID; wait $SNK_PID" INT TERM

eval "$(mamba shell hook --shell=bash)"
mamba activate /projects/foxhol@colostate.edu/miniforge3/envs/snakemake-8.20.4

CONDA_CHANNEL_PRIORITY=flexible snakemake --unlock  \
	  --configfile /scratch/alpine/foxhol@colostate.edu/losh-captive/mega-non-model-wgs-snakeflow/example-configs/losh-captive/config.yaml \

#SNK_PID=$!
# wait for snakemake to finish
#wait $SNK_PID
