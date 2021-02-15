#$1 chemin du fichier à analyser
#$2 nom du fichier

dir=$1
tsv_line=$2
filename=$(echo "$tsv_line" | cut -d$'\t' -f 1)
outpoutdir=$dir"/Résultats"

mkdir -p $outpoutdir

outpout=$outpoutdir'/'"$filename"
samtools flagstat $dir'/'"$filename"_sorted.bam > $outpout~.txt


IFS=$'\n' read -d '' -r -a lines < $outpout~.txt
IFS=$'+' read total _<<< "${lines[0]}"
IFS=$'+' read mapped other <<< "${lines[4]}"
IFS=$'(' read before after <<< "$other"
IFS=$':' read percent _ <<< "$after"

echo "$filename : Mapped = $mapped  Total = $total Percent of mapped = $percent" >> $outpoutdir/flagstat.txt
rm -f $outpout~.txt
