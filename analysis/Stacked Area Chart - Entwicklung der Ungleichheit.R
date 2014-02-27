####
# Entwicklung der Ungleichheit in der Schweiz nach Schichten 
##

####
# Idee: Wir möchten eine Grafik, die die Entwicklung des Wohlstands und 
# die Verteilung nach Quantilen aufzeichnet
# Lösung: Stacked Area Chart: http://nvd3.org/ghpages/stackedArea.html
###


####
# Packages laden




library(foreign)

####
# Daten laden

setwd("P:/WGS/FBS/ISS/Projekte laufend/SNF Ungleichheit/Valorisierung/Von Roll Er?ffnung")


##
# ESTV

###
# Daten sind aus Rudis Datei "steuerdaten20131024.dta"
# Ergänzend dazu wurde mit der Pareto-Interpelation (siehe Syntax Klohto)
# die kummulierten Einkommen nach Perzentilen geschätzt.

estv<-read.table("estv_oli.csv", header = TRUE, sep = ";")

##
# Fehlende Werte werden mit ZOO imputiert

library(zoo)
estvZoo <- zoo(estv)
index(estvZoo) <- estvZoo[,1]
estv<- na.approx(estvZoo)
estv<-data.frame(estv)


# Konsumentenpreisindex (Preise 1914)
# Dokument von der Nationalbank (?ber Rudi)
# Index wird f?r Preisse im Jahr 200 umgerechnet

kpi<-read.csv("KPI_1914BFS-aktuell.csv", header=T, sep = ";")
kpi$index_2000<-(kpi$Index_1914/960.2)*100


##
# Nominale Einkommen mit dem Konsumentenpreisindex deflationieren damit Vergleiche ?ber die Zeit 
# m?glich sind 

estv<-merge(estv,kpi,by="year") 
estv$share_p20_real <- estv$share_p20/(estv$index_2000/100)
estv$share_p80_real <- estv$share_p80/(estv$index_2000/100)
estv$share_p95_real<- estv$share_p95/(estv$index_2000/100)
estv$cinc_real <- estv$cinc/(estv$index_2000/100)


#############
# Version mit ggplot
#
# http://stackoverflow.com/questions/13644529/how-to-create-a-stacked-line-plot
#install.packages("ggplot2") 

library(ggplot2)

# Damit ein stacked flow Chart gemacht werden kann, m?ssen die Daten transformiert werden


##
# Variante mit 95% Perzentil


# Berechnung der Perzentilssumme
# Skala transformieren
# die Zahlen sind in 1000 Fr.-
# Mit der Division durch 1000^2 sind sie in Milliarden

estv$arme<-estv$share_p20_real/1000^2
estv$mittelere<-(estv$share_p80_real-estv$share_p20_real)/1000^2
estv$reiche<-(estv$share_p95_real-estv$share_p80_real)/1000^2
estv$sreiche<-(estv$cinc_real-estv$share_p95_real)/1000^2


# Jetzt muss ein reshape her

estv.graph<-reshape(estv,
varying = c("arme","mittelere","reiche","sreiche"),
v.names = "einkommen",
timevar = "Einkommensklassen",
times = c("Arme (<p20)","Mittelschicht (p20 bis p80)","Reiche (p80 bis p95)","Sehr reiche (p95 bis p100)"),
direction ="long")

# Jetzt k?nnen die Daten geplottet werden

estv.gap<-subset(estv.graph, year > 1993 & year < 2004)
number_ticks <- function(n) {function(limits) pretty(limits, n)}

# Gr?sse und Speicherort festlegen

#pdf("//wgs-s008.bfh.ch/Users/Staff/hlo1/Desktop/Poster/Grafiken/Entwicklung der Ungleichheit.pdf",height=550,width=900)

