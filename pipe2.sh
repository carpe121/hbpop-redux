module load bioinfo
module load bwa/0.7.5a
module load samtools
module load trimmomatic
module load picard-tools/2.9.0
module load GATK
module load lofreq
module load muscle
module load pilon
module load vcftools
module load plink
module load admixture
module load popoolation 
module load popoolation2 

##=== SUBMISSION SCRIPT ===##
#used for all scripts unless otherwise specified
filename='NAME.txt'
exec 4<$filename
while read -u4 p ;
do
	sbatch SCRIPT.sh "$p"
done

##=== TRIMMOMATIC ===##
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

##=== BWA ===##
#only run index once for multiple samples
#if you get empty file errors in parallel, run files one at a time
bwa index Amel_HAv3.1_genomic.fna
bwa mem -t 10 Amel_HAv3.1_genomic.fna $p_1.fastq.gz $p_2.fastq.gz | samtools view -Shu - | samtools sort - | samtools rmdup -s - - | tee $p.bwa.sorted.bam

##=== PICARD ===##
java -jar $CLASSPATH AddOrReplaceReadGroups INPUT=$p.bwa.sorted.bam   OUTPUT=$p.sorted.arrg.bam RGID=$p RGPL=illumina RGLB=$p RGPU=run RGSM=$p VALIDATION_STRINGENCY=LENIENT

##==== GATK ===##
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

##==== DOWNSAMPLING ====##
samtools sort -o $p.sort.bam $p.recal.bam
samtools index $p.sort.bam
samtools depth  $p.sort.bam  |  awk '{sum+=$3} END { print "Average = ",sum/NR}' > $p.sort.bam.dp

#where s is the number of reads you want to save (e.g. the ones below 25X coverage)
#get average and divide that into 25x, e.g. 25/78.5490 = FRACTION YOU WANT TO KEEP; this is what you put after -s in the next step

samtools view -h -s [KEPT FRACTION] -b $p.sort.bam > $p.sort.bam.bam 
samtools sort -o $p.sort.bam.bam.sort.bam $p.sort.bam.bam
samtools index $p.sort.bam.bam.sort.bam

##==== LOFREQ ====##
#for sort, the first file "sort.bam" is the output and the second file ".recal.bam" is the input
lofreq call --no-baq --min-bq 1 --min-alt-bq 1 --no-default-filter --verbose --sig 1 -f Amel_HAv3.1_genomic.fna -o $p.vcf $p.sort.bam.bam.sort.bam

##==== MT DNA ====##
#pilon is more sensitive to SNPs and runs quickly enough to be used for mtDNA
#do not run in a loop or it'll keep overwriting itself
java -Xmx16G -jar $PILON_JAR --genome Amel_HAv3.1_genomic.fna --targets NC_001566.1 --bam $p.sort.bam.bam.sort.bam --threads 10 --defaultqual 0 --nonpf --output $p_pilon --changes  --duplicates --mindepth 1

##=== ADMIXTURE ===##
#vcf='INPUT'
vcftools --gzvcf $p_GGVCF.g.vcf.gz --plink --remove-indels --thin 1000
plink --file out --make-bed --maf 0.05 --noweb

for K in 1 2 3 4 5 ; do admixture --cv=20 --supervised plink.bed $K -j19 | tee log${K}.out; done
grep -h CV log*.out


##=== FST ==##
samtools mpileup --max-depth 30 -f Amel_HAv3.1_genomic.fna $p.sort.bam.bam.sort.bam $p.sort.bam.bam.sort.bam [ETC] > $p_merged.mpile

java -ea -Xmx7g -jar $POPOOLATION2_DIR/mpileup2sync.jar --input $p.mpile --output $p.sync --fastq-type sanger --min-qual 25 --threads 12

perl $POPOOLATION2_DIR/fst-sliding.pl --input $p.sync --output $p.fst --window-size 1 --step-size 1 --pool-size 180 --suppress-noninformative --min-coverage 5 --max-coverage 30 --min-covered-fraction 0.1 --min-count 1