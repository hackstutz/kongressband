####
# Barplot - Vergleich von Einkommen/VermÃ¶gen im Jahr 2010
# nach BevÃ¶lkerungsquintilen

##
# Packages laden
#install.packages("reshape2") 

library(reshape2)

## 
# Daten laden

#setwd("/Users/oliverhuembelin/kongressband/data") 
estv.prop<-read.table("data/estv_proptab.csv", header = TRUE, sep = ";")

##
# Daten transformieren

names(estv.prop)[2] <- "1950"
names(estv.prop)[3] <- "Einkommen"
names(estv.prop)[4] <- "Vermögen"
estvpr <- melt(estv.prop[,c('Perzentile','Einkommen','Vermögen')],id.vars = 1)
levels(estvpr$Perzentile) <- c("Q1", "Q2", "Q3","Q4","Q5") 

## 
# Grafik ploten 

library(ggplot2)

g1<-ggplot(estvpr,aes(x = Perzentile,y = value,ymax=1,fill = variable)) + 
geom_bar(aes(fill = variable),stat="identity",position = "dodge") + 
geom_text(aes(label = paste0(value*100,"%"), y = value+0.02), size=4.5, position= position_dodge(width=1)) + 
  scale_fill_manual(values=c("#323232","#CCCCCC"),name = "")+
  ylab("Total") + 
xlab("Quintile der Steuersubjekte") + geom_hline(yintercept=0.2,linetype="dotted")+scale_y_continuous(labels=c("0%","25%","50%","75%","100%")) +
annotate("text", x = 1.15, y = 0.235, label = "Gleichverteilung") +
theme_bw()
g1

##
# Grafik als pdf speichern

png("figure/incwea2010.png",
    width=800, height=600)
g1
dev.off()


##
# Lorenzkurve





