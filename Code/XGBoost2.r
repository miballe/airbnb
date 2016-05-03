
# Libraries
library(xgboost)
library(dplyr)
library(Matrix)
library(data.table)
library(Ckmeans.1d.dp)
library(e1071)
library(caret)
library(car)
library(readr)

# Set Seed
set.seed(1066)

NAME <- "BASIC_2_05" # Name of Run (used for save file names)
DATAPATH <- "../Data/users_FE_notOHE.RDa" # Path to preprocessed data
COMPUTE_IMPORTANCE <- TRUE # Toggle computing importance or not because it is computationally expensive

# Read data
df_all <- read_rds("../Data/users_FE.RDa")

# Convert all factors into characters (so NAs can be replaced)
i <- sapply(df_all, is.factor)
df_all[i] <- lapply(df_all[i], as.character)
# Ensure there are no NA values (makes sparse matrix method fail)
df_all[is.na(df_all)] <- -1

# Extract dataset index and output labels from data
labels <- df_all$country_destination
set <- df_all$dataset

# Remove unwanted features if present
features_rm <- colnames(df_all) %in% c("id", "dataset", "first_browser", "age_cln", "age_cln2", "date_first_booking, X")
dat <- df_all[, !features_rm] %>%
    data.table(keep.rownames = F)

# One - hot encoding 
sparse_dat <- suppressWarnings( # Suppress warnings used to prevent warning messages about factor conversion
    sparse.model.matrix(country_destination ~.-1, data = dat)
)

# Split into training and test set
sparse_tr <- sparse_dat[set == "train",]
sparse_ts <- sparse_dat[set == "test",]

# XGB requires labels to be numeric indexed at 0. 
y <- recode(labels,"'NDF'=0; 'US'=1; 'other'=2; 'FR'=3; 'CA'=4; 'GB'=5; 'ES'=6; 'IT'=7; 'PT'=8; 'NL'=9; 'DE'=10; 'AU'=11")

# train xgboost
model <- xgboost(data = sparse_tr, #data.matrix(X[,-1]), 
               label = y[set == "train"], 
               eta = 0.1,
               max_depth = 4, 
               nround=25, 
               subsample = 0.5,
               colsample_bytree = 0.5,
               eval_metric = "merror",
               objective = "multi:softprob",
               num_class = 12,
               nthread = 3
)

# Plots performance metrics if caret was used 
if(COMPUTE_IMPORTANCE){
# Evaluating importance of features to the model
importance <- xgb.importance(sparse_tr@Dimnames[[2]], 
                             model = model, 
                             data = sparse_tr, 
                             label = labels[set == "train"]
                            )
xgb.plot.importance(importance_matrix = head(importance,30))
}

# Generate predictions on competition test set. 
# compare prediction to results
source("Generate_submission.R")
final <- submission(model, sparse_ts, df_all[set == "test", "id"], NAME)

head(final$df,20)
head(final$file,20)
