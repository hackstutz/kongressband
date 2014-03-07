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
library(foreign)

##
# Prepare data

# load data
setwd("/Users/oliverhuembelin/kongressband/") 
wealth<-read.dta("data/vermoegen1981_2010.dta")

# Prepare Data

wealth$Gini<-wealth$G*100

##
# load functions
number_ticks <- function(n) {function(limits) pretty(limits, n)}


##
# Visualize

ggplot(wealth, aes(x=year,y=Gini))+
  geom_line(aes(x=year,y=Gini))+
  geom_point(aes(x=year,y=Gini),size=3.5)+
  xlab("Jahr") +
  scale_x_continuous(breaks=number_ticks(10))+
  ylab("Gini") +
  scale_y_continuous(limits=c(82,85)) +
  theme_bw()


