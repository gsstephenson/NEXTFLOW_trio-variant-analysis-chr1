#!/bin/bash
#############################################################################
# Download All Chromosome Data for Family Trio
# Downloads BAM files and reference genomes for all chromosomes (1-22, X, Y)
#############################################################################

set -e

# Directories
DATA_DIR="/mnt/data_1/CU_Boulder/MCDB-4520/data/human_trios"
REMOTE_USER="gest9386"
REMOTE_HOST="piel.int.colorado.edu"
REMOTE_BASE="/data/human_trios"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Create directories
mkdir -p "${DATA_DIR}"/{HG002,HG003,HG004,reference}

# Chromosomes to download (autosomes + sex chromosomes)
CHROMOSOMES=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" \
             "chr11" "chr12" "chr13" "chr14" "chr15" "chr16" "chr17" "chr18" "chr19" "chr20" \
             "chr21" "chr22" "chrX" "chrY")

# Samples
SAMPLES=("HG002" "HG003" "HG004")

log_info "=========================================="
log_info "Downloading All Chromosome Data"
log_info "=========================================="
log_info "This will download ~300-400 GB of data"
log_info "Estimated time: Several hours"
log_info ""

# Download BAM files for each sample and chromosome
for SAMPLE in "${SAMPLES[@]}"; do
    log_info "Downloading ${SAMPLE} data..."
    
    for CHR in "${CHROMOSOMES[@]}"; do
        log_info "  ${SAMPLE}_${CHR}.bam"
        scp "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/family1/${SAMPLE}/${SAMPLE}_${CHR}.bam" \
            "${DATA_DIR}/${SAMPLE}/" || log_info "  Skipped (may not exist)"
        
        log_info "  ${SAMPLE}_${CHR}.bam.bai"
        scp "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/family1/${SAMPLE}/${SAMPLE}_${CHR}.bam.bai" \
            "${DATA_DIR}/${SAMPLE}/" || log_info "  Skipped (may not exist)"
    done
    
    log_success "${SAMPLE} download complete"
done

# Download reference genomes for each chromosome
log_info "Downloading reference genomes..."
for CHR in "${CHROMOSOMES[@]}"; do
    log_info "  hg38_${CHR}.fa"
    scp "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/reference/hg38_${CHR}.fa" \
        "${DATA_DIR}/reference/" || log_info "  Skipped (may not exist)"
    
    log_info "  hg38_${CHR}.fa.fai"
    scp "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/reference/hg38_${CHR}.fa.fai" \
        "${DATA_DIR}/reference/" || log_info "  Skipped (may not exist)"
done

log_success "All downloads complete!"
log_info "Data saved to: ${DATA_DIR}"

# Show disk usage
log_info ""
log_info "Disk usage:"
du -sh "${DATA_DIR}"/*
