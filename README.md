# Set-Up

There are a few tools that you will need to set up before class.

Please note that this repository and all the results files that you will create will require approximately <b>3.0 GB</b> of space. <b>Please ensure that you have enough disk space for this.</b>

## 1. Create a conda environment for snakemake

Clone this repository:

```bash
git clone https://github.com/sanju99/snakemake_tutorial_BST281.git
```

All your output files will be stored in this repository.

Create the base virtual environment for snakemake using the provided `envs/snakemake.yaml` file, which I've called `snakemake_tutorial_BST281` by running one of the commands below.

### 1.1 Apple Silicon Mac Users

Many conda packages are not available for the Apple silicon processor (ARM), only for the Intel processors. 

However, you can create an Intel conda environment with an additional flag (<a href="https://blog.rtwilson.com/how-to-create-an-x64-intel-conda-environment-on-your-apple-silicon-mac-arm-conda-install/" target="_blank">original instructions</a>):

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake.yaml --name snakemake_tutorial_BST281 --platform osx-64 
```

### 1.2 Linux Users

Some of the graphics and fonts packages I built my environment with are only available for OSX and Windows operating systems. So please use the other YAML file to build your environment:

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake_linux.yaml --name snakemake_tutorial_BST281
```

### 1.3 All Other Users

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake.yaml --name snakemake_tutorial_BST281
```

### 1.4 Minimal Environment

I created a minimal environment file, in which only `snakemake=7.32.4` and direct dependencies are installed. It can be found at `envs/snakemake_minimal.yaml`. An environment generated from this file will not be able to generate an image of the DAG, but it can run the workflow. If this still doesn't work, try running the following (which is how I created the environment from which I generated the YAML file):

```bash
conda create -n snakemake_tutorial_BST281 snakemake=7.32.4 -c bioconda -c conda-forge -c anaconda -c defaults
```

## 2. Download Input FASTQ files from the Releases Section

Navigate to the Releases section of this repository and download the 6 FASTQ files there. 

Each FASTQ file has a sample name, named like `ERRXXXXXXX`. Download the 2 FASTQ files for each sample and place them in the corresponding `results/ERRXXXXXXX` folder in this repository. 

Leave the files in that directory (i.e., don't make a separate subdirectory within `results/ERRXXXXXXX` for the FASTQ files).

Instead of downloading the FASTQ files from the SRA GUI, you can download them through the command line using `sratoolkit`. Installing it is a bit involved, and the instructions are on this <a href="https://github.com/ncbi/sra-tools/wiki" target="_blank">wiki</a>. If you are able to install and use it, you can use the rule `download_input_FASTQ_files` in the `rules.smk` file to download the FASTQ files.


## 3. Install Visual Studio Code (Optional)

Jupyter doesn't color snakemake syntax, which can be annoying while coding. VS Code does, however, which makes coding and debugging easier.

After you've installed VS Code, install <a href="https://marketplace.visualstudio.com/items?itemName=Snakemake.snakemake-lang" target="_blank">Snakemake Language</a> to highlight syntax in your scripts.

# In Class

## 1. Running the Workflow

Run the following steps to run the full workflow. It took ~3 minutes on an M1 Mac with 8 cores. 

```bash
cd snakemake_tutorial_BST281

# activate the environment
conda activate snakemake_tutorial_BST281

# change the number of cores and RAM available for your local machine
snakemake --snakefile snakefile --use-conda --conda-frontend conda --configfile config.yaml --cores 8 --resources mem_mb=8000
```
