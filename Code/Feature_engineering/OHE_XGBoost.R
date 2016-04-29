# This R script is based on Sandro's python script, which produces a LB score of 0.8655
# This script should produce a LB score of 0.86547

# load libraries
library(xgboost)
library(readr)
library(stringr)
library(Matrix)
library(caret)
library(dplyr)
library(car)

set.seed(1)
# users_FE = readRDS(paste0(path,'users_FE.Rda'))
# path <- 'C:/Users/Manuel/Desktop/Southampton/Data_Mining/airbnb_project/'
# df_all = readRDS(paste0(path,'users_FE.Rda'))
df_all <- users_FE_NAsReplaced
df_test <- df_all[df_all$dataset == "test",]
# df_all <- users_FE1
# df_all <- read_rds("../Data/users_FE.RDa")

# Convert all factors into characters (so NAs can be replaced)
i <- sapply(df_all, is.factor)
df_all[i] <- lapply(df_all[i], as.character)
# Ensure there are no NA values (makes sparse matrix method fail)
df_all[is.na(df_all)] <- 'NA'

# turn them into factors again: problems with sparse function: missing first value of every field
j <- sapply(df_all, is.character)
df_all[j] <- lapply(df_all[j], as.factor)



# Extract dataset index and output labels from data
labels <- df_all$country_destination
set <- df_all$dataset
df_all <- df_all %>% select(-country_destination, -dataset)




# # One - hot encoding 
sparse_dat <- sparse.model.matrix(~ ., data = df_all[,-1], 
             contrasts.arg = lapply(df_all[,colnames(df_all)[j][-1]], contrasts, contrasts=FALSE))
#  Comment: need to use contrast option, if not the function misses the first value of each field
#           translating in missing variables after OHE.



 

# df_all_matrix <- as.matrix(df_all)
# sparse_dat <- Matrix(df_all_matrix, sparse = TRUE)
# sparse_dat <- df_all_matrix
# Split into training and test set
sparse_tr <- sparse_dat[set == "train",]
sparse_ts <- sparse_dat[set == "test",]



#############################################################

# split train and test
y <- recode(labels,"'NDF'=0; 'US'=1; 'other'=2; 'FR'=3; 'CA'=4; 'GB'=5; 'ES'=6; 'IT'=7; 'PT'=8; 'NL'=9; 'DE'=10; 'AU'=11")

# train xgboost
xgb <- xgboost(data = sparse_tr, #data.matrix(X[,-1]), 
               label = y[set == "train"], 
               eta = 0.1,
               max_depth = 9, 
               nround=25, 
               subsample = 0.5,
               colsample_bytree = 0.5,
               eval_metric = "merror",
               objective = "multi:softprob",
               num_class = 12,
               nthread = 3
)

# library(Ckmeans.1d.dp)
# importanceTable <- xgb.importance(sparse_tr@Dimnames[[2]], model = xgb)
# xgb.plot.importance(importanceTable)
# importanceTable[1:30,]$Feature


source("Generate_submission.R")
test <- submission(xgb, sparse_ts, df_test$id, "temp4")
