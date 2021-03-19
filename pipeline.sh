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
  mkdir -p $dir"/Résultats" # -p enlève le warning si le dossier existe déja
  IFS=$'\n'
  for line in $(cat $tsv)
  do
    if (( "$j" >= "$begin" )) && ( [ -z "$end" ] || (( "$j" <= "$end" )) )
    then
      bash flagstat.sh "$dir" "$line"
      bash cov.sh "$dir" "$line"
    fi
    ((j++))
  done
  bash Database.sh "$dir" "$tsv"
}

usage()
{
    echo "usage: <command> options:
    <p:Nombre max de shells en parallèle>
    <d>(download files only)
    <f> (download and fast forward cleaning)
    <b:x> <e:y> (télécharge et/ou traite les fichers entre les lignes x et y)
    <k> (conserve les fichers intermediaires)"
}

maxN=1
unset dl_opt
begin=0
i=0
unset end # end unset --> pas de limite supérieure
unset keep
while getopts p:dfb:e:k option
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
            k)
              keep=1;;
            *)
            usage
            exit;;
    esac
done
shift $((OPTIND-1))    # On retire les options

dir=$1
tsv=$2                 # On explicite les parametres
fasta=$3

bwa index $fasta
gatk CreateSequenceDictionary -R $fasta
samtools faidx $fasta

IFS=$'\n'
if [ -z "$dl_opt" ]
then
  open_sem $max
  for line in $(cat $tsv)
  do
    #if (( "$i" >= "$begin" )) && ( [ -z "$end" ] || (( "$i" <= "$end" )) )
    #then
      #run_with_lock bash cleandata.sh $dir "$line" $fasta $keep
    #fi
    ((i++))
  done
  wait          #On attend la fin de tout les opérations parrallèles
  boucle_seq    #Pour lancer un traitement sequentiel des données
elif [ $dl_opt == "dl_files_only" ]
then
  mkdir -p $dir
  printf "\nTéléchargement des fastq.gz de: $tsv\n\n" >> $dir"/dl_log.out"
  for line in $(cat $tsv)
  do
    if (( "$i" >= "$begin" )) && ( [ -z "$end" ] || (( "$i" <= "$end" )) )
    then
      bash dl.sh $dir "$line"
    fi
    ((i++))
  done
elif [ $dl_opt == "fast_forward" ]
then
  open_sem $maxN
  mkdir -p $dir
  printf "\nTéléchargement des fastq.gz de: $tsv\n\n" >> $dir"/dl_log.out"
  for line in $(cat $tsv)
  do
    if (( "$i" >= "$begin" )) && ( [ -z "$end" ] || (( "$i" <= "$end" )) )
    then
      bash dl.sh $dir "$line"
      run_with_lock bash cleandata.sh $dir "$line" $fasta $keep
    fi
    ((i++))
  done
  wait          #On attend la fin de tout les opérations parrallèles
  boucle_seq    #Pour lancer un traitement sequentiel des données
fi
