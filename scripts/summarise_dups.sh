#!/bin/bash
set -euo pipefail

INDIR="results/bqsr-round-0/qc/mkdup"
FINAL="results/bqsr-round-0/qc/mkdup/duplicate_summary.tsv"

echo -e "sample\tlibrary\tunpaired_reads_examined\tread_pairs_examined\tsecondary_or_supplementary_rds\tunmapped_reads\tunpaired_read_duplicates\tread_pair_duplicates\tread_pair_optical_duplicates\tpercent_duplication\testimated_library_size" > "$FINAL"

for f in "${INDIR}"/*.metrics.txt; do
    sample=$(basename "$f" .metrics.txt)

    header_line=$(grep -n "^LIBRARY" "$f" | head -1 | cut -d: -f1)

    if [ -z "$header_line" ]; then
        echo "Warning: no LIBRARY header found in $f, skipping"
        continue
    fi

    data_line=$((header_line + 1))

    sed -n "${data_line}p" "$f" | awk -F'\t' -v s="$sample" 'BEGIN{OFS="\t"} {print s, $0}' >> "$FINAL"
done

echo "Wrote: $FINAL"
column -t "$FINAL" | head -5
