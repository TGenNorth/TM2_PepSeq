#!/bin/bash

#SBATCH --time=96:00:00
#SBATCH --mem=120G
#SBATCH -c 1 
#SBATCH --mail-type=ALL 
#SBATCH--job-name=IM0048bcl
#SBATCH--mail-user=ekelley@tgen.org 
#SBATCH --nice=50
# SBATCH --begin=now+17hours

#module load bcl2fastq2/2.20.0-GCC-8.3.0

bcl2fastq --runfolder-dir /illumina_run_folders/tgen/NextSeq/211008_NB502107_0277_AHN3YKAFX2/ \
         --output-dir /scratch/ekelley/IM0048/ \
        --create-fastq-for-index-reads \
        --no-lane-splitting \


