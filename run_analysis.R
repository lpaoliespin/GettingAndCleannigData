# Create one R script called run_analysis.R that does the following:

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set.
# 4. Appropriately labels the data set with descriptive activity names.
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


# Setting work directory

# setwd('Set here your work directory')
setwd('~/Documents/Training/DataScience/Coursera_JHU/DS-Specialization/CourseProjects/GettingAndCleannigData')

# Importing libraries

suppressMessages(library("dplyr"))

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")


# Downloading data, metadata and reading it into R

dataUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataUrl, destfile = "./getdata_projectfiles_UCI HAR Dataset.zip", method = "curl")

# Setting the path to the zip file
zip_path <- "./getdata_projectfiles_UCI HAR Dataset.zip"

# Extracting all files to the directory "./UCI HAR Dataset"
unzip(zipfile = zip_path, exdir = "./")

# Loading activity labels data
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Loading features data
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Loading X_test, y_test and subject_test data
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Setting features as X_test column names
names(X_test) = features

# Extracting only the measurements on the mean and standard deviation for each test measurement
extr_feat <- grepl("mean|std", features)
X_test = X_test[,extr_feat]

# Setting descriptive names to name the activities and the subject in the test data sets
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("ActivityID", "ActivityLabel")
names(subject_test) = "Subject"

# Binding the test data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)


# Loading X_train, y_train and subject_train data
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Setting features as X_train column names
names(X_train) = features

# Extracting only the measurements on the mean and standard deviation for each train measurement
X_train = X_train[,extr_feat]

# Setting descriptive names to name the activities and the subject in the train data sets
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("ActivityID", "ActivityLabel")
names(subject_train) = "Subject"

# Binding the train data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)


# Merging the test and the train data
merged_data = rbind(test_data, train_data)

# Choosing the desired column labels and melting the merged data in a new data set
col_labels  = c("Subject", "ActivityID", "ActivityLabel")
data_labels = setdiff(colnames(merged_data), col_labels)
melted_data = melt(merged_data, id = col_labels, measure.vars = data_labels)

# Applying mean function to the data set using the dcast function to create the tidy data set
tidy_data = dcast(melted_data, Subject + ActivityLabel ~ variable, mean)

# Writing the tidy data set to an output text file
write.table(tidy_data, file = "./tidy_data.txt", row.name = FALSE)

