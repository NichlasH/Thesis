import nltk
import nltk.corpus 
import string
import re
import csv
import time
import os, sys, codecs
from nltk.text import Text
from nltk.tokenize import TweetTokenizer
from nltk.corpus import stopwords
from collections import Counter
from nltk.stem import WordNetLemmatizer 

start = time.time()  
lemmatizer = WordNetLemmatizer() 

tweet = TweetTokenizer(strip_handles=True)
# Setting Stopwords
stop_words = set(stopwords.words('english'))
# Updating stop words with punctuation
stop_words.update(['.', ',', '"', "'", '?', '!', ':', ';', '(', ')', '[', ']', '{', '}','/', '-','~','&','*','<','>','=','%'])
# updating stopwords with links
stop_words.update(['http','httpbitly','httptinyurl','://'])
# updating stopwords with Expressions and words of no impact
stop_words.update(['à¹ˆ','ã€','ã€','ã€‚','ã€','Ã©','|','ï¼','â€¦','â€™','à¹ˆ','^','ï¼Œ',')','à¹‰','à¸±','#p2','ã€‚','â€™','#tcot','à¸±','ã€','à¹ˆ','via','ã€'])
# updating stopwords with Contractions
stop_words.update(["i've","that's","can't", "i'll", "i'm",'que',"i'm",'your',"you're","i'd","i'm"])
# updating stopwords with Digits
stop_words.update(['0','1','2','3','4','5','6','7','8','9','10','0'])
# updating stopwords with Bot Words
stop_words.update(['handsome','Mystery','Sexy','Best','Free','Cute','Avaiable','attractive','free','sexy','hot','win','avaiable','cute',])





DATA_PATH = 'Thesis\\Files\\'
lemmatizer = WordNetLemmatizer()
# file_name = 'RiskTweets.txt'

file_name = '../Files/RiskTweets.txt'

POSITIVES = set()
NEGATIVES = set()

def remove_bom_inplace(filepath):
    """Removes BOM mark, if it exists, from a file and rewrites it in-place"""
    buffer_size = 4096
    bom_length = len(codecs.BOM_UTF8)
 
    with open(filepath, "r+b") as fp:
        chunk = fp.read(buffer_size)
        if chunk.startswith(codecs.BOM_UTF8):
            i = 0
            chunk = chunk[bom_length:]
            while chunk:
                fp.seek(i)
                fp.write(chunk)
                i += len(chunk)
                fp.seek(bom_length, os.SEEK_CUR)
                chunk = fp.read(buffer_size)
            fp.seek(-bom_length, os.SEEK_CUR)
            fp.truncate()


def directorySkip(s=DATA_PATH):
	path = os.path.dirname(os.path.abspath(__file__))
	if type(path) == str:
		i,j = len(path),0
		while (j!=2):
			i = i-1
			if path[i] == '\\':
				j = j + 1
		return path[0:i+1] + s
	return None

def getDataPath(s, endtag='.txt'):
	path =  directorySkip() + s + endtag
	return path

def loadFile(s, endtag='.txt'):
	list = []
	with open(getDataPath(s, endtag=endtag), "r") as file:
		for line in file:
			list.append(line.replace('\n', ''))
	return list

POSITIVES = set(loadFile("positives"))
NEGATIVES = set(loadFile("negatives"))

# def get_emotwordlist(filepath):
 #   with open(filepath, 'r', encoding="utf8",errors='ignore') as f:
  #      emotwordlist = [word.strip().lower() for word in f.read().split('\n') if len(word.strip()) > 1]
     #   print(*emotwordlist)
     #   return emotwordlist

def alter_prolonged(list):
	lemmatizer = WordNetLemmatizer()
	res = list.copy()
	for v in range(len(list)):
		i = 0
		j = -1
		w = list[v]
		while(i + 2 < len(w)):
			if (w[i] == w[i+1] and w[i+1] == w[i+2]):
				w = w[:i] + w[(i+1):]
				j = i
			else:
				i+= 1
		if (not (w in POSITIVES or w in NEGATIVES)) and j != -1:
			w = w[:j] + w[(j+1):]
		try:
			res[v] = lemmatizer.lemmatize(w)
		except:
			print("Could not lemmatize word '" + w + "'")
			res[v] = w
			pass
	return res


with open(file_name, 'r', encoding="utf8",errors='ignore') as f:
    text = f.read()
    # remove punctuation from each word  (What's -> Whats)
    list_of_words = [i.lower() for i in tweet.tokenize(text) if i.lower() not in stop_words]

    list_of_words = alter_prolonged(list_of_words)

    global wordcount

    wordcount = (len(list_of_words))

    fdist = Counter(list_of_words)

    dist = fdist.most_common(10000)

    RiskWords = '../Output/Risk/RiskWords.csv'

    with open(RiskWords, 'w', encoding="utf8",errors='ignore') as csvFile:
    	csv_out = csv.writer(csvFile, delimiter=",", lineterminator="\r\n")
    	csv_out.writerow(['Name','Count'])
    	for row in dist:
       		 csv_out.writerow(row)

    with open('../Output/Risk/RiskWords.txt', 'w', encoding="utf8",errors='ignore') as File:
    	File.write(('\n'.join('%s %s' % x for x in dist)))

    # emotword_set = set(get_emotwordlist('EmotionalWords.txt'))
    emotword_set = NEGATIVES
    emot_fdist = Counter()

    # filtering non emotional words
    for word in emotword_set:
        if word in fdist:
            emot_fdist[word] = fdist[word]
    



    dist = emot_fdist.most_common(10000)

    RiskNegatives = '../Output/Risk/RiskNegatives.csv'

    # rt = retweet
    with open(RiskNegatives, 'w', encoding="utf8",errors='ignore') as csvFile:
    	csv_out = csv.writer(csvFile, delimiter=",", lineterminator="\r\n")
    	csv_out.writerow(['Name','Count'])
    	for row in dist:
       		 csv_out.writerow(row)
       		 # rt = retweet 

    with open('../Output/Risk/RiskNegatives.txt', 'w', encoding="utf8",errors='ignore') as File:
    	File.write(('\n'.join('%s %s' % x for x in dist)))

 
    # emotword_set = set(get_emotwordlist('EmotionalWords.txt'))
    emotword_set = POSITIVES
    emot_fdist = Counter()

    # filtering non emotional words
    for word in emotword_set:
        if word in fdist:
            emot_fdist[word] = fdist[word]    



    dist = emot_fdist.most_common(10000)

    RiskPositives = '../Output/Risk/RiskPositives.csv'

# rt = retweet
    with open(RiskPositives, 'w', encoding="utf8",errors='ignore') as csvFile:
    	csv_out = csv.writer(csvFile, delimiter=",", lineterminator="\r\n")
    	csv_out.writerow(['Name','Count'])
    	for row in dist:
       		 csv_out.writerow(row)


# rt = retweet 
    with open('../Output/Risk/RiskPositives.txt', 'w', encoding="utf8",errors='ignore') as File:
    	File.write(('\n'.join('%s %s' % x for x in dist)))




remove_bom_inplace('../Output/Risk/RiskNegatives.csv')
remove_bom_inplace('../Output/Risk/RiskPositives.csv')
remove_bom_inplace('../Output/Risk/RiskWords.csv')


end = time.time()
seconds = (end - start)
minutes = (seconds/60)
print("ControlFreq Script Done")
print("This Script took " + str(minutes) + " To run")
print("The Text Corpus Contatins " + str(wordcount) + " Words")
