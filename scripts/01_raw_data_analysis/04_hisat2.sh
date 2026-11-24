#!/bin/bash
#-----------SLURM Parameters--------
#SBATCH -p normal
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=32
#SBATCH --mem=120g
#SBATCH --mail-user=sijie3@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J Hisat2_align_ZF_PTBP1
#SBATCH -o HISAT2_%j.out
#SBATCH -e HISAT2_%j.err

set -euo pipefail

# ----------------Load Modules--------------------
module load HISAT2
module load SAMtools

# ----------------Set Directories-----------------
PROJECT_DIR="/home/n-z/sijie3/data/ZF_PTBP1/data_Nov2026"

INPUT_DIR="${PROJECT_DIR}/3_trim"
OUTPUT_DIR="${PROJECT_DIR}/5_HISAT2"

# ----------------Reference Index-----------------
INDEX="/home/n-z/sijie3/genome_data/index/danRer11_hisat2_withspikein_m6A/danRer11-withspikein-m6A"

mkdir -p "${OUTPUT_DIR}"

# ----------------Set Threads---------------------
HISAT2_THREADS=24
SAMTOOLS_THREADS=8

# ----------------Check Reference-----------------
if [[ ! -f "${INDEX}.1.ht2" && ! -f "${INDEX}.1.ht2l" ]]; then
    echo "ERROR: HISAT2 index not found: ${INDEX}"
    exit 1
fi

# ----------------Check Input Files---------------
shopt -s nullglob

R1_FILES=("${INPUT_DIR}"/*_R1_trimmed.fastq)

if [[ ${#R1_FILES[@]} -eq 0 ]]; then
    echo "ERROR: No trimmed R1 FASTQ files found."
    exit 1
fi

# ----------------Commands------------------------
echo "Starting HISAT2 alignment: $(date)"
echo "Number of samples: ${#R1_FILES[@]}"
echo "Allocated CPUs: ${SLURM_CPUS_PER_TASK}"

for R1 in "${R1_FILES[@]}"; do

    R2="${R1/_R1_trimmed.fastq/_R2_trimmed.fastq}"

    # Check paired FASTQ files
    if [[ ! -f "${R2}" ]]; then
        echo "WARNING: Missing R2 for ${R1}"
        continue
    fi

    sample=$(basename "${R1}" _R1_trimmed.fastq)

    SAMPLE_DIR="${OUTPUT_DIR}/${sample}"
    mkdir -p "${SAMPLE_DIR}"

    SORTED_BAM="${SAMPLE_DIR}/${sample}_sorted.bam"
    ALIGN_LOG="${SAMPLE_DIR}/${sample}_hisat2.log"

    echo "======================================"
    echo "Processing sample: ${sample}"
    echo "Start time: $(date)"
    echo "======================================"

    # Align reads and sort BAM directly
    hisat2 \
        -t \
        -p "${HISAT2_THREADS}" \
        -x "${INDEX}" \
        -1 "${R1}" \
        -2 "${R2}" \
        2> "${ALIGN_LOG}" \
    | samtools sort \
        -@ "${SAMTOOLS_THREADS}" \
        -m 2G \
        -T "${SAMPLE_DIR}/sort_temp" \
        -o "${SORTED_BAM}" \
        -

    # Index sorted BAM
    samtools index \
        -@ "${SAMTOOLS_THREADS}" \
        "${SORTED_BAM}"

    # Generate alignment statistics
    samtools flagstat \
        -@ "${SAMTOOLS_THREADS}" \
        "${SORTED_BAM}" \
        > "${SAMPLE_DIR}/${sample}_flagstat.txt"

    echo "Completed sample: ${sample}"
    echo "End time: $(date)"

done

echo "All HISAT2 alignments completed: $(date)"
