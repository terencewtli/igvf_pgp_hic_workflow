#!/bin/bash
#$ -cwd
#$ -o logs/A01a_gen_matrix.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01a_gen_matrix
#$ -l h_data=2G,h_rt=2:00:00
#$ -pe shared 2
#$ -t 1-285:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate schicluster

PROJDIR=/u/home/t/terencew/project-cluo/igvf/2023_YR2/snm3C/hicluster/
cd $PROJDIR

# ID=1
ID=${SGE_TASK_ID}
printf -v BATCH "%03d" $(($ID - 1))
CONTACTS=$PROJDIR/txt/batch/rmbkl/${BATCH}.txt

CHROM_SIZES=/u/project/cluo/terencew/reference/hg38_igvf/GRCh38.autosomal.chromsizes

OUTDIR=$PROJDIR/old_hicluster/cell_matrix/25kb_resolution/

RES=25000

time for CONTACT in $(cat $CONTACTS);
do
  CELL=$(basename ${CONTACT%.contact*})
  hicluster generatematrix-cell \
    --infile $CONTACT \
    --outdir $OUTDIR \
    --chrom_file $CHROM_SIZES \
    --res $RES --cell $CELL \
    --chr1 0 --pos1 1 --chr2 2 --pos2 3;
done


