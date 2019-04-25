## The R code snippet to retrieve the letters was obtained from Michel Toth's post.
setwd("D:/Thesis")
library(pdftools)      
library(rvest)       
library(XML)
require(tidyverse)
require(tidytext)
require(RColorBrewer)
require(gplots)
library("readtext", lib.loc="~/R/win-library/3.5")
theme_set(theme_bw(12))
DATA_DIR <- system.file("extdata/", package = "readtext")



dir <- "D:/Thesis"
Risk = readtext(paste0(dir, "/Corpora/Risk/*"), encoding ="UTF-8")
Control = readtext(paste0(dir, "/Corpora/Control/*"), encoding ="UTF-8")

### pull emotion words and aggregate by id and emotion terms
emotions <- Risk %>% 
  unnest_tokens(word, text) %>%                           
  anti_join(stop_words, by = "word") %>%                  
  filter(!grepl('[0-9]', word)) %>%
  left_join(get_sentiments("nrc"), by = "word") %>%
  filter(!(sentiment == "negative" | sentiment == "positive")) %>%
  group_by(doc_id, sentiment) %>%
  summarize( freq = n()) %>%
  mutate(percent=round(freq/sum(freq)*100)) %>%
  select(-freq) %>%
  ungroup()
### need to convert the data structure to a wide format
emo_box = emotions %>%
  spread(sentiment, percent, fill=0) %>%
  ungroup()
### color scheme for the box plots (This step is optional)
cols  <- colorRampPalette(brewer.pal(7, "Set3"), alpha=TRUE)(8)
boxplot2(emo_box[,c(2:9)], col=cols, lty=1, shrink=0.8, textcolor="red",        xlab="Emotion Terms", ylab="Emotion words count (%)", main="Distribution of emotion words count in risk group")


### calculate overall averages and standard deviations for each emotion term
overall_mean_sd <- emotions %>%
  group_by(sentiment) %>%
  summarize(overall_mean=mean(percent), sd=sd(percent))
### draw a bar graph with error bars
ggplot(overall_mean_sd, aes(x = reorder(sentiment, -overall_mean), y=overall_mean)) +
  geom_bar(stat="identity", fill="darkgreen", alpha=0.7) + 
  geom_errorbar(aes(ymin=overall_mean-sd, ymax=overall_mean+sd), width=0.2,position=position_dodge(.9)) +
  xlab("Emotion Terms") +
  ylab("Emotion words count (%)") +
  ggtitle("Emotion words expressed in Risk Group") + 
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  coord_flip( )

total_words_count <- Control %>%
  unnest_tokens(word, text) %>%  
  anti_join(stop_words, by = "word") %>%                  
  filter(!grepl('[0-9]', word)) %>%
  left_join(get_sentiments("nrc"), by = "word") %>%                        
  group_by(doc_id) %>%
  summarize(total= n()) %>%
  ungroup()

emotion_words_count <- Control %>% 
  unnest_tokens(word, text) %>%                           
  anti_join(stop_words, by = "word") %>%                  
  filter(!grepl('[0-9]', word)) %>%
  left_join(get_sentiments("nrc"), by = "word") %>%
  filter(!(sentiment == "negative" | sentiment == "positive" | sentiment == "NA")) %>%
  group_by(sentiment) 

emotions_to_total_words <- total_words_count %>%
  left_join(emotion_words_count, by="doc_id") %>%
  mutate(percent_emotions=round((emotions/total)*100,1))

