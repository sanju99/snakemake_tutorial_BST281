import numpy as np
import pandas as pd

configfile: "config.yaml"

# define the output directory. The outputs will be saved to "results", a subdirectory in your home directory
home_dir = os.getcwd()
output_dir = f"{home_dir}/results"

# number of cores available to use
num_available_cores = config["num_available_cores"]

# dataframe of isolates to run. First column is the sample ID, second column is the sequencing run ID
df_samples_runs = pd.read_csv(config['isolates_to_run'])
sample_run_dict = dict(zip(df_samples_runs['BioSample'], df_samples_runs['Run']))

# Import rules
include: "rules/rules.smk"

rule all:
    input:
        [f"{output_dir}/{sample_ID}/{sample_run_dict[sample_ID]}/read_QC/{sample_run_dict[sample_ID]}_{num}_fastqc.html" for sample_ID in sample_run_dict.keys() for num in [1, 2]],
        [f"{output_dir}/{sample_ID}/{sample_run_dict[sample_ID]}/fastp/{sample_run_dict[sample_ID]}.R{num}.trimmed.fastq.gz" for sample_ID in sample_run_dict.keys() for num in [1, 2]],
        # [f"{output_dir}/{sample_ID}/{sample_run_dict[sample_ID]}/read_QC/{sample_run_dict[sample_ID]}.R{num}.stats.tsv" for sample_ID in sample_run_dict.keys() for num in [1, 2]],
        [f"{output_dir}/{sample_ID}/{sample_run_dict[sample_ID]}/read_QC/{sample_run_dict[sample_ID]}.R{num}.trimmed.stats.tsv" for sample_ID in sample_run_dict.keys() for num in [1, 2]],
        [f"{output_dir}/{sample_ID}/{sample_run_dict[sample_ID]}/kraken/keep_read_names.txt" for sample_ID in sample_run_dict.keys()],
        [f"{output_dir}/{sample_ID}/{sample_run_dict[sample_ID]}/kraken/{sample_run_dict[sample_ID]}.R{num}.trimmed.classified.fastq.gz" for sample_ID in sample_run_dict.keys() for num in [1, 2]],