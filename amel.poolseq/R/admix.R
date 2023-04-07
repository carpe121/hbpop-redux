#HBPOP2022 Admixture figures
#' generate figures associated with admixture of US honey bee populations
#' @param plink3 .plink created by ADMIXTURE
#' @param temp data.frame with population names
#' @import ggplot2
#' @examples set later 
#' @export


hbpop_admix <- function(plink3, temp){
  #organize table-----
  colnames(plink3) <- c("A", "M", "C") #pooled sequences from ancestral population
  temp <- read.table("pca_rn.txt", header=T)
  plink3 <- cbind(plink3,temp)
  #write.table(plink3, "plink.3.Q_org", col.names=T, row.names=F, quote=F, sep="\t")
  #plink3 <- read.table("plink.3.Q_org", header=T)

  plink3 <- plink3[-c(66,67,68), ] #get rid of reference samples; DROP REFERENCE BY VALUE, not POSITION
  sort.tbl <- with(plink3, plink3[order(plink3$Pop),]) #sort alphabetically by stock
  plot.tbl <- subset(sort.tbl, select=-c(4,5)) #get rid of pop and management cols for plot

  anc.plot <- barplot(t(as.matrix(plot.tbl)), 
                  col=c("red", "black", "yellow"), 
                  xlab="Individual", las=2,
                  ylab="Ancestry", 
                  legend=c("A", "M", "C"),
                  args.legend=list(title="Ancestry", x="topright"))
  abline(h=0.2, col="blue", lty=c(2), lwd=c(5)) #for the cutoff for AHBs

  #avg. ancestry boxplot------
  table.means <- aggregate(plink3$A~plink3$Management, plink3, mean)
  table.means2 <- aggregate(plink3$C~plink3$Management, plink3, mean)
  table.means3 <- aggregate(plink3$M~plink3$Management, plink3, mean)
  avg.anc <- cbind(table.means, table.means2, table.means3)
  avg.anc <- subset(avg.anc, select=-c(3,5)) #drop by name, not position
  colnames(avg.anc) <- c("Origin", "A", "C", "M")

  table.sd <- aggregate(plink3$A~plink3$Management, plink3, sd)
  table.sd1 <- aggregate(plink3$C~plink3$Management, plink3, sd)
  table.sd2 <- aggregate(plink3$M~plink3$Management, plink3, sd)
  avg.sd <- cbind(table.sd, table.sd1, table.sd2)
  avg.sd <- subset(avg.sd, select=-c(3,5))
  colnames(avg.sd) <- c("Origin", "A", "C", "M")

  x <- aov(plink3$C~plink3$Management, data=plink3)
  TukeyHSD(x)

  x <- aov(plink3$M~plink3$Management, data=plink3)

#boxplot of ancestry by stock -> make a loop so it spits out three boxplots
  p <- ggplot(sort.tbl, aes(x=Pop, y=M)) + geom_boxplot(fill='#A29F9E', color="black") + 
    labs(x="Management", y="Proportion") + coord_cartesian(ylim=c(0,1)) + 
    theme_classic()
  }