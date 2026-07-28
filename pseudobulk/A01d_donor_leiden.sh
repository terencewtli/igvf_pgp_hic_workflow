#!/bin/bash
#$ -cwd
#$ -o logs/A01d_donor_leiden.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01d_donor_leiden
#$ -l h_data=4G,h_rt=16:00:00
#$ -pe shared 12
#$ -t 1-49:1

echo "Job $JOB_ID.$SGE_TASK_ID started: $(hostname -s) $(date)"

source ~/.bashrc
conda activate mapping

# ── paths ────────────────────────────────────────────────────────────────────
PSEUDO=donor_leiden
PROJDIR=/u/project/cluo/terencew/igvf/2023_YR2/snm3C/pseudobulk_hic
SCRATCHDIR=/u/project/cluo_scratch/terencew/igvf/2023_YR2/snm3C/pseudobulk_hic
JUICER=/u/project/cluo/terencew/programs/juicer_tools_1.22.01.jar

BINS=/u/project/cluo/terencew/reference/hg38_igvf/bed/windows/1kb/GRCh38.1kb.bed
RESOLUTIONS=1000,5000,10000,25000,100000
BALANCE_RES="1000 5000 10000 25000 100000"
NCPUS=12

# ── sample ───────────────────────────────────────────────────────────────────
SAMPLE=$(sed -n "${SGE_TASK_ID}p" $PROJDIR/txt/${PSEUDO}.txt)
echo "Sample: $SAMPLE"

CONTACT_LIST=$PROJDIR/txt/pseudobulk/${PSEUDO}/${SAMPLE}.txt
RAW=$SCRATCHDIR/merged_contacts/raw/${PSEUDO}/${SAMPLE}.tsv
COOL=$SCRATCHDIR/merged_contacts/cooler/${PSEUDO}/${SAMPLE}.1kb.cool
MCOOL=$SCRATCHDIR/merged_contacts/cooler/${PSEUDO}/${SAMPLE}.mcool
HIC=$SCRATCHDIR/merged_contacts/juicer/${PSEUDO}/${SAMPLE}.hic

mkdir -p $(dirname $RAW) $(dirname $COOL) $(dirname $HIC)

# ── step 1: merge contacts → sorted TSV ──────────────────────────────────────
echo "[1/4] Merging contacts..."
time xargs -a $CONTACT_LIST zcat | \
    awk -v OFS='\t' '{print $1,$2,$3,$4,1}' | \
    sort -S 4G --parallel=$NCPUS -k1,1 -k2,2n -k3,3 -k4,4n > $RAW

# ── step 2: cooler cload → zoomify ───────────────────────────────────────────
echo "[2/4] cooler cload (1kb base)..."
time cooler cload pairs \
    --assembly hg38 \
    -c1 1 -p1 2 -c2 3 -p2 4 \
    $BINS $RAW $COOL

echo "[2/4] cooler zoomify ($RESOLUTIONS)..."
time cooler zoomify \
    -r $RESOLUTIONS \
    -n $NCPUS \
    -o $MCOOL \
    $COOL

rm -f $COOL

# ── step 3: balance ───────────────────────────────────────────────────────────
echo "[3/4] Balancing..."
for RES in $BALANCE_RES; do
    echo "  balancing ${RES}..."
    time cooler balance -f -p $NCPUS ${MCOOL}::/resolutions/${RES}
done

# ── step 4: mcool → .hic ─────────────────────────────────────────────────────
# Juicer pre cannot read from a pipe (/dev/stdin is not seekable).
# Write expanded pairs to a temp file in scratch, then pass to juicer.
echo "[4/4] Converting mcool → hic..."
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

echo "  running juicer pre..."
time java -Xmx16g -jar $JUICER pre \
    -r $RESOLUTIONS \
    -j $NCPUS \
    $TMPAIRS $HIC hg38

rm -f $TMPAIRS

echo "Job $JOB_ID.$SGE_TASK_ID finished: $(date)"
