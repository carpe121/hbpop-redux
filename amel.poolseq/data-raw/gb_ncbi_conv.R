library(wrapr)
library(tidyverse)
library(usethis)

gb_gbo$comb <- gb_gbo$GBold %?% gb_gbo$GB
gb_ncbi_comb <- merge(gb_gbo, gb_ncbi, by.x="comb", by.y="Gene", all.y=TRUE)
gb_ncbi_comb <- select(gb_ncbi_comb, -GBold)
gb_ncbi_conv <- gb_ncbi_comb[!(gb_ncbi_comb$comb==""),]

usethis::use_data(gb_ncbi_conv, overwrite = TRUE)
