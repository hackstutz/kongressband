## program:     inequality.wealth
## task:        describe change of wealth inequality
## project:     inequality of income and wealth in switzerland
## subproject:  sgs-congressbook
## author:      Oliver Hümbelin
## date:        February2014

##
# load packages

library(reshape2)
library(ggplot2)

##
# Prepare data

# load data
setwd("/Users/oliverhuembelin/kongressband") 
wealth<-read.dta("data/vermoegen20131023.dta")

##
# Visualize

ggplot(welath, aes(x=Year,y=mdp))+
  geom_line(aes(x=Year,y=mdp))+
  xlab("Jahr") +
  scale_x_continuous(breaks=number_ticks(10))+
  ylab("BIP pro Kopf in 1990 GK$") +
  scale_y_continuous(limits=c(9000, 26000)) +
  theme_bw()


