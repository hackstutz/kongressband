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
library(sjPlot)
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
# Graphs

# Gini
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
  scale_x_continuous(breaks=number_ticks(10)) +
  annotate("text", x = 1955, y = 31, label = "Min Gini=30.9",size=3) +
  annotate("text", x = 1977, y = 36, label = "Max Gini=35.9",size=3) +
  theme_bw()


# Wirtschaftswachstum
ggplot(macro, aes(x=Year,y=mdp))+
  geom_line(aes(x=Year,y=mdp))+
  xlab("Jahr") +
  #scale_x_continuous(breaks=number_ticks(10))+
  ylab("BIP pro Kopf in 1990 GK$") +
  scale_y_continuous(limits=c(9000, 26000)) +
  theme_bw() +
  annotate("text", x = 1974, y = 19000, label = "Ölkrise 1974",size=3) +
  annotate("text", x = 1990, y = 22000, label = "Strukturkrise der 90er",size=3) +
  annotate("text", x = 2008, y = 26000, label = "Finanzkrise",size=3)

g.mdp<-ggplot(macro,aes(x=mdp.g,y=Gini.g)) +
  geom_point(shape=1)+ 
  geom_smooth(method=lm,colour="black") +
  theme_bw() + 
  annotate("text", x = -4, y = 2, label = "r=0.48") +
  ylab("Veränderung Gini (in Prozent)") + 
  xlab("Wirtschaftswachstum (in Prozent)") 
g.mdp

r<-cor.test(x=macro$Gini.g,y=macro$mdp.g,use="complete.obs",method="pearson")
r

##
# Entwicklung Sozialquote
ggplot(macro, aes(x=Year,y=sozialquote))+
  geom_line(aes(x=Year,y=sozialquote))+
  xlab("Jahr") +
  scale_x_continuous(breaks=number_ticks(10))+
  ylab("Sozialquote") +
  theme_bw() +
  annotate("text", x = 1975, y = 19, label = "Erhöhung AHV-Renten",size=3) +
  annotate("text", x = 2000, y = 22, label = "Reaktion auf Strukturkrise",size=3)

g.sq<-ggplot(macro,aes(x=sozialquote.g,y=Gini.g)) +
  geom_point(shape=1)+ 
  geom_smooth(method=lm,colour="black") +
  theme_bw() + 
  annotate("text", x = 10, y = 2, label = "r=-0.56") +
  ylab("Veränderung Gini (in Prozent)") + 
  xlab("Veränderung Sozialquote (in Prozent)") 
g.sq

r<-cor.test(x=macro$Gini.g,y=macro$sozialquote.g,use="complete.obs",method="pearson")
r

##
# Sozialausgaben

ggplot(macro, aes(x=Year,y=sozialausgaben))+
  geom_line(aes(x=Year,y=sozialausgaben))+
  xlab("Jahr") +
  scale_x_continuous(breaks=number_ticks(10))+
  ylab("Sozialausgaben") +
  theme_bw()



# Anteil 1-Personen Haushalte
ggplot(macro, aes(x=Year,y=HHp1))+
  geom_line(aes(x=Year,y=HHp1))+
  xlab("Jahr") +
  scale_x_continuous(breaks=number_ticks(10))+
  ylab("Anteil 1-Personen Haushalte ") +
  scale_y_continuous(limits=c(0, 50)) +
  theme_bw()

g.hhp1<-ggplot(macro,aes(x=HHp1.g,y=Gini.g)) +
  geom_point(shape=1)+ 
  geom_smooth(method=lm,colour="black") +
  theme_bw() + 
  annotate("text", x = 0.5, y = 2.5, label = "r=-0.04") +
  ylab("Veränderung Gini (in Prozent)") + 
  xlab("Veränderung Anteil 1-Personen HH (in Prozent)") 
g.hhp1

r<-cor.test(x=macro$Gini.g,y=macro$HHp1.g,use="complete.obs",method="pearson")
r


# Ausländeranteil
ggplot(macro, aes(x=Year,y=foreigner))+
  geom_line(aes(x=Year,y=foreigner))+
  xlab("Jahr") +
  scale_x_continuous(breaks=number_ticks(10))+
  ylab("Ausländeranteil ") +
  scale_y_continuous(limits=c(0, 30)) +
  theme_bw()

g.f<-ggplot(macro,aes(x=foreigner.g,y=Gini.g)) +
  geom_point(shape=1)+ 
  geom_smooth(method=lm,colour="black") +
  theme_bw() + 
  annotate("text", x = 0.5, y = 2.5, label = "r=-0.22") +
  ylab("Veränderung Gini (in Prozent)") + 
  xlab("Veränderung Ausländeranteil(in Prozent)") 
