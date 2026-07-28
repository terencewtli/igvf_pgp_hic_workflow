#!/bin/bash
#$ -cwd
#$ -o logs/A01e_ips_cluster_hic.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01e_ips_cluster_hic
#$ -l h_data=4G,h_rt=8:00:00
#$ -pe shared 12
#$ -t 1-2:1

echo "Job $JOB_ID.$SGE_TASK_ID started: $(hostname -s) $(date)"

source ~/.bashrc
conda activate mapping

# ── paths ────────────────────────────────────────────────────────────────────
PSEUDO=ips_cluster
PROJDIR=/u/project/cluo/terencew/igvf/2023_YR2/snm3C/pseudobulk_hic
SCRATCHDIR=/u/project/cluo_scratch/terencew/igvf/2023_YR2/snm3C/pseudobulk_hic
JUICER=/u/project/cluo/terencew/programs/juicer_tools_1.22.01.jar

RESOLUTIONS=5000,10000,25000,100000,250000,500000,1000000
NCPUS=12

# ── sample ───────────────────────────────────────────────────────────────────
SAMPLE=$(sed -n "${SGE_TASK_ID}p" $PROJDIR/txt/${PSEUDO}.txt)
echo "Sample: $SAMPLE"

MCOOL=$SCRATCHDIR/merged_contacts/cooler/${PSEUDO}/${SAMPLE}.mcool
HIC=$SCRATCHDIR/merged_contacts/juicer/${PSEUDO}/${SAMPLE}.hic

mkdir -p $(dirname $HIC)

# ── step 4: mcool → .hic ─────────────────────────────────────────────────────
TMPDIR_HIC=$(dirname $HIC)/tmp
mkdir -p $TMPDIR_HIC
TMPAIRS=$TMPDIR_HIC/${SAMPLE}.pairs.tmp

echo "  dumping + expanding pairs to $TMPAIRS ..."
time cooler dump --join ${MCOOL}::/resolutions/1000 | \
    awk 'BEGIN{OFS="\t"} {
        pos1 = $2 + 1
        pos2 = $5 + 1
        n = int($7)
        for (i = 0; i < n; i++) print 0, $1, pos1, 0, 16, $4, pos2, 1
    }' > $TMPAIRS

# cooler dump emits pixels in (bin1,bin2) order: for each bin1, ALL bin2 contacts
# follow, so the same chr pair appears in many non-contiguous chunks.
# Sort by (chr1, chr2, pos1, pos2) to make each chromosome pair contiguous,
# then pass -s (pre-sorted) to juicer pre.
echo "  sorting pairs by chr pair..."
TMPSORTED=${TMPAIRS}.sorted
time sort -k2,2 -k6,6 -k3,3n -k7,7n -S 8G --parallel=$NCPUS $TMPAIRS > $TMPSORTED
mv $TMPSORTED $TMPAIRS

echo "  running juicer pre..."
time java -Xmx16g -jar $JUICER pre \
    -r $RESOLUTIONS \
    $TMPAIRS $HIC hg38

rm -f $TMPAIRS

echo "Job $JOB_ID.$SGE_TASK_ID finished: $(date)"
