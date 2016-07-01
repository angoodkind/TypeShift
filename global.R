library(tidyr)
library(dplyr)
library(reshape)

# read in CSV and format
df <- read.csv('tokens.csv',sep='|',na.strings = "")
# df <- read.csv('token_viz_debug.csv',sep=',',na.strings = "")
df <- within(df, user.answer <- paste(UserID, QuestionID, sep='-'))
df$Token <- as.character(df$Token)
df <- df[ , !names(df) %in% c('CogLoad')]
df$TokenTime <- df$EndTime - df$StartTime
# keystroke rate = keystroke count / time
df$KeystrokeRate <- df$KeystrokeCount/df$TokenTime
# add a column of cumulative total keystrokes
df <- transform(df, cumul.ans.keystroke = ave(KeystrokeCount, user.answer,
                                              FUN=cumsum))
# normalize keystroke rate across users
df$KeystrokeRate.Z <- (df$KeystrokeRate - min(df$KeystrokeRate))/
  (max(df$KeystrokeRate)-min(df$KeystrokeRate))

# normalized cumulative time progress
df$Relative.Time.Progress <- df$EndTime/
  ave(df$EndTime,df$user.answer,FUN=max)
df$Percent.Complete <- 100*df$Relative.Time.Progress

# add user information
df.userInfo <- read.csv('user_data.csv',sep=',',na.strings="")
df.userInfo <- df.userInfo[!duplicated(df.userInfo[, 1]), ]
df.userInfo$NativeEnglish <- ifelse(df.userInfo$FirstLanguage=='English','English',
                                    ifelse(is.na(df.userInfo$FirstLanguage),'Non-English',
                                           'Non-English'))
df.userInfo <- within(df.userInfo, Demog.Info <- paste("User: ", sprintf("%02d",UserID),
                                                       ", Age: ", Age,
                                                       ", Gender: ", toupper(Gender),
                                                       ", L1: ", FirstLanguage,
                                                       sep=""))
df <- merge(df,df.userInfo,by="UserID")

# add question information
df.questionInfo <- read.csv('question_data.csv',sep=',', na.strings="")
df.questionInfo$QuestionText <- as.character(df.questionInfo$QuestionText)
df <- merge(df,df.questionInfo,by="QuestionID")

# add POS information
df.pos <- read.csv("POS.csv",sep=',')
df <- merge(df,df.pos, by='POS')

# write.table(df, "FullTokenInfo.csv", sep='|', row.names=F)