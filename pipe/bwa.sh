#!/bin/bash
#FILENAME: bwa.sh

#' @where $p_1_TP.fastq.gz is one end of a paired Illumina strand produced by Trimmomatic
#' @where $p_2_TP.fastq.gz is the other end of a paired Illumina strand produced by Trimmomatic
#' NOTE: may not work in parallel with submission script. If BWA outputs empty files, run files one at a time.
#' NOTE: only run "bwa index" command once for multiple samples

module load bioinfo
module load bwa/0.7.5a

date +"%d%B%Y%H:%M:%S"

bwa index Amel_HAv3.1_genomic.fna
bwa mem -t 10 Amel_HAv3.1_genomic.fna $p_1_TP.fastq.gz $p_2_TP.fastq.gz | samtools view -Shu - | samtools sort - | samtools rmdup -s - - | tee $p.bwa.sorted.bam
