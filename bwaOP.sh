# utilisation ./use_bwa.sh $1 $2 $3
# $1 le dossier où sont les fichers
# $2 un ficher TSV formaté de la sorte: run_accession \t study_alias \t fastq_md5 \t fastq
# $3 le chemin vers le genome de reference (déja indexé, à changer probablement)
# fastq et md5 peuvent contenir plusieurs liens séparé par des;

IFS=$'\n'
for line in $(cat $2)
do
  IFS=$'\t' read -r -a array <<< "$line" #Divise ligne en un tableau,le séparateur est \n, la tabulation
  if [ "${array[3]}" != "fastq_ftp" ] && [ "${array[3]}" != "" ] #On zappe la première ligne et les lignes vides
  then
      IFS=$';' read -r -a nb_read <<< "${array[3]}" #Divise la case en un tableau,le séparateur est;
      if [ "${#nb_read[@]}" == 1 ]
      then
       filename=$(basename $"${nb_read[0]}")
       bwa mem $3 $1'/'$filename  -R '@RG\tID:PRJEB24932\tPL:ILLUMINA\tPI:0\tSM:'"${array[0]}"'\tLB:1' > $1'/'"${array[0]}".sam
      elif [ "${#nb_read[@]}" == 2 ]  #Normalement 1 ou 2 sont les seules valeurs possibles de "${#nb_read[@]}" la taille du tableau
      then
        filename0=$(basename $"${nb_read[0]}")
        filename1=$(basename $"${nb_read[1]}")
        bwa mem $3 $1'/'$filename0 $1'/'$filename1 -R '@RG\tID:PRJEB24932\tPL:ILLUMINA\tPI:0\tSM:'"${array[1]}"'\tLB:1' > $1'/'"${array[0]}".sam
      fi
      samtools view -bt $3 $1'/'"${array[0]}".sam > $1'/'"${array[0]}".bam
      samtools sort -o $1'/'"${array[0]}"_sorted.bam $1'/'"${array[0]}".bam
  fi
done
