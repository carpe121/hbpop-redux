#HBPOP2022 Admixture PCA
#' generate PCA based on admixture of US honey bee populations
#' @param plink_2.bed .plink created by ADMIXTURE
#' @param stockname list of stock names
#' @param pca_rn.txt data.frame single column file that has stock corresponding to the row
#' @returns figure pca_hbpop2022_admix
#' @import ggplot2
#' @importFrom pcadapt read.pcadapt
#' @examples set later 
#' @export

hbpop_pca <- function(plink_2.bed, stockname, pca_rn.txt) {
  #BED file---------
  file <- read.pcadapt("plink_2.bed", type="bed")
  x <- pcadapt(input=file, K=20)
  plot(x, option="screeplot")

  #poplist <- c(rep("STOCKNAME", no. of samples in that stock), rep(repeat as neccessary))
  plot(x, option="scores", pop=poplist)

  df <- subset(data.frame(x$scores), select=c(1,2)) #pulls out the first two PCs
  rn <- read.table("pca_rn.txt", header=F)
  df$Stock <- rn$V1
  write.table(df, "pca_table", row.names=F, col.names=T, quote=F)

  pca_hb <- ggplot(df, aes(x=X1, y=X2, shape=Stock, color=Stock)) + 
    geom_point(size=5) +
    scale_shape_manual(values=c(17,16,16,16,17,17,17,17,17)) +
    scale_color_manual(values=c('#332288', '#117733', '#DDCC77', '#882255', '#44AA99', '#CC6677', '#AA4499', '#882255', '#88CCEE')) +
    labs(x="PC2 (14.1%)", y="PC1 (15.4%)", title="PCA") +
    theme_bw()

  pca_hb
}