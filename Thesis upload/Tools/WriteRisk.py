import time
start = time.time()
TweetCount = 0
# file_names from which fav_users tweets needs to be extracted, like: [Tweets06.txt','Tweets07.txt','Tweets08.txt',]
tweets_file_names = ['../Files/Tweets06.txt','../Files/Tweets07.txt','../Files/Tweets08.txt','../Files/Tweets09.txt','../Files/Tweets10.txt','../Files/Tweets11.txt','../Files/Tweets12.txt',]


# fav_users_file_names users whose tweets needs to be extracted, like: ['List.txt', 'AddictList.txt', 'LastList.txt'...]
fav_users_file_names = ['../R/RiskList.txt',]

TweetCount = 0
fav_users = set()
for file_name in fav_users_file_names:
    with open(file_name,'r') as f:
        fav_users.update(f.read().strip().split('\n'))


fav_f = open('../Files/RiskTweets.txt', 'w', encoding="utf8",errors='ignore')

# Creating Dummy List
# Splitting the tweet string into two strings, saving the url part without 'U' in the new url var
def check_user_twt(lines):
    global TweetCount
    if lines != ['T','U','W']:
        url = lines[1].strip().split('\t')[1]
        tweet = lines[2].strip().split('\t')[1]
        if url in fav_users:
            fav_f.write(tweet)
            fav_f.write(' ')
            TweetCount +=1
            print(TweetCount)

for file_name in tweets_file_names:
    with open(file_name, 'r', encoding="utf8",errors='ignore') as f:

        j=0
        lines = ['T','U','W']
        for i,line in enumerate(f):
            print('.',end='')
            # first line or blank lines
            if i%4 == 0:
                # it's a blank line
                if i:
                    j=0
                    try:
                        check_user_twt(lines)
                        lines = ['T','U','W']
                    except Exception as e:
                        print(e)

            # curate T,U,W
            else:
                lines[j]=line.strip()
                j+=1


        # consume-if-any-tweet-left
        check_user_twt(lines)
            
        
                    
fav_f.close()


end = time.time()
seconds = (end - start)
minutes = (seconds/60)
print("WriteRisk Script Done")
print("This Script took " + str(minutes) + " Minutes To run")
print("This Script Mined " + str(TweetCount) + " Tweets")



'''

i
0 count                             lines = ['T','U','W']                                                              #j     #initial
1 T     2009-06-01 21:43:59         lines = ['T     2009-06-01 21:43:59 ','U','W']                                      0
2 U     http://twitter.com/nrl      lines = ['T     2009-06-01 21:43:59 ','U        http://twitter.com/nrl','W']        1
3 W     This                        lines = ['T     2009-06-01 21:43:59 ','U        http://twitter.com/nrl','This']     2
4                                   lines = ['T','U','W']                                                               3     #check_user_twt #reset
5 T     2009-06-01 21:47:23                                                                                             0
6 U     http://twitter.com/tv                                                                                           1
7 W     Is                                                                                                              2
if file last line is W instead of a blank we would be out of loop and since we have'nt call check_user_twt and perform #reset ie lines = ['T','U','W'] 
when we call check_user_twt our lines=['T       2009-06-01 21:47:23','U     http://twitter.com/tv','W       Is'] != ['T','U','W'] becomes True
and we would be able to perform check this tweet is of fav_user. 

while if the last line was blank we would have called #check_user_twt and did a #reset of lines to ['T','U','W'] in loop itself so when we call check_user_twt function outside of loop
if condition lines != ['T','U','W'] will be False as lines contain ['T','U','W']

'''