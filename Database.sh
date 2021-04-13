#$1 chemin du fichier à analyser
#$2 nom du fichier

dir="$1"
tsv="$2"
outpoutdir="$dir/Database"
names="$dir/names.txt"

rm -f "$names"

IFS=$'\n'
for line in $(cat "$tsv")
do
  IFS=$'\t' read -r -a array <<< "$line"    # Divise ligne en un tableau,le séparateur est \t, la tabulation
  if [ "${array[2]}" != "fastq_ftp" ] && [ "${array[2]}" != "" ]  # On zappe la première ligne et les lignes vides
  then
    echo  -e "${array[0]}\t$dir/${array[0]}.g.vcf.gz" >> $names
  fi
done
gatk --java-options "-Xmx4g" GenomicsDBImport --genomicsdb-workspace-path "$outpoutdir" -L interval.list --sample-name-map "$names"
