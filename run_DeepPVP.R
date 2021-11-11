options(stringsAsFactors = F)
options('digits'=2)
library(org.Hs.eg.db)

data <- "DDD"; info <- read.csv("/work/software/phenotype_software/scripts/old/result_simplified-new.csv"); vcf_path <- "/work/data/phenotype_software_BK/DDD_dataset/data_selected"
#data <- "KMCS1"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS1_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF1"
#data <- "KMCS2"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS2_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF2"
all_gene <- read.delim2("/work/software/phenotype_software/scripts/old/hgnc-search-1617963799278.txt", header = T); all_gene <- all_gene[, 2]


#KMCS VCF pre-processing
#for (i in 1:dim(info)[1]){
#  vcf_id <- info[i,3]
#  system(paste0("vcf=`ls -1 ", vcf_path, "/*", vcf_id, "*` && vcftools --vcf $vcf --recode --max-maf 0.01 --out ", vcf_path, "/deeppvp_results/", vcf_id, "_filtered.vcf"))
#}



#DDD VCF pre-processing
#for (i in 1:dim(info)[1]){
#  vcf_id <- info[i,3]
#  system(paste0("vcf=`ls -1 ", vcf_path, "/*", vcf_id, "*` && zcat $vcf | grep \"^#\" > ", vcf_path, "/deeppvp_results/", vcf_id, ".vcf && zcat $vcf | grep \"GT:\" >> ", vcf_path, "/deeppvp_results/", vcf_id, ".vcf && vcftools --vcf ", vcf_path, "/deeppvp_results/", vcf_id, ".vcf --recode --max-maf 0.01 --out ", vcf_path, "/deeppvp_results/", vcf_id, "_filtered.vcf"))
#}



for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  hpo_id <- info[i,2]
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = ",")
  system(paste0("vcf=`ls -1 ", vcf_path, "/deeppvp_results/", vcf_id, "_filtered.vcf.recode.vcf` && 
               cd /NGSDATA/DeepPVP/phenomenet-vp-2.1 && bin/phenomenet-vp -f $vcf -p ", hpo_id))
}



#Summary
all_files <- list.files(paste0(vcf_path, "/deeppvp_results"))
all_tsv <- all_files[grep(".res", all_files)]
deeppvp <- c()
for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  tsv <- all_tsv[grep(vcf_id, all_tsv)]
  tsv <- read.delim2(paste0(vcf_path, "/deeppvp_results/", tsv))
  
  
  
  if (gene %in% intersect(unique(tsv[,6]), all_gene)){
    deeppvp <- c(deeppvp, which(intersect(unique(tsv[,6]), all_gene)==gene))
  }
  else{deeppvp <- c(deeppvp, "no")}
}

result <- cbind(info, deeppvp)
write.csv(result, file=paste0("/work/data/phenotype_software_BK/results/deeppvp_with_", data, ".csv"), row.names = F)


