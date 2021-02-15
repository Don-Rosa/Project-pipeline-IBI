#!/bin/bash
# initialize a semaphore with a given number of tokens
open_sem(){
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}

# run the given command asynchronously and pop/push tokens
run_with_lock(){
    local x
    # this read waits until there is something to read
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
     ( "$@"; )
    # push the return code of the command to the semaphore
    printf '%.3d' $? >&3
    )&
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

if [ -z "$dl_opt" ]
then
  open_sem $maxN
  IFS=$'\n'
  for line in $(cat $tsv)
  do
    if (( "$i" >= "$begin" )) && ( [ -z "$end" ] || (( "$i" <= "$end" )) )
    then
      run_with_lock bash cleandata.sh $dir "$line" $fasta $keep
      bash flagstat.sh $dir "$line"
    fi
    ((i++))
  done
elif [ $dl_opt == "dl_files_only" ]
then
  IFS=$'\n'
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
  IFS=$'\n'
  mkdir -p $dir
  printf "\nTéléchargement des fastq.gz de: $tsv\n\n" >> $dir"/dl_log.out"
  for line in $(cat $tsv)
  do
    if (( "$i" >= "$begin" )) && ( [ -z "$end" ] || (( "$i" <= "$end" )) )
    then
      bash dl.sh $dir "$line"
      run_with_lock bash cleandata.sh $dir "$line" $fasta $keep
      bash flagstat.sh $dir "$line"
    fi
    ((i++))
  done
fi

wait
