#HBPOP2022 ADMIXTURE Plot
#' generate ggplot boxplot for ADMIXTURE data
#' @param tbl data.table produced by ADMIXTURE
#' @param popname string that can be 'A', 'C', or 'M'
#' @param fill_col hexcode '#000000'
#' @import ggplot2 
#' @return figure
#' @export


amel_adplot <- function(popname, fill_col, tbl){
  p <- ggplot(tbl, aes(x=Pop, y={{popname}}), environment=environment()) + 
    geom_boxplot(fill=fill_col, color="black") + coord_cartesian(ylim=c(0,1)) + 
    ggtitle("Ancestry by Management") + xlab("Management") + ylab("Proportion")
  p + theme_bw()
}