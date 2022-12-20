#!/bin/bash
#Name: header.sh

##=== DATA ORGANIZATION ===##

#Setting col names in R-----
df <- read.table("all.fst", header=F)
names(df) <- lapply(df[1,], as.character) #sets first row as column names
df2 <- gsub("_.*", "", colnames(df)) #removes everything after the "_"
colnames(df) <- df2 #sets #:# as column names
df3 <- subset(df, select=-c(1:5)) #remove non-fst values from dataframe

#Setting col names in Unix (easier)----
sed -i "1 s/.*/$(< file_header.tsv)/" all.fst #where file_header.tsv has been filled in with actual file names
sed 's/=/_/g' all.fst > all2.fst #if you have the equals signs left over from FST replace them in the command line with underscores to make them easier to remove later

#R data organization if you cheated using unix-----
df <- read.table("all2.fst", header=T)=
df[,6:281] <- apply(df[,6:X], 2, function(x) as.numeric(gsub('.*_','',x))) #function that removes the comparison numbers from values; just rows 6-last row (X)
df <- as.data.table(df)
write.table(df, "fst_df", col.names=T, row.names=F, quote=F)