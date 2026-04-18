#!/bin/bash
#SBATCH --job-name=mnm-smk
#SBATCH --account=csu96_alpine1
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --mem=8G
#SBATCH --output=logs/mnm-smk-%j.out
#SBATCH --error=logs/mnm-smk-%j.err

eval "$(mamba shell hook --shell=bash)"
mamba activate /projects/foxhol@colostate.edu/miniforge3/envs/snakemake-8.20.4

CONDA_CHANNEL_PRIORITY=flexible snakemake --use-conda \
	  --conda-frontend conda \
	  --profile /scratch/alpine/foxhol@colostate.edu/apr26-clone/mega-non-model-wgs-snakeflow/hpcc-profiles/slurm/alpine/ \
	  --configfile /scratch/alpine/foxhol@colostate.edu/apr26-clone/mega-non-model-wgs-snakeflow/example-configs/LOSH-Apr-25/config.yaml \
	  -p \
	  --until thin_bam
