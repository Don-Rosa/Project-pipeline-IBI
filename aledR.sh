#!/bin/bash

dir="$1"
filename="$2"                 # On explicite les parametres

##CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	AP13.1	UFMG-CM-Y215	UFMG-CM-Y223	UFMG-CM-Y228	UFMG-CM-Y251	UFMG-CM-Y617	UFMG-CM-Y618	UFMG-CM-Y619	UFMG-CM-Y620	UFMG-CM-Y621	UFMG-CM-Y622	UFMG-CM-Y623	UFMG-CM-Y624	UFMG-CM-Y625	UFMG-CM-Y627	UFMG-CM-Y628	UFMG-CM-Y629	UFMG-CM-Y630	UFMG-CM-Y631	UFMG-CM-Y632	UFMG-CM-Y633	UFMG-CM-Y634	UFMG-CM-Y635	UFMG-CM-Y637	UFMG-CM-Y638	UFMG-CM-Y648

IFS=$'\n'
for line in $(cat "$dir"/"$filename")
do
  IFS=$'\t' read -r -a vcf_l <<< "$line" #Gros gain de performance à ne pas utiliser cut et |
  info="${vcf_l[7]}"

  if [ "$info" != "INFO" ]
  then
    IFS=$';' read -r -a info_split <<< "$info"
    IFS=$'='
    QD=0  ; FS=0 ; MQ=0 ; MQRankSum=0 ; ReadPosRankSum=0 ;SOR=0
    for ((i=0; i<"${#info_split[@]}"; i++))
    do
      read -r -a filters <<< "${info_split[i]}"
      case "${filters[0]}" in
        "QD") QD="${filters[1]}" ;;
        "FS") FS="${filters[1]}" ;;
        "MQ") MQ="${filters[1]}" ;;
        "MQRankSum") MQRankSum="${filters[1]}" ;;
        "ReadPosRankSum") ReadPosRankSum="${filters[1]}" ;;
        "SOR") SOR="${filters[1]}" ;;
         *) ;;
      esac
    done
    echo -e "$line""\t$QD\t$FS\t$MQ\t$MQRankSum\t$ReadPosRankSum\t$SOR" >> "$dir"/"levure_forR.vcf"

  else #La première ligne
    echo -e "$line""\tQD\tFS\tMQ\tMQRankSum\tReadPosRankSum\tSOR" >> "$dir"/"levure_forR.vcf"
  fi
done
