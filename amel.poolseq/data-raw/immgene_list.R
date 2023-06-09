# Brutscher et al (2015) Table S1
## https://doi.org/10.1016/j.cois.2015.04.016

# Evans et al (2006) Table S1
## https://doi.org/10.1111/j.1365-2583.2006.00682.x
# manually converted from Word doc to tsv

# Harpur et al (2019) Table S3
## https://doi.org/10.1093/gbe/evz018

#dim(immgene_list) should be 596x4

library(readxl)
library(dplyr)
library(usethis)

data(gb_ncbi_conv)

brut <- read_excel("1-s2.0-S2214574515000772-mmc1.xlsx", range=cell.cols("A:C"))
	#brut <- read.csv("brut.tsv", header=F, sep="\t")

evans <- read.csv("evans.tsv", sep="\t", header=T)
harp <- read_excel("evz018_supp/TableS3.xlsx", range=cell.cols("D6:D78"))
	#harp <- read.csv("harp.tsv", sep="\t", header=F)

brut1 <- brut %>% filter(!row_number() %in% c(1,2)) %>%
	select(1:3) %>%
	rename(
		Gene.Name=1,
		Pathway=2,
		Gene.ID=3)

brut_ev <- bind_rows(brut1, evans) %>%
	left_join(gb_ncbi_conv, by=join_by(Gene.ID==Transcript)) %>%
	select(!GB)

#brut contains GBs in Gene.ID col
#move GBs to comb column and check for transcript matches
brut_evt <- brut_ev[grep("GB", brut_ev$Gene.ID),]
brut_evt <- brut_evt %>% 
	relocate(comb, .before=Gene.ID) %>% 
	rename(
		Gene.ID=3,
		comb=4) %>% 
	left_join(gb_ncbi_conv, by=join_by(comb==comb)) %>%
	select(!c(5,6))

brut_ev2 <- brut_ev[-grep("GB", brut_ev$Gene.ID),]
brut_ev3 <- rbind(brut_ev2, brut_evt)

colnames(harp) <- c("GB")
harp$Pathway <- 'Hygiene'
harp$Gene.Name <- NA
harp2 <- harp %>% 
	left_join(gb_ncbi_conv, by=join_by(GB==comb), multiple="all") %>%
	select(!GB.y) %>%
	relocate(Gene.Name) %>%
	relocate(Pathway, .after=Gene.Name) %>%
	relocate(GB, .after=last_col()) %>%
	rename(
		Gene.ID=3,
		comb=4
		)

br_ev_ha <- rbind(brut_ev3, harp2)
immgene_list <- br_ev_ha[!duplicated(br_ev_ha$Gene.ID, incomparables=NA),]

colnames(immgene_list) <- c("Gene.Name", "Pathway", "Transcript", "GBID")

usethis::use_data(immgene_list, overwrite = TRUE)
