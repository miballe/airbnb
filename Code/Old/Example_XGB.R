# This R script is based on Sandro's python script, which produces a LB score of 0.8655
# This script should produce a LB score of 0.86547

# load libraries
library(xgboost)
library(readr)
library(stringr)
library(Matrix)
library(caret)
library(car)

set.seed(1)

# load data
df_train = read_csv("../Data/train_users_2.csv")
df_test = read_csv("../Data/test_users.csv")
labels = df_train['country_destination']
df_train = df_train[-grep('country_destination', colnames(df_train))]

# combine train and test data
df_all = rbind(df_train,df_test)
# remove date_first_booking
df_all = df_all[-c(which(colnames(df_all) %in% c('date_first_booking')))]
# replace missing values
df_all[is.na(df_all)] <- -1

# split date_account_created in year, month and day
dac = as.data.frame(str_split_fixed(df_all$date_account_created, '-', 3))
df_all['dac_year'] = dac[,1]
df_all['dac_month'] = dac[,2]
df_all['dac_day'] = dac[,3]
df_all = df_all[,-c(which(colnames(df_all) %in% c('date_account_created')))]

# split timestamp_first_active in year, month and day
df_all['tfa_year'] = substring(as.character(df_all$timestamp_first_active), 1, 4)
df_all['tfa_month'] = substring(as.character(df_all$timestamp_first_active), 5, 6)
df_all['tfa_day'] = substring(as.character(df_all$timestamp_first_active), 7, 8)
df_all = df_all[,-c(which(colnames(df_all) %in% c('timestamp_first_active')))]

# clean Age by removing values
df_all[df_all$age < 14 | df_all$age > 100,'age'] <- -1

#############################################################

# One-hot encoding  
# https://cran.r-project.org/web/packages/xgboost/vignettes/discoverYourData.html
sparse_dat <- sparse.model.matrix( ~ . -1, data = df_all[,-1])

# Find the training set
sparse_tr <- sparse_dat[df_all$id %in% df_train$id,]
sparse_ts <- sparse_dat[df_all$id %in% df_test$id,]
#############################################################

# split train and test
y <- recode(labels$country_destination,"'NDF'=0; 'US'=1; 'other'=2; 'FR'=3; 'CA'=4; 'GB'=5; 'ES'=6; 'IT'=7; 'PT'=8; 'NL'=9; 'DE'=10; 'AU'=11")

# train xgboost
xgb <- xgboost(data = sparse_tr, #data.matrix(X[,-1]), 
               label = y, 
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

source("Generate_submission.R")
test <- submission(xgb, sparse_ts, df_test$id, "temp")
