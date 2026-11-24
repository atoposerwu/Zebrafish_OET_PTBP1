#!/bin/bash
#-----------SLURM Parameters--------
#SBATCH -p normal
#SBATCH -n 8
#SBATCH --mem=40g
#SBATCH -N 1
#SBATCH --mail-user=sijie3@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH -J Kallisto_Index
#SBATCH -o Kallisto_Index_%j.out
#SBATCH -e Kallisto_Index_%j.err

# ----------------Load Modules--------------------
module load kallisto

# ----------------Set Directories-----------------
REF_DIR="/home/n-z/sijie3/genome_data/ZF_Tu_2017"
INDEX_DIR="/home/n-z/sijie3/genome_data/index/GRCz11_cDNA_kallisto_2026_index"

TRANSCRIPTOME="${REF_DIR}/Danio_rerio.GRCz11.cdna.all.withSpikein.fa"
INDEX="${INDEX_DIR}/Danio_rerio.GRCz11.cdna.all.withSpikein.kallisto.idx"

mkdir -p "${INDEX_DIR}"

# ----------------Build Index---------------------
echo "Kallisto version:"
kallisto version

echo "Starting index building: $(date)"

kallisto index \
    -i "${INDEX}" \
    -t 8 \
    "${TRANSCRIPTOME}"

# ----------------Check Results-------------------
if [ $? -eq 0 ]; then
    echo "Index building completed successfully: $(date)"
    ls -lh "${INDEX}"
else
    echo "ERROR: Kallisto index building failed."
    exit 1
fi
