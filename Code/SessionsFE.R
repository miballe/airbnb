# AirBnB New User Booking - Kaggle
# https://www.kaggle.com/c/airbnb-recruiting-new-user-bookings
# Script to explore and perform some actions of Feature Engineering as part of the Data Mining module coursework

# Load libraries
library(sqldf)
# library(tcltk)
# library(ade4)

# Load data
s <- read.csv("sessions.csv");
u <- read.csv("train_users_2.csv")
# t <- read.csv("test_users.csv")

# uq <- unique(s$user_id)

# These lines unifies the "unknown" value to the same exact string for all columns
# then the actioncat field is created by concatenating action, action_type and action_detail
# Deletes all empty user ids. Those only add noise because cannot be matched to any user data.
s <- s[s$user_id != "",]
# Keeps only all session records that can be matched to an existing user_id in the training set.
# This reduces the dataset by half!
s <- sqldf("select s.user_id, s.action, s.action_type, s.action_detail, s.device_type, s.secs_elapsed from s, u where s.user_id == u.id")

# Asumes all empty values as unknown that is an existing value. Also unifies the unknown notation removing dashes.
s$action_detail <- sub("^$", "unknown", s$action_detail)
s$action_type <- sub("^$", "unknown", s$action_type)
s$action <- sub("^$", "unknown", s$action)
s$action_detail <- sub("-unknown-", "unknown", s$action_detail)
s$device_type <- sub("-unknown-", "unknown", s$device_type)
s$action_type <- sub("-unknown-", "unknown", s$action_type)
# Removes any space from action to later have column names without spaces. Also unifies notation.
s$action <- gsub(" ", "_", s$action)
s$action <- gsub("-", "_", s$action)
# Removes spaces and unwanted characters from DeviceType
s$device_type <- gsub("/", "", s$device_type)
s$device_type <- gsub(" ", "", s$device_type)
# Concatenates Action, ActionType and ActionDetail in a single cleaned field. This will reduce dimensionality. The concatenation order is to avoid column names starting with a number.
s$action <- gsub(" ", "", paste(s$action_type, "N", s$action, "N", s$action_detail))
# Removes NA values from secs_elapsed and then creates bins.
s$secs_elapsed[is.na(s$secs_elapsed)] <- -1
# Seconds elapsed are stored in bins considering the following criteria
# secs < 0 -> 0. No available information.
# 0 < secs < 30. Within 30 seconds a user can load a read quickly some data, then continue to the next step.
# 30 < secs < 60. The user may take longer to read the page or fill a small form.
# 60 < secs < 300. The user is reading information in detail or filling a medium sized form like the payments page or performing a parallel research.
# 300 < secs < 600. A page view taking this long can be caused by a user researching in parallel in other windows or simply a lost of continuity in the process
# 600 < secs < 3600. The user definitely lost attention and is browsing without intention to complete a process.
# 3600 < secs. The time is not reliable and the page view can hardly be considered part of a process.
s$secs_elapsed <- cut(s$secs_elapsed, c( - Inf, 0, 30, 60, 300, 600, 3600, Inf), labels = 0:6)
s$action_detail <- NULL
s$action_type <- NULL
s$action <- factor(s$action)
s$device_type <- factor(s$device_type)

# Converting categorical columns in binary columns (actio and device_type)

# From library ade4, method acm.disjonctif didn't work with a data frame the size of s
# binfeatures <- acm.disjonctif(subset(s, select = c("action", "device_type")))
# cbind(s, binfeatures)
# Creating the binary columns manually...

acnames <- array(unique(s$action))
dtnames <- array(unique(s$device_type))

memory.limit(size = 64800)

for (i in 1:length(acnames)) {
    s[, acnames[i]] <- ifelse(s$action == acnames[i], 1, 0)
    }


for (i in 1:length(dtnames)) {
    s[, dtnames[i]] <- ifelse(s$device_type == dtnames[i], 1, 0)
    }

s$action <- NULL
s$device_type <- NULL

write.csv(s, "sessionsFE.csv", row.names = FALSE, quote = FALSE)

# Creates a table with all action-actiontype-actiondetail unique combinations
# allact <- sqldf("select actioncat, count(*) as nact from s group by actioncat order by nact desc")

# Using lines like this, some exploration was performed to check how likely some observations can be
# combined as part of a single session sequence
# es <- allact[allact$action_type == "booking_request",]

# Filters the users table to get only those that completed the booking process
# bkd <- unique(u[u$country_destination != "NDF",])

# Combines users and sessions to get only the session records that contain full booking processes
# noNdf <- sqldf("select s.user_id, u.signup_method, u.signup_flow, u.signup_app, u.first_browser, s.action, s.action_type, s.device_type, s.secs_elapsed, u.country_destination from s, u where s.user_id == u.id and u.country_destination != 'NDF'")

# Filters the noNDF table to those that booked a particular country
# The aim is to find potential row combinations to reduce the number of observations by grouping actions
# in meaningful calculated rows that may boost the prediction process.
# es <- noNdf[noNdf$country_destination == "ES",]
# esa <- unique(es$action)
# esu <- unique(es$user_id)
# esb <- es[es$action_type == "booking_request",]

# After playing with the data it wasn't possible to identify unique sequences that clearly evidence a booking action
# In some cases some actions are missing or not complete which suggest that the data is not complete

# At this point it makes sense to apply Feature Engineering as binary columns for each unique value in the table
# user_id --> 1 column
# allact --> 457 Columns
# device_type --> 14 Columns
# secs_elapsed --> 1 Column

# Creates a new column in allact that concatenates the values for action, actiontype and actiondetail, which will
# become as the column name for the new feature. It basically replaces any space with '_', '-unknown-' with 'unknown'
# blanks with 'unknown' and use the dash '-' as concatenation 

# allact <- sqldf("select action, action_type, action_detail, count(*) as nact from s group by action, action_type, action_detail order by nact desc")

