require(dplyr)
require(ggplot2)
require(tidyr)

compare_plot <- function(feature = NA, df = train_users_2, output = "abroad", seperate = FALSE, plot = TRUE) {
# Graphs comparison statistics of the output factor feature grouped by the feature argument for a "frequency based" dataframe. By default it tests the factors of "abroad" feature in the dataset "train_users_2" but this can be overwritten in the arguments. Arguments are supplied as strings. If seperate is set to TRUE then it compares the NDF rates and the internal travel rates seperately, only if using the default output feature. The boolean plot argument supresses the plot from printing. Also returns the summarised data from which the plots were made. 
    
    # Sumarise data into country destination frequencies
    Counts <- df %>% 
        group_by_(output, feature) %>%
        summarise(number = n()) %>%
        arrange(desc(number)) %>%
        group_by_(feature) 
    
   
    if (is.na(feature)) {
        # Plot barchart
        gg <- ggplot(data = Counts, 
               aes(x = reorder(get(output), -number), y = number, 
                   label = round(number / nrow(df),2))) +
            geom_bar(stat = "identity") +
            geom_text(vjust = -.6) +
            xlab("Destination Country")
    }
    
    
    else if (seperate == FALSE) {
        # Distill information into plottable form
        Counts <- Counts %>% mutate(percent = 100 * number / sum(number)) %>%
            gather(measurement, value, number, percent)
        
        # Plot barchart
        gg <- ggplot(data = Counts,
                     aes(x = reorder(get(output), -value), y = value, fill = get(feature),
                         label = round(value / nrow(df),2))) +
                  geom_bar(stat = "identity", position = "dodge") +
                  facet_grid(measurement ~ ., scales = "free")
    }
    else if (seperate == TRUE & output == "abroad") {
        # Distill information into plottable form
        Counts <- Counts %>%
            spread(abroad, number) %>%
            mutate(NDF_rate = NDF / sum(NDF, US, EXT),
                   US_rate = US / sum(US, EXT)) %>%
            select(-c(NDF, US, EXT))
        
        PlotCounts <- Counts %>%
            gather(measurement, value, -get(feature))
    
        # Plot barchart
        gg <- ggplot(data = PlotCounts,
                     aes(x = reorder(measurement, -value), y = value, fill = get(feature),
                         label = round(value / nrow(df),2))) +
                  geom_bar(stat = "identity", position = "dodge")
    }

    else stop("You must use output == 'abroad' to use the seperate = T argument")
    if (plot == TRUE) print(gg)
    return(list(Counts,gg))
}


featureFactorComp <- function(df = train_users_2) {
    # Performs operation on all factor variables with less than 20 levels other than the output
    # Currently only works for output = "abroad" May refactor this later to allow for other output levels. 
    output = "abroad"
    
    # Select factors variables with less than 20 factors not the output
    level_length <- sapply(df, function(x) length(levels(x)))
    factors <- names(df)[level_length > 0 & level_length < 30]
    factors <- factors[factors != output]
    
    # Do not compare country_destination to abroad as 1:1
    factors <- factors[factors != "country_destination"]
    
    # Initialise return dataframe
    return_df <- data.frame(feature_value = factor(), feature = factor(),
                            NDF_rate = numeric(), US_rate = numeric(),
                            NDF_rate_relative = numeric(), US_rate_relative = numeric())
    
    # Apply compare function on each factor variable
    sapply(factors, function(x) {
        Counts <- compare_plot(feature = x, df = df, output = output, 
                               seperate = T, plot = F)[[1]] %>%
            group_by() %>%
            mutate(NDF_rate_relative = NDF_rate - mean(NDF_rate, na.rm = T), 
                   US_rate_relative = US_rate - mean(US_rate, na.rm = T))
        # Reformat names and bind to return dataframe
        Counts$feature <- names(Counts)[1]
        names(Counts)[1] <- names(return_df)[1]
        # Rename feature factors which are already in return_df
        Counts$feature_value <- as.character(Counts$feature_value)
        index <- Counts$feature_value %in% as.character(return_df$feature_value)
        while(sum(index > 0)) {
        Counts$feature_value[index] <- paste0(Counts$feature_value[index], "_")
        index <- Counts$feature_value %in% as.character(return_df$feature_value)
        }
        Counts$feature_value <- as.factor(Counts$feature_value)
        
        return_df <<- rbind(return_df, Counts)
    })
    return_df$feature_value <- as.factor(return_df$feature_value)
    return_df$feature <- as.factor(return_df$feature)
    return(return_df)
}

