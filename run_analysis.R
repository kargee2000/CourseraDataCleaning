#install the required packages
install.packages("LaF")
library(LaF)

install.packages("ffbase")
library(ffbase)
install.packages("sqldf")
library(sqldf)

s1 <- as.integer(c(17))
s2 <- as.integer(rep(16,559))
s3 <- as.integer(c(15))
s <- c(s1,s2,s3)

#####Read the test and the train data sets#####
cur_dir <- getwd()

xtrain_dir <- paste(cur_dir,"/train/X_train.txt",sep="")
ytrain_dir <- paste(cur_dir,"/train/y_train.txt",sep="")

xtest_dir <- paste(cur_dir,"/test/X_test.txt",sep="")
ytest_dir <- paste(cur_dir,"/test/y_test.txt",sep="")

xtrain <- laf_open_fwf(xtrain_dir, column_widths = s, column_types=rep("character", length(s)),column_names = paste("V", seq_len(length(s)), sep = " "))
my.data <- laf_to_ffdf(xtrain,rows=7352)
xtrain <- as.data.frame(my.data)
xtrain1 <- sapply(xtrain,function(x) as.numeric(as.character(x)))
xtrain2 <- as.data.frame(xtrain1)

ytrain <- laf_open_fwf(ytrain_dir, column_widths = c(1), column_types=rep("character", 1),column_names = paste("V", seq_len(1), sep = " "))
my.data <- laf_to_ffdf(ytrain,rows=7352)
ytrain <- as.data.frame(my.data)
ytrain1 <- sapply(ytrain,function(x) as.numeric(as.character(x)))
ytrain2 <- as.data.frame(ytrain1)

xtest <- laf_open_fwf(xtest_dir, column_widths = s, column_types=rep("character", length(s)),column_names = paste("V", seq_len(length(s)), sep = " "))
my.data <- laf_to_ffdf(xtest,rows=2947)
xtest <- as.data.frame(my.data)
xtest1 <- sapply(xtest,function(x) as.numeric(as.character(x)))
xtest2 <- as.data.frame(xtest1)


ytest <- laf_open_fwf(ytest_dir, column_widths = c(1), column_types=rep("character", 1),column_names = paste("V", seq_len(1), sep = " "))
my.data <- laf_to_ffdf(ytest,rows=2947)
ytest <- as.data.frame(my.data)
ytest1 <- sapply(ytest,function(x) as.numeric(as.character(x)))
ytest2 <- as.data.frame(ytest1)
#####Read the test and the train data sets#####

###Read the subjects data###
subtrain_dir <- paste(cur_dir,"/train/subject_train.txt",sep="")

subtest_dir <- paste(cur_dir,"/test/subject_test.txt",sep="")

ztest <- read.fwf(subtest_dir,widths=c(2))

ztrain <- read.fwf(subtrain_dir,widths=c(2))
###Read the subjects data###

#Assign columns names and convert to the appropriate data types
colnames(ztest)[1] <- "sub_col"
colnames(ztrain)[1] <- "sub_col"
ztest$sub_col <- as.integer(ztest$sub_col)
ztrain$sub_col <- as.integer(ztrain$sub_col)

##Read the column names of the features
feat_dir <- paste(cur_dir,"/features.txt",sep="")

col1 <- read.table(feat_dir,sep=" ")
colnames(col1)[2] <- "cols1"
colnames(col1)[1] <- "colsnum"
fin_cols <- sqldf("select colsnum from col1 where cols1 like '%mean%' or cols1 like '%std%'")

col2 <- col1["cols1"]
col2 <- as.character(col2)
colnames(xtest2) <- col2$cols1
colnames(xtrain2) <- col2$cols1

xtest3 <- xtest2[,fin_cols$colsnum]
xtrain3 <- xtrain2[,fin_cols$colsnum]


#Combine the test data and the train data
test_data <- cbind(ytest2,xtest3)
test_data <- cbind(test_data,ztest)
train_data <- cbind(ytrain2,xtrain3)
train_data <- cbind(train_data,ztrain)

colnames(test_data)[1] <- "activity"
colnames(train_data)[1] <- "activity"

final_data <- rbind(train_data,test_data)

final_data$activity <- as.integer(final_data$activity)

#ASsign the activity names based on the activity codes
final_data$activ_name[final_data$activity == 1] <- "WALKING"
final_data$activ_name[final_data$activity == 2] <- "WALKING_UPSTAIRS"
final_data$activ_name[final_data$activity == 3] <- "WALKING_DOWNSTAIRS"
final_data$activ_name[final_data$activity == 4] <- "SITTING"
final_data$activ_name[final_data$activity == 5] <- "STANDING"
final_data$activ_name[final_data$activity == 6] <- "LAYING"

final_data <- final_data[,-c(1)]

#Find the average of the columns by Subject and Activity
s4 <- 1:86
results <- aggregate(final_data[,s4],by=list(final_data$activ_name,final_data$sub_col),FUN=mean)

colnames(results)[2] <- "subject"
colnames(results)[1] <- "Activity"

result_dir <- paste(cur_dir,"/tidy_data_set.txt",sep="")
write.table(results,result_dir,row.name=FALSE)

