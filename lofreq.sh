#!/bin/bash
#FILENAME: lofreq.sh

#' @where $p_sort.bam.bam.sort.bam is the sorted bam file (depth corrected) put out by samtools
#' NOTE: the first file "sort.bam" is the output and the second file ".recal.bam" is the input

module load bioinfo
module load GATK
module load lofreq

date +"%d%B%Y%H:%M:%S"

p=$1

lofreq call --no-baq --min-bq 1 --min-alt-bq 1 --no-default-filter --verbose --sig 1 -f Amel_HAv3.1_genomic.fna -o $p.vcf $p.sort.bam.bam.sort.bam