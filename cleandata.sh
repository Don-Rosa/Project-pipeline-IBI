#!/bin/bash
# utilisation ./cleandata.sh $1 $2 $3 $4
# $1 le dossier où sont les fichers
# $2 une ligne d'un ficher TSV formaté de la sorte: run_accession \t study_alias \t fastq_md5 \t fastq
# $3 le chemin vers le genome de reference (déja indexé, à changer probablement)
# $4 --> Si il n'est pas null on garde les fichers intermediaires
# fastq et md5 peuvent contenir plusieurs liens séparé par des;

#IFS=$'\n'
#for line in $(cat $2)
#do

dir=$1
tsvLine=$2                 # On explicite les parametres
fasta=$3
keep=$4

IFS=$'\t' read -r -a array <<< "$tsvLine" #Divise ligne en un tableau,le séparateur est \t, la tabulation

if [ "${array[3]}" != "fastq_ftp" ] && [ "${array[3]}" != "" ] #On zappe la première ligne et les lignes vides
then
    IFS=$';' read -r -a nb_read <<< "${array[3]}" #Divise la case en un tableau,le séparateur est ;
    if [ "${#nb_read[@]}" == 1 ]
    then
     filename=$(basename "${nb_read[0]}")
     bwa mem $fasta $dir'/'$filename  -R '@RG\tID:${array[0]}\tPL:ILLUMINA\tPI:0\tSM:${array[0]}\tLB:1' > $dir'/'"${array[0]}".sam
     if [ -z "$keep" ]
     then
       rm $dir'/'$filename
     fi
    elif [ "${#nb_read[@]}" == 2 ]  #Normalement 1 ou 2 sont les seules valeurs possibles de "${#nb_read[@]}" la taille du tableau
    then
      filename0=$(basename "${nb_read[0]}")
      filename1=$(basename "${nb_read[1]}")
      bwa mem $fasta $dir'/'$filename0 $1'/'$filename1 -R '@RG\tID:${array[0]}\tPL:ILLUMINA\tPI:0\tSM:${array[0]}\tLB:1' > $dir'/'"${array[0]}".sam
      if [ -z "$keep" ]
      then
        rm $dir'/'$filename0 $dir'/'$filename1
      fi
    fi
    samtools view -bt $fasta $dir'/'"${array[0]}".sam > $dir'/'"${array[0]}".bam
    if [ -z "$keep" ]
    then
      rm $dir'/'"${array[0]}".sam
    fi
    samtools sort -o $dir'/'"${array[0]}"_sorted.bam $dir'/'"${array[0]}".bam
    if [ -z "$keep" ]
    then
      rm $dir'/'"${array[0]}".bam
    fi
    bedtools genomecov -ibam $dir'/'"${array[0]}"_sorted.bam -bga > $dir'/'"${array[0]}"_cov
    gatk MarkDuplicatesSpark -I $dir'/'"${array[0]}"_sorted.bam -O $dir'/'"${array[0]}"_gatk.bam -OBI
fi

#done
