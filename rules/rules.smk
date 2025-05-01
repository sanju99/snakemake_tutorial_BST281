import os, glob
import numpy as np
import pandas as pd

# define the output path for each sample to shorted the paths in the rules
run_out_dir = f"{output_dir}/{{run_ID}}"



rule download_input_FASTQ_files:
    output:
        fastq1 = f"{run_out_dir}/{{run_ID}}_1.fastq.gz",
        fastq2 = f"{run_out_dir}/{{run_ID}}_2.fastq.gz",
    params:
        run_out_dir = run_out_dir,
    shell:
        """
        # download paired-end FASTQ files. Split into R1 and R2 files (--split-files)
        # specify the output directory and the SRA run ID
        fastq-dump --split-files --gzip --outdir "{params.run_out_dir}/{wildcards.run_ID}" {wildcards.run_ID}
        """


rule run_fastqc:
    input:
        fastq1 = f"{run_out_dir}/{{run_ID}}_1.fastq.gz", # provided as input in the repository
        fastq2 = f"{run_out_dir}/{{run_ID}}_2.fastq.gz", # provided as input in the repository
    output:
        # fastqc output files
        fastq1_html = f"{run_out_dir}/read_QC/{{run_ID}}_1_fastqc.html",
        fastq2_html = f"{run_out_dir}/read_QC/{{run_ID}}_2_fastqc.html",
        fastq1_zip = temp(f"{run_out_dir}/read_QC/{{run_ID}}_1_fastqc.zip"),
        fastq2_zip = temp(f"{run_out_dir}/read_QC/{{run_ID}}_2_fastqc.zip"),
    params:
        readQC_dir = f"{run_out_dir}/read_QC",
        min_read_length = config["min_read_length"],
        average_qual_threshold = config['average_qual_threshold'],
    conda:
        f"{home_dir}/envs/read_QC.yaml"
    threads:
        config['threads']
    shell:
        """
        fastqc --outdir {params.readQC_dir} {input.fastq1} {input.fastq2} --threads {threads}
        """



rule fastp_adapter_trimming:
    input:
        fastq1 = f"{run_out_dir}/{{run_ID}}_1.fastq.gz", # provided as input in the repository
        fastq2 = f"{run_out_dir}/{{run_ID}}_2.fastq.gz", # provided as input in the repository
    output:
        # fastp output files
        fastq1_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R1.trimmed.fastq.gz",
        fastq2_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R2.trimmed.fastq.gz",
        fastp_html = f"{run_out_dir}/fastp/fastp.html",
        fastp_json = f"{run_out_dir}/fastp/fastp.json"
    params:
        min_read_length = config["min_read_length"],
        average_qual_threshold = config['average_qual_threshold'],
    conda:
        f"{home_dir}/envs/read_QC.yaml"
    threads:
        config['threads']
    shell:
        """
        fastp -i {input.fastq1} -I {input.fastq2} \
                -o {output.fastq1_trimmed} -O {output.fastq2_trimmed} \
                -h {output.fastp_html} -j {output.fastp_json} \
                --average_qual {params.average_qual_threshold} \
                --length_required {params.min_read_length} \
                --thread {threads} \
                --dedup
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


rule get_unclassified_read_names:
    input:
        kraken_classifications = f"{run_out_dir}/kraken/kraken_classifications.txt.gz",
    output:
        read_names_file = f"{run_out_dir}/kraken/unclassified_read_names.txt"
    run:
        df_kraken_classifications = pd.read_csv(input.kraken_classifications, sep='\t', header=None)
        df_kraken_classifications.columns = ['Classified_Unclassified', 'Read_Name', 'Tax_ID', 'Read_Length', 'LCA_kmer']

        # get a pandas series of names of unclassified reads
        reads_to_keep = df_kraken_classifications.query("Classified_Unclassified=='U'")['Read_Name']

        # save the series as a text file with no header
        reads_to_keep.to_csv(output.read_names_file, index=False, sep='\t', header=None)



rule extract_unclassified_kraken_reads:
    input:
        fastq1_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R1.trimmed.fastq.gz",
        fastq2_trimmed = f"{run_out_dir}/fastp/{{run_ID}}.R2.trimmed.fastq.gz",
        read_names_file = f"{run_out_dir}/kraken/unclassified_read_names.txt"
    output:
        fastq1_trimmed_unclassified_unzipped = f"{run_out_dir}/kraken/{{run_ID}}.R1.trimmed.unclassified.fastq",
        fastq2_trimmed_unclassified_unzipped = f"{run_out_dir}/kraken/{{run_ID}}.R2.trimmed.unclassified.fastq",
    conda:
        f"{home_dir}/envs/read_QC.yaml"
    params:
        run_ID = f"{{run_ID}}"
    shell:
        """
        # seqtk will write outputs to unzipped files, even if the input was compressed
        seqtk subseq {input.fastq1_trimmed} {input.read_names_file} > {output.fastq1_trimmed_unclassified_unzipped}
        seqtk subseq {input.fastq2_trimmed} {input.read_names_file} > {output.fastq2_trimmed_unclassified_unzipped}

        # check that the output file names have the same number of lines. wc -l gets line count. Divide by 4 to get number of reads
        num_reads_unclassified_R1=$(( $(wc -l < {output.fastq1_trimmed_unclassified_unzipped}) / 4 ))
        num_reads_unclassified_R2=$(( $(wc -l < {output.fastq2_trimmed_unclassified_unzipped}) / 4 ))

        # get the total number of lines in the original files to print out the percent of unclassified reads
        # the fastp-trimmed files are gzipped, so need to unzip them first.
        num_reads_trimmed_R1=$(( $(gunzip -c {input.fastq1_trimmed} | wc -l) / 4 ))
        num_reads_trimmed_R2=$(( $(gunzip -c {input.fastq2_trimmed} | wc -l) / 4 ))

        # example of QC. Check that the number of reads is the same in the R1 and R2 files
        if [[ $num_reads_unclassified_R1 -eq $num_reads_unclassified_R2 ]]; then
            echo "The two paired-end kraken-classified files for {params.run_ID} have the same number of reads: $num_reads_unclassified_R1"
        else
            echo "Discrepant numbers of lines for {params.run_ID}: R1 = $num_reads_unclassified_R1, R2 = $num_reads_trimmed_R2"
        fi

        # print out the percent of reads that are unclassified. We already checked that the numbers of reads are the same for R1 and R2, so can just check one
        percent_unclassified=$(echo "scale=2; 100 * $num_reads_unclassified_R1 / $num_reads_trimmed_R1" | bc)
        echo "$num_reads_unclassified_R1/$num_reads_trimmed_R1 ($percent_unclassified%) of {params.run_ID} reads are unclassified"
        """