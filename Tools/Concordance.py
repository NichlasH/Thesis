import os
import nltk.corpus  
from nltk.text import Text 
import nltk
import nltk.corpus 
import string
import re
import csv
import os, sys, codecs
from nltk.text import Text
from nltk.tokenize import TweetTokenizer
from nltk.corpus import stopwords
from collections import Counter
from nltk.stem import WordNetLemmatizer 
  


tweet = TweetTokenizer(strip_handles=True)




DATA_PATH = 'Thesis\\Files\\'

# file_name = 'RiskTweets.txt'

file_name = '../Files/RiskTweets.txt'




# def get_emotwordlist(filepath):
 #   with open(filepath, 'r', encoding="utf8",errors='ignore') as f:
  #      emotwordlist = [word.strip().lower() for word in f.read().split('\n') if len(word.strip()) > 1]
     #   print(*emotwordlist)
     #   return emotwordlist



with open(file_name, 'r', encoding="utf8",errors='ignore') as f:
    text = f.read()

    # remove punctuation from each word  (What's -> Whats)
    list_of_words = tweet.tokenize(text)

  #Sorry, lol check
  #Check LMAO (More Used in R, hope for Negative Usage in Risk And Pos in C)
  #Check Work (More Used in C, hope for Negative Usage in Risk And Pos in C)

    list_of_words = Text(list_of_words)    
    list_of_words.concordance("Madden")
   