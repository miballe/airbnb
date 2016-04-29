library(dplyr)
library(readr)
library(plyr)
library(tidyr)
library(readr)
library(stringr)
library(caret)
library(car)

path <- 'C:/Users/Manuel/Desktop/Southampton/Data_Mining/airbnb_project/'

train <- read.csv(paste0(path,"train_users_2.csv"),header=T, na.strings = c('','NA'), stringsAsFactors = F)
#train$timestamp_first_active <- as.character(train$timestamp_first_active)

# test = read_csv(paste0(path,"test_users.csv"),
#                    col_types = cols(
#                      timestamp_first_active = col_character()))

test <- read.csv(paste0(path,"test_users.csv"),header=T, na.strings = c('','NA'), stringsAsFactors = F)
#test$timestamp_first_active <- as.character(test$timestamp_first_active)
test$country_destination <- NA

# labels = train[, c('id', 'country_destination')]

# age_gender_bkts <- fread(paste0(path,"age_gender_bkts.csv"), data.table=F)
# countries <- fread(paste0(path,"countries.csv"), data.table=F)
# sample_submission_NDF <- fread(paste0(path,"sample_submission_NDF.csv"), data.table=F)
# sessions <- fread(paste0(path,"sessions.csv"), data.table=F)


train$dataset <- "train"
test$dataset <- "test"
users <- rbind(train, test)

users$date_account_created <- as.Date(users$date_account_created)
users$date_first_booking <- as.Date(users$date_first_booking)
users$gender <- ifelse(users$gender == '-unknown-', NA, users$gender)
users$timestamp_first_active <- as.character(users$timestamp_first_active)


users <- users %>%
  dplyr::mutate(
    age_cln = ifelse(age >= 1920, 2015 - age, age),
    age_cln2 = ifelse(age_cln < 14 | age_cln > 100, -1, age_cln),
    age_bucket = cut(age, breaks = c(min(age_cln, na.rm =T), 4, 9, 14, 19, 24,
                                     29, 34, 39, 44, 49, 54,
                                     59, 64, 69, 74, 79, 84,
                                     89, 94, 99, max(age_cln, na.rm =T)
    )),
    age_bucket = mapvalues(age_bucket,
                           from=c("(1,4]", "(4,9]", "(9,14]", "(14,19]",
                                  "(19,24]", "(24,29]", "(29,34]", "(34,39]",
                                  "(39,44]", "(44,49]", "(49,54]", "(54,59]",
                                  "(59,64]", "(64,69]", "(69,74]", "(74,79]",
                                  "(79,84]", "(84,89]", "(89,94]", "(94,99]", "(99,150]"),
                           to=c("0-4", "5-9", "10-14", "15-19",
                                "20-24", "25-29", "30-34", "35-39",
                                "40-44", "45-49", "50-54", "55-59",
                                "60-64", "65-69", "70-74", "75-79",
                                "80-84", "85-89", "90-94", "95-99", "100+"))
  )


########################################################################################################################################


users2 <- users %>%
  separate(date_account_created, into = c("dac_year", "dac_month", "dac_day"), sep = "-", remove=FALSE) %>%
  dplyr::mutate(
    dac_yearmonth = paste0(dac_year, dac_month),
    dac_yearmonthday = as.numeric(paste0(dac_year, dac_month, dac_day)),
    dac_week = as.numeric(format(date_account_created, "%U")),
    dac_yearmonthweek = as.numeric(paste0(dac_year, dac_month, formatC(dac_week, width=2, flag="0"))),
    dac_yearweek = as.numeric(paste0(dac_year, formatC(dac_week, width=2, flag="0"))),
    tfa_year = str_sub(timestamp_first_active, 1, 4),
    tfa_month = str_sub(timestamp_first_active, 5, 6),
    tfa_day = str_sub(timestamp_first_active, 7, 8),
    tfa_yearmonth = str_sub(timestamp_first_active, 1, 6),
    tfa_yearmonthday = as.numeric(str_sub(timestamp_first_active, 1, 8)),
    tfa_date = as.Date(paste(tfa_year, tfa_month, tfa_day, sep="-")),
    tfa_week = as.numeric(format(tfa_date, "%U")),
    tfa_yearmonthweek = as.numeric(paste0(tfa_year, tfa_month, formatC(tfa_week, width=2, flag="0"))),
    tfa_yearweek = as.numeric(paste0(tfa_year, formatC(tfa_week, width=2, flag="0"))),
    lag = as.numeric(date_account_created - tfa_date),
    NAs_profile = is.na(gender)+is.na(age),
    age_NAs = (is.na(age))*1,
    gender_NAs = (is.na(gender))*1
  )


