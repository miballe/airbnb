setwd("~/Southampton/Term2/DataMining/GroupCoursework/Code")
training <- read_rds("training.rds")
df_all <- read_rds("df_all.rds")
# Final is model on test data, 'training' is model on training data, #df_all is dataset
train <- training$df 
train$targets <- as.factor(df_all[set == "train", "country_destination"]$country_destination)
for (i in 1:5) {
    train[,i] <- factor(as.character(train[,i]), levels = levels(train$targets))
}

# Targets shows the numbers of each target destination in the training set
total_observations <- df_all[set == "train", "country_destination"] %>% table

# We can see the number of targets predicted correctly up to each bracket. 
correct <- data.frame( V1 = (train$targets == train$V1))
correct$V2 <- (train$targets == train$V1 | train$targets == train$V2)
correct$V3 <- (train$targets == train$V1 | train$targets == train$V2 | train$targets == train$V3)
correct$V4 <- (train$targets == train$V1 | train$targets == train$V2 | train$targets == train$V3 | train$targets == train$V4)
correct$V5 <- (train$targets == train$V1 | train$targets == train$V2 | train$targets == train$V3 | train$targets == train$V4 | train$targets == train$V5)


# Table up the training set predictions
# Here we see that the model nearly universally predicts NDF and US in the top 2 places. As we know this will be correct 87% of the time it is reasonably accurate at this. 
# The model primarily predicts in order of frequency unless it isn't sure about something. NDF - US - OTHER - FR - IT
summary <- as.data.frame(sapply(train[,1:5], table))
percentage_correct <- round(sapply(correct, mean), digits = 2)
summary$total_observations <- total_observations
summary <- rbind(summary, c(percentage_correct*100,NA,NA))
rownames(summary)[13] <- "Percent correct" 

summary

X <- vector()
for (col in colnames(summary)[1:5]) {
    for (dest in levels(train$targets)) {
        index <- train$targets == dest
        X <- c(X, (sum(train$targets[index] == train[index, col]) / sum(index)))
    }    
}

Y <- matrix(X, nrow = 12)

# We can see that 97% of targets where present in the top 5, whereas 87% where in the top2. 
# This implies that the model was able to pick the top 2 with reasonable accuracy (87% of observations were NA or US) and also find which of the less popular destinations users may be likely to visit but was unable to assign high enough probabilities to this. 
summary(correct)
sapply(correct, mean)

# Here we can see that in the training set where US is predicted first only 1/2 of the values are correct. Equally only about half the total 
ii <- training$df$V1 == "US"
dest_US <- df_all[set == "train", "country_destination"][ii] %>% table

# Accuracy when predicting only NDF and US
# 0.83068
id <- df_all[set == "test", "id"]$id
ids <- as.vector(matrix(id, 1)[rep(1,5), ])
submission_file <- data.frame(id = ids, country = c("US", "NDF", "other", "FR", "IT"))
name <- paste0("./Submission_Files/null_hypothesis.csv")
write.table(submission_file, name, row.names = FALSE, quote = FALSE, sep = ",")

# GENERATE CONFUSION MATRIX OF NDF vs US

