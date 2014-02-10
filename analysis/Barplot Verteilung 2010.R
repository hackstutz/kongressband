####
# Barplot - Vergleich von Einkommen/Verm?gen im Jahr 2010
# nach Bev?lkerungsquintilen

##
# Packages laden
#install.packages("reshape2") 

library(reshape2)

## 
# Daten laden

setwd("U:/kongressband/data") 
estv.prop<-read.table("estv_proptab.csv", header = TRUE, sep = ";")

##
# Daten transformieren

names(estv.prop)[2] <- "1950"
names(estv.prop)[3] <- "Einkommen"
names(estv.prop)[4] <- "Verm?gen"
estvpr <- melt(estv.prop[,c('Perzentile','Einkommen','Verm?gen')],id.vars = 1)


## 
# Grafik ploten 

library(ggplot2)

g1<-ggplot(estvpr,aes(x = Perzentile,y = value,ymax=1,fill = variable)) + 
geom_bar(aes(fill = variable),stat="identity",position = "dodge") + 
geom_text(aes(label = paste0(value*100,"%"), y = value+0.02), size=4.5, position= position_dodge(width=1)) + 
  scale_fill_manual(values=c("#323232","#CCCCCC"),name = "")+
  ylab("Total") + 
xlab("Bev?lkerungs-Quintile") + geom_hline(yintercept=0.2,linetype="dotted") +
annotate("text", x = 1.15, y = 0.235, label = "Gleichverteilung") +
theme_bw()
g1

##
# Grafik als pfg speichern

pdf("U:/kongressband/figure/incwea2010.pdf",
    width=8, height=5)
g1
dev.off()


##
# Lorenzkurve





