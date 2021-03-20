#!/bin/bash

dir="$1"
tsv_line="$2"                 # On explicite les parametres


filename=$(echo "$tsv_line" | cut -d$'\t' -f 1)
if [ "$filename" != "sample_alias" ] && [ "$filename" != "" ] #On zappe la première ligne et les lignes vides
then
  min=99999  #de la merde, à changer
  max=0
  total=0
  nb_lines=0
  IFS=$'\n'
  for line_cov in $(cat "$dir"/"$filename"_cov)
  do
    IFS=$'\t' read -r -a cov <<< "$line_cov" #Gros gain de performance à ne pas utiliser cut et |
    ((size = "${cov[2]}" - "${cov[1]}"))
    ((cov_pond = size*"${cov[3]}"))
    ((nb_lines += $size))
    ((total += $cov_pond))
    if (("${cov[3]}" > $max))
    then
      max="${cov[3]}"
    fi
    if (("${cov[3]}" < $min))
    then
      min="${cov[3]}"
    fi
  done
  average=$(echo "$total / $nb_lines" | bc -l)
  echo "Coverage of $filename : Average = $average  min $min max $max" >> "$dir"/Résultats/Cov.txt
fi