num_feats <- c(
  'age_cln2',
  'age_bucket',
  "dac_year",
  "dac_month",
  "dac_day",
  "dac_week",
  'dac_yearweek',
  "dac_yearmonth",
  "dac_yearmonthday",
  "dac_yearmonthweek",
  "tfa_year",
  "tfa_month",
  "tfa_day",
  "tfa_week",
  'tfa_yearweek',
  "tfa_yearmonth",
  "tfa_yearmonthday",
  "tfa_yearmonthweek",
  'lag',
  'NAs_profile',
  'age_NAs',
  'gender_NAs'
)

ohe_feats = c('gender', 'signup_method', 'signup_flow', 'language', 'affiliate_channel', 'affiliate_provider', 'first_affiliate_tracked', 'signup_app', 'first_device_type', 'first_browser')

# dataset adter preprocessing and first feature engineering
users_FE <- users2[c('id', num_feats, ohe_feats, 'country_destination', 'dataset')]
names(users_FE)[names(users_FE)=="age_cln2"] <- "age"

# delete age variable (doesn't seem relevant after applying xgb.importance function)



# convert NA values to string 'NA': new variable when OHE
#colnames(df_all_combined)[colSums(is.na(df_all_combined)) > 0]

# age_cln2, age_bucket, gender, first_affiliate_tracked
users_FE_NAsReplaced <- users_FE

# need to convert this one to character, not allowed to generate new levels in factors
users_FE_NAsReplaced$age_bucket <- as.character(users_FE_NAsReplaced$age_bucket)

# convert NA values in strings 'NA' (new variable when one-hot encoding)
users_FE_NAsReplaced[is.na(users_FE_NAsReplaced)] <- 'NA'

# ########################################################################################################################################
# ########################################################################################################################################
# ########################################################################################################################################

users_FE_NAsReplaced$dac_year <- as.numeric(users_FE_NAsReplaced$dac_year)
users_FE_NAsReplaced$dac_month <- as.numeric(users_FE_NAsReplaced$dac_month)
users_FE_NAsReplaced$dac_day <- as.numeric(users_FE_NAsReplaced$dac_day)
#users_FE_NAsReplaced$dac_yearmonth <- strtoi(users_FE_NAsReplaced$dac_yearmonth)
# users_FE_NAsReplaced$tfa_year <- strtoi(users_FE_NAsReplaced$tfa_year)
# users_FE_NAsReplaced$tfa_month <- strtoi(users_FE_NAsReplaced$tfa_month)
# users_FE_NAsReplaced$tfa_day <- strtoi(users_FE_NAsReplaced$tfa_day)



######## OHE. output dataframe (for Olivia & Nicola)

#users_FE_factors <- as.data.frame(users_FE, stringsAsFactors = T)
ohe_feats = c('gender', 'signup_method', 'signup_flow', 'language', 'affiliate_channel', 'affiliate_provider', 'first_affiliate_tracked', 'signup_app', 'first_device_type', 'first_browser', 'dac_yearmonth', 'tfa_year', 'tfa_month', 'tfa_day', 'tfa_yearmonth', 'age', 'age_bucket') # 'dac_year', 'dac_month', 'dac_day')
dummies <- dummyVars(~ gender + signup_method + signup_flow + language + affiliate_channel + affiliate_provider + first_affiliate_tracked + signup_app + first_device_type + first_browser + dac_yearmonth + tfa_year + tfa_month + tfa_day + tfa_yearmonth + age + age_bucket, data = users_FE_NAsReplaced)
df_all_ohe <- as.data.frame(predict(dummies, newdata = users_FE_NAsReplaced))
users_FE_dataframe <- cbind(users_FE_NAsReplaced[,-c(which(colnames(users_FE_NAsReplaced) %in% ohe_feats))],df_all_ohe)


saveRDS(users_FE_dataframe, file= paste0(path,'users_FE_dataframe.Rda'))
write.csv(users_FE_dataframe, file = paste0(path,'users_FE_dataframe.csv'))





setdiff(list(names(users_FE_dataframe)),sparse_dat@Dimnames[2])

