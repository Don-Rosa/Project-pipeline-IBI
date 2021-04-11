#R script pour faire des distributions
#!/usr/bin/env Rscript
library(lattice)
library(VennDiagram) # pour les diagrammes de venn

# LECTURE DU FICHIER
args = commandArgs(trailingOnly=TRUE)
annot.file = args[1]
annotations = read.table(annot.file, h=TRUE,na.strings=".")


# dim(annotations)
# head(annotations) 

# INITIALISATION DES SEUILS   Aproche conservative
lim.QD = 21
lim.FS = 5
lim.MQ = 58
lim.MQRankSum = -0.5
lim.ReadPosRankSum = -0.5
lim.SOR = 1.3



# CREATION DES FIGURES
 pdf(paste(annot.file,"Filtres.pdf",sep="_"),height = 8, width = 12)

  prop.QD=length( which(annotations$QD >lim.QD)) / nrow(annotations)
  plot(density(annotations$QD,na.rm=T),main="QD", sub = paste("Filtre: QD >",lim.QD,"( = ", signif(prop.QD,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de QD", ylab = "Densité"  )
  abline(v=lim.QD, col="red")

   prop.FS=length( which(annotations$FS < lim.FS)) / nrow(annotations)
  plot(density(annotations$FS,na.rm=T),main="FS", sub = paste("Filtre: FS <",lim.FS,"( = ", signif(prop.FS,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de FS", ylab = "Densité" )
  abline(v=lim.FS, col="red")

  prop.MQ=length( which(annotations$MQ > lim.MQ)) / nrow(annotations)
  plot(density(annotations$MQ,na.rm=T),main="MQ", sub = paste("Filtre: MQ >",lim.MQ,"( = ", signif(prop.MQ,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de MQ", ylab = "Densité" )
  abline(v=lim.MQ, col="red")

  prop.MQRankSum=length( which(annotations$MQRankSum > lim.MQRankSum & annotations$MQRankSum < -lim.MQRankSum)) / nrow(annotations)
  plot(density(annotations$MQRankSum,na.rm=T),main="MQRankSum", sub = paste("Filtre: MQRankSum >",lim.MQRankSum," & < ",-lim.MQRankSum,"( = ", signif(prop.MQRankSum,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de MQRankSum", ylab = "Densité" )
  abline(v=lim.MQRankSum, col="red")
  abline(v=-lim.MQRankSum, col="blue")

  prop.ReadPosRankSum=length( which(annotations$ReadPosRankSum > lim.ReadPosRankSum & annotations$ReadPosRankSum < -lim.ReadPosRankSum )) / nrow(annotations)
  plot(density(annotations$ReadPosRankSum,na.rm=T),main="ReadPosRankSum", sub = paste("Filtre: ReadPosRankSum >",lim.ReadPosRankSum," & < ",-lim.ReadPosRankSum,"( = ", signif(prop.ReadPosRankSum,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de ReadPosRankSum", ylab = "Densité"  )
  abline(v=lim.ReadPosRankSum, col="red")
  abline(v=-lim.ReadPosRankSum, col="blue")

  prop.SOR=length( which(annotations$SOR < lim.SOR)) / nrow(annotations)
  plot(density(annotations$SOR,na.rm=T),main="SOR", sub = paste("Filtre: SOR < ",lim.SOR,"( = ", signif(prop.SOR,3),"/1 des SNP) " ,sep="") , xlab= "Valeur de SOR", ylab = "Densité" )
  abline(v=lim.SOR, col="red")

dev.off()

#DIAGRAMME DE VENN
 qd.pass = which(annotations$QD > lim.QD)
 fs.pass = which(annotations$FS < lim.FS)
 sor.pass = which(annotations$SOR < lim.SOR)
 mq.pass = which(annotations$MQ > lim.MQ)
 mqrs.pass= which(annotations$MQRankSum > lim.MQRankSum & annotations$MQRankSum < -lim.MQRankSum)
 rprs.pass= which(annotations$ReadPosRankSum > lim.ReadPosRankSum & annotations$ReadPosRankSum < -lim.ReadPosRankSum )

 venn.diagram(
   x=list(qd.pass, fs.pass,mq.pass,sor.pass,rprs.pass),
   category.names = c("QD" , "FS" , "MQ", "SOR","RPRanksSum"),
   fill = c("blue","darkgreen","orange","yellow","red"),
   output=TRUE,
filename = "levure/MondiagrammedeVenn"
 )
