#!/bin/sh

#SBATCH --time=96:00:00
#SBATCH --mem=20G
#SBATCH -c 4 
#SBATCH --partition=defq
#SBATCH --mail-type=ALL 
#SBATCH--job-name=PepSIRF_demux
#SBATCH--mail-user=ekelley@tgen.org 
#SBATCH --nice=10

module load gcc

pepsirf_1.4.0_linux demux --input_r1 /TGenNextGen/Immunology/IM0048/Undetermined_S0_R1_001.fastq.gz \
        --input_r2 /TGenNextGen/Immunology/IM0048/Undetermined_S0_R1_001.fastq.gz \
        --index /home/ekelley/bin/pepseq_refs/BSC_FR_barcodes.fa \
        -a IM0048_TM3_raw_2mm_i1mm.tsv \
        --samplelist ZZ_sample_list_TM3.txt \
        --library /home/ekelley/bin/pepseq_refs/TM3_coded.fna \
        --read_per_loop 800000 \
        --num_threads 4 \
        --seq 43,45,2 \
        --index1 12,12,1 \
        --index2 141,8,1 \
	-d diagnostics.out
