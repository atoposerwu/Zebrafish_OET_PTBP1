#!/bin/bash
#-----------SLURM Parameters--------
#SBATCH -p normal
#SBATCH -n 8
#SBATCH --mem=50g
#SBATCH -N 1
#SBATCH --mail-user=sijie3@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J 4_Kallisto_PE
#SBATCH -o Kallisto_PE_%j.out
#SBATCH -e Kallisto_PE_%j.err

set -euo pipefail

# ----------------Load Modules--------------------
module load kallisto

# ----------------Paths---------------------------
PROJECT_DIR="/home/n-z/sijie3/data/ZF_PTBP1/data_Nov2026"

INPUT_DIR="${PROJECT_DIR}/3_trim"
OUTPUT_DIR="${PROJECT_DIR}/4_Kallisto"

INDEX_DIR="/home/n-z/sijie3/genome_data/index"

CDNA_INDEX="${INDEX_DIR}/GRCz11_cDNA_kallisto_2026_index/Danio_rerio.GRCz11.cdna.all.withSpikein.kallisto.idx"

NCRNA_INDEX="${INDEX_DIR}/GRCz11_ncRNA_kallisto_2026_index/Danio_rerio.GRCz11.ncrna.withSpikein.kallisto.idx"

CDNA_OUTPUT="${OUTPUT_DIR}/cDNA"
NCRNA_OUTPUT="${OUTPUT_DIR}/ncRNA"

mkdir -p "${CDNA_OUTPUT}" "${NCRNA_OUTPUT}"

# ----------------Check Files---------------------
echo "Kallisto version:"
kallisto version

for INDEX in "${CDNA_INDEX}" "${NCRNA_INDEX}"; do
    if [[ ! -f "${INDEX}" ]]; then
        echo "ERROR: Index not found: ${INDEX}"
        exit 1
    fi
done

# ----------------Quantification------------------
echo "Starting kallisto quantification: $(date)"

shopt -s nullglob
R1_FILES=("${INPUT_DIR}"/*_R1_trimmed.fastq)

if [[ ${#R1_FILES[@]} -eq 0 ]]; then
    echo "ERROR: No trimmed R1 FASTQ files found."
    exit 1
fi

for R1 in "${R1_FILES[@]}"; do

    base=$(basename "${R1}" _R1_trimmed.fastq)
    R2="${INPUT_DIR}/${base}_R2_trimmed.fastq"

    if [[ ! -f "${R2}" ]]; then
        echo "WARNING: Paired R2 file not found for ${base}"
        continue
    fi

    echo "======================================"
    echo "Processing sample: ${base}"
    echo "======================================"

    # Quantify against the cDNA transcriptome
    echo "Running cDNA quantification..."

    kallisto quant \
        -i "${CDNA_INDEX}" \
        -o "${CDNA_OUTPUT}/${base}" \
        -t 8 \
        --plaintext \
        "${R1}" "${R2}"

    # Quantify against the ncRNA transcriptome
    echo "Running ncRNA quantification..."

    kallisto quant \
        -i "${NCRNA_INDEX}" \
        -o "${NCRNA_OUTPUT}/${base}" \
        -t 8 \
        --plaintext \
        "${R1}" "${R2}"

    echo "Completed sample: ${base}"

done

echo "All kallisto quantifications completed: $(date)"
