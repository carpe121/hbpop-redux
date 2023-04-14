# Brutscher et al (2015) Table S1
## https://www.sciencedirect.com/science/article/pii/S2214574515000772#upi0005

# Evans et al (2006) Table S1
## https://resjournals.onlinelibrary.wiley.com/doi/10.1111/j.1365-2583.2006.00682.x
# manually converted from Word doc to csv

# Harpur et al (2019) Table S2
## https://academic.oup.com/gbe/article/11/3/937/5318327#supplementary-data

library(readxl)
library(usethis)

brut <- read.csv("1-s2.0-S2214574515000772-mmc1.xlsx")
#evan <- read.csv("imb682_tables1-final.doc")
harp <- read.csv("evz018_supp/TableS2.xlsx")

data(gb_ncbi_fin)




usethis::use_data(immgene_list, overwrite = TRUE)
