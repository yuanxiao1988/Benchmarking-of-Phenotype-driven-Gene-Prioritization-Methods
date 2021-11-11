options(stringsAsFactors = F)
options('digits'=2)

data <- "DDD"; info <- read.csv("/work/software/phenotype_software/scripts/old/result_simplified-new.csv"); vcf_path <- "/work/data/phenotype_software_BK/DDD_dataset/data_selected"
#data <- "KMCS1"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS1_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF1"
#data <- "KMCS2"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS2_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF2"



for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  hpo_id <- info[i,2]
  hpo_id <- paste("'", hpo_id, "'", sep = "")
  system(paste0("cd /work/software/phenotype_software/HPO_only/phenolyzer && 
                perl ./disease_annotation.pl ", hpo_id, " -p -ph -logistic -out ", vcf_path, "/_phenolyzer_results/", vcf_id, " -addon DB_DISGENET_GENE_DISEASE_SCORE,DB_GAD_GENE_DISEASE_SCORE -addon_weight 0.25"
  ))
}



#Summary
all_files <- list.files(paste0(vcf_path, "/_phenolyzer_results"))
all_tsv <- all_files[grep(".final_gene_list", all_files)]
phenolyzer <- c()
for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  tsv <- all_tsv[grep(vcf_id, all_tsv)]
  tsv <- read.delim2(paste0(vcf_path, "/_phenolyzer_results/", tsv))
  if (gene %in% unique(tsv[,2])){
    phenolyzer <- c(phenolyzer, which(unique(tsv[,2])==gene))
  }
  else{phenolyzer <- c(phenolyzer, "no")}
}

result <- cbind(info, phenolyzer)
write.csv(result, file=paste0("/work/data/phenotype_software_BK/results/phenolyzer_with_", data, ".csv"), row.names = F)


