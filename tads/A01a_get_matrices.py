import numpy as np
import pandas as pd

import cooler
from scipy.sparse import csc_matrix
from scipy.io import mmread, mmwrite

from concurrent.futures import ThreadPoolExecutor
from tqdm import tqdm

import sys

cooler_path = sys.argv[1]
s = sys.argv[2]
outdir = sys.argv[3]

res = 25000
clr = cooler.Cooler(f'{cooler_path}::/resolutions/{res}')

chroms = [f'chr{i}' for i in range(1, 23)]
# chroms = [i for i in range(1, 23)]

def process_chrom(chrom, clr, s):
    # idx = chrom.split('chr')[1]
    idx = chrom
    mtx = clr.matrix(balance=False).fetch(idx)
    mtx = np.nan_to_num(mtx)  # Replace NaN values with 0 or other value
    mtx = csc_matrix(mtx)  # Convert to sparse matrix (CSC)

    mmwrite(f'{outdir}/{s}.{chrom}.mtx', mtx)  # Save the matrix in Matrix Market format

with ThreadPoolExecutor(max_workers=8) as executor:
    list(tqdm(executor.map(lambda chrom: process_chrom(chrom, clr, s), chroms), total=len(chroms)))
