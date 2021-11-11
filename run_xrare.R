#cp /work/software/phenotype_software/scripts/run_xrare.R /work/data/phenotype_software_BK
#cp /work/software/phenotype_software/scripts/old/___ /work/data/phenotype_software_BK
#docker run -v /work/data/phenotype_software_BK:/work --name xrare_20210407-KMCS2 -it xrare-pub:2015
#nohup Rscript /work/run_xrare.R &
#taking long time to run a sample!!!



options(stringsAsFactors = F)
options('digits'=2)
library(xrare)



data <- "DDD"; info <- read.csv("/work/result_simplified-new.csv"); vcf_path <- "/work/DDD_dataset/data_selected"
#data <- "KMCS1"; info <- read.csv("/work/KMCS1_sample_info.csv"); vcf_path <- "/work/KMCS_dataset/VCF1"
#data <- "KMCS2"; info <- read.csv("/work/KMCS2_sample_info.csv"); vcf_path <- "/work/KMCS_dataset/VCF2"



all_files <- list.files(vcf_path)
for (i in 140:dim(info)[1]){
  vcf_id <- info[i,3]
  hpo_id <- info[i,2]
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = ",")
  hpo_id <- paste("'", hpo_id, "'", sep = "") #'HP:0001156,HP:0001363,HP:0011304,HP:0010055'
  
  target_vcf <- all_files[grep(vcf_id, all_files)]
  vcffile <- paste0(vcf_path, "/", target_vcf)
  dt <- xrare(vcffile=vcffile, hpoid=hpo_id)
  result <- dt[, .(symbol,xrare_score,CHROM,POS,REF,ALT)]

  write.table(result, file = paste0(vcf_path, "/xrare_results/", vcf_id, ".tsv"), row.names = F, quote = F, sep = "\t")
}



#Summary
all_files <- list.files(paste0(vcf_path, "/xrare_results"))
all_tsv <- all_files[grep(".tsv", all_files)]
xrare <- c()
for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  tsv <- all_tsv[grep(vcf_id, all_tsv)]
  tsv <- read.delim2(paste0(vcf_path, "/xrare_results/", tsv))
  if (gene %in% unique(tsv[,1])){
    xrare <- c(xrare, which(unique(tsv[,1])==gene))
  }
  else{xrare <- c(xrare, "no")}
}

result <- cbind(info, xrare)
write.csv(result, file=paste0("/work/results/xrare_with_", data, ".csv"), row.names = F)


