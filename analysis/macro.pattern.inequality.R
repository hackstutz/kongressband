

## program:     macro.pattern.inequality 
## task:        find patterns in macro changes associated with inequality
## project:     inequality of income and wealth in switzerland
## subproject:  sgs-congressbook
## author:      Oliver Hümbelin
## date:        February2014

##
# load packages

library(reshape2)
library(ggplot2)
library(zoo)
library(plyr)
#library(devtools)
#install_github("rCharts","ramnathv")
#library(rCharts)

##
# Prepare data

# load data

setwd("/Users/oliverhuembelin/kongressband") 
macrodata<-read.table("data/Macro_indicators_gini.csv", header = TRUE, sep = ";")

# Fill gap's with linear interpolation

macrodataZoo <- zoo(macrodata)
index(macrodataZoo) <- macrodataZoo[,1]
macrodata<- na.approx(macrodataZoo)
macrodata<-data.frame(macrodata)


# Restrict dataset to 1950-2010

macro<-subset(macrodata,Year>1949)


# Adding variables wiht change rates
colnames(macro)[which(colnames(macro) == 'mdp.g')] <- 'Mdp.g'
growth<-function(x) c(NA,diff(log(x))*100)
macro.g<-sapply(macro[,c(2:16)],FUN=growth)
colnames(macro.g)<-paste(colnames(macro.g),".g",sep="")
macro<-cbind(macro,macro.g)


###
# Analysis


# Gini from 1950 to 2010

subset1<-subset(macro,Year<1995)
subset2<-subset(macro,Year>1993 & Year<2004)
subset3<-subset(macro,Year>2002)

min(macro$Gini)
max(macro$Gini)
macro$Year[macro$Gini==min(macro$Gini)]
macro$Year[macro$Gini==max(macro$Gini)]

ggplot(macro, aes(x=Year,y=Gini))+
  geom_line(aes(x=Year,y=Gini),subset1)+
  geom_line(aes(x=Year,y=Gini),subset3)+
  geom_line(aes(x=Year,y=Gini),linetype="dotted",subset2) +
  xlab("Jahr") +
  annotate("text", x = 1955, y = 31, label = "Min Gini=30.9",size=3) +
  annotate("text", x = 1977, y = 36, label = "Max Gini=35.9",size=3) +
  theme_bw()

##
# Gini and economic growth

par(mfrow = c(1,2))

attach(macro)
plot(Year, Gini, axes=F, ylim=c(min(Gini),max(Gini)), xlab="", ylab="",type="l",col="black", main="",xlim=c(1950,2010))
#points(Year,Gini,pch=20,col="black")
axis(2, ylim=c(0,max(Gini)),col="black",lwd=2)
mtext(2,text="Ungleichheit (Gini)",line=2)
par(new=T)
plot(Year, mdp, axes=F, ylim=c(min(mdp,na.rm=TRUE),max(mdp,na.rm=TRUE)), xlab="", ylab="", 
     type="l",lty=2, main="",xlim=c(1950,2010),lwd=2)
axis(4, ylim=c(min(mdp,na.rm=TRUE),max(mdp,na.rm=TRUE)),lwd=2,line=-1)
#points(Year, mdp,pch=20)
mtext(4,text="BIP pro Kopf (1990 $)",line=1)
axis(1,pretty(range(Year),10))
mtext("Jahre",side=1,col="black",line=2)
legend(x=1987,y=17000,legend=c("Ungleichheit","BIP pro Kopf "),lty=c(1,2))
detach(macro)

# Wirtschaftswachstum (mit Change rates)

r<-cor.test(x=macro$Gini.g,y=macro$mdp.g,use="complete.obs",method="pearson")
r

# Visualize correlation..
# ... with ggplot2
g.mdp<-ggplot(macro,aes(x=Gini.g,y=mdp.g)) +
  geom_point(shape=1)+ 
  geom_smooth(method=lm,colour="black") +
  theme_bw() + 
  annotate("text", x = 2, y = -0.02, label = "r=0.48") +
  ylab("Wachstumsrate (in Prozent)") + 
  xlab("Veränderung Gini (in Prozent)") 
