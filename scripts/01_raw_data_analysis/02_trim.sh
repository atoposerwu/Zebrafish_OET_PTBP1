#!/bin/bash
#SBATCH -p normal
#SBATCH -n 10
#SBATCH --mem=50g
#SBATCH -N 1
#SBATCH --mail-user=sijie3@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J Run3_trimmomatic_macf1

module swap Java/1.8.0_201 Java/1.8.0_152
module load Trimmomatic/0.38-Java-1.8.0_152
module load parallel

INPUT_DIR=/home/n-z/sijie3/data/ZF_PTBP1/data_Nov2026/1_fastq_files
OUTPUT_DIR=/home/n-z/sijie3/data/ZF_PTBP1/data_Nov2026/3_trim

mkdir -p ${OUTPUT_DIR}

export OUTPUT_DIR
export INPUT_DIR


trim_func() {
    r1="$1"
    r2="${r1/_R1_001.fastq.gz/_R2_001.fastq.gz}"
    sample=$(basename "$r1" _R1_001.fastq.gz)

    echo "Processing ${sample} ..."

    trimmomatic PE -threads 2 -phred33 \
        "$r1" "$r2" \
        "${OUTPUT_DIR}/${sample}_R1_trimmed.fastq" "${OUTPUT_DIR}/${sample}_R1_unpaired.fastq" \
        "${OUTPUT_DIR}/${sample}_R2_trimmed.fastq" "${OUTPUT_DIR}/${sample}_R2_unpaired.fastq" \
        HEADCROP:19 CROP:139 MINLEN:30
}

export -f trim_func
export OUTPUT_DIR

parallel -j 5 trim_func ::: "${INPUT_DIR}"/*_R1_001.fastq.gz
