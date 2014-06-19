#README for run_analysis.R for Getting and Cleaning Data Course Project

run_analysis.R pulls data from this data set https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and creates a tidy data version of it, which only contains the averages of the features in it that are means and standard deviations. This data has two subsets, test data and train data, so this data is combined by our function and tidied to create tidydata.txt. The final output is tidydata2.txt, which is the reshaped averages of the tidydata.txt data.

Below are the steps run_analysis.R takes to get this output. I have put in parantheses at the end of each step the line numbers from the code that do the corresponding part of the function.

1. First run_analysis.R sets up directories and checks to see if the first part of the function was ran already. The first part takes some time, so if it sees you already have the file output from this part of the function (tidydata.txt) it asks if you want to overwrite it, and if not, it loads the previously saved data into memory to speed up the function. (lines 1-31)

##NOTE: If you already have a different tidydata.txt file in your working directory it will overwrite that.

2. If that data didn't already exist, it downloads the dataset to a 'data' directory and sets the folders and files in that directory as variables to make them easier to work with (lines 32-69)

3. It creates a list 'datalist' that contains two tables 'testdata' and 'traindata' that we will create. (lines 70-74)

4. Using For loops, the function adds activity numbers, subject numbers, and measurement data to each testdata and traindata. The only measurement data read in are features that contain 'mean' or 'std'. While it's doing this it adjusts the column names to be descriptive. Column name edits are described further at the bottom of this document. (lines 75-128)

5. testdata and traindata are combined to create tidydata. Then the activity numbers are converted to activity names. (lines 129-140)

6. This tidydata is written to tidydata.txt as it contains the data before we reshape it. This data could be useful so it is preserved. (lines 141-145)

7. Then the function melts the data into a narrow format, then reshapes it again taking only the means of all the measurements from before for each activity and subject and stores it as tidydata2. (lines 146-151)

8. Also since we took averages of the measurements the function adds 'avg' to the end of all the measurement column names in tidydata2. (lines 152-154)

9. The final data is written to tidydata2.txt (lines 155-159)

##Final Notes. This is a tidy data set because:
Each column contains only one variable and each row contains only one observation (means of measurements in this case). 

Also, the activity names are descriptive by using 'WALKING' instead of the code '1'. 

The variable names are descriptive as well. Here is an example: 'timebodyaccmeanxavg'. The original data set had 'tBodyAcc-mean()-X'. Per lecture from Week 4 'Editing Text Variables', variables should be all lower case, descriptive, not duplicated, and not have extra symbols. So, I made the variables lower case, and removed the parentheses and dashes. Then, to make the variable more descriptive I turned those that started with 't' into 'time' and 'f' into 'frequency' per the features_info.txt. The other descriptors 'body', 'gyro', 'acc', etc. were not quite as descriptive, but I felt it was clear enough what they meant without lengthening them. Finally, I added 'avg' to the end of each measurement to indicate that I took the average of the original measurements.