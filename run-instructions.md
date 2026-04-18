# Startup Notes

## Setup conda envs
For various reasons, I don't like snakemake handling my conda envs. It is not always the best at handling dependency issues, finding the hashed envs from compute nodes, etc. etc. For this reason, I prefer to install the conda envs manually for as many rules as possible. For all the non-wrapper rules, I am using prebuilt envs.

Run create-envs.sh to create all the non-wrapper conda envs.
```
bash create-envs.sh
```

## Install snakemake 8 executor plugin

Snakemake 8 uses pre-defined executor plugins for different job schedulers. My profile is setup to use the cluster-generic plugin. So you should install that in the snakemake mamba env
```
mamba activate snakemake-8.20.4

pip install snakemake-executor-plugin-cluster-generic
```

## Running
If on alpine, first check out an acompile node. It is important that snakemake installs the conda envs for the wrapper jobs from a compute node. If you install the conda envs from a login node, snakemake won't be able to find them from a compute node later and will try to remake them.
```
acompile -n 4 --time=08:00:00
```

Now perform a dry-run of the pipeline. Specifying CONDA_CHANNEL_PRIORITY=flexible and --conda-frontend conda can help with snakemake conda env installation and dependency solving issues.
```
CONDA_CHANNEL_PRIORITY=flexible snakemake --use-conda \
	  --conda-frontend conda \
	  --profile /scratch/alpine/foxhol@colostate.edu/apr26-clone/mega-non-model-wgs-snakeflow/hpcc-profiles/slurm/alpine/ \
	  --configfile /scratch/alpine/foxhol@colostate.edu/apr26-clone/mega-non-model-wgs-snakeflow/example-configs/LOSH-Apr-25/config.yaml \
	  -np
```

If that worked, start the full run in acompile. This should prompt snakemake to install the conda envs for the wrapper jobs. Because snakemake is slow at handling conda installs, this may take a while. After the envs are created, the pipeline will start submitting jobs.
```
CONDA_CHANNEL_PRIORITY=flexible snakemake --use-conda \
          --conda-frontend conda \
          --profile /scratch/alpine/foxhol@colostate.edu/apr26-clone/mega-non-model-wgs-snakeflow/hpcc-profiles/slurm/alpine/ \
          --configfile /scratch/alpine/foxhol@colostate.edu/apr26-clone/mega-non-model-wgs-snakeflow/example-configs/LOSH-Apr-25/config.yaml \
          -p
```

Once the wrapper envs are installed and you have it running, you can let it go until acompile times out or control + C to cancel the run. Use the submit_snakemake.sbatch script for the full run
```
sbatch submit_snakemake.sbatch
```

Goodluck!

## Misc Notes
### Replace the genome.fasta from the test data
If you run the test data before your own, make sure to delete the genome.fasta from resources/ that is populated there. This is the reference genome for Salmon. Replace it with your own reference called genome.fasta
### Typical OOM Failures
- Mark_duplicates sometimes requires a LOT of memory. I had one sample that needed more than 30 amilan cores (3.75GB per core).
- Clip_overlaps can also require lots of memory. You amy consider maxing this out if you have OOM failures. The --poolsize might also need to be greatly expanded.
## Checking PCR duplicate rates
Run in results/bqsr-round-0/qc/mkdup/
```
(echo -e "BGP_ID\tPercentDuplication"; for file in *.metrics.txt; do echo -e "$(basename "$file" .metrics.txt)\t$(awk 'NR==8 {print $9}' "$file")"; done) > sample_pcr_dups.tsv
```
