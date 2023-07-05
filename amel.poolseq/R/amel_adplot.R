#HBPOP2022 ADMIXTURE Plot
#' generate ggplot boxplot for ADMIXTURE data
#' @param sort.tbl data.table produced by ADMIXTURE
#' @param popname string that can be 'A', 'C', or 'M'; default=C
#' @param popdiv character ; "Management" or "Pop"
#' @import ggplot2 
#' @return figure
#' @export

amel_adplot <- function(popname="C", popdiv){
  if (popname=="A"){
    p <- ggplot(sort.tbl, aes(x={{popdiv}}, y=A), environment=environment()) + 
      geom_boxplot(fill='#C41E3A', color="black") + coord_cartesian(ylim=c(0,1)) + 
      ggtitle("Ancestry by Management") + xlab("Management") + ylab("Proportion")
  }

  if (popname=="C"){
    p <- ggplot(sort.tbl, aes(x={{popdiv}}, y=C), environment=environment()) + 
      geom_boxplot(fill='#D4AF37', color="black") + coord_cartesian(ylim=c(0,1)) + 
      ggtitle("Ancestry by Management") + xlab("Management") + ylab("Proportion")
  }

  if (popname=="M"){
    p <- ggplot(sort.tbl, aes(x={{popdiv}}, y=M), environment=environment()) + 
    geom_boxplot(fill='#808080', color="black") + coord_cartesian(ylim=c(0,1)) + 
    ggtitle("Ancestry by Management") + xlab("Management") + ylab("Proportion")
  }

  p + theme_bw()
}