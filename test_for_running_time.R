options(stringsAsFactors = F)
test_vcf <- "/work/software/phenotype_software/scripts/old/test_for_running_time/NIST-hg001-7001-gatk.vcf"
test_hpo <- "HP:0000002;HP:0003020;HP:0006089;HP:0009023;HP:0012047"
outdir <- "/work/software/phenotype_software/scripts/old/test_for_running_time/"


#PhenIX
system.time({
  software <- "phenix"
  hpo_id <- test_hpo
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = "\\',\\'")
  hpo_id <- paste("[\\'", hpo_id, "\\']", sep = "")
  system(paste("vcf=", test_vcf, " &&
               cd /work/software/phenotype_software/exomiser/exomiser-cli-12.1.0 && cp -f ./examples/template_", software, ".yml ./ && mv -f ./template_", software, ".yml ./temp.yml
               Rscript /work/software/phenotype_software/scripts/yml.R ./temp.yml $vcf ", hpo_id, " && 
               java -Xms2g -Xmx4g -jar exomiser-cli-12.1.0.jar --analysis ./temp.yml", sep = ""))
})



#Exomiser
system.time({
  software <- "exomiser"
  hpo_id <- test_hpo
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = "\\',\\'")
  hpo_id <- paste("[\\'", hpo_id, "\\']", sep = "")
  system(paste("vcf=", test_vcf, " &&
               cd /work/software/phenotype_software/exomiser/exomiser-cli-12.1.0 && cp -f ./examples/template_", software, ".yml ./ && mv -f ./template_", software, ".yml ./temp.yml
               Rscript /work/software/phenotype_software/scripts/yml.R ./temp.yml $vcf ", hpo_id, " && 
               java -Xms2g -Xmx4g -jar exomiser-cli-12.1.0.jar --analysis ./temp.yml", sep = ""))
})



#DeepPVP
system.time({
  hpo_id <- test_hpo
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = ",")
  system(paste0("vcf=", test_vcf, " && vcftools --vcf $vcf --recode --max-maf 0.01 --out ", test_vcf, "_filtered.vcf"))
  system(paste0("vcf=", test_vcf, "_filtered.vcf.recode.vcf && 
               cd /NGSDATA/DeepPVP/phenomenet-vp-2.1 && bin/phenomenet-vp --python /usr/bin/python -f $vcf -p ", hpo_id))
})



#Xrare
#cp /work/software/phenotype_software/scripts/old/test_for_running_time/NIST-hg001-7001-gatk.vcf /work/data/phenotype_software_BK
#docker run -v /work/data/phenotype_software_BK:/work --name xrare_202105013-test -it --rm xrare-pub:2015
system.time({
  library(xrare)
  hpo_id <- "HP:0000002;HP:0003020;HP:0006089;HP:0009023;HP:0012047"
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = ",")
  hpo_id <- paste("'", hpo_id, "'", sep = "")
  dt <- xrare(vcffile="/work/NIST-hg001-7001-gatk.vcf", hpoid=hpo_id)
})



#AMELIE
system.time({
  hpo_id <- test_hpo
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = ",")
  hpo_id <- paste("'", hpo_id, "'", sep = "")
  system(paste("vcf=", test_vcf, " &&  
          /usr/bin/python3 /work/software/phenotype_software/scripts/API_amelie.py ", hpo_id, " $vcf", sep=""))
})



#LIRICAL
system.time({
  hpo_id <- test_hpo
  hpo_id <- unlist(strsplit(hpo_id, ";"))
  hpo_id <- paste(hpo_id, collapse = "\\',\\'")
  hpo_id <- paste("[\\'", hpo_id, "\\']", sep = "")
  system(paste("vcf=", test_vcf, " && 
               cd /work/software/phenotype_software/LIRICAL/LIRICAL && cp -f ./src/test/resources/yaml/hpo_and_vcf.yml ./ && mv -f ./hpo_and_vcf.yml ./temp.yml && 
               Rscript /work/software/phenotype_software/scripts/yml2.R ./temp.yml $vcf ", hpo_id, " && 
               java -jar ./target/LIRICAL.jar yaml -y ./temp.yml", sep = ""))
  
})



#Phenolyzer
system.time({
  hpo_id <- test_hpo
  hpo_id <- paste("'", hpo_id, "'", sep = "")
  system(paste0("cd /work/software/phenotype_software/HPO_only/phenolyzer && 
                perl ./disease_annotation.pl ", hpo_id, " -p -ph -logistic -out ", outdir, " -addon DB_DISGENET_GENE_DISEASE_SCORE,DB_GAD_GENE_DISEASE_SCORE -addon_weight 0.25"))
})



#HANRD
system.time({
  system("cd /work/software/phenotype_software/HPO_only/gcas && java -Xmx8096M -jar gcas.jar ./data/input/test.tsv")
})



#GADO
system.time({
  info <- "/work/software/phenotype_software/scripts/old/test_for_running_time/GADO/test.txt"
  system(paste0("java -jar /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/GADO.jar --mode PROCESS --output ", info, "_hpoProcessed.txt --caseHpo ", info, " --hpoOntology /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/database/hp.obo --hpoPredictionsInfo /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/database/hpo_predictions_info_01_02_2018.txt"))
  system(paste0("java -jar /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/GADO.jar --mode PRIORITIZE --output ", outdir, "/_GADO_results/ --caseHpoProcessed ", info, "_hpoProcessed.txt --genes /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/database/hpo_predictions_genes_01_02_2018.txt --hpoPredictions /work/software/phenotype_software/HPO_only/GadoCommandline-1.0.1/database/hpo_predictions_sigOnly_spiked_01_02_2018"))
})



#Phen2Gene
#test_hpo <- "HP:0000002;HP:0003020;HP:0006089;HP:0009023;HP:0012047"
#outdir <- "/work/software/phenotype_software/scripts/old/test_for_running_time/"
#system.time({
#  hpo_id <- test_hpo
#  hpo_id <- gsub(";", " ", hpo_id)
#  system(paste0("docker run -it --rm -v ", outdir, ":/code/out -t genomicslab/phen2gene -m ", hpo_id, " -out out/"))
#})








