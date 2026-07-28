library(Matrix)
###
conda_dir <- '/u/home/t/terencew/project-cluo/miniconda3/envs/schicluster'
td_dir <- paste0(conda_dir, '/lib/python3.6/site-packages/schicluster/domain')
td_path <- paste0(td_dir, '/TopDom.R')
source(td_path)

###
args <- commandArgs(trailingOnly = TRUE)
s <- args[1]
indir <- args[2]
outdir <- args[3]

# projdir <- '/u/project/cluo/terencew/igvf/2023_YR2/snm3C'
# indir <- paste0(projdir, '/pseudobulk_hic/mtx/for_topdom/donor_time/')
ws <- 10
bin.size <- 25000
chroms <- paste0('chr', 1:22)

for (chrom in chroms) {

  mtx_path <- paste0(indir, s, '.', chrom, '.', 'mtx')

  mtx <- readMM(mtx_path)
  mtx_dense <- as.matrix(mtx)
  mtx_csc <- as(Matrix(mtx_dense, sparse = TRUE), "dgCMatrix")

  j <- mtx_csc@i + 1
  p <- mtx_csc@p
  x <- mtx_csc@x

  bins <- data.frame(
    chr = rep(chrom, nrow(mtx)), # Adjust to your chromosome
    start = seq(0, by = bin.size, length.out = nrow(mtx)),
    end = seq(bin.size, by = bin.size, length.out = nrow(mtx))
  )
  colnames(bins) <- c("chr", "from.coord", "to.coord")

  topdom_result <- RunTopDom(j, p, x, bins, ws)

  # outdir <- paste0(projdir, '/pseudobulk_hic/tads/topdom/donor_time/by_chrom')
  out <- paste0(outdir, '/', s, '.', chrom, '.bed')
  write.table(topdom_result, out, quote=FALSE, sep='\t', row.names=FALSE, col.names=FALSE)

}
