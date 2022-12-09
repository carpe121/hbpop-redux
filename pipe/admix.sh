#!/bin/bash
#FILENAME: admix.sh

# $p_GGVCF.g.vcf.gz is the single file containing all samples put out by GATK in gatk.sh

module load bioinfo
module load vcftools
module load plink
module load admixture

date +"%d%B%Y%H:%M:%S"

vcftools --gzvcf $p_GGVCF.g.vcf.gz --plink --remove-indels --thin 1000
plink --file out --make-bed --maf 0.05 --noweb

for K in 1 2 3 4 5 ; do admixture --cv=20 --supervised plink.bed $K -j19 | tee log${K}.out; done
grep -h CV log*.out