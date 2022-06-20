##=== PCA ===##
library(data.table)
library(pcadapt)

#BED file---------
file <- read.pcadapt("plink_2.bed", type="bed")
x <- pcadapt(input=file, K=20)
plot(x, option="screeplot")
poplist <- c(rep("STOCKNAME", no. of samples in that stock), rep(repeat as neccessary))
plot(x, option="scores", pop=poplist)
df <- subset(data.frame(x$scores), select=c(1,2)) #pulls out the first two PCs
rn <- read.table("pca_rn.txt", header=F) #single column text file that has stock corresponding to the row
df$Stock <- rn$V1
write.table(df, "pca_table", row.names=F, col.names=T, quote=F)

#GGPLOT2-----------
df <- read.table("pca_table", header=T)
ggplot(df, aes(x=X1, y=X2, shape=Stock, color=Stock)) + 
  geom_point(size=5) +
  scale_shape_manual(values=c(17,16,16,16,17,17,17,17,17)) +
  scale_color_manual(values=c('#332288', '#117733', '#DDCC77', '#882255', '#44AA99', '#CC6677', '#AA4499', '#882255', '#88CCEE')) +
  labs(x="PC2 (14.1%)", y="PC1 (15.4%)", title="PCA") +
  theme_bw()


## ========= ADMIXTURE =========== ##

#organize table-----
tbl <- read.table("plink.3.Q", header=F)
colnames(tbl) <- c("A", "M", "C") #pooled sequences from ancestral population
temp <- read.table("pca_rn.txt", header=T)
tbl <- cbind(tbl,temp)
write.table(tbl, "plink.3.Q_org", col.names=T, row.names=F, quote=F, sep="\t")

#admixture plot-------
tbl <- read.table("plink.3.Q_org", header=T)
tbl <- tbl[-c(66,67,68), ] #get rid of reference samples
sort.tbl <- with(tbl, tbl[order(tbl$Pop),]) #sort alphabetically by stock
plot.tbl <- subset(sort.tbl, select=-c(4,5)) #get rid of pop and management cols for plot

anc.plot <- barplot(t(as.matrix(plot.tbl)), 
                col=c("red", "black", "yellow"), 
                xlab="Individual", las=2,
                ylab="Ancestry", 
                legend=c("A", "M", "C"),
                args.legend=list(title="Ancestry", x="topright"))
abline(h=0.2, col="blue", lty=c(2), lwd=c(5)) #for the cutoff for AHBs

#avg. ancestry boxplot------
table.means <- aggregate(tbl$A~tbl$Management, tbl, mean)
table.means2 <- aggregate(tbl$C~tbl$Management, tbl, mean)
table.means3 <- aggregate(tbl$M~tbl$Management, tbl, mean)
avg.anc <- cbind(table.means, table.means2, table.means3)
avg.anc <- subset(avg.anc, select=-c(3,5))
colnames(avg.anc) <- c("Origin", "A", "C", "M")

table.sd <- aggregate(tbl$A~tbl$Management, tbl, sd)
table.sd1 <- aggregate(tbl$C~tbl$Management, tbl, sd)
table.sd2 <- aggregate(tbl$M~tbl$Management, tbl, sd)
avg.sd <- cbind(table.sd, table.sd1, table.sd2)
avg.sd <- subset(avg.sd, select=-c(3,5))
colnames(avg.sd) <- c("Origin", "A", "C", "M")

x <- aov(tbl$C~tbl$Management, data=tbl)
TukeyHSD(x)

x <- aov(tbl$M~tbl$Management, data=tbl)

p <- ggplot(sort.tbl, aes(x=Pop, y=M)) + geom_boxplot(fill='#A29F9E', color="black") + 
  labs(x="Management", y="Proportion") + coord_cartesian(ylim=c(0,1)) + 
  theme_classic()