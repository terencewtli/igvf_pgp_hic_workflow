#!/bin/bash
#$ -cwd
#$ -o logs/A01c_impute_25kb.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01c_impute_25kb
#$ -l h_data=2G,h_rt=15:00:00
#$ -pe shared 4
#$ -t 1-711:1

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
# CONTACTS=$PROJDIR/txt/batch/rmbkl/${BATCH}.txt
CONTACTS=$PROJDIR/txt/batch/impute_25kb/${BATCH}.txt

CHROM_SIZES=/u/project/cluo/terencew/reference/hg38_igvf/GRCh38.autosomal.chromsizes
BINS_DIR=/u/home/t/terencew/project-cluo/reference/hg38_igvf/bed/25kb/

RES=25000

### impute params
MODE=pad2_std1_rp0.5_sqrtvc
DIST=10050000

INDIR=$PROJDIR/old_hicluster/cell_matrix/25kb_resolution/
OUTDIR=$PROJDIR/old_hicluster/imputed_matrix/25kb_resolution/

TOPDOM=/u/project/cluo/terencew/miniconda3/envs/hiclusterv2/lib/python3.6/site-packages/schicluster/draft/domain_topdom_cell.R

### altogether takes about 20 min per cell

time for CONTACT in $(cat $CONTACTS);
do
  CELL=$(basename ${CONTACT%.contact*})
  time for c in `seq 1 22`;
  do
      ### is it chr${c}?
      hicluster impute-cell --indir $INDIR/chr${c}/ \
        --outdir $OUTDIR/chr${c}/ \
        --cell $CELL --chrom ${c} \
        --res $RES --pad 2 --output_dist $DIST \
        --mode $MODE --chrom_file $CHROM_SIZES;

      hicluster domain-insulation-cell \
      --indir $OUTDIR \
      --cell $CELL --chrom ${c} --mode $MODE --w 10;

      Rscript $TOPDOM $CELL ${c} $MODE \
          10 $OUTDIR $OUTDIR $BINS_DIR
  done
done

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
