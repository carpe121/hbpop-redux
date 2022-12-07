#!/bin/bash
#FILENAME: gatk.sh

#' @where $p_sorted.arrg.bam is the sorted and read group corrected output produced by Picardtools

module load bioinfo
module load GATK

date +"%d%B%Y%H:%M:%S"

p=$1

gatk MarkDuplicates\
  -I $p.sorted.arrg.bam \
  -O $p.sorted.dup.arrg.bam  \
  -M $p.marked.dup.metrics.txt \
	--REMOVE_SEQUENCING_DUPLICATES

echo "markdup"

gatk BaseRecalibrator \
	-I $p.sorted.dup.arrg.bam \
	-R Amel_HAv3.1_genomic.fna \
   --known-sites AMELknown_sites.vcf \
   -O $p.recal.data.table

echo "baserecal"

gatk ApplyBQSR \
	-I $p.sorted.dup.arrg.bam \
	-R Amel_HAv3.1_genomic.fna \
	--bqsr-recal-file $p.recal.data.table \
	-O $p.recal.bam

echo "bqsr"