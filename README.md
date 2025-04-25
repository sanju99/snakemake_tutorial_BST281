# Set-Up (Please Complete Before Class on April 28)

There are a few tools that you will need to set up before class.

Please note that this repository and all the results files that you will create will require approximately <b>2.5 GB</b> of space. <b>Please ensure that you have enough disk space for this.</b>

## 1. Create a conda environment for snakemake

Clone this repository:

```bash
git clone https://github.com/sanju99/snakemake_tutorial_BST281.git
```

All your output files will be stored in this repository.

Create the base virtual environment for snakemake using the provided `envs/snakemake.yaml` file, which I've called `snakemake_tutorial_BST281` by running one of the commands below.

### 1.1 Apple Silicon Mac Users

Many conda packages are not available for the Apple silicon processor (ARM), only for the Intel processors. 

However, you can create an Intel conda environment with a simple additional flag (<a href="https://blog.rtwilson.com/how-to-create-an-x64-intel-conda-environment-on-your-apple-silicon-mac-arm-conda-install/" target="_blank">original instructions</a>):

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake.yaml --name snakemake_tutorial_BST281 --platform osx-64 
```

### 1.2 All Other Users

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake.yaml --name snakemake_tutorial_BST281
```

## 2. Download Input FASTQ files from the Releases Section

Navigate to the Releases section of this repository and download the 6 FASTQ files there. 

Each FASTQ file has a sample name, named like `ERRXXXXXXX`. Download the 2 FASTQ files for each sample and place them in the corresponding `results/ERRXXXXXXX` folder in this repository. 

Leave the files in that directory (i.e., don't make a separate subdirectory within `results/ERRXXXXXXX` for the FASTQ files).

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
