#R script pour faire des distributions
#!/usr/bin/env Rscript
library(lattice)
library(VennDiagram) # pour les diagrammes de venn

# LECTURE DU FICHIER
args = commandArgs(trailingOnly=TRUE)
annot.file = paste(args[1],args[2],sep="/")
annot.res = paste(args[1],"Résultats",args[2],sep="/")
annotations = read.table(annot.file, h=TRUE,na.strings=".")


# dim(annotations)
# head(annotations) 

# INITIALISATION DES SEUILS Version Conservative
lim.QDc = 21
lim.FSc = 5
lim.MQc = 58
lim.MQRankSumc = -0.5
lim.ReadPosRankSumc = -0.5
lim.SORc = 1.3

# INITIALISATION DES SEUILS Version Exhaustive
lim.QDe = 6
lim.FSe = 15
lim.MQe = 54
lim.MQRankSume = -2.5
lim.ReadPosRankSume = -1.3
lim.SORe = 2.5

# CREATION DES FIGURES
 pdf(paste(annot.res,"Filtres et Diagrammes de Venn.pdf",sep="_"),height = 10, width = 16)
  par(mfrow=c(1,2)) 
 
  prop.QDc=length( which(annotations$QD >lim.QDc)) / nrow(annotations)
  plot(density(annotations$QD,na.rm=T),main="QD (Conservative)", sub = paste("Filtre: QD >",lim.QDc,"( = ", signif(prop.QDc,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de QD", ylab = "Densité"  )
  abline(v=lim.QDc, col="red")
  
  prop.QDe=length( which(annotations$QD >lim.QDe)) / nrow(annotations)
  plot(density(annotations$QD,na.rm=T),main="QD (Exhaustive)", sub = paste("Filtre: QD >",lim.QDe,"( = ", signif(prop.QDe,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de QD", ylab = "Densité"  )
  abline(v=lim.QDe, col="red")

  prop.FSc=length( which(annotations$FS < lim.FSc)) / nrow(annotations)
  plot(density(annotations$FS,na.rm=T),main="FS (Conservative)", sub = paste("Filtre: FS <",lim.FSc,"( = ", signif(prop.FSc,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de FS", ylab = "Densité" )
  abline(v=lim.FSc, col="red")
  
  prop.FSe=length( which(annotations$FS < lim.FSe)) / nrow(annotations)
  plot(density(annotations$FS,na.rm=T),main="FS (Exhaustive)", sub = paste("Filtre: FS <",lim.FSe,"( = ", signif(prop.FSe,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de FS", ylab = "Densité" )
  abline(v=lim.FSe, col="red")

  prop.MQc=length( which(annotations$MQ > lim.MQc)) / nrow(annotations)
  plot(density(annotations$MQ,na.rm=T),main="MQ (Conservative)", sub = paste("Filtre: MQ >",lim.MQc,"( = ", signif(prop.MQc,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de MQ", ylab = "Densité" )
  abline(v=lim.MQc, col="red")
  
  prop.MQe=length( which(annotations$MQ > lim.MQe)) / nrow(annotations)
  plot(density(annotations$MQ,na.rm=T),main="MQ (Exhaustive)", sub = paste("Filtre: MQ >",lim.MQe,"( = ", signif(prop.MQe,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de MQ", ylab = "Densité" )
  abline(v=lim.MQe, col="red")

  prop.MQRankSumc=length( which(annotations$MQRankSum > lim.MQRankSumc & annotations$MQRankSum < -lim.MQRankSumc)) / nrow(annotations)
  plot(density(annotations$MQRankSum,na.rm=T),main="MQRankSum (Conservative)", sub = paste("Filtre: MQRankSum >",lim.MQRankSumc," & < ",-lim.MQRankSumc,"( = ", signif(prop.MQRankSumc,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de MQRankSum", ylab = "Densité" )
  abline(v=lim.MQRankSumc, col="red")
  abline(v=-lim.MQRankSumc, col="blue")
  
  prop.MQRankSume=length( which(annotations$MQRankSum > lim.MQRankSume & annotations$MQRankSum < -lim.MQRankSume)) / nrow(annotations)
  plot(density(annotations$MQRankSum,na.rm=T),main="MQRankSum (Exhaustive)", sub = paste("Filtre: MQRankSum >",lim.MQRankSume," & < ",-lim.MQRankSume,"( = ", signif(prop.MQRankSume,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de MQRankSum", ylab = "Densité" )
  abline(v=lim.MQRankSume, col="red")
  abline(v=-lim.MQRankSume, col="blue")

  prop.ReadPosRankSumc=length( which(annotations$ReadPosRankSum > lim.ReadPosRankSumc & annotations$ReadPosRankSum < -lim.ReadPosRankSumc )) / nrow(annotations)
  plot(density(annotations$ReadPosRankSum,na.rm=T),main="ReadPosRankSum (Conservative)", sub = paste("Filtre: ReadPosRankSum >",lim.ReadPosRankSumc," & < ",-lim.ReadPosRankSumc,"( = ", signif(prop.ReadPosRankSumc,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de ReadPosRankSum", ylab = "Densité"  )
  abline(v=lim.ReadPosRankSumc, col="red")
  abline(v=-lim.ReadPosRankSumc, col="blue")
  
  prop.ReadPosRankSume=length( which(annotations$ReadPosRankSum > lim.ReadPosRankSume & annotations$ReadPosRankSum < -lim.ReadPosRankSume )) / nrow(annotations)
  plot(density(annotations$ReadPosRankSum,na.rm=T),main="ReadPosRankSum (Exhaustive)", sub = paste("Filtre: ReadPosRankSum >",lim.ReadPosRankSume," & < ",-lim.ReadPosRankSume,"( = ", signif(prop.ReadPosRankSume,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de ReadPosRankSum", ylab = "Densité"  )
  abline(v=lim.ReadPosRankSume, col="red")
  abline(v=-lim.ReadPosRankSume, col="blue")

  prop.SORc=length( which(annotations$SOR < lim.SORc)) / nrow(annotations)
  plot(density(annotations$SOR,na.rm=T),main="SOR (Conservative)", sub = paste("Filtre: SOR < ",lim.SORc,"( = ", signif(prop.SORc,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de SOR", ylab = "Densité" )
  abline(v=lim.SORc, col="red")
  
  prop.SORe=length( which(annotations$SOR < lim.SORe)) / nrow(annotations)
  plot(density(annotations$SOR,na.rm=T),main="SOR (Exhaustive)", sub = paste("Filtre: SOR < ",lim.SORe,"( = ", signif(prop.SORe,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de SOR", ylab = "Densité" )
  abline(v=lim.SORe, col="red")



#DIAGRAMMES DE VENN (Conservatifs)
 par(mfrow=c(1,1)) 
 futile.logger::flog.threshold(futile.logger::ERROR, name = "VennDiagramLogger") # Pas de logs inutiles
 qdc.pass = which(annotations$QD > lim.QDc)
 fsc.pass = which(annotations$FS < lim.FSc)
 sorc.pass = which(annotations$SOR < lim.SORc)
 mqc.pass = which(annotations$MQ > lim.MQc)
 mqrsc.pass= which(annotations$MQRankSum > lim.MQRankSumc & annotations$MQRankSum < -lim.MQRankSumc)
 rprsc.pass= which(annotations$ReadPosRankSum > lim.ReadPosRankSumc & annotations$ReadPosRankSum < -lim.ReadPosRankSumc )
 
   temp <- venn.diagram(
   x=list(qdc.pass, fsc.pass,mqc.pass,sorc.pass,rprsc.pass),
   category.names = c("QD" , "FS" , "MQ", "SOR","RPRS"),
   fill = c("blue","darkgreen","orange","yellow","red"),
   output=FALSE,
   filename = NULL
 )
 plot(1, type="n", axes=F,xlab="Diagramme de Venn sauf MQRS (Conservative)", ylab="") #Crée une page vide où imprimer le diagramme 
 grid.draw(temp)
 
   temp <- venn.diagram(
   x=list(qdc.pass, fsc.pass,mqc.pass,sorc.pass,mqrsc.pass),
   category.names = c("QD" , "FS" , "MQ", "SOR","MQRS"),
   fill = c("blue","darkgreen","orange","yellow","red"),
   output=FALSE,
   filename = NULL
 )
 plot(1, type="n", axes=F,xlab="Diagramme de Venn sauf RPRS (Conservative)", ylab="") 
 grid.draw(temp)
 
 #DIAGRAMME DE VENN (Exhaustifs)
 qde.pass = which(annotations$QD > lim.QDe)
 fse.pass = which(annotations$FS < lim.FSe)
 sore.pass = which(annotations$SOR < lim.SORe)
 mqe.pass = which(annotations$MQ > lim.MQe)
 mqrse.pass= which(annotations$MQRankSum > lim.MQRankSume & annotations$MQRankSum < -lim.MQRankSume)
 rprse.pass= which(annotations$ReadPosRankSum > lim.ReadPosRankSume & annotations$ReadPosRankSum < -lim.ReadPosRankSume )
 
 
 
   temp <- venn.diagram(
   x=list(qde.pass, fse.pass,mqe.pass,sore.pass,rprse.pass),
   category.names = c("QD" , "FS" , "MQ", "SOR","RPRS"),
   fill = c("blue","darkgreen","orange","yellow","red"),
   output=FALSE,
   filename = NULL
 )
   plot(1, type="n", axes=F,xlab="Diagramme de Venn sauf MQRS (Exhaustive)", ylab="") 
   grid.draw(temp)
   
   temp <- venn.diagram(
   x=list(qde.pass, fse.pass,mqe.pass,sore.pass,mqrse.pass),
   category.names = c("QD" , "FS" , "MQ", "SOR","MQRS"),
   fill = c("blue","darkgreen","orange","yellow","red"),
   output=FALSE,
   filename = NULL
 )
   plot(1, type="n", axes=F,xlab="Diagramme de Venn sauf RPRS (Exhaustive)", ylab="") 
   grid.draw(temp)
 
 
 dev.off()
 
