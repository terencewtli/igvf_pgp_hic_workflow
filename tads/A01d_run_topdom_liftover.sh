#!/bin/bash
#$ -cwd
#$ -o logs/A02d_run_topdom_liftover.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A02d_run_topdom_liftover
#$ -l h_data=2G,h_rt=1:00:00
#$ -pe shared 2
#$ -t 1-10:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

PROJDIR=/u/project/cluo/terencew/igvf/2023_YR2/snm3C/pseudobulk_hic
cd $PROJDIR

# ID=1
ID=$SGE_TASK_ID
SAMPLES=$PROJDIR/txt/liftover.txt
SAMPLE=$(head -${ID} $SAMPLES | tail -1)

TOPDOM=$PROJDIR/scripts/tads/topdom/A01b_run_topdom.R
INDIR=$PROJDIR/mtx/for_topdom/liftover/
OUTDIR=$PROJDIR/tads/topdom/liftover/

time Rscript $TOPDOM $SAMPLE $INDIR $OUTDIR

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
