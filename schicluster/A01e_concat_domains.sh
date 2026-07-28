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

# ID=1
ID=${SGE_TASK_ID}
printf -v BATCH "%03d" $(($ID - 1))
CONTACTS=$PROJDIR/txt/batch/rmbkl/${BATCH}.txt
# CONTACTS=$PROJDIR/txt/batch/impute_25kb/${BATCH}.txt

CHROM_SIZES=/u/project/cluo/terencew/reference/hg38_igvf/GRCh38.autosomal.chromsizes

RES=25000

### impute params
MODE=pad2_std1_rp0.5_sqrtvc
STEP=10000000
DIST=10050000

INDIR=$PROJDIR/old_hicluster/imputed_matrix/25kb_resolution/merged/
OUT=$INDIR/test

CELL_LIST=$INDIR/tmp.txt

time hicluster domain-concatcell-chr \
               --cell_list $CELL_LIST \
               --outprefix $OUT \
               --res $RES \
               --ncpus 40
