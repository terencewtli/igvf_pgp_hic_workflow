#!/bin/bash
#$ -cwd
#$ -o logs/A01b_impute_10kb.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01b_impute_10kb
#$ -l h_data=2G,h_rt=24:00:00
#$ -pe shared 8
#$ -t 1-285:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate schicluster

PROJDIR=/u/home/t/terencew/project-cluo/igvf/2023_YR2/snm3C/hicluster/
cd $PROJDIR

### impute_10kb altogether takes about 1 hour per cell

IN=$PROJDIR/txt/rmbkl_paths.txt
OUT=$PROJDIR/txt/batch/impute_25kb/

split -d -a3 -l 40 --additional-suffix=.txt $IN $OUT

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
