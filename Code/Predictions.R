# This script takes a model and runs predictions against it, outputting the training set and testing set errors

# Input data must have a 'set' factor indicating which set it belongs to
predictions <- function(model, sparse_dat, set, outcomes){
    
    # Split data into training and testing
    ii_tr <- set == "train"
    ii_ts <- set == "test_internal"
    sparse_tr <- sparse_dat[ii_tr,]
    sparse_ts <- sparse_dat[ii_ts,]
    outcomes_tr <- outcomes[ii_tr]
    outcomes_ts <- outcomes[ii_ts]

    # Evaluate performance on training set ####
    
    # Probability matrix
    library(xgboost)
    pred_tr <- predict(model, sparse_tr)
    predictions_tr <- as.data.frame(matrix(pred_tr, nrow = 12))
    rownames(predictions_tr) <- levels(outcomes)
    predictions_tr <- t(predictions_tr)
    # Predict the highest probability 
    out_tr <- apply(predictions_tr, 1, function(x) colnames(predictions_tr)[which.max(x)])
    # Accuracy
    error_tr <- sum(out_tr == outcomes_tr) / length(out_tr)

    # Evaluate performance on test set ####
    # Probability matrix
    pred_ts <- predict(model, sparse_ts)
    predictions_ts <- as.data.frame(matrix(pred_ts, nrow = 12))
    rownames(predictions_ts) <- levels(outcomes_ts)
    predictions_ts <- t(predictions_ts)
    # Predict the highest probability 
    out_ts <- apply(predictions_ts, 1, function(x) colnames(predictions_ts)[which.max(x)])
    # Accuracy
    error_ts <- sum(out_ts == outcomes_ts) / length(out_ts)
    
    
    output <- list(prob_tr = predictions_tr, prob_ts = predictions_ts,
                   pred_tr = out_tr, pred_ts = out_ts,
                   acc_tr = error_tr, acc_ts = error_ts)
    return(output)
}