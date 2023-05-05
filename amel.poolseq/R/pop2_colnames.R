#Popoolation2 Formatting fxn
#' removes non-fst columns and numeric population colnames from fst estimates; sets colnames to population names
#' @param popnames list of sample names IN THE ORDER THEY WERE ADDED TO MPILEUP and their population
#' @param popool_fst data.frame .fst output created by popoolation2 fst-sliding.pl
#' @import dplyr
#' @importFrom utils combn
#' @return data.frame with samples as col names and '#:#=' removed from values
#' @examples
#' ex_pop2names <- data.frame(Sample=c("KYFeral", "Cali", "Tex"), Management=c("Feral","Managed","Managed"), Population=c("AHB", "PAFeral", "PurdueMB"))
#' ex_pop2fst <- data.frame(X1=c("NC_037638.1", "NC_037638.1", "NC_037638.1"), X2=c("58294", "62031", "75893"), X3=c("1", "1", "2"), X4=c("1.000", "1.000", "1.000"), X5=c("12", "5", "6"), X6=c("1:2=0", "1:2=0.0006", "1:2=0.98"), X7=c("1:3=0.738", "1:3=0.89", "1:3=0.0"), X8=c("2:3=0.0000005", "2:3=0.2134", "2:3=0"))
#' amel_colnames(ex_pop2names, ex_pop2fst)
#' @export

amel_colnames <- function(popnames, popool_fst) {
	rmeq <- function(x){
		as.numeric(gsub('.*=', '', x))
	}
	pop2 <- popool_fst %>% mutate(across(6:ncol(popool_fst), rmeq))
	pop2_samp <- data.frame(t(combn(popnames[,1], 2)))
	samp_name <- paste(pop2_samp$X1, pop2_samp$X2, sep='.')
	pop2 <- pop2 %>% 
	rename(
		RefContig = 1,
		WindowPos = 2,
		SNPs = 3,
		CovFrac = 4,
		AvMinCov = 5
		) 
	names(pop2)[6:ncol(pop2)] <- samp_name
	return(pop2)
}
