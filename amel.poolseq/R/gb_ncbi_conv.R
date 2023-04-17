#' GB to NCBI Conversion
#'
#' A dataset of old and new BeeBase gene IDs and NCBI RNA transcripts
#'
#' @format ## `gb_ncbi_conv`
#' A data frame with 3 columns and 22578 rows:
#' \describe{
#'	\item{comb}{Apis mellifera GenBank ID}
#'	\item{GB}{old Apis mellifera GenBank ID, if ID changed}
#'	\item{Transcript}{NCBI RNA transcripts}
#' }
#' @source manually generated
"gb_ncbi_conv"