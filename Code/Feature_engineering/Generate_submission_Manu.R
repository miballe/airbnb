# This script generates a submission file from a model

submission <- function(model, sparse_test, id, filename){
    require(xgboost)
    
    # Probability matrix
    pred_test <- predict(model, sparse_test)
    predictions_test <- as.data.frame(matrix(pred_test, nrow = 12))
    #ifelse(is.null(model$obsLevels),
           levels <- c('NDF','US','other','FR','CA','GB','ES','IT','PT','NL','DE','AU')#, levels <- model$obsLevels)
    rownames(predictions_test) <- levels
    predictions_test <- t(predictions_test)
    
    top5 <- apply(predictions_test, 1, function(x) {
        head(names(sort(x, decreasing = T)),5)
    })
    
    # create submission 
    ids <- as.vector(matrix(id, 1)[rep(1,5), ])
    submission_file <- data.frame(id = ids,
                             country = as.vector(top5))
    
    submission_df <- as.data.frame(t(top5))
    submission_df$id <- id
    
    name <- paste0(path,"Submission_Files/", filename, ".csv")
    write.table(submission_file, name, row.names = FALSE, quote = FALSE, sep = ",")
    return(list(df = submission_df, file = submission_file))
}