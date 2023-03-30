#plyr can be used to manipulate data frames
library(plyr)
library(dplyr)
#ggplot is good for plotting
library(ggplot2)
#lmerTest loads mixed effects regressions and according t/z-tests
library(lmerTest)
library(caret)
library(ROCR)
library(pscl)
library(GGally)
library(patchwork)
library("Rlab") 
require(ROCR)

setwd('/Users/mehmetyoruten/Library/CloudStorage/OneDrive-bwedu/Documents/School/Master/CPI Lab/Thesis/Experiment/behavioral analyses/data/')

# Choose your data set
df <- read.csv("all3.csv", header = TRUE)
#df <- df[,-1]


# Converting into factor variables
df$blockNo<-as.integer(df$blockNo)
#df$cutNo<-as.factor(df$cutNo)
df$expTime<-as.factor(df$expTime)
df$control<-as.factor(df$control)
df$leaf<-as.factor(df$leaf)
df$keyCode<-as.factor(df$keyCode)

subjects = unique(df$participantID)
trgt_subjects = c('eb','mae','go', 're', 'da','js')

# Choose target participant

for (i in 1:6){
  participantID = trgt_subjects[i]
  trgtID = participantID
  trgt_df <- df[(df$control == 0) & (df$participantID == trgtID),]
  
  # TEST
  ###########################################################################
  # Regression with cumulative effort as the main predictor
  ###########################################################################
  m0_eff <- glm(correct ~ 1, data = trgt_df, family = "binomial")
  m1_eff <- glm(correct ~ normed_effortAll, data = trgt_df, family = "binomial")
  m2_eff <- glm(correct ~ normed_effortAll + expTime,  data = trgt_df, family = "binomial")
  m3_eff <- glm(correct ~ normed_effortAll*expTime , data = trgt_df, family = "binomial")
  m4_eff <- glm(correct ~ normed_effortAll*expTime + cutNo, data = trgt_df, family = "binomial")
  m5_eff <- glm(correct ~ normed_effortAll*expTime + cutNo + normed_segSize, data = trgt_df, family = "binomial")
  m6_eff <- glm(correct ~ normed_effortAll*expTime + cutNo + normed_segSize + normed_segCentDist, data = trgt_df, family = "binomial")
  m7_eff <- glm(correct ~ normed_effortAll*expTime + cutNo + normed_segSize + normed_segCentDist + normed_intDiff, data = trgt_df, family = "binomial")
  m8_eff <- glm(correct ~ normed_effortAll*expTime + cutNo + normed_segSize + normed_segCentDist + normed_intDiff + normed_intOrder, data = trgt_df, family = "binomial")
  
  anova_eff <- anova(m0_eff,m1_eff,m2_eff,m3_eff,m4_eff,m5_eff,m6_eff, m7_eff, m8_eff, test = "Chisq")
  anova_eff
  anova_eff <- data.frame(anova_eff)
  anova_eff['model'] <- 'effort'
  anova_eff['control'] <- 0
  anova_eff['id'] <- participantID
  anova_eff['predictor'] <- c('Random', 'Cum. Effort', 'Exp. Time', 'Effort:Time', 'Cut No.','Seg. Size', 'Seg. Dist', 'Int. Diff.','intOrder')
  
  # get probabilities of getting correct answers using model 3
  pHat <- predict(m4_eff, type = 'response', interval = 'confidence')
  df[(df$control == 0) & (df$participantID == trgtID) ,'pHat_effort'] <- pHat
  trgt_df["pHat_effort"] <- pHat
  

  
  ###########################################################################
  # Regression with cut number as the main predictor
  ###########################################################################
  m0 <- glm(correct ~ 1, data = trgt_df, family = "binomial")
  m1 <- glm(correct ~ cutNo, data = trgt_df, family = "binomial")
  m2 <- glm(correct ~ cutNo + expTime,  data = trgt_df, family = "binomial")
  m3 <- glm(correct ~ cutNo*expTime , data = trgt_df, family = "binomial")
  m4 <- glm(correct ~ cutNo*expTime + normed_effortAll, data = trgt_df, family = "binomial")
  m5 <- glm(correct ~ cutNo*expTime + normed_effortAll + normed_segSize, data = trgt_df, family = "binomial")
  m6 <- glm(correct ~ cutNo*expTime + normed_effortAll + normed_segSize + normed_segCentDist, data = trgt_df, family = "binomial")
  m7 <- glm(correct ~ cutNo*expTime + normed_effortAll + normed_segSize + normed_segCentDist + normed_intDiff, data = trgt_df, family = "binomial")
  m8 <- glm(correct ~ cutNo*expTime + normed_effortAll + normed_segSize + normed_segCentDist + normed_intDiff + normed_intOrder, data = trgt_df, family = "binomial")
  
  
  anova_CN <- anova(m0,m1,m2,m3,m4,m5, m6, m7,m8, test = "Chisq")
  anova_CN
  anova_CN <- data.frame(anova_CN)
  anova_CN['model'] <- 'cutNo'
  anova_CN['control'] <- 0
  anova_CN['id'] <- participantID
  anova_CN['predictor'] <- c('Random', 'Cut No', 'Exp. Time', 'Cut No:Time', 'Cum. Effort.','Seg. Size', 'Seg. Dist', 'Int. Diff.','intOrder')
  

  
  # Get probabilities of getting correct answers using model 3
  pHat <- predict(m3, type = 'response', interval = 'confidence')
  df[(df$control == 0) & (df$participantID == trgtID) ,'pHat_cutNo'] <- pHat
  trgt_df["pHat_cutNo"] <- pHat
  
  
  
  # CONTROL
  ###########################################################################
  # Regression with cross correlation results
  ###########################################################################
  # Specify the target control or test trials
  trgt_df <- df[(df$control == 1) & (df$participantID == trgtID),]
  
  m0_sim_cntrl <- glm(correct ~ 1, data = trgt_df, family = "binomial")
  m1_sim_cntrl <- glm(correct ~ 1 + normed_simScore, data = trgt_df, family = "binomial")
  m2_sim_cntrl <- glm(correct ~ 1 + normed_simScore + expTime, data = trgt_df, family = "binomial")
  m3_sim_cntrl <- glm(correct ~ 1 + normed_simScore + expTime + normed_segCentDist, data = trgt_df, family = "binomial")
  m4_sim_cntrl <- glm(correct ~ 1 + normed_simScore + expTime + normed_segCentDist + normed_intDiff, data = trgt_df, family = "binomial")
  m5_sim_cntrl <- glm(correct ~ 1 + normed_simScore + expTime + normed_segCentDist + normed_intDiff + normed_segSize, data = trgt_df, family = "binomial")
  
  anova_sim_cntrl <- anova(m0_sim_cntrl,m1_sim_cntrl,m2_sim_cntrl, m3_sim_cntrl, m4_sim_cntrl, m5_sim_cntrl, test = "Chisq")
  anova_sim_cntrl
  anova_sim_cntrl <- data.frame(anova_sim_cntrl)
  
  anova_sim_cntrl['model'] <- 'similarity'
  anova_sim_cntrl['control'] <- 1
  anova_sim_cntrl['id'] <- participantID
  anova_sim_cntrl['predictor'] <-  c('Random', 'Highest Similarity', 'Exp. Time', 'Seg Dist.', 'Int. Diff.', 'Seg. Size')
  
  # get probabilities of getting correct answers using model 3
  pHat <- predict(m5_sim_cntrl, type = 'response', interval = 'confidence')
  df[(df$control == 1) & (df$participantID == trgtID) ,'pHat_sim'] <- pHat
  
  ###########################################################################
  # Regression with closest cut no.
  ###########################################################################
  # Specify the target control or test trials
  trgt_df <- df[(df$control == 1) & (df$participantID == trgtID),]
  
  m0_cont_seg <- glm(correct ~ 1, data = trgt_df, family = "binomial")
  m1_cont_seg <- glm(correct ~ closestSeg, data = trgt_df, family = "binomial")
  m2_cont_seg <- glm(correct ~ closestSeg + expTime, data = trgt_df, family = "binomial")
  m3_cont_seg <- glm(correct ~ closestSeg*expTime, data = trgt_df, family = "binomial")
  m4_cont_seg <- glm(correct ~ closestSeg*expTime + normed_segSize, data = trgt_df, family = "binomial")
  m5_cont_seg <- glm(correct ~ closestSeg*expTime + normed_segSize + normed_segCentDist, data = trgt_df, family = "binomial")
  
  anova_cont_seg <- anova(m0_cont_seg, m1_cont_seg,m2_cont_seg, m3_cont_seg, m4_cont_seg, m5_cont_seg, test = "Chisq")
  anova_cont_seg
  anova_cont_seg <- data.frame(anova_cont_seg)
  
  anova_cont_seg['model'] <- 'closeSeg'
  anova_cont_seg['control'] <- 1
  anova_cont_seg['id'] <- participantID
  anova_cont_seg['predictor'] <-  c('Random', 'Closest Segment', 'Exp. Time', 'Seg Dist.', 'Int. Diff.', 'Seg. Size')
  
  # get probabilities of getting correct answers using model 3
  pHat <- predict(m5_cont_seg, type = 'response', interval = 'confidence')
  df[(df$control == 1) & (df$participantID == trgtID),'pHat_seg'] <- pHat
  
  # SAVE
  ###########################################################################
  # Save results
  ###########################################################################
  # Save ANOVA
  anova_df <- rbind(anova_CN, anova_eff, anova_sim_cntrl, anova_cont_seg)
  
  file_pth = '/Users/mehmetyoruten/Library/CloudStorage/OneDrive-bwedu/Documents/School/Master/CPI Lab/Thesis/Experiment/behavioral analyses/data/'
  trgt_file_name = paste(file_pth,participantID , '/',participantID, '_',"anova.csv", sep="")
  write.csv(anova_df, trgt_file_name, row.names=FALSE)
  
}


# Save updated df
trgt_file_name = paste(file_pth,"all.csv", sep="")
write.csv(df, trgt_file_name, row.names=FALSE)

