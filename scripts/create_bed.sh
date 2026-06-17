#!/bin/bash
# Build a BED of chromosome 0-based coordinates from chromosomes.tsv, ordered by length descending
tail -n +2 example-configs/losh-captive/chromosomes.tsv | \
  sort -t$'\t' -k2,2 -n -r | \
  awk -F'\t' 'BEGIN{OFS="\t"} {print $1, 0, $2}' > resources/chromosomes_sorted.bed

echo "Chromosomes ordered by length (longest first):"
cat resources/chromosomes_sorted.bed
