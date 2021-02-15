#!/bin/bash

dir=$1
tsv=$2                 # On explicite les parametres

IFS=$'\n'
for line in $(cat $tsv)
do
  filename=$(echo "$line" | cut -d$'\t' -f 1)
  min=99999  #de la merde, à changer
  max=0
  total=0
  nb_lines=0
  for line_cov in $(cat $dir'/'"$filename"_cov)
  do
     IFS=$'\t' read -r -a cov <<< "$line_cov" #Gros gain de performance à ne pas utiliser cut et |
    ((nb_lines++))
    ((total += "${cov[3]}"))
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
done
