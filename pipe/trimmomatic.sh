#!/bin/bash
#FILENAME: trimmomatic.sh

module load bioinfo
module load trimmomatic

#' @where "$p_1.fastq.gz" is one end of an Illumina fastq file
#' @where "$p_2.fastq.gz" is the other end of an Illumina fastq file
#' expected output is two paired-end files ($p_1_TP and $p_2_TP) and two unpaired-end files ($p_1_TU and $p_2_TU)

date +"%d%B%Y%H:%M:%S"

pidlist_sampe=""
endfq="_1.fastq.gz"
endfq2="_2.fastq.gz"
endTP="_1_TP.fastq.gz"
endTP2="_2_TP.fastq.gz"
endTU="_1_TU.fastq.gz"
endTU2="_2_TU.fastq.gz"
fq1=$p$endfq
fq2=$p$endfq2
TP1=$p$endTP
TP2=$p$endTP2
TU1=$p$endTU
TU2=$p$endTU2
trimmomatic PE -threads 9 -phred33 $fq1 $fq2 $TP1 $TU1 $TP2 $TU2 \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:keepBothReads \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36