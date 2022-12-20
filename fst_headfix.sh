#!/bin/bash
#Name: fst_headfix

#The bash command to run this file is:
## $./fst_headfix < all.fst > all_headfix.fst
#where "all.fst" is a tsv with all samples by population, with FST calculated by POPOOLATION2 (see popool.sh); population comparisons listed as 1:2, 1:3, 1:4, etc. (total of 9)

##== PLEASE READ ==##
# POPOOLATION2 output is not an innately intuitive sample list
# You can change the numbers to population names using "file_header.tsv"
# "file_header.tsv" is a tsv file where the header numbers have been manually replaced with file names

module load bioinfo
module load R

cleanup () {
	rm -rf "$scratch"
}

scratch=$(mktemp -d -t)
cd "$scratch"

sed -i "1 s/.*/$(< file_header.tsv)/" all.fst 
sed 's/=/_/g' all.fst

$Rscript header_fix2 all_headfix.fst

set -- "${1:-/dev/stdin}"

trap cleanup EXIT