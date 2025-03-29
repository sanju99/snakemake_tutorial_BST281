import os, glob
import numpy as np
import pandas as pd

# define some paths to make the path names more readable
sample_out_dir = f"{output_dir}/{{sample_ID}}"
run_out_dir = f"{output_dir}/{{sample_ID}}/{{run_ID}}"


rule download_input_FASTQ_files:
    output:
        fastq1 = f"{run_out_dir}/{{run_ID}}_1.fastq.gz",
        fastq2 = f"{run_out_dir}/{{run_ID}}_2.fastq.gz",
    params:
        sample_out_dir = sample_out_dir,
    shell:
        """
        # download paired-end FASTQ files. Split into R1 and R2 files (--split-files)
        # specify the output directory and the SRA run ID
        fastq-dump --split-files --gzip --outdir "{params.sample_out_dir}/{wildcards.run_ID}" {wildcards.run_ID}
        """


rule run_fastqc:
    input:
        fastq1 = f"{run_out_dir}/{{run_ID}}_1.fastq.gz",
        fastq2 = f"{run_out_dir}/{{run_ID}}_2.fastq.gz",
    output:
        fastq1_html = f"{run_out_dir}/read_QC/{{run_ID}}_1_fastqc.html",
        fastq2_html = f"{run_out_dir}/read_QC/{{run_ID}}_2_fastqc.html",
        fastq1_zip = temp(f"{run_out_dir}/read_QC/{{run_ID}}_1_fastqc.zip"),
        fastq2_zip = temp(f"{run_out_dir}/read_QC/{{run_ID}}_2_fastqc.zip"),
    params:
        readQC_dir = f"{run_out_dir}/read_QC"
    conda:
        f"{home_dir}/envs/read_QC.yaml"
    shell:
        """
        fastqc --outdir {params.readQC_dir} {input.fastq1} {input.fastq2} --threads 8
        """



rule trim_adapters_low_qual_sequences:
    input:
        fastq1 = f"{run_out_dir}/{{run_ID}}_1.fastq.gz",
        fastq2 = f"{run_out_dir}/{{run_ID}}_2.fastq.gz",
    output:
        fastq1_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R1.trimmed.fastq.gz",
        fastq2_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R2.trimmed.fastq.gz",
        fastp_html = f"{run_out_dir}/fastp/fastp.html",
        fastp_json = f"{run_out_dir}/fastp/fastp.json"
    conda:
        f"{home_dir}/envs/read_QC.yaml"
    params:
        min_read_length = config["min_read_length"],
        average_qual_threshold = config['average_qual_threshold'],
    shell:
        """
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