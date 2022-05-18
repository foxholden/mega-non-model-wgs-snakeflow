mega-non-model-wgs-snakeflow
================

-   [Quick install and run](#quick-install-and-run)
    -   [So, what just happened there](#so-what-just-happened-there)
-   [Condensed DAG for the workflow](#condensed-dag-for-the-workflow)
-   [Running this with SLURM](#running-this-with-slurm)
-   [What the user must do and values to be set,
    etc](#what-the-user-must-do-and-values-to-be-set-etc)
    -   [`units.tsv`](#unitstsv)
    -   [`chromosomes.tsv`](#chromosomestsv)
    -   [`scaffold_groups.tsv`](#scaffold_groupstsv)
    -   [`config.yaml`](#configyaml)
-   [Assumptions](#assumptions)
-   [Things fixed or added relative to JK’s snakemake
    workflow](#things-fixed-or-added-relative-to-jks-snakemake-workflow)
-   [Things that will be added in the
    future](#things-that-will-be-added-in-the-future)
-   [Stepwise addition of new samples to the Workflow (and the Genomics
    Data
    bases)](#stepwise-addition-of-new-samples-to-the-workflow-and-the-genomics-data-bases)

## Quick install and run

If you would like to put this on your system and test it running on the
tiny test data set it comes with on a single node (or across multiple
nodes if you are on a SLURM cluster), these are the s you have to take.
We assume that you already have `git` installed.

1.  Install Snakemake if you don’t already have it. I have been
    developing and testing this mostly on snakemake-6, but am not
    testing and using it with snakemake-7.7.0. You must have a *full
    installation* of snakemake, and you must have `mamba`. To install
    snakemake so that this all works, follow the installation directions
    at
    <https://snakemake.readthedocs.io/en/stable/getting_started/installation.html>.

If you already have snakemake, but it it version 6 or earlier, you
should create a new snakemake environment with the latest version. Check
the installation page to see what the latest version is and then tag the
name of your snakemake environment with it. For example, if the latest
stable version is 7.7.0, you command would look like:

``` sh
conda activate base
mamba create -c conda-forge -c bioconda -n snakemake-7.7.0 snakemake
```

2.  You must have cloned this repository. If you are savvy with this
    sort of thing, you might as well fork it then clone it. If not, the
    simplest way to clone it will be to use this command:

``` sh
git clone https://github.com/eriqande/mega-non-model-wgs-snakeflow.git
```

3.  When that is done, change into the repository directory, and
    activate the snakemake conda environment:

``` sh
cd mega-non-model-wgs-snakeflow/
conda activate snakemake-7.7.0
```

4.  The first thing we will do is a “dry-run” of the workflow. This
    tells you all the different steps that will be taken, but does not
    actually run them.

``` sh
 snakemake --cores 20 --use-conda  -np --configfile .test/config/config.yaml
```

-   The `--configfile` option tells snakemake to find all the
    configurations for the run in `.test/config/config.yaml`. This runs
    a very small test data set of 8 samples from fastq to VCF.
-   The `-np` option tells snakemake to do a dry run and also to print
    all the shell commands that it would use.

After you run that command, there should be a lot of output (one little
block for each job) and then a summary at the end that looks something
like this:

    Job stats:
    job                                   count    min threads    max threads
    ----------------------------------  -------  -------------  -------------
    all                                       1              1              1
    bung_filtered_vcfs_back_together          6              1              1
    bwa_index                                 1              1              1
    fastqc_read1                             22              1              1
    fastqc_read2                             22              1              1
    genome_dict                               1              1              1
    genome_faidx                              1              1              1
    genomics_db2vcf                           6              2              2
    genomics_db_import_chromosomes            4              2              2
    genomics_db_import_scaffold_groups        2              2              2
    get_genome                                1              1              1
    hard_filter_indels                        6              1              1
    hard_filter_snps                          6              1              1
    make_gvcfs                                8              1              1
    make_indel_vcf                            6              1              1
    make_snp_vcf                              6              1              1
    map_reads                                22              4              4
    mark_dp0_as_missing                       6              1              1
    mark_duplicates                           8              1              1
    multiqc                                   1              1              1
    samtools_stats                            8              1              1
    trim_reads_pe                            22              1              1
    vcf_concat                                1              1              1
    total                                   167              1              4

    This was a dry-run (flag -n). The order of jobs does not reflect the order of execution.

5.  Do the run. But only install the necessary software environments:

``` sh
snakemake --cores 20 --use-conda  --conda-create-envs-only --configfile .test/config/config.yaml
```

This can take 5 or 10 minutes, or even longer, but you only have to do
it once. After that, when you run the workflow, all the software
environments will already be in place.

6.  Once that has finished. Do a whole run of the test data set. Note
    that this is set up to use 20 cores, which is reasonable if you have
    checked out an entire node on SEDNA, using, for example
    `srun -c 20 --pty /bin/bash`. At any rate, to do the run you give
    this command:

``` sh
 snakemake --cores 20 --use-conda  --keep-going --configfile .test/config/config.yaml
```

When you do that it should take about 5 minutes to run through the whole
workflow on the tiny test data. Note that the multiqc step will fail.
This is a quirk of the tiny test data. I have never had a problem with
it failing on real, full-sized data sets. You will get an error message
about the multiqc rule failing, but, with the `--keep-going` option,
everything else will finish.

7.  Once that has finished. Do a dry run of snakemake again and you
    should see that all that remains is that pesky multiqc run (again,
    this won’t be a problem on real data) which is part of rule `all`:

``` sh
snakemake --cores 20 --use-conda  --keep-going  -np --configfile .test/config/config.yaml
```

### So, what just happened there

The upshot is that this workflow started with the fastq files in `.test`
that represent 8 samples sequenced across multiple lanes and prepared in
different libraries:

``` sh
(snakemake-7.7.0) [node08: mega-non-model-wgs-snakeflow]--% ls .test/data/fastq/
T199967_T2087_HY75HDSX2_L001_R1_001.fastq.gz  T199970_T2094_HY75HDSX2_L004_R2_001.fastq.gz  T199973_T2087_HY75HDSX2_L002_R1_001.fastq.gz
T199967_T2087_HY75HDSX2_L001_R2_001.fastq.gz  T199971_T2087_HY75HDSX2_L002_R1_001.fastq.gz  T199973_T2087_HY75HDSX2_L002_R2_001.fastq.gz
T199968_T2087_HY75HDSX2_L001_R1_001.fastq.gz  T199971_T2087_HY75HDSX2_L002_R2_001.fastq.gz  T199973_T2087_HY75HDSX2_L003_R1_001.fastq.gz
T199968_T2087_HY75HDSX2_L001_R2_001.fastq.gz  T199971_T2087_HY75HDSX2_L004_R1_001.fastq.gz  T199973_T2087_HY75HDSX2_L003_R2_001.fastq.gz
T199968_T2087_HY75HDSX2_L002_R1_001.fastq.gz  T199971_T2087_HY75HDSX2_L004_R2_001.fastq.gz  T199973_T2094_HY75HDSX2_L002_R1_001.fastq.gz
T199968_T2087_HY75HDSX2_L002_R2_001.fastq.gz  T199971_T2099_HTYYCBBXX_L002_R1_001.fastq.gz  T199973_T2094_HY75HDSX2_L002_R2_001.fastq.gz
T199969_T2087_HTYYCBBXX_L002_R1_001.fastq.gz  T199971_T2099_HTYYCBBXX_L002_R2_001.fastq.gz  T199973_T2094_HY75HDSX2_L003_R1_001.fastq.gz
T199969_T2087_HTYYCBBXX_L002_R2_001.fastq.gz  T199972_T2087_HTYYCBBXX_L003_R1_001.fastq.gz  T199973_T2094_HY75HDSX2_L003_R2_001.fastq.gz
T199969_T2087_HY75HDSX2_L002_R1_001.fastq.gz  T199972_T2087_HTYYCBBXX_L003_R2_001.fastq.gz  T199974_T2087_HY75HDSX2_L001_R1_001.fastq.gz
T199969_T2087_HY75HDSX2_L002_R2_001.fastq.gz  T199972_T2087_HY75HDSX2_L001_R1_001.fastq.gz  T199974_T2087_HY75HDSX2_L001_R2_001.fastq.gz
T199969_T2087_HY75HDSX2_L003_R1_001.fastq.gz  T199972_T2087_HY75HDSX2_L001_R2_001.fastq.gz  T199974_T2094_HY75HDSX2_L001_R1_001.fastq.gz
T199969_T2087_HY75HDSX2_L003_R2_001.fastq.gz  T199972_T2094_HTYYCBBXX_L004_R1_001.fastq.gz  T199974_T2094_HY75HDSX2_L001_R2_001.fastq.gz
T199970_T2087_HY75HDSX2_L003_R1_001.fastq.gz  T199972_T2094_HTYYCBBXX_L004_R2_001.fastq.gz  T199974_T2099_HY75HDSX2_L001_R1_001.fastq.gz
T199970_T2087_HY75HDSX2_L003_R2_001.fastq.gz  T199972_T2094_HY75HDSX2_L002_R1_001.fastq.gz  T199974_T2099_HY75HDSX2_L001_R2_001.fastq.gz
T199970_T2094_HY75HDSX2_L004_R1_001.fastq.gz  T199972_T2094_HY75HDSX2_L002_R2_001.fastq.gz
```

And then it downloaded the genome for those samples, trimmed the
fastq’s, fastqc-ed them, mapped them to the genome, marked duplicates,
created gVCF files for each sample, imported those gVCF files to a
genomics data base, genotyped the samples from those genomic data bases,
marked sites with 0 read depth as missing, did best-practices GATK
hard-filtering on those genotypes, then combined a lot of VCF files
across multiple regions of the genome into a single VCF file called
`results/vcf/all-filtered.vcf.gz`. You can have a look at that with the
command:

``` sh
zcat results/vcf/all-filtered.vcf.gz | less
```

If you are doing this on a Mac, then you can use `gzcat` instead of
`zcat`.

Additionally, the log files from every job that got run have been
recorded in various directories and files in `results/logs`.

Finally, run-time information (how long it took, how much memory was
required, how much disk I/O occurred) for every one of the jobs that ran
is recorded in various directories and files in `results/benchmarks`.
This can be a treasure trove for estimating how long different
jobs/steps of this workflow will take on new data sets.

All the files generated by the workflow are stored in

-   `resources`: downloaded and indexed genomes, etc. This also contains
    some adapter sequence files for trimmomatic that are distributed
    with this repo.
-   `results`: all the logs, all the outputs, etc.

A number of files are temporary files and are deleted after all
downstream products they depend on have been produced. There are many
more such files to mark as temporary, but I will do that after I have
used this updated workflow to finish out a long project.

Some files are marked as *protected* so that they cannot easily be
accidentally deleted or modified. These include:

-   `results/vcf/all-filtered.vcf.gz`
-   All the dupe-marked BAM files for each sample in `results/mkdup`
-   All the gVCF files for each sample in `results/gvcf`

It would be typical practice to copy and archive all those to some other
place upon completion of the project.

The following section shows a nice acylic directed graph diagram of all
the steps in the workflow.

## Condensed DAG for the workflow

Here is a DAG for the workflow on the test data in `.test`, condensed
into an easier-to-look-at picture by the `condense_dag()` function in
Eric’s [SnakemakeDagR](https://github.com/eriqande/SnakemakeDagR)
package. ![](README_files/test_run_dag_condensed.svg)<!-- -->

## Running this with SLURM

This repository includes a snakemake profile that allows all the jobs in
the workflow to be dispatched via the SLURM scheduler. This can be
really handy. To test this on SEDNA, for example, do this:

1.  Remove the `results` and the genome parts in the `resources`
    directory, so that snakemake will run through the entire workflow,
    again:

``` sh
rm -rf resources/genome* results
```

The `-f` in the `-rf` option in the command above is used to override
the write-protection on some of the files.

2.  Do a dry run using the SEDNA slurm profile:

``` sh
snakemake --profile hpcc-profiles/slurm/sedna -np --configfile .test/config/config.yaml
```

You should get dry-run output like before.

3.  Make sure you have another shell available that you can put this
    command into, in order to see your SLURM job queue:

``` sh
squeue -u $(whoami) -o "%.12i %.9P %.50j %.10u %.2t %.15M %.6D %.18R %.5C %.12m"
```

4.  Start the snakemake job, using the slurm profile:

``` sh
snakemake --profile hpcc-profiles/slurm/sedna --configfile .test/config/config.yaml
```

While this is running, go to your other shell and use the above squeue
command to see all of your jobs that are queued or running. (To be
honest, there seems to be some latency with squeue on SEDNA. Since all
these jobs are super short, it might be that they are not there long
enough for squeue to show them. Instead, you can use
`sacct -u $(whoami)` to see all those jobs when running or completed).

## What the user must do and values to be set, etc

### `units.tsv`

The user has to make a file that lists all the different *units* of a
single sample. Typically different units are different fastq files that
hold sequences from a sinble biological sample. For example, the same
sample might have been sequenced on different lanes, or on different
machines, or it might have been prepared in more than a single library
prep. All that can be accounted for. The `units.tsv` file holds a lot of
necessary information for each sample. Here is a link to the `units.tsv`
file used for the `.test` data set:

<https://github.com/eriqande/mega-non-model-wgs-snakeflow/blob/main/.test/config/units.tsv>

All columns are required. Study it!

### `chromosomes.tsv`

The user must make this file that tells the workflow about the different
fully assembled chromosomes in the reference genome. Here is an example:

<https://github.com/eriqande/mega-non-model-wgs-snakeflow/blob/main/.test/config/chromosomes.tsv>

It is a TAB separated values file. You have to follow the format
exactly. The file can easily be made from the `.fai` file for the
genome. You can modify the helper script at
`workflow/prepare/make_chromosomes_and_scaffolds.R` to prepare this file
for yourself. Here is a link that that file if you want to see the
contents:

<https://github.com/eriqande/mega-non-model-wgs-snakeflow/blob/main/workflow/prepare/make_chromosomes_and_scaffolds.R>

The workflow operates a lot on individual chromosomes to allow
parallelization, so this is critical information.

### `scaffold_groups.tsv`

The user must make this file that tells snakemake which collections of
scaffolds should be merged together into scaffold groups.  
Here is what the `scaffold_groups.tsv` file looks like:

<https://github.com/eriqande/mega-non-model-wgs-snakeflow/blob/main/.test/config/scaffold_groups.tsv>

You have to follow the format, exactly. Also, the order of the scaffolds
in this file must match the order of the scaffolds in the reference
genome EXACTLY.

This file can also be made from the `.fai` file for the genome using the
helper script at `workflow/prepare/make_chromosomes_and_scaffolds.R`:

<https://github.com/eriqande/mega-non-model-wgs-snakeflow/blob/main/workflow/prepare/make_chromosomes_and_scaffolds.R>

### `config.yaml`

The user must make a `config.yaml` file. It serves a lot of purposes,
like:

-   giving the relative path to the `units.tsv`, `chromosomes.tsv`, and
    `scaffold_groups.tsv` files.
-   Giving the URL from which the reference genome can be downloaded.
    (If there is not a URL for it, then just copy the reference FASTA
    file to `resources/genome.fasta`).
-   The location of the adapter file for Trimmomatic must be specified.
    The correct one to use depends on what sequencing platform your data
    come from.
-   Some parameters can be set here; however, some of the YAML blocks
    here are vestigial and need to be cleaned up. Not all of these
    options actually change things. For now, ask Eric for help…

The current `config.yaml` file in the test directory can be viewed at:

<https://github.com/eriqande/mega-non-model-wgs-snakeflow/blob/main/.test/config/config.yaml>

As mentioned above, there is a little bit of cruft in it that should
stay in there for now, but which ought to be cleaned up, ultimately.

## Assumptions

-   Paired end

## Things fixed or added relative to JK’s snakemake workflow

-   fastqc on both reads
-   don’t bother with single end
-   add adapters so illumina clip can work
-   benchmark each rule
-   use genomicsDBimport
-   allow for merging of lots of small scaffolds into genomicsDB

## Things that will be added in the future

-   Develop a sane way to iteratively bootstrap some base-quality score
    recalibration.

## Stepwise addition of new samples to the Workflow (and the Genomics Data bases)

I have made a scheme were we can start with one units.tsv file that
maybe only has six samples in it, and you can run that to completion.
Then you can update the units.tsv file to have two additional samples in
it, and that should then properly update the genomics data bases. This
is done by a system of writing Genomics\_DBI receipts that tell us what
is already in there.

Here is how you can run it and test that system is working properly on
the small included test data set. First we run it on the first six
samples, using `.test/config/units-only-s001-s006.tsv` as the units
file. This file can be viewed
[here](https://github.com/eriqande/mega-non-model-wgs-snakeflow/blob/main/.test/config/units-only-s001-s006.tsv)

``` sh
# run the pipeline on the first six samples:
snakemake --use-conda --cores 6  --keep-going --config units=.test/config/units-only-s001-s006.tsv
```

That should run through just fine. In the above I set it to use 6 cores,
and, after all the conda environments have been installed, it takes
about 5 minutes to run through this small test data set on my old
(mid-2014) Mac laptop that has 8 cores.

After that has completed, you should have a look at all the ouputs in
results. The chromosome- and scaffold-group-specific VCFs are in
`results/vcf_sections`. Note that they haven’t been filtered at all.

Also, you can check the multiqc report by opening
`results/qc/multiqc.html`

Now. Let us pretend that we did that initial run with our first six
samples when those were the only samples we had. But now we want to add
two more samples: `s007` and `s008`. If we have kept the genomics
databases, they can simply be updated. The snakemake workflow does all
that for us. All we have to do is provide an updated units file that has
all our original 6 samples, just like before, but has a few more rows
for the units corresponding to `s007` and `s008`. Such a file can be
seen
[here](https://github.com/eriqande/mega-non-model-wgs-snakeflow/blob/main/.test/config/units.tsv).

We run that as shown below. We have to be careful to force re-running
two rules,

``` sh
# To add the final two samples
# re-run it with the standard config that
# has the units.tsv file with all 8 samples, and we will --forcerun the
# genomics_db2vcf rule, to make sure it notices that it needs to add
# some more samples to the genomics data bases. # We also --forcerun the
# multiqc step, since that has to do re-done with all the new samples.
snakemake --use-conda --cores 6  --keep-going \
   --config units=.test/config/units.tsv \
   --forcerun genomics_db2vcf multiqc 
```

**NOTE:** on this tiny data set in `./test`, everything works on this
*except* that multiqc fails, likely because there isn’t enough data for
one of the samples or something weird like that…At any rate, don’t be
alarmed by that failure. It doesn’t seem to happen on more complete data
sets.

**HUGE CRUCIAL NOTE:** You *cannot* use this process to add any
additional units of samples you have already run through the workflow.
If you do that, it will completely screw everything up. This is useful
only when you are adding completely new samples to the workflow, it is
not designed for adding more reads from any sample that has already been
put into the genomics data bases. (That said, if you got new sequences
on a new machine/flow-cell or library from a sample that you had already
run through the pipeline, and you wanted to compare the results from the
new sequences to those from the original sequences, you could simply
give those newly-resequenced samples new sample\_id’s (and sample
numbers). That would work.)
