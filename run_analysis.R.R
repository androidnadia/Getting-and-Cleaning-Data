# Getting and cleaning Data : Final Assignment 
# Loading libraries
library(dplyr)
library(tidyr)
library(readr)

# Downloading files
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "datasetfiles.zip", model = "wb")
unzip(zipfile = "datasetfiles.zip")

# change working directory
setwd("UCI HAR Dataset")

# Loading files
features <- read.table("features.txt", header = FALSE, col.names = c("index", "features"))
activities <- read.table("activity_labels.txt", header = FALSE, sep = " ", col.names = c("code", "activity"))
subject_test <- read.table("test/subject_test.txt", header = FALSE, col.names = "subject")
x_test <- read.table("test/X_test.txt", header = FALSE, col.names = features$features)
y_test <- read.table("test/y_test.txt", header = FALSE, col.names = "code")
subject_train <- read.table("train/subject_train.txt", header = FALSE, col.names = "subject")
x_train <- read.table("train/X_train.txt", header = FALSE, col.names = features$features)
y_train <- read.table("train/y_train.txt", header = FALSE, col.names = "code")

# Combining training and test sets
train <- cbind(subject_train, y_train, x_train)
test <- cbind(subject_test, y_test, x_test)
all_data <- bind_rows(train, test)

# Get features containing mean or std
features_wanted <- grep("mean|std", features$features)
measure <- all_data[,features_wanted]
# Alternative
# measure <- all_data %>% select(subject, code, contains("mean"), contains("std"))

# change activity codes with activity names
measure <- merge(measure, activities, by = 'code', all.x = TRUE)
measure <- measure[,-1]

# Give descriptive names to features
names(measure)<-gsub("Acc", "Accelerometer", names(measure))
names(measure)<-gsub("Gyro", "Gyroscope", names(measure))
names(measure)<-gsub("BodyBody", "Body", names(measure))
names(measure)<-gsub("Mag", "Magnitude", names(measure))
names(measure)<-gsub("^t", "Time", names(measure))
names(measure)<-gsub("^f", "Frequency", names(measure))
names(measure)<-gsub(".mean()", "Mean", names(measure), ignore.case = TRUE)
names(measure)<-gsub(".std()", "STD", names(measure), ignore.case = TRUE)
names(measure)<-gsub(".freq()", "Frequency", names(measure), ignore.case = TRUE)
names(measure)<-gsub("angle", "Angle", names(measure))
names(measure)<-gsub("gravity", "Gravity", names(measure))
names(measure)<-gsub("\\.\\.\\.", "", names(measure))

TidyData <- measure %>% select(subject, activity, 2:79)

# Get the average of each subject and each activity
FinalData <- TidyData %>% group_by(subject, activity) %>% summarize_all(mean)

write.csv(FinalData, "FinalData.csv")