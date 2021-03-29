#!/bin/bash

dir="$1"   # On explicite les parametres
filename="$2"               # Un fichier vcf.gz

##CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	AP13.1	UFMG-CM-Y215	UFMG-CM-Y223	UFMG-CM-Y228	UFMG-CM-Y251	UFMG-CM-Y617	UFMG-CM-Y618	UFMG-CM-Y619	UFMG-CM-Y620	UFMG-CM-Y621	UFMG-CM-Y622	UFMG-CM-Y623	UFMG-CM-Y624	UFMG-CM-Y625	UFMG-CM-Y627	UFMG-CM-Y628	UFMG-CM-Y629	UFMG-CM-Y630	UFMG-CM-Y631	UFMG-CM-Y632	UFMG-CM-Y633	UFMG-CM-Y634	UFMG-CM-Y635	UFMG-CM-Y637	UFMG-CM-Y638	UFMG-CM-Y648
snp=0
indel=0


IFS=$'\n'
for line in $(gunzip -c "$dir"/"$filename")
do
  IFS=$'\t' read -r -a vcf_l <<< "$line" #Gros gain de performance à ne pas utiliser cut et |
  if  [[ "${vcf_l[0]}"  != \#* ]] #On ne compte par les lignes commentées
  then
    ref="${vcf_l[3]}"
    alt="${vcf_l[4]}"   # alt est une liste d'allèle possibles séparées par ','

    IFS=$',' read -r -a alleles <<< "$alt"
    i=0
    max="${#alleles[@]}"
    while (( "$i" < "$max" )) && [[ "${#ref}" -eq "${#alleles[i]}" ]] # Comparaisons numérique
    do                                      # -eq # equal
      ((i++))                                         # -ne # not equal
    done                                                            # -lt # less than
                                                                    # -le # less than or equal
    if [[ "$i" -eq "$max" ]]; #Tous de la même taille                    # -gt # greater than
    then                                                            # -ge # greater than or equal
      ((snp++))
    else
      ((indel++))
    fi
  fi
done

((total=indel+snp))
indelr=$(echo "$indel*100 / $total" | bc -l)
snpr=$(echo "$snp*100 / $total" | bc -l)
echo "(Fait maison) SNP/INDEL of $filename : SNP = $snp  INDEL = $indel Total = $total SNP/INDEL = $snpr% / $indelr%" >> "$dir"/Résultats/snp_indel.txt
