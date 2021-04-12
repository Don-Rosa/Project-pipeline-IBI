library(gdsfmt)
library("SNPRelate") # pour charger les donner et les manipuler
library(ape) # pour faire des arbres
library(RColorBrewer) # pour avoir de jolies couleurs

args = commandArgs(trailingOnly=TRUE)
file= paste(args[1],args[2],sep="/")
res= paste(args[1],"Résultats",args[2],sep="/")
ofile=paste(file,".gds",sep="")
ifile=paste(file,".vcf",sep="")
snpgdsVCF2GDS(ifile, ofile,verbose=TRUE)

genofile <- snpgdsOpen(ofile)
## A propos des échantillons ##
sample.id <- read.gdsn(index.gdsn(genofile, "sample.id"))

n <- 26
qual.col.pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
#col.vector = unlist(mapply(brewer.pal, qual.col.pals$maxcolors, rownames(qual.col.pals)))[1:n]
col.vector = unlist(list("blue","burlywood4","chartreuse3","coral2","cyan","black","darkgoldenrod2","darkgray","darkmagenta","darkolivegreen1","firebrick4","darkseagreen","darkorchid4","green4","red1","seagreen4","salmon","peru","slateblue","steelblue4","springgreen1","violetred4","violet","thistle","orange","tomato"))

# #HCCluster permet de déterminer les groupes par permutation (Z threshold: 15, outlier threshold: 5):
# ibs.hc <- snpgdsHCluster(snpgdsIBS(genofile, num.thread=2, autosome.only=FALSE))
# 
# ## On peut indiquer des groupes prédéfinis comme dans le papier avec l'option samp.group=
# rv <- snpgdsCutTree(ibs.hc ,col.list=col.vector)
# 
# pdf(paste(file,"_Arbre.pdf",sep=""),height=250)
# plot(rv$dendogram, main="Arbre selon IBS", horiz=T)
# 
# legend("topright",
#        legend=sample.id,
#        col=col.vector,
#        pch=19,
#        ncol=2) #ajoute une légende qui associe le nom de l'échantillon à la couleur du vecteur, on la place en haut à droite
# dev.off()


PCA <- snpgdsPCA(genofile,autosome.only=FALSE,remove.monosnp=TRUE, maf=NaN, missing.rate=NaN, eigen.cnt=0, sample.id=sample.id)

colnames(PCA$eigenvect)=PCA$varprop
rownames(PCA$eigenvect)=sample.id

pdf(paste(res,"PCA.pdf",sep="_"),height = 6, width = 12)
plot(x=PCA$eigenvect[,1],
     y=PCA$eigenvect[,2],
     main=paste("PCA (SNPRelate, no projection, ",length(PCA$snp.id)," SNPs)",sep=""), #Titre de la figure
     xlab=paste("Axe 1 (",round(as.numeric(colnames(PCA$eigenvect)[1])*100,2),"%)",sep=""), #On indique la proportion de variance expliquée par le premier axe
     ylab=paste("Axe 2 (",round(as.numeric(colnames(PCA$eigenvect)[2])*100,2),"%)",sep=""), #idem pour l'axe 2
     pch=0:25,
     col=col.vector) # forme et couleur des points

par(fig=c(0, 1, 0, 1), oma=c(0, 0, 0, 0), mar=c(0, 0, 0, 0), new=FALSE)
plot(0, 0, type='n', bty='n', xaxt='n', yaxt='n')
legend("top", #on met la légende en haut à droite
       legend = sample.id, 
       pch=0:25, 
       col=col.vector,
       ncol=7)

dev.off()