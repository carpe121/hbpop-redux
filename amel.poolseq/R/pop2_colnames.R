#Popoolation2 Formatting fxn
#' removes non-fst columns and numeric population colnames from fst estimates; sets colnames to population names
#' @param popnames list of sample names IN THE ORDER THEY WERE ADDED TO MPILEUP and their population
#' @param popool_fst data.frame .fst output created by popoolation2 fst-sliding.pl
#' @importFrom utils combn
#' @return data.frame (2) popool_fst2, amel_fst_df
#' @examples
#' ex_pop2names <- data.frame(Sample=c("AHB_3829", "Scranton-LBG", "P02"), Management=c("Feral","Feral","Managed"), Population=c("AHB", "PAFeral", "PurdueMB"))
#' ex_pop2fst <- data.frame(X1=c("NC_CHROM", "NC_CHROM", "NC_CHROM"), X2=c("4000", "4100", "4200"), X3=c("19", "105", "739"), X4=c("1.000", "1.000", "1.000"), X5=c("100.0", "99.7", "98.9"), X6=c("1:2=0", "1:2=0.0006", "1:2=0.98"), X7=c("1:3=0.738", "1:3=0.89", "1:3=0.0"), X8=c("2:3=0.0000005", "2:3=0.2134", "2:3=0"))
#' amel_colnames(ex_pop2names, ex_pop2fst)
#' @export

amel_colnames <- function(popnames, popool_fst) {
	popool_fst2 <- popool_fst[,grepl("=", popool_fst)]
	popool_fst2 <- data.frame(apply(popool_fst2, 2, function(x) as.numeric(gsub('.*=', '', x))))
	pop2_samp <- data.frame(t(combn(popnames[,1],2)))
	samp_name <- paste(pop2_samp$X1, pop2_samp$X2, sep='.')
	colnames(popool_fst2) <- samp_name
	pop2_pop <- data.frame(t(combn(popnames[,2],2)))
	pop_name <- paste(pop2_pop$X1, pop2_pop$X2, sep='')
	amel_fst_df <- data.frame(cbind(samp_name, pop_name))
	out <- list(popool_fst2, amel_fst_df)
	return(out)
}

amel_colnames <- function(popnames, popool_fst) {
	rmeq <- function(x){
		as.numeric(gsub('.*=', '', x))
	}
	pop2 <- popool_fst %>% mutate(across(6:ncol(popool_fst), rmeq))
	pop2_samp <- data.frame(t(combn(popnames[,1], 2)))
	samp_name <- paste(pop2_samp$X1, pop2_samp$X2, sep='.')



	colnames(pop2) <- samp_name
	return(pop2)
}

pop2 %>% select(1:5) %>%
rename(
	RefContig = 1,
	WindowPos = 2,
	SNPs = 3,
	CovFrac = 4,
	AvMinCov = 5
	) %>% select(6:ncol(pop2)) %>%
rename(

	)


pop2 %>% select(6:ncol(pop2)) %>%
rename_with(samp_name
	)
