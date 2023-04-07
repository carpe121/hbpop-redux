#HBPOP2022 FST figures.....now with genes
#' generate figures associated with FST on gene level of US honey bee populations
#' @param fst_df created by fst_remake.R 
#' @returns data.table
#' @importFrom reshape2 melt
#' @examples set later 
#' @export




#!/usr/bin/env

#' script that converts to fst output into something that can be run through bedtools
#' WIP: need to find a way to exchange between UNIX and R commands OR streamline it in one system


#Sort FST by Comparison Class-------
df4$Comb <- paste(df4$RefContig, df4$WindowPos)
df5 <- melt(df4, id.vars="Comb", measure.vars=c("NAMES OF ALL COMPARISON COLUMNS"))
df5$Chrom <- gsub(' .*','',df5$Comb)
df5$WindowPos <- gsub('.* ','',df5$Comb)
df5$Comb <- NULL
colnames(df5) <- c("Comparison", "FST", "Chrom", "WindowPos")
fstsort <- read.table("fstsort.txt", header=T) #table mapping each comparison to their class, e.g. Feral/Feral, etc.
df6 <- merge(df5, fstsort, by="Comparison") #assigns comparison to sample

#Write BED file output------
fm_fst <- df6[which(df6$Type=='Feral/Managed'),] #for example; just change type to Feral/Managed or Managed/Managed
fm_fst <- fm_fst %>% arrange(desc(FST)) #arrange in descending order; not required
n <- 10 #n = top percentage of FST you want
top10 <- fm_fst[fm_fst$FST > quantile(fm_fst$FST,prob=1-n/100),] #outputs top percentages, in this case top 10%
top10$Comb <- paste(top10$Chrom, top10$WindowPos) #gotta combine chrom and window pos to get unique SNPs
    x <- as.data.frame(unique(top5$Comb)) #gives you number of unique SNPs
bed <- top10[,c("Chrom", "WindowPos")]
bed$chromEnd <- bed$WindowPos #bed requires start and end; window=1 BP on POPOOL; might require making a second file and just adding 1
colnames(bed) <- c("chrom", "chromStart", "chromEnd") #bed file required column names
write.table(bed, "top10_fm.bed", sep="\t", col.names=T, row.names=F) #writes out the bed file


##=== BEDTOOLS: SWITCH TO UNIX COMMAND LINE ===##
module load biocontainers/default
module load bedtools/2.30.0

bedtools intersect -loj -wao -a top10_fst.bed -b AMEL_cds.gtf > intersect_top10.bed
grep -i "transcript_id" intersect_top10.bed > gene_top10.bed
grep -o '".*"' gene_top10.bed | sed 's/"//g' | awk -F ';' '{print $1}' | awk -F '-' '{print $2}' > gene2_top10.bed
paste gene_top10.bed gene2_top10.bed  > gene_top10_gene.bed

#BED 2 ... look it's just easier to switch back to R if you want to pull immune genes out of this dataset--------
my.genes <- read.table("gene2_top10.bed", header=F)
my.imm <- read.table("Brutscher_Imm_Gene_ID", header=T, fill=T, sep="\t") #from Brutscher 2015

conv <- read.table("GB_to_NCBI", header=F, fill=T)
colnames(conv) <- c("V21", "GB")
test <- merge(x=y, y=conv, all.y=TRUE)
head(test)
y$Gene.ID <- y$V21
test <- merge(x=y, y=my.imm, all.y=TRUE)