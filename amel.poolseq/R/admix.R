#HBPOP2022 Admixture figures
#' for each ancestral population, calculate average contribution and standard deviation for each sample
#' @param plink3 .plink created by ADMIXTURE
#' @importFrom stats aggregate
#' @importFrom stats sd
#' @examples set later 
#' @export


hbpop_admix <- function(plink3){
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
}