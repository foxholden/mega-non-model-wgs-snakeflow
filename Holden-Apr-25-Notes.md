## notes form Apr-25 run.


I have had no trouble running the workflow with conda envs from the env.yaml. If you have trouble installing or snakmake trying to install envs that are already built. Try giving the rule the name of a conda env that already exists e.g. snakmake-8.20.4. Download bwa, picard, gatk, etc in here...

you should install this executor plugin
```
pip install snakemake-executor-plugin-cluster-generic
```


I ran the test data before my run, which might have helped the above problem.

Delete the genome from the test data and put your genome.fasta in resources/

Mark dups sometimes requires a lot of memory. I had one sample that needed more than 30 amilan cores (3.75GB per core). Instead of asking for a ton of memory for all, try 30 cores and for the few that need it run again with more mem. I am asking for 200GB using 100 amilan128c cores (ea w/ 2.01GB). Change this back when ur done.

Check pcr dup rates:

# i ran this in results/bqsr-round-0/qc/mkdup/ but you could change path and run from mnmws dir.
(echo -e "BGP_ID\tPercentDuplication"; for file in *.metrics.txt; do echo -e "$(basename "$file" .metrics.txt)\t$(awk 'NR==8 {print $9}' "$file")"; done) > sample_pcr_dups.tsv
