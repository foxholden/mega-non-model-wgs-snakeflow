#!/bin/bash
#SBATCH --job-name=filter-snps
#SBATCH --account=csu96_alpine1
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --time=08:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=3
#SBATCH --output=logs/filter-snps-%j.out
#SBATCH --error=logs/filter-snps-%j.err

set -euo pipefail

eval "$(mamba shell hook --shell=bash)"
mamba activate /projects/foxhol@colostate.edu/miniforge3/envs/bcftools

# ---------------------------------------------------------------------------
# Help / usage
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<EOF
Usage:
  sbatch $0 <input> <output>

Description:
  Filter variants to biallelic PASS SNPs using bcftools, then index the result.

Arguments:
  <input>   Input variant file. Accepted formats:
              .bcf
              .vcf
              .vcf.gz

  <output>  Output variant file. Accepted formats:
              .bcf       → written as compressed BCF  (-Ob)
              .vcf.gz    → written as bgzipped VCF    (-Oz)

            Note: if your input is a plain .vcf, you must specify a .vcf.gz
            output — plain .vcf output is not supported.

Filters applied:
  -f PASS   Keep only PASS-tagged sites
  -m2 -M2   Require exactly 2 alleles (biallelic only)
  -v snps   Keep SNPs only

Output:
  The filtered file is written to <output> and indexed with bcftools index.

Examples:
  sbatch $0 variants.bcf          filtered_snps.bcf
  sbatch $0 variants.vcf.gz       filtered_snps.vcf.gz
  sbatch $0 raw_calls.vcf         filtered_snps.vcf.gz

EOF
    exit 0
fi

# ---------------------------------------------------------------------------
# Argument check
# ---------------------------------------------------------------------------
if [[ $# -ne 2 ]]; then
    echo "Usage: sbatch $0 <input.{bcf,vcf,vcf.gz}> <output.{bcf,vcf.gz}>"
    echo "Run with -h or --help for full usage."
    exit 1
fi

INPUT="$1"
OUTPUT="$2"

# ---------------------------------------------------------------------------
# Validate input file exists
# ---------------------------------------------------------------------------
if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: Input file not found: $INPUT"
    exit 1
fi

# ---------------------------------------------------------------------------
# Determine input format
# ---------------------------------------------------------------------------
case "$INPUT" in
    *.bcf)      INTYPE="b" ;;
    *.vcf.gz)   INTYPE="z" ;;
    *.vcf)      INTYPE="v" ;;
    *)
        echo "ERROR: Input must end in .bcf, .vcf, or .vcf.gz"
        exit 1
        ;;
esac

# ---------------------------------------------------------------------------
# Determine output format
# ---------------------------------------------------------------------------
case "$OUTPUT" in
    *.bcf)      OUTTYPE="b" ;;
    *.vcf.gz)   OUTTYPE="z" ;;
    *)
        echo "ERROR: Output must end in .bcf or .vcf.gz"
        echo "       Plain .vcf output is not supported — use .vcf.gz"
        exit 1
        ;;
esac

# ---------------------------------------------------------------------------
# Enforce .vcf → .vcf.gz rule
# ---------------------------------------------------------------------------
if [[ "$INTYPE" == "v" && "$OUTTYPE" != "z" ]]; then
    echo "ERROR: Plain .vcf input requires .vcf.gz output"
    exit 1
fi

# ---------------------------------------------------------------------------
# Create output directory if needed
# ---------------------------------------------------------------------------
OUTDIR="$(dirname "$OUTPUT")"
if [[ ! -d "$OUTDIR" ]]; then
    echo "Creating output directory: $OUTDIR"
    mkdir -p "$OUTDIR"
fi

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
echo "Input:       $INPUT"
echo "Output:      $OUTPUT"
echo "Output type: -O${OUTTYPE}"
echo ""

bcftools view \
    -f PASS \
    -m2 -M2 \
    -v snps \
    -O${OUTTYPE} \
    -o "$OUTPUT" \
    "$INPUT"

bcftools index -f "$OUTPUT"

echo ""
echo "Done."
