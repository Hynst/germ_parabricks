#!/bin/bash

SAMPLE_DIR=$1
RUN_ID=$2

touch /mnt/shared/MedGen/ACGT/src_parabricks/config/$RUN_ID.tsv

for sample in `ls $SAMPLE_DIR/*.gz | grep R1`
do
	# get sample ID
	S_ID=`basename ${sample%_R1.fastq.gz}`
	#
	echo $S_ID
	# R1 and R2 fastq
	R1=`echo $sample`
	R2=`echo ${SAMPLE_DIR}/${S_ID}_R2.fastq.gz`
	#
	# get flow cell ID
	FC_ID=`zcat $R1 | head -n 1 | cut -f3 -d":"`
	echo $FC_ID
	#
	# create TSV config file
	R1_DIR_F=`echo $R1`
	R2_DIR_F=`echo $R2`
	#echo $R1_DIR_F
	#echo $R2_DIR_F
	awk -v S_ID="$S_ID" -v FC_ID="$FC_ID" -v R1="$R1_DIR_F" -v R2="$R2_DIR_F" 'BEGIN{print S_ID, "XX", "0", S_ID, FC_ID, R1, R2}' \
        | sed 's/ /\t/g' >> /mnt/shared/MedGen/ACGT/src_parabricks/config/$RUN_ID.tsv
done
