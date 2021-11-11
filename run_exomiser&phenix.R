options(stringsAsFactors = F)



#software <- "exomiser"
software <- "phenix"



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
               cd /work/software/phenotype_software/exomiser/exomiser-cli-12.1.0 && cp -f ./examples/template_", software, ".yml ./ && mv -f ./template_", software, ".yml ./temp.yml
               Rscript /work/software/phenotype_software/scripts/yml.R ./temp.yml $vcf ", hpo_id, " && 
               java -Xms2g -Xmx4g -jar exomiser-cli-12.1.0.jar --analysis ./temp.yml", sep = ""))
  system(paste0("mv ", vcf_path, "/*.genes.tsv ", vcf_path, "/", software, "_results/"))
}



#Summary
all_files <- list.files(paste0(vcf_path, "/", software, "_results/"))
all_tsv <- all_files[grep(".genes.tsv", all_files)]
Exomiser <- c()
for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  tsv <- all_tsv[grep(vcf_id, all_tsv)]
  tsv <- read.delim2(paste0(vcf_path, "/", software, "_results/", tsv))
  if (gene %in% tsv[,1]){
    Exomiser <- c(Exomiser, which(tsv[,1]==gene))
  }
  else{Exomiser <- c(Exomiser, "no")}
}

result <- cbind(info, Exomiser)
write.csv(result, file=paste0("/work/data/phenotype_software_BK/results/", software ,"_with_", data, ".csv"), row.names = F)


