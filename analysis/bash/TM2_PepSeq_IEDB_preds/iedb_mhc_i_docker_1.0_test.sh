#!/bin/bash

#SBATCH --partition=defq
#SBATCH --job-name=mhc_i_pred
#SBATCH -c 1 
#SBATCH --mem=10G
# SBATCH -o slurm-%j_%A.out-%N
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ekelley@tgen.org
#SBATCH --array=0-31
#SBATCH --nice=40

set -x

alleles=(
"HLA-A*01:01"
"HLA-B*08:01"
"HLA-C*03:04"
"HLA-B*07:02"
"HLA-C*07:01"
"HLA-A*02:01"
"HLA-B*40:01"
"HLA-C*16:01"
"HLA-C*05:01"
"HLA-A*24:02"
"HLA-B*18:01"
"HLA-C*04:01"
"HLA-A*03:01"
"HLA-C*03:03"
"HLA-B*44:03"
"HLA-B*57:01"
"HLA-C*06:02"
"HLA-C*12:02"
"HLA-A*31:01"
"HLA-A*02:05"
"HLA-C*07:02"
"HLA-B*45:01"
"HLA-A*68:01"
"HLA-B*44:02"
"HLA-B*35:02"
"HLA-C*12:03"
"HLA-A*01:107"
"HLA-B*55:01"
"HLA-A*29:02"
"HLA-C*16:58"
"HLA-B*50:01"
"HLA-C*06:116N"
"HLA-B*52:01" )


fastas=( *.fasta )
allele=${alleles[$SLURM_ARRAY_TASK_ID]}
module load singularity

for fasta in ${fastas[@]}; do
  singularity run \
    --bind $PWD:$PWD \
    --bind /scratch/ekelley/tempfiles:/tmp \
    /labs/Immunology/ekelley/pepseq_library_design_TIL/mhc_binding_predictions/mhc_i_binding_pred/iedbtools.simg \
    bash -c ". /conda/etc/profile.d/conda.sh; conda activate iedbtools_py27; /bin/iedb/mhc_i/src/predict_binding.py IEDB_recommended $allele 9 $fasta > ${fasta}_mhc_I_${allele}.txt"
done
