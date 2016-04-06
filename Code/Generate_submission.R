# This script generates a submission file from a model

submission <- function(model, sparse_test, id){
    
    # Probability matrix
    pred_test <- predict(model, sparse_test)
    predictions_test <- as.data.frame(matrix(pred_test, nrow = 12))
    rownames(predictions_test) <- model$obsLevels
    predictions_test <- t(predictions_test)
    
    top5 <- apply(predictions_test, 1, function(x) {
        head(names(sort(x, decreasing = T)),5)
    })
    
    # create submission 
    ids <- NULL
    for (i in id) {
        ids <- append(ids, rep(i,5))
    }
    
    submission_file <- data.frame(id = ids,
                             country = as.vector(top5))
    submission_df <- as.data.frame(t(top5))
    submission_df$id <- id
    
    write.table(submission_file, "./Submission_Files/submission.csv", row.names = FALSE, quote = FALSE, sep = ",")
    return(list(df = submission_df, file = submission_file))
}