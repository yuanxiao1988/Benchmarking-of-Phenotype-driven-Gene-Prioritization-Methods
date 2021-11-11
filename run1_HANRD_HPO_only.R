#cd /work/software/phenotype_software/HPO_only/gcas && nohup java -Xmx8096M -jar gcas.jar ./data/input/DDD.tsv &
#cd /work/software/phenotype_software/HPO_only/gcas && nohup java -Xmx8096M -jar gcas.jar ./data/input/KMCS1.tsv &
#cd /work/software/phenotype_software/HPO_only/gcas && nohup java -Xmx8096M -jar gcas.jar ./data/input/KMCS2.tsv &



options(stringsAsFactors = F)
options('digits'=2)
library(org.Hs.eg.db)

data <- "DDD"; info <- read.csv("/work/software/phenotype_software/scripts/old/result_simplified-new.csv"); vcf_path <- "/work/data/phenotype_software_BK/DDD_dataset/data_selected"
#data <- "KMCS1"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS1_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF1"
#data <- "KMCS2"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS2_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF2"



#Summary
summary_file <- read.delim2(paste0("/work/software/phenotype_software/HPO_only/gcas/data/output/", data, "_genes.out"), header = F, sep = "\t")
gene_symbol <- sapply(summary_file[, 6], function(x){unlist(strsplit(x, ","))[1]}, USE.NAMES=F)
summary_file <- cbind(summary_file[, 1:5], gene_symbol)

hanrd <- c()
for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  summary_file_selected <- summary_file[which(summary_file[, 1]==vcf_id), ]

  if (gene %in% summary_file_selected[, 6]){
    hanrd <- c(hanrd, which(summary_file_selected[, 6]==gene))
  }
  else{hanrd <- c(hanrd, "no")}
}

result <- cbind(info, hanrd)
write.csv(result, file=paste0("/work/data/phenotype_software_BK/results/hanrd_with_", data, ".csv"), row.names = F)