intersect(list(names(users_FE_dataframe)),sparse_dat@Dimnames[2])






for (i in 1:length(c(do.call("cbind",sparse_dat@Dimnames[2])))) {
  vectorNames_dataframe <- ifelse(names(users_FE_dataframe) == c(do.call("cbind",sparse_dat@Dimnames[2]))[i], T, F)
}
names(users_FE_dataframe)[vectorNames]

for (i in 1:length(names(users_FE_dataframe))) {
  vectorNames_sparse <- ifelse(c(do.call("cbind",sparse_dat@Dimnames[2])) == names(users_FE_dataframe)[i], T, F)
}
c(do.call("cbind",sparse_dat@Dimnames[2]))[vectorNames]




























# 
# ########################################################################################################################################
# 
# # Explore different feature engineering (one-hot of numeric variables like day, month or week) and test
# # results applying XGBoost
# 
# # TODO: one-hot encode numeric variables and test
# 
# ohe_feats3 = c('age', 'age_bucket')  # 'dac_month', 'dac_day', 'dac_week', 
# dummies3 <- dummyVars(~ age + age_bucket, data = users_FE_2)
# df_all_ohe3 <- as.data.frame(predict(dummies3, newdata = users_FE_2))
# users_FE_3 <- cbind(users_FE_2[,-c(which(colnames(users_FE_2) %in% ohe_feats3))],df_all_ohe3)
# 
# 
# saveRDS(users_FE_3, file= paste0(path,'users_FE_3.Rda'))
# write.csv(users_FE_3, file = paste0(path,'users_FE_3.csv'))
# 
# 
# 
# ########################################################################################################################################
# 
# users_FE_3$dac_week <- as.character(users_FE_3$dac_week)
# 
# ohe_feats4 = c('dac_month', 'dac_day', 'dac_week')
# dummies4 <- dummyVars(~ dac_month + dac_day + dac_week, data = users_FE_3)
# df_all_ohe4 <- as.data.frame(predict(dummies4, newdata = users_FE_3))
# users_FE_4 <- cbind(users_FE_3[,-c(which(colnames(users_FE_3) %in% ohe_feats4))],df_all_ohe4)
# 
# 
# saveRDS(users_FE_4, file= paste0(path,'users_FE_4.Rda'))
# write.csv(users_FE_4, file = paste0(path,'users_FE_4.csv'))
# 

############################################################################################################
########################################################################################################################################
#    ONE-HOT ENCODING



# 
# ## turn characters into factors (one by one??)
# 
# users_FE_factors$gender <- as.factor(users_FE_factors$gender)
# users_FE_factors$signup_method <- as.factor(users_FE_factors$signup_method)
# users_FE_factors$language <- as.factor(users_FE_factors$language)
# users_FE_factors$signup_app <- as.factor(users_FE_factors$signup_app)
# users_FE_factors$first_device_type <- as.factor(users_FE_factors$first_device_type)
# users_FE_factors$first_browser <- as.factor(users_FE_factors$first_browser)
# 
# 
# # ONE HOT ENCODING
# 
# # library(Matrix)
# 
# # sparse_matrix <- sparse.model.matrix(country_destination~.-1, data = users_FE_factors)
# # head(sparse_matrix)
# # 
# # 
# #prueba <- fac2sparse(users_FE_factors$gender)
# 
# 
# 



# ########################################################################################################################################
# ########################################################################################################################################
# ########################################################################################################################################
#########################################################################################################
#########################################################################################################
#   OHE using sparse.model.matrix
# 
# users_FE1 <- users_FE
# users_FE1$age <- as.character(users_FE1$age)
# saveRDS(users_FE1, file= paste0(path,'users_FE1.Rda'))
# 





users_FE2 <- users_FE
users_FE2$dac_week <- as.character(users_FE2$dac_week)
users_FE2$tfa_week <- as.character(users_FE2$tfa_week)
saveRDS(users_FE2, file= paste0(path,'users_FE2.Rda'))

users_FE3 <- users_FE2
users_FE3$signup_flow <- as.character(users_FE3$signup_flow)
saveRDS(users_FE3, file= paste0(path,'users_FE3.Rda'))

users_FE4 <- users_FE2
users_FE4$signup_flow <- as.character(users_FE4$signup_flow)
saveRDS(users_FE4, file= paste0(path,'users_FE4.Rda'))
