

#CAN'T NOT RUN THIS SCRIPT USING NOHUP?

options(stringsAsFactors = F)
options('digits'=2)

data <- "DDD"; info <- read.csv("/work/software/phenotype_software/scripts/old/result_simplified-new.csv"); vcf_path <- "/work/data/phenotype_software_BK/DDD_dataset/data_selected"
#data <- "KMCS1"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS1_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF1"
#data <- "KMCS2"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS2_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF2"



for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  hpo_id <- info[i,2]
  hpo_id <- gsub(";", " ", hpo_id)
  system(paste0("docker run -it --rm -v ", vcf_path, "/_phen2gene_results:/code/out -t genomicslab/phen2gene -m ", hpo_id, " -out out/"))
  system(paste0("mv ", vcf_path, "/_phen2gene_results/output_file.associated_gene_list ", vcf_path, "/_phen2gene_results/", vcf_id, ".tsv"))
}



#Summary
all_files <- list.files(paste0(vcf_path, "/_phen2gene_results"))
all_tsv <- all_files[grep(".tsv", all_files)]
phen2gene <- c()
for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  tsv <- all_tsv[grep(vcf_id, all_tsv)]
  tsv <- read.delim2(paste0(vcf_path, "/_phen2gene_results/", tsv))
  if (gene %in% unique(tsv[,2])){
    phen2gene <- c(phen2gene, which(unique(tsv[,2])==gene))
  }
  else{phen2gene <- c(phen2gene, "no")}
}

result <- cbind(info, phen2gene)
write.csv(result, file=paste0("/work/data/phenotype_software_BK/results/phen2gene_with_", data, ".csv"), row.names = F)


