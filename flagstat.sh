#$1 chemin du fichier à analyser
#$2 nom du fichier

file=$1
name=$2
outpoutdir="Résultat"
mkdir -p $outpoutdir #cacher l'erreur à terme

outpout=$outpoutdir'/'"$name"
samtools flagstat $file > $outpout~.txt


IFS=$'\n' read -d '' -r -a lines < $outpout~.txt
IFS=$'+' read total _<<< "${lines[0]}"
IFS=$'+' read mapped other <<< "${lines[4]}"
IFS=$'(' read before after <<< "$other"
IFS=$':' read percent _ <<< "$after"

echo "$name" : > echo "Mapped = $mapped" > echo "Total = $total" > echo "Percent of mapped = $percent" >> $outpoutdir/flagstat.txt
rm -f $outpout~.txt
