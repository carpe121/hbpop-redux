# Brutscher et al (2015) Table S1
## https://doi.org/10.1016/j.cois.2015.04.016

# Evans et al (2006) Table S1
## https://doi.org/10.1111/j.1365-2583.2006.00682.x
# manually converted from Word doc to tsv

# Harpur et al (2019) Table S3
## https://doi.org/10.1093/gbe/evz018

library(readxl)
library(dplyr)
library(usethis)

data(gb_ncbi_conv)

brut <- read_excel("1-s2.0-S2214574515000772-mmc1.xlsx", range=cell.cols("A:C"))
	#brut <- read.csv("brut.tsv", header=F, sep="\t")

evans <- read.csv("evans.tsv", sep="\t", header=T)
harp <- read_excel("evz018_supp/TableS3.xlsx", range=cell.cols("D6:D78"))
	#harp <- read.csv("harp.tsv", sep="\t", header=T)

colnames(brut) <- brut[1,]
brut <- brut[-c(1,2),]
brut <- brut[,c(1:3)]
colnames(brut) <- c("Gene.Name", "Pathway", "Gene.ID")

brut_ev <- rbind(brut, evans) %>% left_join(gb_ncbi_conv, by=join_by(Gene.ID==Transcript))

#brut contains GBs in Gene.ID col -> swap col values and check for transcript matches
brut_ev3 <- brut_ev[-c(5)]
brut_evt <- brut_ev3[grep("GB", brut_ev3$Gene.ID),]
brut_ev3 <- brut_ev3[-grep("GB", brut_ev3$Gene.ID),]

brut_evt <- brut_evt[,c(1,2,4,3)]
colnames(brut_evt) <- c("Gene.Name", "Pathway", "Gene.ID", "comb")
brut_evt2 <- brut_evt %>% left_join(gb_ncbi_conv, by=join_by(comb==comb))
brut_evt2 <- brut_evt2[,c(1,2,3,4)]
brut_ev4 <- rbind(brut_ev3, brut_evt2)

colnames(harp) <- c("GB")
harp$Pathway <- 'Hygiene'
harp$Gene.Name <- NA
harp2 <- harp %>% left_join(gb_ncbi_conv, by=join_by(GB==comb), multiple="all")
harp3 <- harp2[,c(3,2,5,1)]
colnames(harp3) <- c("Gene.Name", "Pathway", "Gene.ID", "comb")

br_ev_ha <- rbind(brut_ev4, harp3)
immgene_list <- br_ev_ha[!duplicated(br_ev_ha$Gene.ID, incomparables=NA),]

colnames(immgene_list) <- c("Gene.Name", "Pathway", "Transcript", "GBID")

usethis::use_data(immgene_list, overwrite = TRUE)
