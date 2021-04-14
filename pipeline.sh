#!/bin/bash
# initialize a semaphore with a given number of tokens
open_sem(){
    mkfifo /tmp/pipe-$$
    exec 3<>/tmp/pipe-$$ #$$ le process ID de ce shell
    rm /tmp/pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3  # & pour un file descriptor
    done                   #  0 - stdin
}                          #  1 - stdout
                           #  2 - stderr
                           #  3 ---> Sans signification spéciale

# run the given command asynchronously and pop/push tokens
run_with_lock(){
    local x
    # this read waits until there is something to read
    read -u 3 -n 3 x && ((0==x)) || exit $x # Le || exit $x permet de propagé une erreur qui aurait été push par un sous-Shell
    # && --> lance la commande ssi celle de gauche c'est bien exécuté
    # || --> l'inverse, ssi celle de gauche n'a pas rendu 0

    (
     ( "$@"; ) # Dans notre cas, $@" est remplacé par en bash cleandata.sh $dir "$line" $fasta $keep
               # La commande voulue est bien lancé en parallèle, cf le & à la fin
    # push the return code of the command to the semaphore
    printf '%.3d' $? >&3  #($?) Le status de retour du dernier programme exectuée à l'avant plan
    )&
}

function boucle_seq(){      # Pour les opérations qu'on veut effectuer séquentiellement
  j=0                       # (Pour ne pas les avoir dans un ordre aléatoire)
  mkdir -p "$dir/Résultats" # -p enlève le warning si le dossier existe déja
  IFS=$'\n'
  for line in $(cat "$tsv")
  do
    if (( $j >= $begin )) && ( [ -z $end ] || (( $j <= $end )) )
    then
      bash flagstat.sh "$dir" "$line"
      bash cov.sh "$dir" "$line" "$keep"
    fi
    ((j++))
  done
  bash Database.sh "$dir" "$tsv"
  stdacc=$(cat "sampleAlias_md5_fastq_studyAccession.tsv" | cut -d$'\n' -f 2 | cut -d$'\t' -f 4)  #Récupère le nom de l'étude
  gatk --java-options "-Xmx4g" GenotypeGVCFs -R "$fasta" -V gendb://"$dir/Database" -O "$dir/$stdacc.vcf.gz"

  gatk SelectVariants -R $fasta -V "$dir/$stdacc.vcf.gz" --select-type-to-include SNP -O "$dir/$stdacc"_snp.vcf.gz

  rm -f "$dir/Résultats/snp_indel.txt"
  total=$(gatk CountVariants -V "$dir/$stdacc.vcf.gz"   | cut -d' ' -f 3)
  snp=$(gatk CountVariants -V "$dir/$stdacc"_snp.vcf.gz | cut -d' ' -f 3)
  total=$(echo $total)
  snp=$(echo $snp) #Truc bizarre avec les fins de ligne

  ((indel=total-snp))
  indelr=$(echo "$indel*100 / $total" | bc -l)
  snpr=$(echo "$snp*100 / $total" | bc -l)
  echo "SNP/INDEL of $stdacc.vcf.gz : SNP = $snp  INDEL = $indel Total = $total SNP/INDEL = $snpr% / $indelr%" > "$dir"/Résultats/snp_indel.txt
  bash INDEL_SNP.sh $dir "$stdacc.vcf.gz"   #Pour la gloire

  rm -f "$dir/$stdacc"_snp_filtres
  echo -e "CHROM\tPOS\tREF\tALT\tQD\tFS\tMQ\tMQRankSum\tReadPosRankSum\tSOR\tDP" >> "$dir/$stdacc"_snp_filtres  # Pour avoir le nom des colonnes
  bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%QD\t%FS\t%MQ\t%MQRankSum\t%ReadPosRankSum\t%SOR\t%DP\n' "$dir/$stdacc"_snp.vcf.gz >> "$dir/$stdacc"_snp_filtres
  Rscript Filtration.R "$dir" "$stdacc"_snp_filtres

  if [ $filterMode == "cons" ] || [ $filterMode == "both" ]
  then
    gatk VariantFiltration -R $fasta -V "$dir/$stdacc"_snp.vcf.gz -O "$dir/$stdacc"_snp_cons.vcf.gz -filter "QD < 11.0 || FS > 5.0 || MQ < 58.0 || SOR > 1.3 || MQRankSum < -0.5 || MQRankSum > 0.5 || ReadPosRankSum < -0.5 || ReadPosRankSum > 0.5" --filter-name "6filtrescons"
    vcftools --gzvcf "$dir/$stdacc"_snp_cons.vcf.gz --remove-filtered-all --recode --stdout  > "$dir/$stdacc"_snp_cons_PASS.vcf
    Rscript Arbre.R "$dir" "$stdacc"_snp_cons_PASS
  fi

  if [ $filterMode == "exhau" ] || [ $filterMode == "both" ]
  then
    gatk VariantFiltration -R $fasta -V "$dir/$stdacc"_snp.vcf.gz -O "$dir/$stdacc"_snp_exhau.vcf.gz -filter "QD < 5.0 || FS > 15.0 || MQ < 54.0 || SOR > 2.5 || MQRankSum < -2.5 || MQRankSum > 2.5 || ReadPosRankSum < -1.3 || ReadPosRankSum > 1.3" --filter-name "6filtresexhau"
    vcftools --gzvcf "$dir/$stdacc"_snp_exhau.vcf.gz --remove-filtered-all --recode --stdout > "$dir/$stdacc"_snp_exhau_PASS.vcf
    Rscript Arbre.R "$dir" "$stdacc"_snp_exhau_PASS
  fi
}

