# HBPOP2022
REWRITTEN code written for M. Carpenter's Master's thesis (May 2022)
(currently in prep for publication). Scripts written for processing many high-coverage poolseq honey bee (*Apis mellifera*) samples.

## pipe
`pipe` is a folder containing shell scripts for processing samples from raw fasta to vcf, bam, or other desired output. It is written for operation in a HPC Linux/Unix system operating on SLURM.

## amel.poolseq
`amel.poolseq` is a folder containing an R package (amel.poolseq) with functions used to generate figures and dataframes. `amel.poolseq` uses R command line (>= 4.1.0).

You must provide a csv, tsv, or txt file (`popnames`) with at least two columns. The first column must be the sample name. Additional columns can any other method of sample classification (e.g. population, management style). If you are using functions that work with a POPOOLATION2 output, you *must* order sample names in the same order they were added to the POPOOLATION2 mpileup file. Otherwise, they can be in any order. 

### Example `popnames` Dataframe
|Sample | Management | Population |
|------ | ---------- | ---------- |
|AHB_3829 | Feral | AHB|
|Scranton-LBG | Feral | PAFeral|
|P02 | Managed | PurdueMB|