g.f

r<-cor.test(x=macro$Gini.g,y=macro$foreigner.g,use="complete.obs",method="pearson")
r

##
# Gini and economic growth (in one plot)

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

# Visualize correlation with scatterplot..
# ...  ggplot2
g.mdp<-ggplot(macro,aes(x=mdp.g,y=Gini.g)) +
  geom_point(shape=1)+ 
  geom_smooth(method=lm,colour="black") +
  theme_bw() + 
  annotate("text", x = -4, y = 2, label = "r=0.48") +
  ylab("Veränderung Gini (in Prozent)") + 
  xlab("Wachstumsrate (in Prozent)") 
g.mdp

# ... with classic plot # switch Gini to y-axis!!!
attach(macro)
plot(Gini.g, mdp.g, axes=F, ylim=c(min(mdp.g,na.rm=TRUE),max(mdp.g,na.rm=TRUE)), xlab="", ylab="",type="p",col="black", main="",xlim=c(min(Gini.g,na.rm=TRUE),max(Gini.g,na.rm=TRUE)))
axis(2, ylim=c(-7,7),col="black",lwd=2)
mtext(2,text="Wachstumsrate (in Prozent)",line=2)
axis(1,xlim=c(-4,4),col="black",lwd=2)
mtext("Veränderung Gini (in Prozent",side=1,col="black",line=2)
abline(lm(mdp.g~Gini.g))
detach(macro)
par(mfrow = c(1,1))





#######
# Analysis assoication patterns

##
# Correlation

cor(x=macro$Gini.g,y=macro[,c(19:33)],use="pairwise.complete.obs",method="pearson")

##
# Regression

# simple static model
model.stat<-lm(Gini~1+sozialquote+mdp+HHp1,macro)
summary(model.stat)

# simple static model accounting for trend
model.stat.trend<-lm(Gini~1+sozialquote+mdp+HHp1+Year,macro)
summary(model.stat.trend)


# simple model (sozialquote, gdp and hh1) First difference model
model.fd<-lm(Gini.g~1+sozialquote.g+mdp.g+HHp1.g,macro)
summary(model.fd)
plot(model.fd)

# testing for serial correlation
library(lmtest)
dwtest(model.fd)

# simple model with lag
library(dyn)
model.lag<-dyn$lm(ts(Gini.g)~1+ts(sozialquote.g)+ts(mdp.g)+ts(HHp1.g)+lag(ts(Gini.g),-1),macro)
summary(model.lag)

# more complex models (with less observations)

# Model 57 obs
model.57<-lm(Gini.g~1+sozialquote.g+mdp.g+foreigner.g+HHp1.g+altersquotient_2.g,macro)
summary(model.57)

# Model 49 obs
model.49<-lm(Gini.g~1+sozialquote.g+mdp.g++HHp1.g+uniondensity+sector2.g+sector3.g+altersquotient.g+foreigner.g,macro)
summary(model.49)

sum(!is.na(macro$Gini.g))
sum(!is.na(macro$foreigner.g))
sum(!is.na(macro$foreigner_2.g))
sum(!is.na(macro$altersquotient.g))
sum(!is.na(macro$altersquotient_2.g))
sum(!is.na(macro$unempILO.g))
sum(!is.na(macro$HHp1.g))
sum(!is.na(macro$HHp1Child.g))
sum(!is.na(macro$sozialquote.g))
sum(!is.na(macro$sozialausgaben.g))
sum(!is.na(macro$uniondensity.g))
sum(!is.na(macro$mdp.g))
sum(!is.na(macro$sector1.g))
sum(!is.na(macro$sector2.g))
sum(!is.na(macro$sector3.g))

##
# Paste Regression results in a format, i can use in word

sjt.lm(model.49,model.fd)

sjt.lm(model.fd,
       labelDependentVariables=c("Veränderung Gini"),
       labelPredictors=c("Sozialquote", "BIP pro Kopf", "Anteil 1-P.HH"),
       showStdBeta=FALSE, pvaluesAsNumbers=TRUE, showAIC=FALSE,
       separateConfColumn=T,
       file="MacroModell1.html")

sjt.lm(model.49,
       labelDependentVariables=c("Veränderung Gini"),
       labelPredictors=c("Sozialquote", "BIP pro Kopf", "Anteil 1-P.HH","Gewerkschaftsdichte","Beschäftigte 2.Sektor","Beschäftigte 3.Sektor","Altersquotient","Ausländer"), separateConfColumn=T,
       showStdBeta=FALSE, pvaluesAsNumbers=TRUE, showAIC=FALSE,
       file="MacroModell2.html")




####
# Weitere Scatterplots

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

  





