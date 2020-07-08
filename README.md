TM2 PepSeq Library Design
================
E. Kelley
08 July, 2020

## Analysis Goal:

Design a TM2 PepSeq library for our second cohort of patients for the
Tumor Infiltrating Lymphocytes (TIL) Project. Exome sequencing and
initial sequence analysis was performed at TGen HQ. A collection of
files has been provided by Kevin Drenner in the Sharma lab. Each file
corresponds to a unique patient, prefaced by ‘C038,’ or a unique mouse,
‘mm10.’ This analysis will gather the data set and perform some
pre-processing steps prior to using an external `oligo_encoding` tool
written by Zane Fink in the [Ladner lab at
NAU](https://github.com/LadnerLab/Library-Design) to select the best
peptides for the final PepSeq library.

-----

## R analysis to pre-process peptides

Start with importing the necessary libraries.

``` r
library(tidyverse)
library(MHCbindR)
library(DT)
```

``` r
create_dt <- function(x) {
  DT::datatable(x,
    extensions = "Buttons",
    options = list(
      dom = "Blfrtip",
      buttons = c("copy", "csv", "excel", "pdf", "print"),
      lengthMenu = list(
        c(10, 25, 50, -1),
        c(10, 25, 50, "All")
      )
    )
  )
}
```

Import tumor mutations data generated by Kevin Drenner at TGen HQ.  
Create a single data frame of all mutations, `data`. Count the number of
rows in each file; this is a rough indicator of the number of variants
in a file. Plot number of rows per file.

``` r
files <- dir("data_from_kevin/TILPepseq2_Updated/TILPepseq2_mutations/", pattern = "*.csv")
data <- files %>%
  map_dfr(function(x) {
    read_csv(file.path("data_from_kevin/TILPepseq2_Updated/TILPepseq2_mutations/", x)) %>% mutate(file = x)
  })
glimpse(data)
```

    ## Rows: 5,211
    ## Columns: 36
    ## $ variantId  [3m[38;5;246m<chr>[39m[23m "chr1 g.109492471A>T", "chr1 g.110022034G>A", "chr1 g.110022034G>A", "chr1 g.110998923C>T", "chr1 g…
    ## $ mutPept1   [3m[38;5;246m<chr>[39m[23m "NHKLDSLTYKIDECE", "ENCWFVFKETPWHGQ", "ENCWFVFKETPWHGQ", "SDGRYRCSMDLKNIN", "IKFGSPDWAQVPCLQ", "HFS…
    ## $ mutPept2   [3m[38;5;246m<chr>[39m[23m "CNHKLDSLTYKIDEC", "AENCWFVFKETPWHG", "AENCWFVFKETPWHG", "FSDGRYRCSMDLKNI", "PIKFGSPDWAQVPCL", "GHF…
    ## $ mutPept3   [3m[38;5;246m<chr>[39m[23m "ECNHKLDSLTYKIDE", "WAENCWFVFKETPWH", "WAENCWFVFKETPWH", "RFSDGRYRCSMDLKN", "WPIKFGSPDWAQVPC", "FGH…
    ## $ mutPept4   [3m[38;5;246m<chr>[39m[23m "SECNHKLDSLTYKID", "LWAENCWFVFKETPW", "LWAENCWFVFKETPW", "SRFSDGRYRCSMDLK", "AWPIKFGSPDWAQVP", "EFG…
    ## $ mutPept5   [3m[38;5;246m<chr>[39m[23m "ISECNHKLDSLTYKI", "FLWAENCWFVFKETP", "FLWAENCWFVFKETP", "CSRFSDGRYRCSMDL", "IAWPIKFGSPDWAQV", "LEF…
    ## $ mutPept6   [3m[38;5;246m<chr>[39m[23m "EISECNHKLDSLTYK", "FFLWAENCWFVFKET", "FFLWAENCWFVFKET", "LCSRFSDGRYRCSMD", "KIAWPIKFGSPDWAQ", "QLE…
    ## $ mutPept7   [3m[38;5;246m<chr>[39m[23m "DEISECNHKLDSLTY", "NFFLWAENCWFVFKE", "NFFLWAENCWFVFKE", "LLCSRFSDGRYRCSM", "PKIAWPIKFGSPDWA", "MQL…
    ## $ mutPept8   [3m[38;5;246m<chr>[39m[23m "ADEISECNHKLDSLT", "INFFLWAENCWFVFK", "INFFLWAENCWFVFK", "NLLCSRFSDGRYRCS", "PPKIAWPIKFGSPDW", "EMQ…
    ## $ mutPept9   [3m[38;5;246m<chr>[39m[23m "CADEISECNHKLDSL", "FINFFLWAENCWFVF", "FINFFLWAENCWFVF", "PNLLCSRFSDGRYRC", "PPPKIAWPIKFGSPD", "GEM…
    ## $ mutPept10  [3m[38;5;246m<chr>[39m[23m "SCADEISECNHKLDS", "GFINFFLWAENCWFV", "GFINFFLWAENCWFV", "LPNLLCSRFSDGRYR", "KPPPKIAWPIKFGSP", "PGE…
    ## $ mutPept11  [3m[38;5;246m<chr>[39m[23m "LSCADEISECNHKLD", "FGFINFFLWAENCWF", "FGFINFFLWAENCWF", "CLPNLLCSRFSDGRY", "KKPPPKIAWPIKFGS", "EPG…
    ## $ mutPept12  [3m[38;5;246m<chr>[39m[23m "DLSCADEISECNHKL", "LFGFINFFLWAENCW", "LFGFINFFLWAENCW", "PCLPNLLCSRFSDGR", "EKKPPPKIAWPIKFG", "AEP…
    ## $ mutPept13  [3m[38;5;246m<chr>[39m[23m "PDLSCADEISECNHK", "VLFGFINFFLWAENC", "VLFGFINFFLWAENC", "CPCLPNLLCSRFSDG", "PEKKPPPKIAWPIKF", "WAE…
    ## $ mutPept14  [3m[38;5;246m<chr>[39m[23m "SPDLSCADEISECNH", "LVLFGFINFFLWAEN", "SVLFGFINFFLWAEN", "TCPCLPNLLCSRFSD", "NPEKKPPPKIAWPIK", "YWA…
    ## $ mutPept15  [3m[38;5;246m<chr>[39m[23m "VSPDLSCADEISECN", "PLVLFGFINFFLWAE", "ISVLFGFINFFLWAE", "HTCPCLPNLLCSRFS", "YNPEKKPPPKIAWPI", "RYW…
    ## $ effectId   [3m[38;5;246m<chr>[39m[23m "ENST00000302500_p.Y68N|ENST00000348264_p.Y68N|ENST00000356970_p.Y68N|ENST00000369968_p.Y68N|ENST00…
    ## $ gene_name  [3m[38;5;246m<chr>[39m[23m "CLCC1", "SYPL2", "SYPL2", "PROK1", "PIFO", "PTPN22", "NRAS", "PTCHD2", "GDAP2", "SPAG17", "UBE2J2"…
    ## $ topEffect  [3m[38;5;246m<lgl>[39m[23m TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TR…
    ## $ wtPept1    [3m[38;5;246m<chr>[39m[23m "YHKLDSLTYKIDECE", "GNCWFVFKETPWHGQ", "GNCWFVFKETPWHGQ", "PDGRYRCSMDLKNIN", "MKFGSPDWAQVPCLQ", "PFS…
    ## $ wtPept2    [3m[38;5;246m<chr>[39m[23m "CYHKLDSLTYKIDEC", "AGNCWFVFKETPWHG", "AGNCWFVFKETPWHG", "FPDGRYRCSMDLKNI", "PMKFGSPDWAQVPCL", "GPF…
    ## $ wtPept3    [3m[38;5;246m<chr>[39m[23m "ECYHKLDSLTYKIDE", "WAGNCWFVFKETPWH", "WAGNCWFVFKETPWH", "RFPDGRYRCSMDLKN", "WPMKFGSPDWAQVPC", "FGP…
    ## $ wtPept4    [3m[38;5;246m<chr>[39m[23m "SECYHKLDSLTYKID", "LWAGNCWFVFKETPW", "LWAGNCWFVFKETPW", "SRFPDGRYRCSMDLK", "AWPMKFGSPDWAQVP", "EFG…
    ## $ wtPept5    [3m[38;5;246m<chr>[39m[23m "ISECYHKLDSLTYKI", "FLWAGNCWFVFKETP", "FLWAGNCWFVFKETP", "CSRFPDGRYRCSMDL", "IAWPMKFGSPDWAQV", "LEF…
    ## $ wtPept6    [3m[38;5;246m<chr>[39m[23m "EISECYHKLDSLTYK", "FFLWAGNCWFVFKET", "FFLWAGNCWFVFKET", "LCSRFPDGRYRCSMD", "KIAWPMKFGSPDWAQ", "QLE…
    ## $ wtPept7    [3m[38;5;246m<chr>[39m[23m "DEISECYHKLDSLTY", "NFFLWAGNCWFVFKE", "NFFLWAGNCWFVFKE", "LLCSRFPDGRYRCSM", "PKIAWPMKFGSPDWA", "MQL…
    ## $ wtPept8    [3m[38;5;246m<chr>[39m[23m "ADEISECYHKLDSLT", "INFFLWAGNCWFVFK", "INFFLWAGNCWFVFK", "NLLCSRFPDGRYRCS", "PPKIAWPMKFGSPDW", "EMQ…
    ## $ wtPept9    [3m[38;5;246m<chr>[39m[23m "CADEISECYHKLDSL", "FINFFLWAGNCWFVF", "FINFFLWAGNCWFVF", "PNLLCSRFPDGRYRC", "PPPKIAWPMKFGSPD", "GEM…
    ## $ wtPept10   [3m[38;5;246m<chr>[39m[23m "SCADEISECYHKLDS", "GFINFFLWAGNCWFV", "GFINFFLWAGNCWFV", "LPNLLCSRFPDGRYR", "KPPPKIAWPMKFGSP", "PGE…
    ## $ wtPept11   [3m[38;5;246m<chr>[39m[23m "LSCADEISECYHKLD", "FGFINFFLWAGNCWF", "FGFINFFLWAGNCWF", "CLPNLLCSRFPDGRY", "KKPPPKIAWPMKFGS", "EPG…
    ## $ wtPept12   [3m[38;5;246m<chr>[39m[23m "DLSCADEISECYHKL", "LFGFINFFLWAGNCW", "LFGFINFFLWAGNCW", "PCLPNLLCSRFPDGR", "EKKPPPKIAWPMKFG", "AEP…
    ## $ wtPept13   [3m[38;5;246m<chr>[39m[23m "PDLSCADEISECYHK", "VLFGFINFFLWAGNC", "VLFGFINFFLWAGNC", "CPCLPNLLCSRFPDG", "PEKKPPPKIAWPMKF", "WAE…
    ## $ wtPept14   [3m[38;5;246m<chr>[39m[23m "SPDLSCADEISECYH", "LVLFGFINFFLWAGN", "SVLFGFINFFLWAGN", "TCPCLPNLLCSRFPD", "NPEKKPPPKIAWPMK", "YWA…
    ## $ wtPept15   [3m[38;5;246m<chr>[39m[23m "VSPDLSCADEISECY", "PLVLFGFINFFLWAG", "ISVLFGFINFFLWAG", "HTCPCLPNLLCSRFP", "YNPEKKPPPKIAWPM", "RYW…
    ## $ sourceName [3m[38;5;246m<chr>[39m[23m "C038_0022_009388_PB_Whole_C1_K1ID2_A50599-C038_0022_009388_XX_Whole_T2_K1ID2_A50598", "C038_0022_0…
    ## $ file       [3m[38;5;246m<chr>[39m[23m "C038_0022_merged_Ashion_Research_Peptide_100PercentIdentityRemoved.varCode.csv", "C038_0022_merged…

``` r
table(data$file)
```

    ## 
    ## C038_0022_merged_Ashion_Research_Peptide_100PercentIdentityRemoved.varCode.csv 
    ##                                                                            915 
    ##                           C038_0031_merged_Ashion_Research_Peptide.varCode.csv 
    ##                                                                             97 
    ## C038_0034_merged_Ashion_Research_Peptide_100PercentIdentityRemoved.varCode.csv 
    ##                                                                            120 
    ## C038_0036_merged_Ashion_Research_Peptide_100PercentIdentityRemoved.varCode.csv 
    ##                                                                            105 
    ##                           C038_0038_merged_Ashion_Research_Peptide.varCode.csv 
    ##                                                                             68 
    ## C038_0039_merged_Ashion_Research_Peptide_100PercentIdentityRemoved.varCode.csv 
    ##                                                                             49 
    ##                           C038_0044_merged_Ashion_Research_Peptide.varCode.csv 
    ##                                                                             87 
    ## C038_0045_merged_Ashion_Research_Peptide_100PercentIdentityRemoved.varCode.csv 
    ##                                                                            280 
    ## C038_0046_merged_Ashion_Research_Peptide_100PercentIdentityRemoved.varCode.csv 
    ##                                                                            219 
    ##                                           Phiser_mm10_B16F10_Final.varCode.csv 
    ##                                                                           1042 
    ##                                      Phiser_mm10_MC38_Phiser_Final.varCode.csv 
    ##                                                                           2229

``` r
p1 <- data %>%
  mutate(file = str_replace(file, ".varCode.csv", replacement = "")) %>%
  ggplot(aes(file)) +
  geom_histogram(stat = "count") +
  coord_flip() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  theme_bw()
```

    ## Warning: Ignoring unknown parameters: binwidth, bins, pad

``` r
p1
```

![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

Select mutations 7, 8, 9 for wildtype and mutant sequences. Gather into
a long data frame. Drop any rows with `NA` for `sequence`. Filter for
peptides with `topEffect == TRUE` and 15mers.

``` r
peptides_long <- data %>%
  gather(
    key = "peptide", value = "sequence", mutPept7,
    mutPept8, mutPept9, wtPept7, wtPept8, wtPept9
  ) %>%
  select(variantId, effectId, gene_name, topEffect, sourceName, file, peptide, sequence) %>%
  filter(!is.na(sequence)) %>%
  relocate(effectId, .after = sequence)
#create_dt(peptides_long)
```

We only want to include variants with `topEffect` and length=15.
Summarizing the non-topEffect and non-15mers here to show what has been
excluded from the library design.

``` r
not_topEffect <- peptides_long %>%
  filter(topEffect == FALSE)
#create_dt(not_topEffect)

not_15mers <- peptides_long %>%
  filter(!(str_length(sequence) == 15))
#create_dt(not_15mers)
```

After filtering for `topEffect == TRUE`, there are some duplicated
sequences remaining. Some duplicates are across multiple patients,
whereas others are across the same patient, just from another
sample/sequence library.

``` r
pep_dups <- peptides_long %>%
  filter(topEffect == TRUE) %>%
  ungroup() %>%
  group_by(sequence) %>%
  mutate(dup = n() > 1) %>%
  filter(dup == TRUE)
#create_dt(pep_dups)
```

Need to just include a single peptide sequence for the duplicates in our
peptide pool for library design. `annotated_peptides` won’t include
information from duplicated sequences, so if we need the metadata for
duplicates, will have to pull from the `pep_dups` data frame.

``` r
annotated_peptides <- peptides_long %>%
  filter(topEffect == TRUE) %>%
  filter(str_length(sequence) == 15)
```

Keep only rows with distinct peptide sequences. `distinct` keeps only
the first row if there are replicated sequences. `.keep all` retains the
other columns.

``` r
unique_peptides <- peptides_long %>%
  filter(topEffect == TRUE) %>%
  filter(str_length(sequence) == 15) %>%
  distinct(sequence, .keep_all = TRUE)
```

Create a data frame with named unique peptides to serve as input for the
PepSeq Library Design tool; this data frame is called `named_peptides`.
Export `named_peptides.csv` to use as the import for the
`oligo_encoding` tool.

``` r
for_library_design <- unique_peptides %>% select(sequence)
for_library_design <- tibble(for_library_design)
for_library_design$id <- str_c(rep("TM2_", length(for_library_design$sequence)), sprintf("%05d", seq_along(for_library_design$sequence)))

# This file contains 2 columns – the first with one entry for each unique peptide; the second with the peptide identifier (eg "TM1_00001")
named_peptides <- for_library_design %>% select(id, sequence)
#create_dt(named_peptides)
# write_csv(named_peptides, path = "design_outs/named_peptides.csv", col_names = FALSE,  quote = FALSE)
# write_csv(annotated_peptides, path = "design_outs/annotated_peptides.csv")
```

-----

## Run `oligo_encoding` script to choose the best peptides for the PepSeq library.

#### This analysis was performed on our HPC cluster using Conda for package management. Conda yaml file is provided here to allow for reproducibility of the environment. The `oligo_encoding` tool requires a specific version of h2O, along with some other dependencies (details on Ladner lab github). I am using the `oligo_encoding` script from the `Library-Design` tool (pulled from git sha: 416bee3458855e76dc73d10a87515144abbee799).

``` bash
cat analysis/bash/conda_pepseq_design.yml
```

    ## name: pepseq_design
    ## channels:
    ##   - defaults
    ##   - conda-forge
    ##   - bioconda
    ##   - r
    ## dependencies:
    ##   - ca-certificates=2019.1.23=0
    ##   - certifi=2019.3.9=py37_0
    ##   - libedit=3.1.20181209=hc058e9b_0
    ##   - libffi=3.2.1=hd88cf55_4
    ##   - libgcc-ng=8.2.0=hdf63c60_1
    ##   - libstdcxx-ng=8.2.0=hdf63c60_1
    ##   - llvm-openmp=8.0.0=hc9558a2_0
    ##   - ncurses=6.1=he6710b0_1
    ##   - openmp=8.0.0=0
    ##   - openssl=1.1.1b=h7b6447c_1
    ##   - pip=19.0.3=py37_0
    ##   - python=3.7.3=h0371630_0
    ##   - readline=7.0=h7b6447c_5
    ##   - setuptools=41.0.0=py37_0
    ##   - sqlite=3.28.0=h7b6447c_0
    ##   - tk=8.6.8=hbc83047_0
    ##   - wheel=0.33.1=py37_0
    ##   - xz=5.2.4=h14c3975_4
    ##   - zlib=1.2.11=h7b6447c_3
    ##   - pip:
    ##     - chardet==3.0.4
    ##     - colorama==0.4.1
    ##     - future==0.17.1
    ##     - h2o==3.20.0.8
    ##     - idna==2.8
    ##     - numpy==1.16.3
    ##     - pandas==0.24.2
    ##     - python-dateutil==2.8.0
    ##     - pytz==2019.1
    ##     - requests==2.21.0
    ##     - six==1.12.0
    ##     - tabulate==0.8.3
    ##     - urllib3==1.24.2
    ## prefix: /home/ekelley/bin/anaconda3/envs/pepseq_design

### Step 1 in the `oligo_encoding` analysis.

#### Generate 10,000 random encodings and select 300 encodings with the lowest deviation from of GC ratio from 0.55 for downstream predictions. This was performed on our HPC cluster using the following \#\#\# slurm script; note that you must activate the conda environment prior to running the slurm script.

``` bash
cat analysis/bash/run_pepseq_design_step1.sh
```

    ## #!/usr/bin/bash
    ## 
    ## #SBATCH --time=96:00:00
    ## #SBATCH --mem=100G
    ## #SBATCH --partition=hmem
    ## #SBATCH -c 2 
    ## #SBATCH --mail-type=ALL 
    ## #SBATCH--job-name=pepseq1
    ## #SBATCH--mail-user=ekelley@tgen.org 
    ## #SBATCH --nice=10
    ## 
    ## /labs/Immunology/ekelley/Library-Design/scripts/oligo_encoding/main \
    ##  -r /scratch/ekelley/TM2_PepSeq_Library_Design/output_ratio \
    ##  -s /scratch/ekelley/TM2_PepSeq_Library_Design/out_seqs \
    ##  -n 300 \
    ##         -c 2 \
    ##  -p /labs/Immunology/ekelley/Library-Design/scripts/oligo_encoding/codon_weights.csv \
    ##  -i /scratch/ekelley/TM2_PepSeq_Library_Design/named_peptides.csv \
    ##         -t 10000 \
    ##  -g 0.55 \
    ## 

### Step 2 in the `oligo_encoding` analysis.

#### Select the best oligo encodings using the neural network; `-n 3` will give the three best encodings per peptide. This was performed on our HPC cluster using the following slurm script; note that you must activate the conda environment prior to running the slurm script. This analysis took slightly more than an hour using 2 cores with 40G memory.

``` bash
cat analysis/bash/run_pepseq_design_step2.sh
```

    ## #!/usr/bin/bash
    ## 
    ## #SBATCH --time=96:00:00
    ## #SBATCH --mem=40G
    ## #SBATCH -c 2 
    ## #SBATCH --mail-type=ALL  
    ## #SBATCH--job-name=neuralnet
    ## #SBATCH--mail-user=ekelley@tgen.org 
    ##           
    ## #source activate pepseq_design 
    ## 
    ## /labs/Immunology/ekelley/Library-Design/scripts/oligo_encoding/encoding_with_nn.py \
    ##         -m /labs/Immunology/ekelley/Library-Design/scripts/oligo_encoding/DeepLearning_model_R_1539970074840_1_20181019 \
    ##         -r /scratch/ekelley/TM2_PepSeq_Library_Design/output_ratio \
    ##         -s /scratch/ekelley/TM2_PepSeq_Library_Design/out_seqs \
    ##         -o best_encodings \
    ##  --subsample 300 \
    ##  --read_per_loop 10 \
    ##  -n 3 \
    ## 

#### The final `best_encodings` output from `oligo_encoding`:

``` r
best_encodings <- read_csv("analysis/bash/best_encodings")
#create_dt(best_encodings)
```
