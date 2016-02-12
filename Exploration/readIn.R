options(stringsAsFactors = TRUE)
path <- "../Data/"
age_gender_bkts <- read.csv(paste0(path,"age_gender_bkts.csv"))
countries <- read.csv(paste0(path,"countries.csv"))
sessions <- read.csv(paste0(path,"sessions.csv"))
test_users <- read.csv(paste0(path,"test_users.csv"))
train_users_2 <- read.csv(paste0(path,"train_users_2.csv"))
sample_submission <- read.csv(paste0(path, "sample_submission_NDF.csv"))
rm(path)
