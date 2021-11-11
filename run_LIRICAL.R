options(stringsAsFactors = F)
options('digits'=2)
library(org.Hs.eg.db)

data <- "DDD"; info <- read.csv("/work/software/phenotype_software/scripts/old/result_simplified-new.csv"); vcf_path <- "/work/data/phenotype_software_BK/DDD_dataset/data_selected"
#data <- "KMCS1"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS1_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF1"
#data <- "KMCS2"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS2_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF2"



for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  hpo_id <- info[i,2]
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = "\\',\\'")
  hpo_id <- paste("[\\'", hpo_id, "\\']", sep = "")
  system(paste("vcf=`ls -1 ", vcf_path, "/*", vcf_id, "*` && 
               cd /work/software/phenotype_software/LIRICAL/LIRICAL && cp -f ./src/test/resources/yaml/hpo_and_vcf.yml ./ && mv -f ./hpo_and_vcf.yml ./temp.yml && 
               Rscript /work/software/phenotype_software/scripts/yml2.R ./temp.yml $vcf ", hpo_id, " && 
               java -jar ./target/LIRICAL.jar yaml -y ./temp.yml", sep = ""))
  system(paste0("mv ", vcf_path, "/*_LIRICAL.tsv ", vcf_path, "/LIRICAL_results"))
}



#converting format
all_files <- list.files(paste0(vcf_path, "/LIRICAL_results"))
all_tsv <- all_files[grep("_LIRICAL.tsv", all_files)]
for (i in all_tsv) {
  temp <- read.table(paste0(vcf_path, "/LIRICAL_results/", i), comment.char = "!", sep = "\t", header = T, quote = "")
  temp <- temp[, c(7, 1)]
  temp[, 1] <- gsub("NCBIGene:", "", temp[, 1])
  GENE_SYMBOL <- mapIds(org.Hs.eg.db,keys=temp[, 1],column="SYMBOL",keytype="ENTREZID",multiVals="first")
  temp <- cbind(GENE_SYMBOL, temp)
  target_name <- paste0(vcf_path, "/LIRICAL_results/", i)
  target_name <- gsub("_LIRICAL.tsv", "_LIRICAL_new.tsv", target_name)
  write.table(temp, file = target_name, quote = F, sep = "\t", row.names = F)
}



#Summary
all_files <- list.files(paste0(vcf_path, "/LIRICAL_results"))
all_tsv <- all_files[grep("_LIRICAL_new.tsv", all_files)]
LIRICAL <- c()
for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  tsv <- all_tsv[grep(vcf_id, all_tsv)]
  tsv <- read.delim2(paste0(vcf_path, "/LIRICAL_results/", tsv))
  if (gene %in% unique(tsv[,1])){
    LIRICAL <- c(LIRICAL, which(unique(tsv[,1])==gene))
  }
  else{LIRICAL <- c(LIRICAL, "no")}
}

result <- cbind(info, LIRICAL)
write.csv(result, file=paste0("/work/data/phenotype_software_BK/results/LIRICAL_with_", data, ".csv"), row.names = F)


