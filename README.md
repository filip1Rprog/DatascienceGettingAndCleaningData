# Getting and Cleaning Data - Course Project

### The R script 'run_analysis.R' performs the following tasks:

1. Merge the training and the test sets to create one data set
- download and unzip data (if it doesn't exist)
- read and merge training and test data sets

2. Extract measurements on mean and standard deviation for each measurements
- use file feature.txt to retrieve the names of the features
- filter out the columns that contain 'mean' or 'std' to create a data set only containing mean and std values

3. Create descriptive activity names
- use y_train.txt and y_test.txt to read the train and test data label codes and then merge them
- use activity_labels.txt to retrieve the activity names
	
4. Label the data set with descriptive variable names as per information given in feature_info.txt
- use subject_train.txt and subject_test.txt to retrieve the subject IDs for the train and test data and combine them
- combine the subjects and activities data with the mean_std_reduced data set to create a preliminary tidy data set 
	
5. Create an independent tidy data set with the average of each variable for each activity and each subject
- use plyr library's ddply function to determine the means based on a grouping of Subject and Activity
- modify column names to reflect that the data set holds the mean for a given subject and activity_means
- write the file to disk
- return the tidy data set (to the console) and write it to the disk (tidyDataSet.txt)
