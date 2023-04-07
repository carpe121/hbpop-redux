#input file 'all.fst' is popoolation2 fst output tsv where sample comparisons are noted as 1:2, 1:3, 2:3, etc.

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
df <- read.table("all2.fst", header=T)
df[,6:281] <- apply(df[,6:X], 2, function(x) as.numeric(gsub('.*_','',x))) #function that removes the comparison numbers from values; just rows 6-last row (X)
df <- as.data.table(df)
write.table(df, "fst_df", col.names=T, row.names=F, quote=F)

##=== MEAN FST ===#
library(data.table)
library(ggplot2)
df <- read.table("fst_df", header=T)
df1 <- subset(df, select=-c(1,2,3,4,5)) #remove non-fst value columns from dataframe
mean <- colMeans(df1) #calculate column means
mean.n0 <- apply(df1,2,function(x) mean(x[x>0])) #calculate column means and exclude zeros
comp <- read.table("comp", header=F) #read in comparison metrics; in this case, if FST is comparing Feral/Feral, Feral/Managed, or Managed/Managed populations
temp <- cbind(mean, mean.n0, comp) #make sure mean goes first to preserve rownames
colnames(temp) <- c("FST", "FST_n0", "comp")

#Plot-----
temp <- subset(temp, select=-c(1))
temp$stock <- rownames(temp)
rownames(temp) <- NULL
new.temp <- temp[order(temp$FST_n0),]

#Plot by aggregating avg. FST by comparison class----
u <- aggregate(new.temp$FST_n0, by=list(new.temp$comp), function(x) mean(x, na.rm=TRUE))
colnames(u) <- c("Comparison", "FST")

new.plot2 <- ggplot(data=u, aes(x=Comparison, y=FST, fill=Comparison)) + 
  geom_bar(stat="identity") + 
  theme_classic() +
  theme(legend.position="none",
        axis.title.x=element_tok ext(color="black", size=15),
        axis.title.y=element_text(color="black", size=15)) +
  ylab("Average FST") + xlab("Stock") + 
  ggtitle("Average FST by Comparison") + theme(plot.title=element_text(hjust=0.5))
p <- new.plot2+scale_fill_brewer(palette="Dark2")

p <- new.plot2+scale_color_manual(values=c("#4D1434", "#903163", "#969FA7"))

#ANOVA------
temp <- temp[-grep("Ref", df$Field1),]
x <- aov(temp$FST_n0~temp$comp)
summary(x)
tukey.plot <- TukeyHSD(x)
plot(tukey.plot, las=1)

#Avg FST Heatmap------
mean.n0 <- as.data.frame(apply(df3,2,function(x) mean(x[x>0]))) #this one makes a table instead of a matrix like before
mean.n0$names <- rownames(mean.n0)
rownames(mean.n0) <- NULL
colnames(mean.n0) <- c("FST", "Comp")
mean.n0$Field1 <- gsub('[.].*','', mean.n0$Comp)
mean.n0$Field2 <- gsub('.*[.]','', mean.n0$Comp)
temp4 <- subset(mean.n0, select=-c(2))
write.table(temp4, "fst_table", sep="\t", col.names=T, row.names=F, quote=F) #manually set values for fst

fst_list <- read.table("fst_table", header=T) 
ggplot(fst_list, aes(Field1, Field2, fill=FST)) + geom_tile() + 
  geom_text(aes(label=sprintf("%.3f", FST)), color="white", size=4) +
  labs(x=NULL, y=NULL) +
  coord_fixed() + theme_bw()

## ===== GENOME-WIDE FST ====== ##
#Manhattan plot------
library(dplyr)
library(ggplot2)
df4 <- df[-grep("NW_", df$RefContig),] #removes unclassified pieces of genome for easier plotting
df4 <- df4 %>%
  group_by(RefContig) %>%
  summarize(chr_len=max(WindowPos)) %>%
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  left_join(df4, ., by=c("RefContig"="RefContig")) %>%
  arrange(RefContig, WindowPos) %>%
  mutate(BPcum=WindowPos+tot)

axisdf = df4 %>% group_by(RefContig) %>% summarize(center=( max(BPcum) + min(BPcum) ) / 2 )

p <- ggplot(df4, aes(x=BPcum, y=df4[,7])) +
  geom_point( aes(color=as.factor(RefContig)), alpha=0.8, size=1.3) +
  scale_color_manual(values = rep(c("grey", "skyblue"), 70 )) +
  scale_x_continuous( label = axisdf$RefContig, breaks= axisdf$center ) +
  scale_y_continuous() +
  theme_bw() +
  theme( 
    legend.position="none",
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

p + facet_wrap(~RefContig, scales="free")


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