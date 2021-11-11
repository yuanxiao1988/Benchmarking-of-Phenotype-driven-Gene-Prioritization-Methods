options(stringsAsFactors = F)
library(rjson)

data <- "DDD"; info <- read.csv("/work/software/phenotype_software/scripts/old/result_simplified-new.csv"); vcf_path <- "/work/data/phenotype_software_BK/DDD_dataset/data_selected"
#data <- "KMCS1"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS1_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF1"
#data <- "KMCS2"; info <- read.csv("/work/software/phenotype_software/scripts/old/KMCS2_sample_info.csv"); vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF2"



all_gene <- read.delim2("/work/software/phenotype_software/scripts/old/hgnc-search-1617963799278.txt", header = T); all_gene <- paste0(all_gene[, 2], collapse = ","); all_gene <- paste0("'", all_gene, "'")
amelie_API <- function(vcf_path, vcf_id, hpo_id, all_gene_list){system(paste("/usr/bin/python3 /work/software/phenotype_software/scripts/API_amelie_HPO_only.py ", hpo_id, " ", all_gene_list, " >", vcf_path, "/_amelie_results/", vcf_id, ".txt", sep=""))}



for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  hpo_id <- info[i,2]
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = ",")
  hpo_id <- paste("'", hpo_id, "'", sep = "") #'HP:0001156,HP:0001363,HP:0011304,HP:0010055'
  
  try(amelie_API(vcf_path, vcf_id, hpo_id, all_gene), silent = T)
  API_running_result <- class(try(result <- fromJSON(file=paste(vcf_path, "/_amelie_results/", vcf_id, ".txt", sep="")), silent = T))
  cat(paste0("\n---->", API_running_result, "\n", "\n"))
  
  while (API_running_result == "try-error") {
    try(amelie_API(vcf_path, vcf_id, hpo_id, all_gene), silent = T)
    API_running_result <- class(try(result <- fromJSON(file=paste(vcf_path, "/_amelie_results/", vcf_id, ".txt", sep="")), silent = T))
    cat(paste0("\n---->", API_running_result, "\n", "\n"))
  }
  
  gene <- c()
  pmid <- c()
  for (i in 1:length(result)){
    gene <- c(gene, result[[i]][[1]])
    id <- c()
    if (length(result[[i]][[2]]) != 0){
      for (j in 1:length(result[[i]][[2]])){
        temp <- result[[i]][[2]][[j]][[2]]
        id <- c(id, temp)
        id <- paste(id, collapse = ",")
      }
      pmid <- c(pmid, id)
    }
    else{pmid <- c(pmid, "NA")}
  }
  
  all <- cbind(gene, pmid)
  write.table(all, file = paste(vcf_path, "/_amelie_results/", vcf_id, ".tsv", sep=""), row.names = F, quote = F, sep = "\t")
}



Summary
all_files <- list.files(paste0(vcf_path, "/_amelie_results"))
all_tsv <- all_files[grep(".tsv", all_files)]
amelie <- c()
for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  tsv <- all_tsv[grep(vcf_id, all_tsv)]
  tsv <- read.delim2(paste0(vcf_path, "/_amelie_results/", tsv))
  if (gene %in% unique(tsv[,1])){
    amelie <- c(amelie, which(unique(tsv[,1])==gene))
  }
  else{amelie <- c(amelie, "no")}
}

result <- cbind(info, amelie)
write.csv(result, file=paste0("/work/data/phenotype_software_BK/results/_amelie_with_", data, ".csv"), row.names = F)


