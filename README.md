# Family Trio Variant Analysis Pipeline
## MCDB 4520 Computational Genomics Group Project

### Project Overview
Flexible, automated pipeline for Oxford Nanopore long-read variant analysis of a family trio 
(HG002/son, HG003/father, HG004/mother). Supports analysis of any chromosome(s) and sample(s).

### System Configuration
- **CPU Cores**: 32
- **Memory**: 188 GB RAM
- **Workflow**: epi2me-labs/wf-human-variation (Nextflow)

### Pipeline Versions

**v2.0 (Flexible Pipeline)** - Recommended
- Run any combination of samples and chromosomes
- Parameterized via command-line flags
- Batch processing with `--all` flags

**v1.0 (Original)** - Chr1 Trio Analysis
- Hardcoded for chromosome 1, all three samples
- Simple execution: `./run_trio_analysis.sh`

---

## Quick Start

### Option 1: Flexible Pipeline (v2.0) - Recommended

```bash
# Single sample, single chromosome
./run_flexible_analysis.sh -s HG002 -c chr1 -o ./output

# All samples on one chromosome
./run_flexible_analysis.sh --all-samples -c chr1 -o ./output

# One sample on all available chromosomes
./run_flexible_analysis.sh -s HG002 --all-chromosomes -o ./output

# Complete analysis (all samples × all chromosomes)
./run_flexible_analysis.sh --all -o ./output

# View all options
./run_flexible_analysis.sh --help
```

### Option 2: Original Chr1 Trio Pipeline (v1.0)

```bash
# Runs all three samples on chromosome 1
./run_trio_analysis.sh
```

---

## Directory Structure

```
project/
├── nextflow.config                    # Nextflow configuration (max performance)
├── run_flexible_analysis.sh          # v2: Flexible pipeline (recommended)
├── run_trio_analysis.sh              # v1: Original chr1 trio pipeline
├── smoke_test.sh                      # Validation test suite (24 tests)
├── download_all_chromosomes.sh        # Bulk data download utility
├── summarize_performance.sh          # Performance statistics extractor
├── pipeline_master_TIMESTAMP.log     # Master execution log
│
├── HG002_chr1/                       # Son (male, child)
│   ├── output/                       # Analysis results (VCF, reports, etc.)
│   ├── work/                         # Temporary work directory (auto-cleaned)
│   └── logs/                         # Execution logs and time statistics
│       ├── time_stats_TIMESTAMP.txt
│       ├── nextflow_TIMESTAMP.log
│       ├── nextflow_report_TIMESTAMP.html
│       ├── nextflow_timeline_TIMESTAMP.html
│       ├── nextflow_trace_TIMESTAMP.txt
│       └── nextflow_dag_TIMESTAMP.html
│
├── HG003_chr1/                       # Father (male)
│   └── [same structure as HG002]
│
└── HG004_chr1/                       # Mother (female)
    └── [same structure as HG002]
```

---

## Data Files (Downloaded)

Located in `/mnt/data_1/CU_Boulder/MCDB-4520/data/human_trios/`:

```
human_trios/
├── HG002/
│   ├── HG002_chr1.bam         (13 GB)
│   └── HG002_chr1.bam.bai
├── HG003/
│   ├── HG003_chr1.bam         (10 GB)
│   └── HG003_chr1.bam.bai
├── HG004/
│   ├── HG004_chr1.bam         (10 GB)
│   └── HG004_chr1.bam.bai
└── reference/
    ├── hg38_chr1.fa           (242 MB)
    └── hg38_chr1.fa.fai
```

---

## Pipeline Execution

### Validation (Recommended First Step)

```bash
./smoke_test.sh
```

Runs 24 validation tests to ensure everything is set up correctly. All tests should pass before running analyses.

### Running Analyses

**Flexible Pipeline (v2.0):**
```bash
# Example: Analyze HG002 on chr1
./run_flexible_analysis.sh -s HG002 -c chr1 -o ./output

# Multiple samples and chromosomes
./run_flexible_analysis.sh -s HG002 -s HG003 -c chr1 -c chr17 -o ./output
```

**Original Pipeline (v1.0):**
```bash
# Runs all three samples on chromosome 1
./run_trio_analysis.sh
```

**Estimated Runtime**: 1-4 hours per sample per chromosome

