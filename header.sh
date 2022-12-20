#!/usr/bin/env

#' fix POPOOLATION2 output header into more legible format for downstream analysis
#' @param all_headfix.fst tsv with all samples by population, with FST calculated by POPOOLATION2 (see popool.sh); population comparisons listed as 1:2, 1:3, 1:4, etc. (total of 9)
#' @param file_header.tsv
#' @export

# Each data point is representated as 1:2=0.004 (or whatever FST is), and the "1:2=" should be removed before analysis
# Finally, columns 1-5 contain data not necessary for analysis 

df <- read.table("all2.fst", header=T)
df[,6:281] <- apply(df[,6:X], 2, function(x) as.numeric(gsub('.*_','',x))) #function removes comparison numbers from values in rows 6-last
names(df) <- lapply(df[1,], as.character) #sets first row as column names
df <- gsub("_.*", "", colnames(df)) #removes everything after the "_"
colnames(df) <- df #sets #:# as column names
df <- subset(df, select=-c(1:5)) #remove non-fst values from dataframe
df <- as.data.table(df)
write.table(df, "fst_df", col.names=T, row.names=F, quote=F, sep="\t")