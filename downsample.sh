#!/bin/bash
#FILENAME: downsample.sh

module load bioinfo
module load samtools

#' @params $p.recal.bam = recalibrated bam file run though trimmomatic, BWA, and Picardtools
#' @params samtools view "-s" is the proportion of reads needed to save (i.e. everything below 25X coverage)
##' calculate average (output in text file as $p.sort.bam.dp) and divide that into 25
##' e.g. if the bam file has an average of 78X coverage, 25/78="-s"

p=$1

samtools sort -o $p.sort.bam $p.recal.bam
samtools index $p.sort.bam
$p.hb_dp="$samtools depth  $p.sort.bam  |  awk '{sum+=$3} END { print "Average = ",sum/NR}'"
samtools view -h -s $p.hb_dp -b $p.sort.bam > $p.sort.bam.bam 
samtools sort -o $p.sort.bam.bam.sort.bam $p.sort.bam.bam
samtools index $p.sort.bam.bam.sort.bam