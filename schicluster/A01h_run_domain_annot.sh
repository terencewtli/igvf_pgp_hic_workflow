#!/bin/bash
#$ -cwd
#$ -o logs/A01h_run_domain_annot.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01h_run_domain_annot
#$ -l h_data=1G,h_rt=1:00:00
#$ -pe shared 1
#$ -t 1-274:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate scFates

PROJDIR=/u/home/t/terencew/project-cluo/igvf/2023_YR2/snm3C/hicluster/
cd $PROJDIR

# ID=1
ID=${SGE_TASK_ID}
printf -v BATCH "%03d" $(($ID - 1))
DOMAIN_PATHS=$PROJDIR/txt/batch/domains/${BATCH}.txt

OUTDIR=$PROJDIR/csv/domains/batch
DOMAIN=$PROJDIR/scripts/domains/A01g_domain_annot.py

time python $DOMAIN $DOMAIN_PATHS $OUTDIR $BATCH

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