---

## Pipeline Features

### Performance Optimization
- **Max CPU Usage**: All 32 cores utilized
- **Max Memory**: 180 GB allocated
- **Process-specific tuning**: 
  - Alignment: 32 CPUs, 64 GB RAM
  - SNP calling: 32 CPUs, 64 GB RAM
  - SV calling: 32 CPUs, 64 GB RAM
  - STR calling: 16 CPUs, 32 GB RAM

### Time Tracking
Each analysis generates comprehensive time statistics including:
- Wall clock time (elapsed)
- CPU time (user + system)
- CPU utilization percentage
- Peak memory usage
- Average memory usage
- File system I/O statistics

### Logging
- **Master log**: `pipeline_master_TIMESTAMP.log` - All pipeline events
- **Individual logs**: Per-sample logs in `SAMPLE_chr1/logs/`
- **Nextflow reports**: HTML visualizations of workflow execution
- **Time statistics**: Detailed resource usage metrics

---

## Analysis Outputs

Each sample generates the following outputs in `SAMPLE_chr1/output/`:

### Quality Control Reports
- `SAMPLE_chr1.wf-human-alignment-report.html` - Sequencing/mapping quality

### Variant Call Reports
- `SAMPLE_chr1.wf-human-snp-report.html` - SNP analysis
- `SAMPLE_chr1.wf-human-sv-report.html` - Structural variants
- `SAMPLE_chr1.wf-human-str-report.html` - Short tandem repeats

### Variant Call Files (VCF)
- `SAMPLE_chr1.wf_snp.vcf.gz` + `.tbi` - SNP variants
- `SAMPLE_chr1.wf_sv.vcf.gz` + `.tbi` - Structural variants
- `SAMPLE_chr1.wf_str.vcf.gz` + `.tbi` - STR variants

### Additional Files
- Annotated variants (if annotation enabled)
- BAM/CRAM alignments
- Summary statistics

---

## Viewing Performance Statistics

After pipeline completion:

```bash
./summarize_performance.sh
```

This generates a summary showing:
- Elapsed time for each sample
- CPU utilization
- Memory usage (peak and average)
- I/O statistics
- Output locations

---

## Downstream Analysis

### Identifying De Novo Mutations
Compare variants across trio members:
1. Load VCF files for HG002 (child), HG003 (father), HG004 (mother)
2. Identify variants in HG002 not present in either parent
3. Filter by quality metrics and coverage

### Inheritance Pattern Analysis
- Determine which variants are inherited from father vs mother
- Identify homozygous vs heterozygous variants
- Trace recombination events

### Clinically Relevant Genes on Chr1
According to project directive:
- **DPYD** - Drug metabolism
- **GBP1** - Immunity
- **MTHFR** - Metabolism/folate pathway

---

## Troubleshooting

### If Analysis Fails
1. Check logs in `SAMPLE_chr1/logs/nextflow_TIMESTAMP.log`
2. Work directory is preserved on failure for debugging
3. Review Nextflow trace file for process failures

### Resource Issues
- If memory errors occur, reduce allocation in `nextflow.config`
- Monitor system resources: `htop` or `top`

### Resuming Failed Runs
Nextflow supports resume capability:
```bash
nextflow run epi2me-labs/wf-human-variation -resume [other params]
```

---

## Key Parameters Used

- `--bam`: Input BAM file path
- `--ref`: Reference genome (hg38 chr1)
- `--override_basecaller_cfg`: ONT basecaller model
- `--sample_name`: Sample identifier
- `--snp`, `--sv`, `--str`: Enable variant calling modes
- `--sex`: XY (male) or XX (female)
- `--bam_min_coverage 0`: Include all coverage regions
- `--annotation true`: Annotate variants with gene/functional info

---

## Project Timeline

- **Data Download**: Completed
- **Pipeline Setup**: Completed
- **Analysis Execution**: Ready to run
- **Report Due**: 11/19/2025

---

## Notes

- Work directories are automatically cleaned after successful completion to save disk space (~30-50 GB per sample)
- Logs and outputs are preserved indefinitely
- All analyses use the same reference genome for consistency
- Pipeline is fully automated and requires no manual intervention

---

## Contact

For questions about this pipeline setup, refer to the project directive or course materials.
