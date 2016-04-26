library(stringr)

# load data
df_all <- readRDS("../Data/users.RDS") 

# replace missing values
df_all[is.na(df_all)] <- -1

# split date_account_created in year, month and day
dac = as.data.frame(str_split_fixed(df_all$date_account_created, '-', 3))
df_all['dac_year'] = dac[,1]
df_all['dac_month'] = dac[,2]
df_all['dac_day'] = dac[,3]
df_all = df_all[,-c(which(colnames(df_all) %in% c('date_account_created')))]

# split timestamp_first_active in year, month and day
df_all[,'tfa_year'] = substring(as.character(df_all[,'timestamp_first_active']), 1, 4)
df_all['tfa_month'] = substring(as.character(df_all['timestamp_first_active']), 5, 6)
df_all['tfa_day'] = substring(as.character(df_all['timestamp_first_active']), 7, 8)
df_all = df_all[,-c(which(colnames(df_all) %in% c('timestamp_first_active')))]

# Clean types for new variables
df_all$tfa_year <- as.factor(df_all$tfa_year)
#df_all$tfa_month <- as.factor(df_all$tfa_month)
#df_all$tfa_day <- as.factor(df_all$tfa_day)

# clean Age by removing values
df_all[df_all$age < 14 | df_all$age > 100,'age'] <- -1

saveRDS(df_all, "preprocessing_test.RDS")

# # one-hot-encoding features
# ohe_feats = c('gender', 'signup_method', 'signup_flow', 'language', 'affiliate_channel', 'affiliate_provider', 'first_affiliate_tracked', 'signup_app', 'first_device_type', 'first_browser')
# dummies <- dummyVars(~ gender + signup_method + signup_flow + language + affiliate_channel + affiliate_provider + first_affiliate_tracked + signup_app + first_device_type + first_browser, data = df_all)
# df_all_ohe <- as.data.frame(predict(dummies, newdata = df_all))
# df_all_combined <- cbind(df_all[,-c(which(colnames(df_all) %in% ohe_feats))],df_all_ohe)
# 
# # split train and test
# X = df_all_combined[df_all_combined$id %in% df_train$id,]
# y <- recode(labels$country_destination,"'NDF'=0; 'US'=1; 'other'=2; 'FR'=3; 'CA'=4; 'GB'=5; 'ES'=6; 'IT'=7; 'PT'=8; 'NL'=9; 'DE'=10; 'AU'=11")
# X_test = df_all_combined[df_all_combined$id %in% df_test$id,]