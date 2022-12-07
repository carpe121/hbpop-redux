#!/bin/bash
#FILENAME: picardtools.sh

#' @where $p_bwa.sorted.bam is a bam file produced by BWA tools

module load bioinfo
module load picard-tools/2.9.0

date +"%d%B%Y%H:%M:%S"

p=$1

java -jar $CLASSPATH AddOrReplaceReadGroups INPUT=$p.bwa.sorted.bam   OUTPUT=$p.sorted.arrg.bam RGID=$p RGPL=illumina RGLB=$p RGPU=run RGSM=$p VALIDATION_STRINGENCY=LENIENT