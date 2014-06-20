tidy <- function() {
    
    ##This library is needed for reshaping the data later
    library(reshape2)
    
    ##Stores m as 1 to consider user prompt as y to overwrite data by default
    m <- 1
    
    ##Checks if tidydata.txt was created by this function already, if so it reads it into memory
    if(file.exists("tidydata.txt")) {
        ##Asks user if they want to overwrite existing file, if yes store as 1, if no store as 2
        l <- readline("File exists, overwrite y/n? ")
        if (l == "y") {m<-1} else if (l == "n") {m<-2} else {m<-0}
        
        ##If user answer was no, reads current file into memory, if yes it continues, if neither, function stops
        if (m == 2) {
            tidydata <- read.table("tidydata.txt")
            print("loaded current tidydata.txt")
        } else if (m == 0) {
            stop("invalid input function stopped")
        }              
    }    
    
    ##Checks if user prompt above was yes to overwrite data, continues function
    if (m == 1) {
        
        ##Create new directory in active directory if it doesn't exist
        if(!file.exists("data")){dir.create("data")}
        
        ##If the needed files haven't been downloaded, downloads them
        if(!file.exists("./data/UCI HAR Dataset")) {
            
            ##downloads file into temporary memory, and saves datedownloaded variable
            temp <- tempfile()
            fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
            download.file(fileURL, temp)
            datedownload <- date()
            
            ##Unzips the downloaded data and unlinks the temporary file
            unzip(temp, exdir="./data")        
            unlink(temp)
        }
            
        ##Sets a variable to direct to the downloaded files
        maindir <- paste("./data/",list.files("./data")[1],"/",sep = "")
        
        ##Sets a variable to list downloaded files
        dirlist <- list.files(maindir)
        
        ##Creates data.frames for the first few files in the directory
        actlab <- read.table(paste(maindir,dirlist[1],sep=""))
        colnames(actlab) <- c("activitynumber","activityname")
        feat <- read.table(paste(maindir,dirlist[2],sep=""))
                
        ##Sets variables to use later for test and train directories, which contain more files
        testdir <- paste(maindir,dirlist[5],"/",sep="")
        traindir <- paste(maindir,dirlist[6],"/",sep="")
        usedir <- c(testdir,traindir)
        
        ##Sets variables to use later to list files in test and train directories
        testfiles <- list.files(paste(maindir,dirlist[5],sep=""))
        trainfiles <- list.files(paste(maindir,dirlist[6],sep=""))
        usefiles <- list(testfiles,trainfiles)
        
        ##Creates variables to store test and train data
        testdata <- data.frame()
        traindata <- data.frame()
        datalist <- list(testdata,traindata)
        
        ##Populates data to testdata and traindata. Loops twice, once for each data set
        ##When complete, variable datalist contains complete testdata and traindata
        for (i in 1:2) {        
            ##Puts subject names, x measurement values, and y labels into variables
            sub <- read.table(paste(usedir[i],usefiles[[i]][2],sep=""))
            x <- read.table(paste(usedir[i],usefiles[[i]][3],sep=""))
            y <- read.table(paste(usedir[i],usefiles[[i]][4],sep=""))
            
            ##Loads above variables y and sub into datatable
            datalist[[i]] <- data.frame(y[,1])
            datalist[[i]] <- cbind(datalist[[i]],sub[,1])
            
            ##Updates the column names for the datatable
            colnames(datalist[[i]]) <- c("activitynumber","subjectnumber")
            
            ##Adds measurement data into the table, but only for means and standard deviations
            for (n in 1:ncol(x)) {
                ##Pulls the feature name from the features table
                featname <- as.character(feat[n,2])
                
                ##Takes the feature name and concats the end of it to find the variable type
                colfeat <- substr(featname,(nchar(featname)-7),(nchar(featname)-4))
                
                ##Turns the feature name into a tidy column name
                colname <- gsub("-","",featname)
                colname <- sub("\\(","",colname)
                colname <- sub("\\)","",colname)
                colname <- tolower(colname)
                
                ##This is done to make the variable more descriptive and remove some abbreviations
                if (substr(colname,1,1)=="t") {
                    colname <- sub("t","time",colname)
                } else if (substr(colname,1,1)=="f"){
                    colname <- sub("f","frequency",colname)
                }
                
                ##Only adds data for variable types that are means or standard deviations
                if (colfeat=="mean") {
                    ##Adds the measurement data to the last column of train or test data
                    datalist[[i]] <- cbind(datalist[[i]],x[,n])
                    
                    ##Changes the newest column name to match the tidy column name created above
                    colnames(datalist[[i]])[ncol(datalist[[i]])] <- colname
                } else if (colfeat=="-std") {
                    ##Adds the measurement data to the last column of train or test data
                    datalist[[i]] <- cbind(datalist[[i]],x[,n])
                    
                    ##Changes the newest column name to match the tidy column name created above
                    colnames(datalist[[i]])[ncol(datalist[[i]])] <- colname
                } else {next}
            }
                
        }
    
        ##Creates a final tidy data set with all the test and train variables in one data frame
        tidydata <- rbind(datalist[[1]],datalist[[2]])
        
        ##Add the activity names to the spreadsheet
        tidydata <- merge(actlab, tidydata, by = "activitynumber")
        
        ##Sets activityname as factor
        tidydata$activityname <- factor(tidydata$activityname)

        ##Removes the first activitynumber column
        tidydata <- tidydata[,2:ncol(tidydata)]

        ##Saves the data as a text file    
        write.table(tidydata, "tidydata.txt")
        print("data written to tidydata.txt")
    }
    
    ##reshapes the data in narrow format so that we dcast it
    meltdata <- melt(tidydata,id=c("activityname","subjectnumber"))
    
    ##casts the narrow data back into a wide format with only the averages of each activity and subject 
    tidydata2 <- dcast(meltdata, activityname + subjectnumber ~ variable,mean)
    
    ##Updates the column names to end in 'avg' so that it describes the fact that these are the averages of the variables
    colnames(tidydata2)[3:ncol(tidydata2)] <- as.character(sapply(colnames(tidydata2)[3:ncol(tidydata2)],function(x) paste0(x,"avg")))
    
    ##Writes the final data into a text file 
    write.table(tidydata2, "tidydata2.txt")
    print("data written to tidydata2.txt")
        
}