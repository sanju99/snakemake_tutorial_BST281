import os, glob
import numpy as np
import pandas as pd

# define the output path for each sample to shorted the paths in the rules
run_out_dir = f"{output_dir}/{{run_ID}}"


rule run_fastqc_and_fastp:
    input:
        fastq1 = f"{run_out_dir}/{{run_ID}}_1.fastq.gz", # provided as input in the repository
        fastq2 = f"{run_out_dir}/{{run_ID}}_2.fastq.gz", # provided as input in the repository
    output:
        # fastqc output files
        fastq1_html = f"{run_out_dir}/read_QC/{{run_ID}}_1_fastqc.html",
        fastq2_html = f"{run_out_dir}/read_QC/{{run_ID}}_2_fastqc.html",
        fastq1_zip = temp(f"{run_out_dir}/read_QC/{{run_ID}}_1_fastqc.zip"),
        fastq2_zip = temp(f"{run_out_dir}/read_QC/{{run_ID}}_2_fastqc.zip"),

        # fastp output files
        fastq1_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R1.trimmed.fastq.gz",
        fastq2_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R2.trimmed.fastq.gz",
        fastp_html = f"{run_out_dir}/fastp/fastp.html",
        fastp_json = f"{run_out_dir}/fastp/fastp.json"
    params:
        readQC_dir = f"{run_out_dir}/read_QC",
        min_read_length = config["min_read_length"],
        average_qual_threshold = config['average_qual_threshold'],
    conda:
        f"{home_dir}/envs/read_QC.yaml"
    shell:
        """
        fastqc --outdir {params.readQC_dir} {input.fastq1} {input.fastq2} --threads 8

        fastp -i {input.fastq1} -I {input.fastq2} \
                -o {output.fastq1_trimmed} -O {output.fastq2_trimmed} \
                -h {output.fastp_html} -j {output.fastp_json} \
                --average_qual {params.average_qual_threshold} \
                --length_required {params.min_read_length} \
                --dedup --thread 8
        """



rule compute_read_stats:
    input:
        fastq1_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R1.trimmed.fastq.gz",
        fastq2_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R2.trimmed.fastq.gz",
    output:
        seqkit_trimmed_stats_1 = f"{run_out_dir}/read_QC/{{run_ID}}.R1.trimmed.stats.tsv",
        seqkit_trimmed_stats_2 = f"{run_out_dir}/read_QC/{{run_ID}}.R2.trimmed.stats.tsv",
    conda:
        f"{home_dir}/envs/read_QC.yaml"
    shell:
        """
        # -a means to compute all possible stats. --tabular converts the output to tabular format
        seqkit stats -a --tabular -o {output.seqkit_trimmed_stats_1} {input.fastq1_trimmed}
        seqkit stats -a --tabular -o {output.seqkit_trimmed_stats_2} {input.fastq2_trimmed}
        """