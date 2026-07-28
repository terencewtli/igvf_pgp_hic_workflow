import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from concurrent.futures import ProcessPoolExecutor
from tqdm import tqdm

from scipy.sparse import csr_matrix
from scipy.io import mmwrite

import sys

tmp_paths = sys.argv[1]
outdir = sys.argv[2]
name = sys.argv[3]

###
projdir = '/u/project/cluo/terencew/igvf/2023_YR2/snm3C/hicluster'

domain_paths = pd.read_csv(tmp_paths, sep='\t', header=None)[0]

bins_path = '/u/project/cluo/terencew/reference/hg38_igvf/bed/windows/25kb/GRCh38.25kb.bed'
bins = pd.read_csv(bins_path, sep='\t', header=None)
bins.index = [f'{x}_{y}' for x,y in zip(bins[0], bins[1])]

nuclei = [x.split('/')[-1].split('.')[0] for x in domain_paths]

###
def load_topdom(path):
    domains = pd.read_csv(path, sep='\t', header=None)
    domains.index = [f'{x}_{y}' for x,y in zip(domains[0], domains[1])]
    domains.columns = ['chrom', 'start', 'end', 'type', 'cell']
    return domains

with ProcessPoolExecutor() as executor:
    results = list(tqdm(executor.map(load_topdom, domain_paths), total=len(domain_paths)))

###

bin_size = 25000

# function to generate bins for one row
def make_bins(row):
    starts = np.arange(row['start'], row['end'], bin_size)
    ends = np.minimum(starts + bin_size, row['end'])
    return pd.DataFrame({
        'chrom': row['chrom'],
        'start': starts,
        'end': ends,
        'type': row['type'],
        'cell': row['cell']
    })

def annotate_domains(domains):
    tmp_bins = pd.DataFrame(index=bins.index, columns=['domain'], data=0)
    tmp_domains = domains[domains['type'] == 'domain']

    ###
    domains_expanded = pd.concat([make_bins(row) for _, row in tmp_domains.iterrows()], ignore_index=True)
    domains_expanded.index = [f'{x}_{y}' for x,y in zip(domains_expanded['chrom'], domains_expanded['start'])]
    mask = tmp_bins.index.isin(domains_expanded.index)
    tmp_bins.loc[mask,'domain'] = 1

    return tmp_bins

with ProcessPoolExecutor() as executor:
    domain_annots = list(tqdm(executor.map(annotate_domains, results), total=len(results)))

domain_merged = pd.concat(domain_annots, axis=1)

###
def annotate_boundaries(domains):
    tmp_bins = pd.DataFrame(index=bins.index, columns=['domain'], data=0)
    tmp_boundaries = domains[domains['type'] == 'boundary']

    ###
    boundaries_expanded = pd.concat([make_bins(row) for _, row in tmp_boundaries.iterrows()], ignore_index=True)
    boundaries_expanded.index = [f'{x}_{y}' for x,y in zip(boundaries_expanded['chrom'], boundaries_expanded['start'])]
    mask = tmp_bins.index.isin(boundaries_expanded.index)
    tmp_bins.loc[mask,'domain'] = 1

    return tmp_bins

with ProcessPoolExecutor() as executor:
    boundary_annots = list(tqdm(executor.map(annotate_boundaries, results), total=len(results)))
boundary_merged = pd.concat(boundary_annots, axis=1)

###
final_domain = csr_matrix(domain_merged.values)
final_boundary = csr_matrix(boundary_merged.values)

mmwrite(f'{outdir}/{name}.domains', final_domain)
mmwrite(f'{outdir}/{name}.boundary', final_boundary)

# boundary_merged.to_csv(f'{outdir}/{name}.boundary.csv.gz', sep='\t', header=True, index=True)

# ###
# domain_merged.columns = nuclei
# boundary_merged.columns = nuclei

###
# domain_merged.to_csv(f'{outdir}/{name}.domains.csv.gz', sep='\t', header=True, index=True)
# boundary_merged.to_csv(f'{outdir}/{name}.boundary.csv.gz', sep='\t', header=True, index=True)
