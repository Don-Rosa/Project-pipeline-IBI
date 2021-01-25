# utilisation ./dl.sh $1 $2
# $1 le dossier où seront télechargé les fichers
# $2 un ficher TSV formaté de la sorte: Not used \t fastq_md5 \t fastq
# fastq et md5 peuvent contenir plusieurs liens séparé par des ;
IFS=$'\n'
for line in $(cat $2)
do
  IFS=$'\t' read -r -a array <<< "$line" #Divise ligne en un tableau,le séparateur est \n, la tabulation
  if [ "${array[2]}" != "fastq_ftp" ] && [ "${array[2]}" != "" ] #On zappe la première ligne et les lignes vides
  then
    i=1   # i sert à couper la bonne partie d'une case du genre ;~~~;~~~;~~~;~~~;~~~
    path=$(echo ${array[2]}";stop" | cut -d';' -f $i) #Rajout de "stop" à la fin pour pouvoir savoir qu'on a lu toute la case
    while [ "$path" != "stop" ]                       #Sinon
     do
      failed_md5=1 #True
      while [ "$failed_md5" == 1 ] #Tant que le ficher n'est pas reçu correctement
      do
        filename=$(basename $path)
        printf "Téléchargement de : %s \n" $filename
        wget -P $1  -nc --no-clobber "ftp://"$path #marche stp
        md5=$(md5sum $1'/'$filename | cut -d' ' -f 1) #md5sum rajoute le nom du ficher en plus du hash code--> on ne garde que ce dernier
        failed_md5=$([ "echo ${array[1]} | cut -d';' -f $i" != "$md5" ])

        if [ "$failed_md5" == 1 ]
        then
          printf "Erreur dans le téléchargement de : %s \n" $filename
          rm $1'/'$filename
        else
          printf "Fin du téléchargement de : %s \n" $filename
        fi
      done
      ((i++))     #(()) indique une opération arithmétique
      path=$(echo ${array[2]}";stop" | cut -d';' -f $i)   #Pas de do while en bash ...
    done
  fi
done
