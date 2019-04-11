setwd("D:/Thesis/R")
library("sqldf", lib.loc="~/R/win-library/3.5")
library("dplyr", lib.loc="~/R/win-library/3.5")
library(readr)
UserFrequencyList <- read_delim("UserFrequencyList.txt","\t", escape_double = FALSE, trim_ws = TRUE)
# Merging All UserLists Together Created with Unix/Linux Bash
# Merging Two lists by username
Users <- merge(L1, L2, by = "Username", all = TRUE)
# Renaming Columns to not get columns with same name
names(Users)[names(Users) == 'Frequency.x'] <- 'a'
names(Users)[names(Users) == 'Frequency.y'] <- 'b'
# Repeat for all columns
Users <- merge(Users, L3, by = "Username", all = TRUE)
names(Users)[names(Users) == 'Frequency'] <- 'c'
Users <- merge(Users, L4, by = "Username", all = TRUE)
names(Users)[names(Users) == 'Frequency'] <- 'd'
Users <- merge(Users, L5, by = "Username", all = TRUE)
names(Users)[names(Users) == 'Frequency'] <- 'e'
Users <- merge(Users, L6, by = "Username", all = TRUE)
names(Users)[names(Users) == 'Frequency'] <- 'f'
Users <- merge(Users, L7, by = "Username", all = TRUE)
names(Users)[names(Users) == 'Frequency'] <- 'g'

# Replacing Null Values with 0
Users <- replace(Users,is.na(Users),0)

# Summing/Merging All Frequency columns under 1 column ordered by Descending Frequency                
Users = sqldf('SELECT Username, SUM(a+b+c+d+e+f+g) AS Frequency FROM Users ORDER BY Frequency Desc')


# Writing Table to File Without Quotes and tab as delimiter
write.table(Users, file = "UserFrequencyList.txt", sep = "\t",
            row.names = FALSE, col.names = TRUE)


# RiskGroup <- Filter (Done Manually)
# FrequentUsers.txt is a file of 500 top users where businesses, organizations and non english speaking users are removed

# Removing Frequency Column to get a list of usernames only
RiskList<- FrequentUsers[1]

# Writing Table to File Without Quotes and tab as delimiter
# Word Count 3568587
write.table(RiskList, file = "RiskListManual.txt", sep = "\t",
            row.names = FALSE, col.names = FALSE, quote=FALSE)

# Creating List of User with more than 14 Frequency (2 Activites a month as threshhold for Active User)
ActiveUsers <- sqldf("SELECT * FROM UserFrequencyList WHERE Frequency > 14")

# ControlGroup Filtering
# Finding Mean/Average Frequency of Active Users
result.mean <- mean(ActiveUsers$Frequency)
print(result.mean)
# Mean = 210

# Lines Underneath has undergone an Iterative Process to get a similar summed frequency.
# Could be done with a ForLoop to show the process?

set.seed(295)


# Filtering with Average +/- 10
ControlGroup <- sqldf("SELECT * FROM UserFrequencyList WHERE Frequency  >=  200 AND Frequency <= 220")


ControlGroupSample <- sample_n(ControlGroup, 1664)
# Removing Frequency Column to get a list of usernames only
ControlList<- ControlGroupSample[1]
# Writing Table
write.table(ControlList, file = "ControlList.txt", sep = "\t",
            row.names = FALSE, col.names = FALSE, quote=FALSE)


# Below is commented as The risk list was done Manually - This is how a random risk list could have been created
# <- sqldf("SELECT * FROM UserFrequencyList WHERE Frequency  <=  6000  AND Frequency >= 4000")
# RiskGroupSample <- sample_n(RiskGroup, 500)
# RiskList<- RiskGroupSample[1]
# write.table(RiskList, file = "RiskList.txt", sep = "\t",
#           row.names = FALSE, col.names = FALSE, quote=FALSE)





