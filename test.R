library(dplyr)
library(randomForest)
library(car)

# Example of body mass index on coronary heart disease
# Extract and harmonise data
a <- extract_instruments(2)
b <- extract_outcome_data(a$SNP, 7)
dat <- harmonise_data(a,b)

# Apply all MR methods
r <- mr_wrapper(dat)

# Load the rf object containing the trained models
load("rf.rdata")
# Update the results with mixture of experts
r <- mr_moe(r, rf)

# Now you can view the estimates, and see that they have 
# been sorted in order from most likely to least likely to 
# be accurate, based on MOE prediction
r[[1]]$estimates
