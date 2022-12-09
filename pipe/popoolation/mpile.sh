#!/bin/bash
#FILENAME: mpile.sh

# $p.sort.bam.bam.sort.bam $p.sort.bam.bam.sort.bam [ETC] are the individual sample files put out by samtools in downsample.sh
## pay attention to order of files -> popoolation will output single file with 1, 2, 3, etc. based on input order instead of filenames
# make sure to allocate enough memory and time for mpileup to finish--suggested walltime and memory is maximum of what cluster allows

module load bioinfo
module load GATK

date +"%d%B%Y%H:%M:%S"

samtools mpileup --max-depth 30 -f Amel_HAv3.1_genomic.fna $p.sort.bam.bam.sort.bam $p.sort.bam.bam.sort.bam [ETC] > $p_merged.mpile