usage()
{
    echo "usage: <command> options args:
    <p:Nombre max de shells en parallèle>
    <d>(Télécharge les fichiers)
    <f> (Télécharge et fast forward le nettoyage)
    <b:x> <e:y> (télécharge et/ou traite les fichers entre les lignes x et y)
    <m:x> Choisit le mode de filtration --> x=cons: Concervative(défaut), x=exhau: Exhaustive, x=both: Les deux
    <k> (conserve les fichers intermediaires)
    arg1 --> Dossier de destination
    arg2 --> Ficher TSV au format SampleAlias \t fastq_md5 \t fastq \t studyAccession
    arg3 --> Génome de référence au format FASTA"
}

maxN=1
unset dl_opt
begin=0
i=0
filterMode="cons" #Approche concervative par default
unset end # end unset --> pas de limite supérieure
unset keep

while getopts p:dfb:e:m:k option
do
    case $option in
            p)
              maxN="$OPTARG";;
            d)
              dl_opt="dl_files_only";;
            f)
              dl_opt="fast_forward";;
            b)
              begin="$OPTARG";;
            e)
              end="$OPTARG";;
            m)
              filterMode="$OPTARG";;
            k)
              keep=1;;
            *)
            usage
            exit;;
    esac
done
shift $((OPTIND-1))    # On retire les options

dir="$1"
tsv="$2"                 # On explicite les parametres
fasta="$3"
#Verification que les 3 arguments obligatoires sont fournis
if [ -z "$fasta" ] || [ -z "$tsv" ] || [ -z "$dir" ]
then
  usage
  exit
fi

bwa index "$fasta"
gatk CreateSequenceDictionary -R "$fasta"
samtools faidx "$fasta"

IFS=$'\n'
if [ -z "$dl_opt" ]
then
  for line in $(cat "$tsv")
  do
    if (( $i >= $begin )) && ( [ -z $end ] || (( $i <= $end )) )
    then
      bash dl.sh "$dir" "$line"
    fi
    ((i++))
  done
  i=0
  open_sem $maxN
  for line in $(cat "$tsv")
  do
    if (( $i >= $begin )) && ( [ -z $end ] || (( $i <= $end )) )
    then
      run_with_lock bash cleandata.sh "$dir" "$line" "$fasta" $keep
    fi
    ((i++))
  done
  wait          #On attend la fin de tout les opérations parrallèles
  boucle_seq    #Pour lancer un traitement sequentiel des données
elif [ "$dl_opt" == "dl_files_only" ]
then
  mkdir -p "$dir"
  printf "\nTéléchargement des fastq.gz de: $tsv\n\n" >> "$dir/dl_log.out"
  for line in $(cat "$tsv")
  do
    if (( $i >= $begin )) && ( [ -z $end ] || (( $i <= $end )) )
    then
      bash dl.sh "$dir" "$line"
    fi
    ((i++))
  done
elif [ "$dl_opt" == "fast_forward" ]
then
  open_sem $maxN
  mkdir -p "$dir"
  printf "\nTéléchargement des fastq.gz de: $tsv\n\n" >> "$dir/dl_log.out"
  for line in $(cat "$tsv")
  do
    if (( $i >= $begin )) && ( [ -z $end ] || (( $i <= $end )) )
    then
      bash dl.sh "$dir" "$line"
      run_with_lock bash cleandata.sh $dir "$line" "$fasta" $keep
    fi
    ((i++))
  done
  wait          #On attend la fin de tout les opérations parrallèles
  boucle_seq    #Pour lancer un traitement sequentiel des données
fi
