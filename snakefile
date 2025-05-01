import numpy as np
import pandas as pd

configfile: "config.yaml"

# define the output directory. The outputs will be saved to "results", a subdirectory in your home directory
home_dir = os.getcwd()
output_dir = f"{home_dir}/results"

# dataframe of isolates to run. First column is the sample ID, second column is the sequencing run ID
samples_lst = pd.read_csv(config['isolates_to_run'])['Run'].values

# Import rules
include: "rules/rules.smk"

rule all:
    input:
        [f"{output_dir}/{run_ID}/read_QC/{run_ID}_{num}_fastqc.html" for run_ID in samples_lst for num in [1, 2]],
        [f"{output_dir}/{run_ID}/read_QC/{run_ID}.R{num}.trimmed.stats.tsv" for run_ID in samples_lst for num in [1, 2]],
        [f"{output_dir}/{run_ID}/kraken/{run_ID}.R{num}.trimmed.unclassified.fastq" for run_ID in samples_lst for num in [1, 2]],
