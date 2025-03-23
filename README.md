# Set-Up (Please Complete Before Class on April 28)

There are a few tools that it would be beneficial to have set-up before the in-class activity.

## 1. SRA Toolkit

SRA Toolkit is a suite of tools built by the NCBI for accessing data stored in the Sequence Read Archive (SRA). 

When accessing public data, you can download it from the GUIs provided by SRA or the European Nucleotide Archive (<a href="https://www.ebi.ac.uk/ena/browser/" target="_blank">ENA</a>), which has much of the same public data, or you can download data programmatically using SRA Toolkit, which is my preference.

### Installation

1. Download the appropriate installer for your machine from the first section of the page <a href="https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit" target="_blank">here</a>.
2. Unzip the folder and move it to your desired location. 
3. Follow the steps in this <a href="https://github.com/ncbi/sra-tools/wiki/03.-Quick-Toolkit-Configuration" target="_blank">Quick Configuration Guide</a>, specifically steps 1 and 3. Make sure to navigate to the `bin` subfolder within the sra-tool-kit folder that you just downloaded, before running `vdb-config -i`. For example, mine is `/Users/skulkarni/Desktop/sratoolkit.3.2.0-mac-arm64/bin`
4. Add this line to your `~/.zshrc` or `~/.bashrc` file: `export PATH="/Users/skulkarni/Desktop/sratoolkit.3.2.0-mac-arm64/bin:$PATH"`, changing the directory name to the one on your machine.
5. Run `source ~/.zshrc` or `source ~/.bashrc` to update the changes.
6. Check that you can run `fastq-dump` from any directory, not just where you downloaded the executable above to.

## 2. Create a conda environment for snakemake

Clone this repository:

```bash
git clone https://github.com/sanju99/snakemake_tutorial_BST281.git
```

All your output files will be stored in this repository. Also create the base virtual environment for snakemake using the provided `envs/snakemake.yaml` file. Replace the `<env_name>` placeholder with your desired environment name (commands below).

### 2.1 Apple Silicon Mac Users

Many conda packages are not available for the Apple silicon processor (ARM), only for the Intel processors. 

However, you can create an Intel conda environment with a simple additional flag (<a href="https://blog.rtwilson.com/how-to-create-an-x64-intel-conda-environment-on-your-apple-silicon-mac-arm-conda-install/" target="_blank">original instructions</a>):

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake.yaml --name <env_name> --platform osx-64 
```

### 2.2 All Other Users

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake.yaml --name <env_name>
```

### 3. Install Visual Studio Code (Optional)

Jupyter doesn't color snakemake syntax, which can be annoying while coding. VS Code does, however, which makes coding and debugging easier.

After you've installed VS Code, install <a href="https://marketplace.visualstudio.com/items?itemName=Snakemake.snakemake-lang" target="_blank">Snakemake Language</a> to highlight syntax in your scripts.

# In Class

## 1. Running the Workflow

```bash
cd snakemake_tutorial_BST281

# change the number of cores and RAM available for your local machine
snakemake --snakefile snakefile --use-conda --conda-frontend conda --configfile config.yaml --cores 8 --resources mem_mb=8000
```