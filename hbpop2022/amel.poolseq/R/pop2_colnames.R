#Popoolation2 Formatting fxn
#' removes non-fst columns, population tags from fst estimates, and restores colnames from fst output to population names
#' @param popnames list of population names IN THE ORDER THEY WERE ADDED TO MPILEUP
#' @param popool_fst data.frame .fst output created by popoolation2 fst-sliding.pl
#' @return data.table popool_fst2 chrom_pos
#' @examples
#' ex_pop2names <- c("AHB", "PAFeral", "PurdueMB")
#' ex_pop2fst <- data.frame(X1=c("NC_CHROM", "NC_CHROM", "NC_CHROM"), X2=c("4000", "4100", "4200"), X3=c("19", "105", "739"), X4=c("1.000", "1.000", "1.000"), X5=c("100.0", "99.7", "98.9"), X6=c("1:2=0", "1:2=0.0006", "1:2=0.98"), X7=c("1:3=0.738", "1:3=0.89", "1:3=0.0"), X8=c("2:3=0.0000005", "2:3=0.2134", "2:3=0"))
#' pop2_colnames(ex_pop2names, ex_pop2fst)
#' @export

pop2_colnames <- function(popnames, popool_fst) {
	chrom_pos <- popool_fst[,1:2]
	colnames(chrom_pos) <- c("chrom", "pos")
	popool_fst2 <- popool_fst[,grepl("=", popool_fst)]
	popool_fst2 <- data.frame(apply(popool_fst2, 2, function(x) as.numeric(gsub('.*=', '', x))))
	pop2_name <- data.frame(t(combn(popnames,2)))
	pop2_list <- paste(pop2_name$X1, pop2_name$X2, sep=':')
	colnames(popool_fst2) <- pop2_list
	file_path <- getwd()
	write.table(popool_fst2, paste(file_path, '/popool_fst_df', sep=''), row.names=FALSE, col.names=TRUE, quote=FALSE)
	write.table(chrom_pos, paste(file_path, '/chrom_pos_df', sep=''), row.names=FALSE, col.names=TRUE, quote=FALSE)
	if(file.exists("popool_fst_df")==TRUE){print("fst table created")} 
}