p<-ggplot(estv.graph, aes(x = year, y = einkommen, fill = Einkommensklassen),) +  
geom_area(position = 'stack') + 
geom_area( position = 'stack', colour="white", show_guide=FALSE) +
scale_fill_brewer(palette="Blues") +
scale_x_continuous(breaks=number_ticks(10))+
ylab("(steuerbares) Einkommen in Milliarden zu Preisen von 2000") + 
xlab("Jahre") +
scale_y_continuous(limits=c(0, 250))+
theme_bw()
#Gini-Zeitreihe
p + geom_area(data=estv.gap, aes(x = year, y = einkommen, fill = Einkommensklassen), position = 'stack',alpha=0.1, colour="white", show_guide=FALSE) +
annotate("text", x = 1950, y = 250,face="bold", label = "1950",size=4) +
annotate("text", x = 1950, y = 242,face="bold", label = "Gini=0.32",size=2.5)+
annotate("text", x = 1960, y = 250,face="bold", label = "1960",size=4) +
annotate("text", x = 1960, y = 242,face="bold", label = "Gini=0.34",size=2.5)+
annotate("text", x = 1970, y = 250,face="bold", label = "1970",size=4) +
annotate("text", x = 1970, y = 242,face="bold", label = "Gini=0.36",size=2.5)+
annotate("text", x = 1980, y = 250,face="bold", label = "1980",size=4) +
annotate("text", x = 1980, y = 242,face="bold", label = "Gini=0.35",size=2.5)+
annotate("text", x = 1990, y = 250,face="bold", label = "1990",size=4) +
annotate("text", x = 1990, y = 242,face="bold", label = "Gini=0.35",size=2.5) +
annotate("text", x = 2000, y = 250,face="bold", label = "2000",size=4,colour = "grey") +
annotate("text", x = 2000, y = 242,face="bold", label = "Gini=0.34",size=2.5,colour = "grey")+
annotate("text", x = 2010, y = 250,face="bold", label = "2010",size=4) +
annotate("text", x = 2010, y = 242,face="bold", label = "Gini=0.36",size=2.5)+
#Krisen
annotate("text", x = 1974, y = 135,face="bold", label = "?lkrise 1974",size=3,hjust = 0.5) +
annotate("text", x = 1990, y = 186,face="bold", label = "Strukturkrise der 90er",size=3,hjust = 0.5) +
annotate("text", x = 2009, y = 225,face="bold", label = "Finanzkrise 2009",size=3,hjust = 1)+
#Konjunkturanalyse
annotate("text", x = 1945, y = 220,face="bold", label = "Wachstumsperioden und Ungleichheit",size=4,hjust = 0)+
annotate("text", x = 1945, y = 212,face="bold", label = "1950 bis 1974: Gini +1.1% pro Jahr",size=3,hjust = 0)+
annotate("text", x = 1945, y = 205,face="bold", label = "1976 bis 1990: Gini +0.4% pro Jahr",size=3,hjust = 0)+
annotate("text", x = 1945, y = 198,face="bold", label = "2004 bis 2008: Gini +1.6% pro Jahr",size=3,hjust = 0)+
annotate("text", x = 1945, y = 178,face="bold", label = "Krisen und Ungleichheit",size=4,hjust = 0)+
annotate("text", x = 1945, y = 170,face="bold", label = "?lkrise (1974 bis 1976: Gini -2.3% pro Jahr",size=3,hjust = 0)+
annotate("text", x = 1945, y = 163,face="bold", label = "90er Krise (1990 bis 1994): Gini -2.1% pro Jahr",size=3,hjust = 0)+
annotate("text", x = 1945, y = 156,face="bold", label = "Finanzkrise (2008,2009): Gini -1.3%",size=3,hjust = 0)

#dev.off()








############
# Stacked area Chart with rCharts

##
# rCharts laden
#
# !!!!! Es gibt Probleme bei der Installation !!!!! 

library(devtools)
install_github('rCharts', 'ramnathv')

install.packages('rCharts-master.zip', lib="//wgs-s008.bfh.ch/Users/Staff/hlo1/Desktop/R Packages",repos = NULL)

.libPaths("//wgs-s008.bfh.ch/Users/Staff/hlo1/Desktop/R Packages")

require(rCharts)
library(reshape2)



##
# M?glicher Code f?r den stacked area chart 

data(economics, package = 'ggplot2')
ecm <- reshape2::melt(economics[,c('date', 'uempmed', 'psavert')], id = 'date')
p2 <- nPlot(value ~ date, group = 'variable', data = ecm, type = 'stackedAreaChart')
p2











