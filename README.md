#  Project-pipeline-IBI  

##  Prérequis :  
1. Ces programmes à jour/compilés et  **dans  le  PATH**  
*  bwa  
*  bedtools  
*  picard  
*  samtools  
*  bcftools  
*  vcftools  
*  gatk  
*  R  (Avec ces extensions installées : "VennDiagram" , "BiocManager" , "SNPRelate" , "ape" , "RColorBrewer")  
2. Une version du génome de référence au format  **.fasta**  des échantillons séquencés  
3. Un ficher  **.tsv**  formaté de la sorte : SampleAlias  \t  fastq_md5  \t  fastq  \t  studyAccession  
4. Une connexion internet pour  télécharger  les  fastq  et certaines  fonctions  de  gatk  distribuées  

##  Utilisation  

Tout se fait via le script  **pipeline.sh**  et ses 3 arguments obligatoires  
Usage : pipeline.sh  options  $1 $2 $3  

arg1  -->  Dossier de destination/travail  
arg2  -->  Ficher TSV au format  SampleAlias  \t  fastq_md5  \t  fastq  \t  studyAccession  
arg3  -->  Génome de référence au format  FASTA  


####  Listes des options  
*  Accélération du processus  
   *  **-p  x**  |  Met à x le nombre max de  shells  en parallèle, par défaut 1  
   *  **-f**  |  Télécharge et  fast  forward  le traitement  (Si  -d  et  -f  choisie  -f  a la priorité)  
*  Choix du mode de traitement  
	*  **-d**  |  Télécharge uniquement les fichiers  (Si  -d  et  -f  choisit  -f  a la priorité)  
	*  **-m  s**  |  Choisit la méthode de filtration  -->  s=cons: Conservative(défaut),  s=exhau: Exhaustive,  s=both: Les deux  
Les valeurs des filtres sont respectivement  _Todo  : Rendre  les valeurs/filtres customisables_  
		*  Conservative : QD  < 11.0  ||  FS > 5.0  ||  MQ  < 58.0  ||  SOR  > 1.3  ||  MQRankSum  < -0.5  ||  MQRankSum  > 0.5  ||  ReadPosRankSum  < -0.5  ||  ReadPosRankSum  > 0.5  
		*  Exhaustive : QD  < 5.0  ||  FS > 15.0  ||  MQ  < 54.0  ||  SOR  > 2.5  ||  MQRankSum  < -2.5  ||  MQRankSum  > 2.5  ||  ReadPosRankSum  < -1.3  ||  ReadPosRankSum  > 1.3  
	*  [**-k**][k]  |  conserve les fichiers intermédiaires au  gvcf / optionels  (###fast.gz  ,  ###.sam  ,  ###.bam  ,  ###sorted.bam  ,  ###gatk.bam  ,  ###_cov  ###gatk.bam.bai  ,  ###gatk.bam.sbi)  , par défaut  **ils  seront  supprimés**  
*  Utile pour redémarrer le pipeline après un arrêt avant sa fin  
	*  **-b  x**  |  Télécharge et/ou traite les fichiers pour les lignes x  <=  i du TSV, par défaut 0  
	*  **-e  y**  |  Télécharge et/ou traite les fichiers pour les lignes i  <=  y du  TSV, par défaut sans limite  

PS: ./pipeline.sh  sans rien pour un rappel l'usage du script  

##  Résultats  

Télécharge chaque échantillon indiqué par les lignes du TSV, produit  un  GVCF  par échantillon et un  VCF  contenant tout les variants des échantillons. Le nom du  vcf  est  _studyAccession.vcf.gz_  
Voir l'option  **-k**  pour une liste des fichiers  intermédiaires  conservables.  
Extrait et filtre les  SNP  du  VCF  dans  _studyAccession_snp_cons_PASS.vcf_  ou/et  _studyAccession_snp_exhau_PASS.vcf_  en fonction du mode de filtration choisit  
Dans  _Dossier/Résultats/_  sont disponibles les informations suivantes  
*  _flagstat.txt_  , le nombre de  read  et le pourcentage mappé au génome de référence  
*  _cov.txt_  , le taux de couverture de  moyen/min/max  de chaque échantillon, voir les fichiers  _cov  pour la couverture de chaque zone génétique
:warning: NB: cov.sh peut avoir des soucis de durée en fonction de l'OS en particulier sur une VM, commentez la ligne 40 de pipeline.sh si cette partie optionnelle au pipeline bloque l'exécution trop longtemps  :warning:
*  _snp_indel.txt_  , le nombre de sites variants dans notre  VCF  et la proportion  SNP/INDEL. (Calculé  par  gatk  et par un script équivalent)  
*  _studyAccession_snp_filtres_Filtres  et Diagrammes de  Venn.pdf_  , des figures montrant l'effet des filtres sur les  SNP  
*  _studyAccession_snp_exhau_PASS_PCA.pdf_  et/ou  _studyAccession_snp_exhau_PASS_PCA.pdf_  , une représentation en deux dimensions des échantillons
