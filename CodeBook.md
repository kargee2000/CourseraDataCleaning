
The variable names of the final data set is the same as those provided in the features.txt file.

Manipulations performed
------------------------
1) The initial xtest,ytest,ytrain and xtrain datasets are read from the paths provided.
2) The subjects data is read in a separate file named subject_test and subject_train.txt respectively
3) The features files is read as a vector and is assigned as column names to the xtest and xtrain datasets
4) Assign the column names "activity" to the activity column read from ytest and ytrain
5) Shortlist the column numbers that contain mean() or std() as the feature names. SElect only the xtest and xtrain data that have these column numbers
6) Combine the columns for test and train and combine the rows using rbind()
7) Calculate the mean of all columns by subject and activity. We get 180 rows(30 subjects and 6 activities) 
8) Write the final file to the file /tidy_data_set.txt in current working directory