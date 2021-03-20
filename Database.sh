#$1 chemin du fichier à analyser
#$2 nom du fichier

dir=$1
tsv=$2
outpoutdir=$dir"/Database"
names="names.txt"

rm -f $names
declare -i nbligne=0


cut -f 1 $tsv > 1.temp
tail -n +2  1.temp > 1b.temp
wc -l 1b.temp > lines.temp
nbligne=$(cut -c1-2 lines.temp)
write=$(basename $dir)
for (( var=0; var<$nbligne; var++ )); do echo $write >> 1c.temp; done
for (( var=0; var<$nbligne; var++ )); do echo g.vcf.gz >> 1e.temp; done
paste 1b.temp 1c.temp > 1d.temp
paste 1d.temp 1b.temp -d"/" > 2.temp
paste 2.temp 1e.temp -d"." > $names
rm -f *.temp
gatk --java-options "-Xmx4g" GenomicsDBImport --genomicsdb-workspace-path $outpoutdir -L interval.list --sample-name-map $names
