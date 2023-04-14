#HBPOP2022 FST figures.....now with genes
#' generate figures associated with FST on gene level of US honey bee populations
#' @param fst_df data.frame created by amel_popfig
#' @param n_percent number n% (1-100) of FST from top, e.g. n_percent=10 gives top 10%
#' @import dplyr 
#' @importFrom reshape2 melt
#' @importFrom stats quantile
#' @return data.table
#' @examples set later 
#' @export

hbpop_bed <- function(fst_df, n_percent) {
    #Sort FST by Comparison Class-------
    ampop_mhdf$Comb <- paste(ampop_mhdf$RefContig, ampop_mhdf$WindowPos)
    ampop_melt <- reshape2::melt(ampop_mhdf, id.vars="Comb", measure.vars=c("Managed/Managed", "Feral/Managed", "Feral/Feral"))
    #rewrite to integrate FST df -> use output from fst table to avoid previous line
    #pop_table = data.frame mapping each comparison (e.g. PurdueMB:PAFeral; header="Comparison") to class (e.g. Managed/Feral; header="Type") 
    ampop_melt$Chrom <- gsub(' .*','', ampop_melt$Comb)
    ampop_melt$WindowPos <- gsub('.* ','', ampop_melt$Comb)
    ampop_melt$Comb <- NULL
    colnames(ampop_melt) <- c("Comparison", "FST", "Chrom", "WindowPos")
    ampop_bedsort <- merge(ampop_melt, pop_table, by="Comparison") #assigns comparison to sample
    
    #Write BED file output------
    fm_fst <- ampop_bedsort[which(ampop_bedsort$Type=='Feral/Managed'),] #for example; just change type to Feral/Managed or Managed/Managed -> LOOP? for each unique(ampop_bedsort$Type)
    fm_fst <- fm_fst %>% arrange(desc(fm_fst$FST))
    bed_out <- fm_fst[fm_fst$FST > quantile(fm_fst$FST,prob=1-n_percent/100),]
    bed_out$Comb <- paste(bed_out$Chrom, bed_out$WindowPos) #gotta combine chrom and window pos to get unique SNPs
        #x <- data.frame(unique(top5$Comb)) #gives you number of unique SNPs
    bed_out <- bed_out[,c("Chrom", "WindowPos")]
    bed_out$chromEnd <- bed_out$WindowPos #bed requires start and end; window=1 BP on POPOOL; might require making a second file and just adding 1
    colnames(bed_out) <- c("chrom", "chromStart", "chromEnd") #bed file required column names
    #write.table(bed, "top10_fm.bed", sep="\t", col.names=T, row.names=F)
    
    
    ##=== BEDTOOLS: SWITCH TO UNIX COMMAND LINE ===##
    
    # script that converts to fst output into something that can be run through bedtools
    # WIP: need to find a way to exchange between UNIX and R commands OR streamline it in one system
    

    #module load biocontainers/default
    #module load bedtools/2.30.0
    #
    #bedtools intersect -loj -wao -a top10_fst.bed -b AMEL_cds.gtf > intersect_top10.bed
    #grep -i "transcript_id" intersect_top10.bed > gene_top10.bed
    #grep -o '".*"' gene_top10.bed | sed 's/"//g' | awk -F ';' '{print $1}' | awk -F '-' '{print $2}' > gene2_top10.bed
    #paste gene_top10.bed gene2_top10.bed  > gene_top10_gene.bed
    #
    ##BED 2 ... look it's just easier to switch back to R if you want to pull immune genes out of this dataset--------
    #my.genes <- read.table("gene2_top10.bed", header=F)
    #my.imm <- read.table("Brutscher_Imm_Gene_ID", header=T, fill=T, sep="\t") #from Brutscher 2015
    #
    #conv <- read.table("GB_to_NCBI", header=F, fill=T)
    #colnames(conv) <- c("V21", "GB")
    #test <- merge(x=y, y=conv, all.y=TRUE)
    #head(test)
    #y$Gene.ID <- y$V21
    #test <- merge(x=y, y=my.imm, all.y=TRUE)
}