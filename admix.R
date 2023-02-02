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