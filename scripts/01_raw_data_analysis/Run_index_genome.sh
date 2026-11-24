#!/bin/bash
#SBATCH -p normal
#SBATCH -N 1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G
#SBATCH -J hisat2_index_mm39
#SBATCH -o hisat2_index_mm39_%j.log
#SBATCH -e hisat2_index_mm39_%j.err

module purge
module load HISAT2

GENOME_FA="/home/n-z/sijie3/genome_data/Mus_RGCm39/Mus_musculus.GRCm39.dna.primary_assembly.fa"

INDEX_DIR="/home/n-z/sijie3/genome_data/index/GRCm39_hisat2"
INDEX_PREFIX="${INDEX_DIR}/Mus_musculus.GRCm39"

mkdir -p "${INDEX_DIR}"

hisat2-build -p 8 "${GENOME_FA}" "${INDEX_PREFIX}"
