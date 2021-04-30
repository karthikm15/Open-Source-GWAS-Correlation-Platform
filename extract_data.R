library(TwoSampleMR)
ao = available_outcomes()
cancer_ids = c(
               'ieu-a-812', #Parkison's
               'ieu-b-7',
               'ukb-b-6548',
               'ieu-a-818',
               'finn-a-G6_PARKINSON_EXMORE',
               'ieu-a-824', #Alzheimers
               'ieu-a-297',
               'ieu-a-298',
               'finn-a-AD')

#'prot-a-1736', #leukemia
#'prot-a-235',
#'prot-a-1130',
#'prot-a-1737',
#'prot-a-63', #apoptosis
#'prot-a-236',
#'prot-a-64', 
#'prot-c-3412_7_1',
#'prot-a-1373',
ao_subset = ao[is.element(ao$id, cancer_ids),]

all_snps_associated = c()
for (id in cancer_ids) {
  print(id)
  associated_instruments = extract_instruments(id)
  all_snps_associated = c(all_snps_associated, associated_instruments$SNP)
}
all_snps_associated = unique(all_snps_associated)

all_snps_cancers = data.frame('SNP'=all_snps_associated)
for (id in cancer_ids) {
  cancer_name = as.character(ao[ao$id == id,'trait'])
  effect_of_snps = extract_outcome_data(all_snps_cancers$SNP, id)
  effect_of_snps = effect_of_snps[, c('SNP', 'beta.outcome', 'se.outcome', 'pval.outcome')] 
  names(effect_of_snps) = c('SNP', paste0('beta.', cancer_name), paste0('se.', cancer_name), paste0('pval.', cancer_name))
  all_snps_cancers = merge(all_snps_cancers, effect_of_snps, by='SNP', all.x = TRUE)
}
write.csv(all_snps_cancers, 'all_snps_cancers.csv', row.names = F, quote=F)
