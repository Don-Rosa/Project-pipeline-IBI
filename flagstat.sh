file=$1
outpoutdir=$2
mkdir $outpoutdir #cacher l'erreur à terme

IFS=$'/' read _ name <<< $file
outpout=$outpoutdir'/'"$name"
samtools flagstat $file > $outpout~.txt


IFS=$'\n' read -d '' -r -a lines < $outpout~.txt
IFS=$'+' read total _<<< "${lines[0]}"
IFS=$'+' read mapped other <<< "${lines[4]}"
IFS=$'(' read before after <<< "$other"
IFS=$':' read percent _ <<< "$after"

echo "$name" : > echo "Mapped = $mapped" > echo "Total = $total" > echo "Percent of mapped = $percent" >> $outpoutdir/info.txt
rm -f $outpout~.txt
