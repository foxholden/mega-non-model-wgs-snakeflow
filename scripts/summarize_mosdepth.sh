#!/bin/bash
set -euo pipefail

OUTDIR="results/bqsr-round-0/mosdepth_windows"
CHROM_LIST="example-configs/losh-captive/chromosomes.tsv"
FINAL="results/bqsr-round-0/mosdepth_windows/all_samples_windowed_depth.tsv"

echo -e "sample\tchrom\tstart\tend\tdepth" > "$FINAL"

for f in "${OUTDIR}"/*.regions.bed.gz; do
    sample=$(basename "$f" .regions.bed.gz)
    zcat "$f" | awk -v s="$sample" 'BEGIN{OFS="\t"} {print s, $1, $2, $3, $4}' >> "$FINAL"
done

# Keep only chromosomes in chromosomes.tsv (drops unplaced scaffolds)
awk -F'\t' 'NR==FNR {if(FNR>1) keep[$1]=1; next} FNR==1 || ($2 in keep)' \
    "$CHROM_LIST" "$FINAL" > "${FINAL}.filtered"
mv "${FINAL}.filtered" "$FINAL"

echo "Combined windowed depth table: $FINAL"
wc -l "$FINAL"
