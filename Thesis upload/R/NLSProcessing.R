setwd("D:/Thesis/R")
library(readr)
library("sqldf", lib.loc="~/R/win-library/3.5")
RiskWords <- read_table2("D:/Thesis/Output/Risk/RiskWords.txt", col_names = FALSE)
RiskNegatives <- read_table2("D:/Thesis/Output/Risk/RiskNegatives.txt", col_names = FALSE)
RiskPositives <- read_table2("D:/Thesis/Output/Risk/RiskPositives.txt", col_names = FALSE)
ControlWords <- read_table2("D:/Thesis/Output/Control/ControlWords.txt", col_names = FALSE)
ControlNegatives <- read_table2("D:/Thesis/Output/Control/ControlNegatives.txt", col_names = FALSE)
ControlPositives <- read_table2("D:/Thesis/Output/Control/ControlPositives.txt", col_names = FALSE)



names(RiskPositives)[1] <- "Word"
names(RiskPositives)[2] <- "Count"
names(RiskWords)[1] <- "Word"
names(RiskWords)[2] <- "Count"
names(RiskNegatives)[1] <- "Word"
names(RiskNegatives)[2] <- "Count"
names(ControlPositives)[1] <- "Word"
names(ControlPositives)[2] <- "Count"
names(ControlNegatives)[1] <- "Word"
names(ControlNegatives)[2] <- "Count"
names(ControlWords)[1] <- "Word"
names(ControlWords)[2] <- "Count"
ControlWords$Count <- as.numeric(as.character(ControlWords$Count))
RiskWords$Count <- as.numeric(as.character(RiskWords$Count))

# Compare all words
Compare <- merge(RiskWords, ControlWords, by = "Word", all = TRUE)
Compare <- replace(Compare,is.na(Compare),0)
names(Compare)[names(Compare) == 'Count.x'] <- 'RiskGroup'
names(Compare)[names(Compare) == 'Count.y'] <- 'ControlGroup'
Compare = sqldf('SELECT Word, RiskGroup, ControlGroup FROM Compare ORDER BY RiskGroup DESC')
RiskUsage = sqldf('SELECT Word, RiskGroup - ControlGroup AS Count FROM Compare ORDER BY Count DESC')
ControlUsage = sqldf('SELECT Word, ControlGroup- RiskGroup AS Count FROM Compare ORDER BY Count DESC')

# Compare Negatives
Negatives <- merge(RiskNegatives, ControlNegatives, by = "Word", all = TRUE)
Negatives<- replace(Negatives,is.na(Negatives),0)
names(Negatives)[names(Negatives) == 'Count.x'] <- 'RiskNegatives'
names(Negatives)[names(Negatives) == 'Count.y'] <- 'ControlNegatives'
Negatives = sqldf('SELECT Word, RiskNegatives, ControlNegatives FROM Negatives ORDER BY RiskNegatives DESC')
RiskNeg = sqldf('SELECT Word, RiskNegatives - ControlNegatives AS Count FROM Negatives ORDER BY Count DESC')
ControlNeg = sqldf('SELECT Word, ControlNegatives- RiskNegatives AS Count FROM Negatives ORDER BY Count DESC')


#Compare positives
Positives <- merge(RiskPositives, ControlPositives , by = "Word", all = TRUE)
Positives <- replace(Positives,is.na(Positives ),0)
names(Positives)[names(Positives) == 'Count.x'] <- 'RiskPositives'
names(Positives)[names(Positives) == 'Count.y'] <- 'ControlPositives'
Positives = sqldf('SELECT Word, RiskPositives, ControlPositives FROM Positives ORDER BY RiskPositives DESC')
RiskPos = sqldf('SELECT Word, RiskPositives - ControlPositives AS Count FROM Positives ORDER BY Count DESC')
ControlPos = sqldf('SELECT Word, ControlPositives- RiskPositives AS Count FROM Positives ORDER BY Count DESC')

R_Positives = sqldf("SELECT SUM(Count) FROM RiskPositives")
R_Negatives = sqldf("SELECT SUM(Count) FROM RiskNegatives")
C_Positives = sqldf("SELECT SUM(Count) FROM ControlPositives")
C_Negatives = sqldf("SELECT SUM(Count) FROM ControlNegatives")

print(C_Negatives)
print(R_Negatives)
print(C_Positives)
print(R_Positives)

x <- R_Positives[1]
X1 <- as.matrix(x)[1,]
y <- R_Negatives[1]
Y1 <- as.matrix(y)[1,]
Z1 <- X1+Y1
x <- C_Positives[1]
X2 <- as.matrix(x)[1,]
y <- C_Negatives[1]
Y2 <- as.matrix(y)[1,]
Z2 <- X2 + Y2
R_Total <- 2560102
C_Total <- 2548578

dif = R_Total - C_Total
print(dif)
Matrix <- data.frame("Measure" = c("Total","Sentiments","Positive","Negative"), "RiskCount" = c(R_Total,Z1,X1,Y1), "ControlCount" = c(C_Total,Z2,X2,Y2), stringsAsFactors = FALSE)


write.table(Matrix, file = "SentimentMatrix.txt", sep = "/",
            row.names = FALSE, col.names = TRUE, quote=FALSE)


R_Sentiment_Percent = ((Z1/R_Total)*100)
print(R_Sentiment_Percent)
C_Sentiment_Percent = ((Z2/C_Total)*100)
print(C_Sentiment_Percent) 

R_Negative_Percent = ((Y1/Z1)*100)
print(R_Negative_Percent)
C_Negative_Percent = ((Y2/Z2)*100)
print(C_Negative_Percent)
