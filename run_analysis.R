# R script to download the data set available at:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# This data set contains human activity data collected from the accelerometers from the Samsung
# Galaxy S smartphone.
# The script performs the downloading of the zipped datafile and subsequent creation of a tidy dataset 

run_Analysis <- function() {

	## 1. Merge the training and the test sets to create one data set

	# download and unzip data
	fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	zippedfilename <- "har_dataset.zip"
	
	if (!file.exists(zippedfilename)) {
		# download data file
		download.file(fileURL, zippedfilename)
	}
	
  dataDir <- "UCI HAR Dataset"
  if(!file.exists(dataDir)) { 
		# unzip the zipped data file
		unzip(zippedfilename, exdir = ".")
	}

	# read and merge training and test data sets
	Xtrain <- read.table(paste(dataDir, "train/X_train.txt", sep="/"))
	Xtest  <- read.table(paste(dataDir, "test/X_test.txt", sep="/"))
	Xmerged <- rbind(Xtrain, Xtest)
	
	## 2. Extract measurements on mean and standard deviation for each measurements

	# column 2 of the feature.txt file contains the names of the features
	features  <- read.table(paste(dataDir, "features.txt", sep="/"))[,2]
	# add the feature names to the (X)merged dataset
	names(Xmerged) <- features
	
	# filter out the columns that contain 'mean' or 'std'
	mean_std_cols <- grep(".*mean.*|.*std.*", features)
	# retrieve the reduced data set
	mean_std_reduced <- Xmerged[,mean_std_cols]
	
	## 3. Create descriptive activity names

	# read and merge the train and test data label codes
	Ytrain_label_cds <- read.table(paste(dataDir, "train/y_train.txt", sep="/"))
	Ytest_label_cds <- read.table(paste(dataDir, "test/y_test.txt", sep="/"))
	Ymerged_label_cds <- rbind(Ytrain_label_cds,Ytest_label_cds)[,1]
	# get the activity names
	activity_names_tbl  <- read.table(paste(dataDir, "activity_labels.txt", sep="/"))
	activity_names_tbl[,2] <- as.character(activity_names_tbl[,2])
	activity_names_col <- activity_names_tbl[,2]
	activities <- activity_names_col[Ymerged_label_cds]
	
	## 4. Label the data set with descriptive variable names
	
    # rename as per feature_info.txt:
	# prefix 't' denotes time
	# prefix 'f' denotes frequency (domain signals)
	# mean denotes Mean value
	# std denotes Standard deviation
	# also remove '()'
	names(mean_std_reduced) <- gsub('^t', 'Time', names(mean_std_reduced))
	names(mean_std_reduced) <- gsub('^f', 'Frequency', names(mean_std_reduced))
	names(mean_std_reduced) <- gsub('-mean', 'Mean', names(mean_std_reduced))
	names(mean_std_reduced) <- gsub('-std', 'StdDev', names(mean_std_reduced))
	names(mean_std_reduced) <- gsub('[()]', '', names(mean_std_reduced))
	
	# get the subjects who performed the activities for train and test and combine them
	subjectTrain <- read.table(paste(dataDir, "train/subject_train.txt", sep="/"))
	subjectTest  <- read.table(paste(dataDir, "test/subject_test.txt", sep="/"))
	subjects <- rbind(subjectTrain, subjectTest)[, 1]
	
	# combine the subjects and activities data with the mean_std_reduced data set 
	tidy_data_set <- cbind(Subject = subjects, Activity = activities, mean_std_reduced)
	
	## 5. Create an independent tidy data set with the average of each variable for each activity and each subject.
	library(plyr)
	# get the means for all the columns except the Subject and the Activity
	# we need a function that gets that task to be passed to ddply 
	columnMeans <- function(data) { 
		colMeans(data[,-c(1,2)]) 
	}
	# call ddply to get the means by the groups Subject and Activity
	tidy_data_set_activity_means <- ddply(tidy_data_set, .(Subject, Activity), columnMeans)
	# fix up the column names as the columns now hold the means for a given subject and activity
	names(tidy_data_set_activity_means)[-c(1,2)] <- paste("ActivityMean", names(tidy_data_set_activity_means)[-c(1,2)], sep="")

	# write the file to disk
	write.table(tidy_data_set_activity_means, "tidyDataSet.txt", row.names = FALSE)

	# return  the tidy data set
	tidy_data_set_activity_means
  
  }