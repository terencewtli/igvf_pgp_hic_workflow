#!/bin/bash
#$ -cwd
#$ -o logs/A01c_concat_domains.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01c_concat_domains
#$ -l h_data=2G,h_rt=2:00:00
#$ -pe shared 2
#$ -t 1-286:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

# conda activate schicluster

### dangerous gameeeee
conda activate hiclusterv2

PROJDIR=/u/home/t/terencew/project-cluo/igvf/2023_YR2/snm3C/hicluster/
cd $PROJDIR

IN=$PROJDIR/txt/domains/domains_paths.txt
OUT=$PROJDIR/txt/batch/domains/

split -d -a3 -l 100 --additional-suffix=.txt $IN $OUT

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

