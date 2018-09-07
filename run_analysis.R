library(dplyr)
library(tidyr)
#get the data
if(!file.exists("./data")){dir.create("./data")
fileurl<-"http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl,destfile = "./data/dataset.zip")}
#unzip file
unzip("./data/dataset.zip", exdir = "./data")
files<-list.files("./data/UCI HAR Dataset",recursive = TRUE)

#Merges the activity,subject and features and create one data set.
activity_train<-read.table("./data/UCI HAR Dataset/train/y_train.txt",header = FALSE)
activity_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt",header=FALSE)
activity_data<-rbind(activity_train,activity_test)

subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt",header=FALSE)
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt",header=FALSE)
subject_data<-rbind(subject_train,subject_test)

features_train<-read.table("./data/UCI HAR Dataset/train/x_train.txt", header=FALSE)
features_test<-read.table("./data/UCI HAR Dataset/test/x_test.txt",header=FALSE)
features_data<-rbind(features_train,features_test)

names(activity_data)<-"activity"
names(subject_data)<-"subject"
featuresname<-read.table("./data/UCI HAR Dataset/features.txt")
names(features_data)<-featuresname$V2
dataset<-cbind(features_data,activity_data,subject_data)

#Extracts only the measurements of mean and standard deviation for each measurement.
subfeaturesname<-featuresname$V2[grep("mean\\(\\)|std\\(\\)",featuresname$V2)]
subnames<-c(as.character(subfeaturesname),"activity","subject")

dataset<-subset(dataset,select=subnames)
activities_labels<-read.table("./data/UCI HAR Dataset/activity_labels.txt",header = FALSE)
dataset$activity<-factor(dataset$activity,labels=activities_labels[,2])
#Appropriately labels the data set with descriptive variable names
names(dataset)<-gsub("^t", "time", names(dataset))
names(dataset)<-gsub("^f", "frequency", names(dataset))
names(dataset)<-gsub("Acc", "Accelerometer", names(dataset))
names(dataset)<-gsub("Gyro", "Gyroscope", names(dataset))
names(dataset)<-gsub("Mag", "Magnitude", names(dataset))
names(dataset)<-gsub("BodyBody", "Body", names(dataset))

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
FinalData<-aggregate(. ~subject + activity, dataset,FUN=mean)
FinalData<-FinalData[order(FinalData$subject,FinalData$activity),]
write.table(FinalData, file = "tidydata.txt",row.name=FALSE,quote = FALSE, sep = '\t')
