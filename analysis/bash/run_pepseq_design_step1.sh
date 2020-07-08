#!/usr/bin/bash

#SBATCH --time=96:00:00
#SBATCH --mem=100G
#SBATCH --partition=hmem
#SBATCH -c 2 
#SBATCH --mail-type=ALL 
#SBATCH--job-name=pepseq1
#SBATCH--mail-user=ekelley@tgen.org 
#SBATCH --nice=10

/labs/Immunology/ekelley/Library-Design/scripts/oligo_encoding/main \
	-r /scratch/ekelley/TM2_PepSeq_Library_Design/output_ratio \
	-s /scratch/ekelley/TM2_PepSeq_Library_Design/out_seqs \
	-n 300 \
        -c 2 \
	-p /labs/Immunology/ekelley/Library-Design/scripts/oligo_encoding/codon_weights.csv \
	-i /scratch/ekelley/TM2_PepSeq_Library_Design/named_peptides.csv \
        -t 10000 \
	-g 0.55 \
  
