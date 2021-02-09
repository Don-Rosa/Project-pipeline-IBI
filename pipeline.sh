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
    echo "usage: <command> options:<p:Nombre max de shell en parallèle> <d>(download files only) <f> (download and fast forward cleaning)"
}

maxN=1
unset dl_opt
while getopts p:df option
do
    case $option in
            p)
              maxN="$OPTARG";;
            d)
              dl_opt="dl_files_only";;
            f)
              dl_opt="fast_forward";;
            *)
            usage
            exit;;
    esac
done
shift $((OPTIND-1))    # On retire les options

dir=$1
tsv=$2                 # On explicite les parametres
fasta=$3


if [ -z "$dl_opt" ]
then
  open_sem $maxN
  IFS=$'\n'
  for line in $(cat $tsv)
  do
    run_with_lock bash cleandata.sh $dir "$line" $fasta
  done
  wait
elif [ $dl_opt == "dl_files_only" ]
then
  IFS=$'\n'
  mkdir -p $dir
  printf "\nTéléchargement des fastq.gz de: $tsv\n\n" >> $dir"/dl_log.out"
  for line in $(cat $tsv)
  do
    bash dl.sh $dir "$line"
  done
elif [ $dl_opt == "fast_forward" ]
then
  open_sem $maxN
  IFS=$'\n'
  mkdir -p $dir
  printf "\nTéléchargement des fastq.gz de: $tsv\n\n" >> $dir"/dl_log.out"
  for line in $(cat $tsv)
  do
    bash dl.sh $dir "$line"
    run_with_lock bash cleandata.sh $dir "$line" $fasta
  done
  wait
fi
