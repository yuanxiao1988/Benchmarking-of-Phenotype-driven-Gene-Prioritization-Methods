options(stringsAsFactors = F)

#total_cases <- info[, c(3, 2)]
#for (i in 1:dim(total_cases)[1]){
#  temp <- paste0(total_cases[i, 1], "\t", gsub(";", "\t", total_cases[i, 2]))
#  write.table(temp, "/work/software/phenotype_software/scripts/old/____________.txt", quote = F, row.names = F, col.names = F, append = TRUE)
#}



data <- "DDD"; info <- "/work/software/phenotype_software/scripts/old/result_simplified-new.txt"; vcf_path <- "/work/data/phenotype_software_BK/DDD_dataset/data_selected"
#data <- "KMCS1"; info <- "/work/software/phenotype_software/scripts/old/KMCS1_sample_info.txt"; vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF1"
#data <- "KMCS2"; info <- "/work/software/phenotype_software/scripts/old/KMCS2_sample_info.txt"; vcf_path <- "/work/data/phenotype_software_BK/KMCS_dataset/VCF2"



#system(paste0("java -jar /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/GADO.jar --mode PROCESS --output ", info, "_hpoProcessed.txt --caseHpo ", info, " --hpoOntology /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/database/hp.obo --hpoPredictionsInfo /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/database/hpo_predictions_info_01_02_2018.txt"))
#system(paste0("java -jar /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/GADO.jar --mode PRIORITIZE --output ", vcf_path, "/_GADO_results/ --caseHpoProcessed ", info, "_hpoProcessed.txt --genes /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/database/hpo_predictions_genes_01_02_2018.txt --hpoPredictions /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/database/hpo_predictions_sigOnly_spiked_01_02_2018"))



#Summary
all_files <- list.files(paste0(vcf_path, "/_GADO_results"))
all_files <- all_files[-grep("samples.txt", all_files)]
all_tsv <- all_files[grep(".txt", all_files)]
GADO <- c()

info <- read.csv(gsub("txt", "csv", info))

for (i in 1:dim(info)[1]){
  vcf_id <- info[i,3]
  gene <- info[i,5]
  tsv <- all_tsv[grep(vcf_id, all_tsv)]
  tsv <- read.delim2(paste0(vcf_path, "/_GADO_results/", tsv), sep = "\t")
  if (gene %in% unique(tsv[,2])){
    GADO <- c(GADO, which(unique(tsv[,2])==gene))
  }
  else{GADO <- c(GADO, "no")}
}

result <- cbind(info, GADO)
write.csv(result, file=paste0("/work/data/phenotype_software_BK/results/GADO_with_", data, ".csv"), row.names = F)


