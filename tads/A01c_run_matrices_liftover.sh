#!/bin/bash
#$ -cwd
#$ -o logs/A02c_run_matrices_liftover.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A02c_run_matrices_liftover
#$ -l h_data=2G,h_rt=2:00:00
#$ -pe shared 4
#$ -t 1-10:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/project/cluo/terencew/igvf/2023_YR2/snm3C/pseudobulk_hic
cd $PROJDIR

# ID=1
ID=$SGE_TASK_ID
SAMPLES=$PROJDIR/txt/liftover.txt
SAMPLE=$(head -${ID} $SAMPLES | tail -1)

MATRICES=$PROJDIR/scripts/tads/topdom/A01a_get_matrices.py
INDIR=/u/project/cluo_scratch/terencew/igvf/2023_YR2/snm3C/pseudobulk_hic/merged_contacts/cooler/liftover/
COOLER=$INDIR/${SAMPLE}.mcool

OUTDIR=$PROJDIR/mtx/for_topdom/liftover

time python $MATRICES $COOLER $SAMPLE $OUTDIR

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
