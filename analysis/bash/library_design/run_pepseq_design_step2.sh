#!/usr/bin/bash

#SBATCH --time=96:00:00
#SBATCH --mem=40G
#SBATCH -c 2 
#SBATCH --mail-type=ALL  
#SBATCH--job-name=neuralnet
#SBATCH--mail-user=ekelley@tgen.org 
          
#source activate pepseq_design 

/labs/Immunology/ekelley/Library-Design/scripts/oligo_encoding/encoding_with_nn.py \
        -m /labs/Immunology/ekelley/Library-Design/scripts/oligo_encoding/DeepLearning_model_R_1539970074840_1_20181019 \
        -r /scratch/ekelley/TM2_PepSeq_Library_Design/output_ratio \
        -s /scratch/ekelley/TM2_PepSeq_Library_Design/out_seqs \
        -o best_encodings \
	--subsample 300 \
	--read_per_loop 10 \
	-n 3 \
 
