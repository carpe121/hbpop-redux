#!/bin/bash
#FILENAME: pilon.sh

# $p.sort.bam.bam.sort.bam is the individual downsampled file produced by samtools
# do NOT run individual files in a loop or the output will overwrite itself

module load bioinfo
module load pilon

date +"%d%B%Y%H:%M:%S"

java -Xmx16G -jar $PILON_JAR --genome Amel_HAv3.1_genomic.fna --targets NC_001566.1 --bam $p.sort.bam.bam.sort.bam --threads 10 --defaultqual 0 --nonpf --output $p_pilon --changes  --duplicates --mindepth 1