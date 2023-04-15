# Brutscher et al (2015) Table S1
## https://www.sciencedirect.com/science/article/pii/S2214574515000772#upi0005

# Evans et al (2006) Table S1
## https://resjournals.onlinelibrary.wiley.com/doi/10.1111/j.1365-2583.2006.00682.x
# manually converted from Word doc to tsv

# Harpur et al (2019) Table S3
## https://academic.oup.com/gbe/article/11/3/937/5318327#supplementary-data

library(readxl)
library(dplyr)
library(usethis)

brut <- read_excel("1-s2.0-S2214574515000772-mmc1.xlsx", range=cell.cols("A:C"))


brut <- brut[-1,]
colnames(brut) <- brut[1,]
brut <- brut[-c(1,2),]
brut <- brut[,c(1:3)]
colnames(brut) <- c("Gene.Name", "Pathway", "Gene.ID")

evans <- read.csv("evans.tsv", sep="\t", header=T)

data(gb_ncbi_conv)

brut_ev <- rbind(brut, evans)
brut_ev2 <- brut_ev %>% left_join(gb_ncbi_conv, by=join_by(Gene.ID==Transcript))
brut_ev3 <- brut_ev2[c(1,2,3,4)]

harp <- read_excel("evz018_supp/TableS3.xlsx", range=cell.cols("D6:D78"))
colnames(harp) <- c("GB")
harp$Pathway <- 'Hygiene'
harp$Gene.Name <- NA
harp2 <- harp %>% left_join(gb_ncbi_conv, by=join_by(GB==comb), multiple="all")
harp3 <- harp2[c(1,2,3,5)]
harp4 <- harp3[,c(3,2,4,1)]
colnames(harp5) <- c("Gene.Name", "Pathway", "Gene.ID", "comb")

immgene <- rbind(brut_ev3, harp5)
test <- immgene$Gene.ID[duplicated(immgene$Gene.ID)]






usethis::use_data(immgene_list, overwrite = TRUE)
