#!/bin/bash
#FILENAME: popool.sh

# where $p.mpile is a single mpileup file containing all SNPs output in mpile.sh
# make sure to allocate enough memory and time for sync to finish--suggested walltime and memory is maximum of what cluster allows

module load bioinfo
module load popoolation 
module load popoolation2 

date +"%d%B%Y%H:%M:%S"

java -ea -Xmx7g -jar $POPOOLATION2_DIR/mpileup2sync.jar --input $p.mpile --output $p.sync --fastq-type sanger --min-qual 25 --threads 12

perl $POPOOLATION2_DIR/fst-sliding.pl --input $p.sync --output $p.fst --window-size 1 --step-size 1 --pool-size 180 --suppress-noninformative --min-coverage 5 --max-coverage 30 --min-covered-fraction 0.1 --min-count 1