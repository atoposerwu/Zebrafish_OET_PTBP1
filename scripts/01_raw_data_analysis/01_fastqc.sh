#!/bin/bash
#-----------SLURM Parameters--------
#SBATCH -p normal
#SBATCH -n 1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20g
#SBATCH -N 1
#SBATCH --time=12:00:00
#SBATCH --mail-user=sijie3@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J ZF_PTBP1_FastQC
#SBATCH -o FastQC_%j.out
#SBATCH -e FastQC_%j.err

# ----------------Load Modules--------------------
module load FastQC

# ----------------Set Directories-----------------
PROJECT="/home/n-z/sijie3/data/ZF_PTBP1"

INPUT_DIR="${PROJECT}/data_Nov2026/1_fastq_files"
OUTPUT_DIR="${PROJECT}/data_Nov2026/2_fastqc_results"

mkdir -p "${OUTPUT_DIR}"

# ----------------Commands------------------------
echo "Starting FastQC analysis: $(date)"

# Process all compressed FASTQ files (R1 and R2)
for fq in "${INPUT_DIR}"/*.fastq.gz; do

    # Check whether FASTQ files exist
    [[ -f "${fq}" ]] || continue

    echo "Processing: $(basename "${fq}")"

    fastqc \
        --threads 4 \
        --outdir "${OUTPUT_DIR}" \
        "${fq}"

done

echo "FastQC analysis completed: $(date)"
