#!/usr/bin/env

#' generate statistical analyses and figures associated with genetic differentiation between US honey bee populations
#' @param fst_df tsv with all samples by population, with FST calculated by POPOOLATION2; header fixed by header.sh
#' @param comp tsv with all comparisons listed by origin (Feral/Feral, Feral/Managed, or Managed/Managed)
#' @examples for Unix command line: $Rscript fst.R fst_df comp
#' @export

#Load libraries--------------
#if libraries do not load, uncomment next line
#install.packages(c("reshape2", "data.table", "dplyr", "ggplot2"))

library(data.table)
library(dplyr)
library(ggplot2)
library(reshape2)

print ("Libraries loaded")

#Step 1: Reading in data------------
args=commandArgs(trailingOnly=TRUE)
df <- read.table(args[1], header=T)

print("Data loaded")

#Step 2: Calculating average FST per population----------
mean <- colMeans(df)
mean.n0 <- apply(df,2,function(x) mean(x[x>0])) #calculate column means and exclude zeros
comp <- read.table(args[2], header=F)
df_means <- cbind(mean, mean.n0, comp) #mean needs to go first to preserve rownames
colnames(df_means) <- c("FST", "FST_n0", "comp")

write.table(df_means, "avg_fst_tbl", col.names=T, sep="\t", row.names=F, quote=F)

print("Average FST table printed")

#Step 3: Plot FST-----
df_means <- subset(df_means, select=-c(1))
df_means$stock <- rownames(df_means)
rownames(df_means) <- NULL
new.df_means <- df_means[order(df_means$FST_n0),]

#Plot by aggregating avg. FST by comparison class----
u <- aggregate(new.df_means$FST_n0, by=list(new.df_means$comp), function(x) mean(x, na.rm=TRUE))
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

#OUTPUT FIGURE HERE

print("Average FST plot generated")

#ANOVA------
temp <- temp[-grep("Ref", df$Field1),]
x <- aov(temp$FST_n0~temp$comp)
summary(x)
tukey.plot <- TukeyHSD(x)
plot(tukey.plot, las=1)

#Avg FST Heatmap------
mean.n0 <- as.data.frame(apply(df,2,function(x) mean(x[x>0]))) #constructs table
mean.n0$names <- rownames(mean.n0)
rownames(mean.n0) <- NULL
colnames(mean.n0) <- c("FST", "Comp")
mean.n0$Field1 <- gsub('[.].*','', mean.n0$Comp)
mean.n0$Field2 <- gsub('.*[.]','', mean.n0$Comp)
temp4 <- subset(mean.n0, select=-c(2))
write.table(temp4, "fst_table", sep="\t", col.names=T, row.names=F, quote=F)

fst_list <- read.table("fst_table", header=T) 
ggplot(fst_list, aes(Field1, Field2, fill=FST)) + geom_tile() + 
  geom_text(aes(label=sprintf("%.3f", FST)), color="white", size=4) +
  labs(x=NULL, y=NULL) +
  coord_fixed() + theme_bw()

## ===== GENOME-WIDE FST ====== ##
#Manhattan plot------

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













