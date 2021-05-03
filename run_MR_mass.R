library(TwoSampleMR)
library(dplyr)
setwd('/Users/adityamittal/Documents/FocusHackathon/')
getwd()
ao = available_outcomes()
# Load the downloaded RData object. This loads the rf object
load("./store/rf.rdata")

# outcomes = c( 'prot-a-1868', 'prot-a-235', 'prot-a-1130', 'prot-a-1736', 'prot-a-1737')
# exposures = c('prot-a-569', 'prot-a-532', 'prot-c-4500_50_2', 'prot-c-2475_1_3', 'prot-c-2966_65_2', 'prot-a-1652')

# values <- read.csv('MRBASE.csv')x
# exposures = as.list(values$id)
exposures = as.list(ao$id)
outcomes = c('ukb-d-C_LYMPHOMA')

for (exposure in exposures) {
  for (outcome in outcomes) {
    print(paste(outcome, exposure))
    if (file.exists(paste0("RES_MOE/",exposure,"_", outcome, ".csv"))) {
      next
    }
    if (file.exists(paste0("RES_MOE/",exposure,"_", outcome, ".csv"))){
      variants_harmonised = read.csv(paste0('RES_MOE/', exposure,"_", outcome, "_harmonised.csv"), stringsAsFactors=F)
    } else {
      variants_exposure = extract_instruments(exposure)
      print("HERE")
      variants_outcome = extract_outcome_data(variants_exposure$SNP, outcome)
      if (is.null(variants_outcome)){
        next
      }
      variants_harmonised = harmonise_data(variants_exposure, variants_outcome)
      # write.csv(variants_harmonised, file=paste0('RES_MOE/', exposure,"_", outcome, "_harmonised.csv"), row.names=F)
    }
    if (nrow(variants_harmonised) == 0 || (is.null(variants_harmonised))){
      next
    }
    print("HELLO")
    result = tryCatch({
      mr_wrapper(variants_harmonised)
    }, error = function(error_condition) {
      "fail"
    })
    if (result == "fail") {
      next
    }
    res_moe = tryCatch({
      mr_moe(result,rf)
    }, error = function(error_condition) {
      "fail"
    })
    if (res_moe == "fail") {
      next
    }
    print("ONCE MORE")
    res_moe_df = tryCatch({
      as.data.frame(res_moe[[1]]$estimates)
    }, error = function(error_condition) {
      "fail"
    })
    if (res_moe_df == "fail") {
      next
    }
    write.csv(x = res_moe_df, file = paste0("RES_MOE/",exposure,"_", outcome, ".csv"), row.names = F)
    # result_plot = mr(variants_harmonised)
    # p1 <- mr_scatter_plot(result_plot, variants_harmonised)
    # png(file=paste0("PLOT/",exposure,"_", outcome, ".png"))
    #print(p1)
    # dev.off()
  }
}