g.mdp

# ... with classic plot
attach(macro)
plot(Gini.g, mdp.g, axes=F, ylim=c(min(mdp.g,na.rm=TRUE),max(mdp.g,na.rm=TRUE)), xlab="", ylab="",type="p",col="black", main="",xlim=c(min(Gini.g,na.rm=TRUE),max(Gini.g,na.rm=TRUE)))
axis(2, ylim=c(-7,7),col="black",lwd=2)
mtext(2,text="Wachstumsrate (in Prozent)",line=2)
axis(1,xlim=c(-4,4),col="black",lwd=2)
mtext("Veränderung Gini (in Prozent",side=1,col="black",line=2)
abline(lm(Gini.g~mdp.g))
detach(macro)
par(mfrow = c(1,1))

##
# time-series with two axis # doesn't work

#http://stackoverflow.com/questions/18535665/rcharts-adding-second-y-axis-to-time-series

#h<-Highcharts$new()
#h$xAxis(categories = macro$year)
#h$yAxis(list(title = list(text = 'Ungleichheit')), list(title = list(text = 'BIP pro Person (1990$)"'), opposite = TRUE))
#h$series(name="Ungleichheit",type="spline",data=macro$Gini,yAxis=1)
#h$series(name="BIP pro Person (1990$)",type="spline",data=macro$mdp,yAxis=2)
#h$printChart()



#######
# Correlation and Regressionmodel

cor(x=macro$Gini.g,y=macro[,c(19:33)],use="pairwise.complete.obs",method="pearson")

model<-lm(Gini.g~1+foreigner.g+altersquotient.g+unempILO.g+sozialquote.g+mdp.g,macro)
summary(model)
model.2<-lm(Gini.g~1+sozialquote.g+mdp.g+HHp1,macro)
summary(model.2)
model<-lm(Gini.g~1+foreigner.g+altersquotient.g+unempILO.g+sozialquote.g+mdp.g+sector2.g+sector3.g,macro)
summary(model)

##
# Kuznet müsste speziell modelliert werden. Es ist ja eine Gleichgewichtsfrage. Mit Interaktionen.


####
# Scatterplot with growth rates

# Ausländeranteil (Gesamtbevölkerung)

r<-cor(x=macro$Gini.g,y=macro$foreigner.g,use="complete.obs",method="pearson")
r

g1<-ggplot(macro,aes(x=Gini.g,y=foreigner.g)) +
geom_point(shape=1)+ 
  geom_smooth(method=lm) +
  theme_bw() + 
  annotate("text", x = 2.5, y = 1, label = "r=0.22") 
g1 + ggtitle("Ausländeranteil (Gesamtbevölkerung)")

# Ausländeranteil (Erwerbsbevölkerung)

r<-cor(x=macro$Gini.g,y=macro$foreigner_2.g,use="complete.obs",method="pearson")
r

g2<-ggplot(macro,aes(x=Gini.g,y=foreigner_2.g)) +
  geom_point(shape=1)+ 
  geom_smooth(method=lm) +
  theme_bw() + 
  annotate("text", x = 2.5, y = -5, label = "r=0.33") 
g2 + ggtitle("Ausländeranteil (Erwerbsbevölkerung)")

# Altersquotient

r<-cor(x=macro$Gini.g,y=macro$altersquotient.g,use="complete.obs",method="pearson")
r

g2<-ggplot(macro,aes(x=Gini.g,y=foreigner_2.g)) +
  geom_point(shape=1)+ 
  geom_smooth(method=lm) +
  theme_bw() + 
  annotate("text", x = 2.5, y = -5, label = "r=0.33") 
g2 + ggtitle("Ausländeranteil (Erwerbsbevölkerung)")

  





