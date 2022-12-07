#!/bin/sh
#FILENAME: submission_script

#' where filename is a text file containing a list of sample names
#' where script is a shell script with the desired command
#' where $p is the variable name of all samples. scripts using this submission script MUST start with the line p=$1
#' to begin script in SLURM, use command
##' $ sbatch sub.sh

date +"%d%B%Y%H:%M:%S"

filename='NAME.txt'
exec 4<$filename
while read -u4 p ;
do
	sbatch SCRIPT.sh "$p"
done