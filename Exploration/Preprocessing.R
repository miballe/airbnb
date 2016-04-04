# Libraries
require(dplyr)
require(ggplot2)
require(tidyr)

# Read in the data
# Assumes the data files from the competition are in a subirectory of the working directory labelled "Data".
path <- "../Data/"
age_gender_bkts <- read.csv(paste0(path,"age_gender_bkts.csv"))
countries <- read.csv(paste0(path,"countries.csv"))
sessions <- read.csv(paste0(path,"sessions.csv"))
test_users <- read.csv(paste0(path,"test_users.csv"))
train_users_2 <- read.csv(paste0(path,"train_users_2.csv"))
sample_submission <- read.csv(paste0(path, "sample_submission_NDF.csv"))

# Define a feature dictating if the user travelled abroad or internally or not at all.
index <- train_users_2$country_destination %in% c("NDF", "US")
train_users_2$abroad <- factor("EXT", levels = c("NDF", "US", "EXT"))
train_users_2$abroad[index] <- factor(train_users_2$country_destination[index])

# Define a binary feature out of language dictating in the user speaks english or not. 
train_users_2$en <- factor("other", levels = c("en", "other"))
index <- train_users_2$language %in% "en"
train_users_2$en[index] <- train_users_2$language[index]

# Label the training data for which we have session data (~1/3)
train_users_2$sessions <- train_users_2$id %in% sessions$user_id

# Define a feature for level of completion of online form