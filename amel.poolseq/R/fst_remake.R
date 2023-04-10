#HBPOP2022 POPOOLATION2 Fst figures
#' generate statistical analyses and figures associated with genetic differentiation between US honey bee populations
#' @param popool2_fst .fst created by popoolation2 fst-sliding.pl
#' @import dplyr
#' @import ggplot2
#' @import reshape2
#' @returns several plots and figures
#' @examples set later 
#' @export

amel_popfig <- function(popool2_fst) {
  #Step 1: Alter input header---------
  df <- amel_colnames(pop2names, popool2_fst)

  #Step 2: Calculate mean FST per population----------
  mean <- colMeans(df[[1]])
  mean.n0 <- apply(df,2,function(x) mean(x[x>0])) #exclude zeros
  df_means <- cbind(mean, mean.n0, df[[2]])
  colnames(df_means) <- c("FST", "FST_n0", "comp")
  #write.table(df_means, "amelpop_meanfst", col.names=T, sep="\t", row.names=F, quote=F)

  #Step 3: Aggregate mean FST by comparison class and plot-----
  df_means <- subset(df_means, select=-c(1))
  df_means$stock <- rownames(df_means)
  rownames(df_means) <- NULL
  df_means2 <- df_means[order(df_means$FST_n0),]

  df_fstag <- aggregate(df_means2$FST_n0, by=list(df_means2$comp), function(x) mean(x, na.rm=TRUE))
  colnames(df_fstag) <- c("Comparison", "FST")

  ampop_avfst <- ggplot(data=df_fstag, aes(x=Comparison, y=FST, fill=Comparison)) + 
    geom_bar(stat="identity") + 
    theme_classic() +
    theme(legend.position="none",
          axis.title.x=element_text(color="black", size=15),
          axis.title.y=element_text(color="black", size=15)) +
    ylab("Average FST") + xlab("Stock") + 
    ggtitle("Average FST by Comparison") + theme(plot.title=element_text(hjust=0.5))
  ampop_avfst <- ampop_avfst + scale_color_manual(values=c("#4D1434", "#903163", "#969FA7"))
  #png('output/ampop_avfst')

  #ANOVA------
  df_means <- df_means[-grep("Ref", df$Field1),]
  df_aov <- aov(df_means$FST_n0~df_means$comp)
  summary(df_aov)
  df_tukey <- TukeyHSD(df_aov)
  plot(df_tukey, las=1)

  #Avg FST Heatmap------
  mean.n0 <- data.frame(apply(df,2,function(x) mean(x[x>0]))) #constructs table
  mean.n0$names <- rownames(mean.n0)
  rownames(mean.n0) <- NULL
  colnames(mean.n0) <- c("FST", "Comp")
  mean.n0$Field1 <- gsub('[.].*','', mean.n0$Comp)
  mean.n0$Field2 <- gsub('.*[.]','', mean.n0$Comp)
  mean.n0_2 <- subset(mean.n0, select=-c(2))
  #write.table(mean.n0_2, "fst_table", sep="\t", col.names=T, row.names=F, quote=F)
  #fst_list <- read.table("fst_table", header=T) 

  ggplot(mean.n0_2, aes(Field1, Field2, fill=FST)) + geom_tile() + 
    geom_text(aes(label=sprintf("%.3f", FST)), color="white", size=4) +
    labs(x=NULL, y=NULL) +
    coord_fixed() + theme_bw()

  ## ===== GENOME-WIDE FST ====== ##
  #Manhattan plot------

  ampop_mhdf <- df[-grep("NW_", df$RefContig),] #removes unclassified pieces of genome for easier plotting
  ampop_mhdf <- ampop_mhdf %>%
    group_by(RefContig) %>%
    summarize(chr_len=max(WindowPos)) %>%
    mutate(tot=cumsum(chr_len)-chr_len) %>%
    select(-chr_len) %>%
    left_join(ampop_mhdf, ., by=c("RefContig"="RefContig")) %>%
    arrange(RefContig, WindowPos) %>%
    mutate(BPcum=WindowPos+tot)

  axisdf = ampop_mhdf %>% group_by(RefContig) %>% summarize(center=( max(BPcum) + min(BPcum) ) / 2 )

  ampop_manplot <- ggplot(ampop_mhdf, aes(x=BPcum, y=df4[,7])) +
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

  ampop_manplot + facet_wrap(~RefContig, scales="free")
}







