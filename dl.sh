# utilisation ./dl.sh $1 $2
# $1 le dossier où seront télechargé les fichers
# $2 un ficher TSV formaté de la sorte: run_accession \t study_alias \t fastq_md5 \t fastq
# fastq et md5 peuvent contenir plusieurs liens séparé par des ;

IFS=$'\n'
mkdir -p $1
printf "\nTéléchargement des fastq.gz de: $2\n\n" >> $1"/dl_log.out"
for line in $(cat $2)
do
  IFS=$'\t' read -r -a array <<< "$line"    # Divise ligne en un tableau,le séparateur est \t, la tabulation
  if [ "${array[3]}" != "fastq_ftp" ] && [ "${array[3]}" != "" ]  # On zappe la première ligne et les lignes vides
  then
    IFS=$';'
    read -r -a fastq_array <<< "${array[3]}"    # Divise la case en un tableau,le séparateur est ;
    read -r -a md5_array <<< "${array[2]}"
    for ((i=0; i<"${#fastq_array[@]}"; i++))    # ${#fastq_array[@]} la taille du tableau
    do
        path="${fastq_array[i]}"
        filename=$(basename $path)
        failed_md5=1
        nb_try=0
        while [ "$failed_md5" == 1 ] && [ "$nb_try" != 5 ]    # 5 essais pour recevoir correctement le ficher
        do
          printf "Téléchargement de : $filename, essai $nb_try \n"  >> $1"/dl_log.out"
          wget -P $1  -nc --no-clobber "ftp://"$path
          md5=$(md5sum $1'/'$filename | cut -d' ' -f 1)   # md5sum rajoute le nom du ficher en plus du hash code--> on ne garde que ce dernier

          if [ "${md5_array[i]}" == "$md5" ]    # Si il y a plus élégant je suis preneur
          then
            failed_md5=0
          fi

          echo $failed_md5
          if [ "$failed_md5" == 1 ]
          then
            printf "  $filename Echec md5\n    md5_dl:  $md5 != \n    md5tsv:  ${md5_array[i]}\n" >> $1"/dl_log.out"
            rm $1'/'$filename
            ((nb_try++))    # (()) signifie une opération arithmetique
          else
            printf "  $filename OK\n    md5_dl:  $md5 == \n    md5TSV:  ${md5_array[i]}\n\n" >> $1"/dl_log.out"
          fi
        done

        if [ "$nb_try" == 5 ]
        then
            printf "Abandon du téléchargement de $filename \n\n" >> $1"/dl_log.out"
        fi
      done
    fi
done
