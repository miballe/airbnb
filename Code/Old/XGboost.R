# Libraries ####
library(xgboost)
library(dplyr)
require(Matrix)
require(data.table)
if (!require('vcd')) install.packages('vcd')
library(Ckmeans.1d.dp)
library("e1071")
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Read data ####
# Read data remove id variable
tr <- readRDS("../Data/train_users_2_tr.RDS") %>%
    na.omit() %>%
    select(-id) %>%
    select(-c(date_account_created, date_first_booking, first_browser)) ## Removing more complex factors _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
ts <- readRDS("../Data/train_users_2_ts.RDS") %>%
    na.omit() %>%
    select(-id) %>%
    select(-c(date_account_created, date_first_booking, first_browser)) ## Removing more complex factors _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# One-hot encoding #### 
# https://cran.r-project.org/web/packages/xgboost/vignettes/discoverYourData.html
tr <- data.table(tr, keep.rownames = F)
sparse_tr <- sparse.model.matrix(country_destination~. -1, data = tr)
dim(sparse_tr)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# XGBoost ####
# xgboost parameters
xgb_params_1 = list(
    objective = "multi:softprob",  # Multiclass outputs
    num_class = length(levels(tr$country_destination)) + 1, 
    eta = 0.01,                    # learning rate
    max.depth = 3,                 # max tree depth
    eval_metric = "merror"            # evaluation/loss metric
)

# fit the model with the arbitrary parameters specified above
xgb_1 = xgboost(data = sparse_tr,
                label = tr$country_destination,
                params = xgb_params_1,
                nrounds = 100,       # max number of trees to build
                verbose = TRUE,                                         
                print.every.n = 1,
                early.stop.round = 10    # stop if no improvement within 10 trees
)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Evaluating model ####
importance <- xgb.importance(sparse_tr@Dimnames[[2]], 
                             model = xgb_1, 
                             data = sparse_tr, 
                             label = tr$country_destination)
xgb.plot.importance(importance_matrix = importance)


# Parameter search using X-val
# http://stats.stackexchange.com/questions/171043/how-to-tune-hyperparameters-of-xgboost-trees

# set up the cross-validated hyper-parameter search
xgb_grid_1 = expand.grid(
    nrounds = 1000,
    max_depth = c(2, 4, 6, 8, 10),
    eta = c(0.01, 0.001, 0.0001),
    gamma = 1,
    colsample_bytree = 0.3,
    min_child_weight = 1
)

# trainControl creates settings for caret::train
xgb_trcontrol_1 = trainControl(
    method = "cv",          # Cross validation
    number = 5,             # number of folds
    verboseIter = TRUE,
    returnData = FALSE,
    returnResamp = "all",   # How many summary stats to save                                                     # save losses across all models
    allowParallel = TRUE
)

# train the model for each parameter combination in the grid, 
#   using CV to evaluate
xgb_train_1 = train(
    x = sparse_tr,
    y = tr$country_destination,
    trControl = xgb_trcontrol_1,
    tuneGrid = xgb_grid_1,
    method = "xgbTree", 
    metric = "Kappa"
)

# scatter plot of the AUC against max_depth and eta
ggplot(xgb_train_1$results, aes(x = as.factor(eta), y = max_depth, size = ROC, color = ROC)) + 
    geom_point() + 
    theme_bw() + 
    scale_size_continuous(guide = "none")
