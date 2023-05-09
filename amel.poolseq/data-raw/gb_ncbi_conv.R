library(wrapr)
library(tidyverse)
library(usethis)

data(gb_gbo)
data(gb_ncbi)

gb_gbo$comb <- gb_gbo$GBold %?% gb_gbo$GB 
gb_ncbi_conv <- full_join(gb_gbo, gb_ncbi, join_by(comb==Gene), multiple="all", relationship="many-to-many") %>%
	select(!GBold) %>%
	distinct(Transcript, .keep_all=TRUE)

usethis::use_data(gb_ncbi_conv, overwrite = TRUE)
