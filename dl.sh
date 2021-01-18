IFS=$'\n'
for line in $(cat $2)
do
  IFS=$'\t;' read -r -a array <<< "$line"
  if [ ${array[2]} != "fastq_ftp" ]
  then
    boucle=true
    while [ $boucle ]
    do
      filename=$(basename "ftp://"${array[3]})
      printf "Téléchargement de : %s \n" $filename
      wget -P $1  -nc --no-clobber "ftp://"${array[3]}
      $boucle = [${array[1]} != md5sum $filename]
      if [ $boucle ]
      then
        rm $1/$filename
      fi
    done
  fi
done
