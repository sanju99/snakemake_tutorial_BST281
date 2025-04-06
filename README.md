# Set-Up (Please Complete Before Class on April 28)

There are a few tools that you will need to set up before class.

Please note that this repository and all the results files that you will create will require approximately <b>2 GB</b> of space. <b>Please ensure that you have enough disk space for this.</b>

## 1. SRA Toolkit

SRA Toolkit is a suite of tools built by the NCBI for accessing data stored in the Sequence Read Archive (SRA). 

When accessing public data, you can download it from the GUIs provided by SRA or the European Nucleotide Archive (<a href="https://www.ebi.ac.uk/ena/browser/" target="_blank">ENA</a>), which has much of the same public data, or you can download data programmatically using SRA Toolkit, which is my preference.

### Installation

1. Download the appropriate installer for your machine from the first section of the page <a href="https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit" target="_blank">here</a>.
2. Unzip the folder and move it to your desired location. The exact location does not matter because we will add the path to your shell configuration file so that you can run the command from anywhere. My full path is `/Users/skulkarni/Desktop/sratoolkit.3.2.0-mac-arm64`. Replace everywhere where I have `SRA_PATH` with your own full path.
3. Navigate to the `bin` subfolder within the `SRA_PATH` folder.
4. Run `./vdb-config -i` to start the settings configuration. If you get an error, <b>make sure you are in the `bin` subfolder within the `SRA_PATH` folder that you just downloaded</b>. To navigate between tabs in the configuration window, use the tab-key button on your keyboard or press the red underlined letters corresponding to each tab. To make selections, press the tab-key until you get to the desired option, then press the enter key on your keyboard, or press the press the red underlined letter for the desired option. An "X" should appear in front of the desired option.
5. Enable the "Remote Access" option on the Main screen.
6. Navigate to the "Cache" tab and enable "local file-caching".
8. Create an empty directory for the tool to store cached files. This can be anywhere and is effectively a trash directory. For example, I created mine at `/Users/skulkarni/ncbi_cache.`
9. Copy the <b>FULL PATH</b> to this folder to the "location of user-repository" box.
10. Navigate to the "cloud provider" or "GCP" tab and accept to "report cloud instance identity".
11. Save and exit.
12. Add this line to your `~/.zshrc` or `~/.bashrc` file: `export PATH="<SRA_PATH>/bin:$PATH"`. Make sure to change the `SRA_PATH` directory name to the one on your machine.
13. Run `source ~/.zshrc` or `source ~/.bashrc` to update the changes.
14. Check that you can run `fastq-dump` from any directory, not just where you downloaded the executable above to.

## 2. Create a conda environment for snakemake

Clone this repository:

```bash
git clone https://github.com/sanju99/snakemake_tutorial_BST281.git
```

All your output files will be stored in this repository. Also create the base virtual environment for snakemake using the provided `envs/snakemake.yaml` file, which I've called `snakemake_tutorial_BST281`. Run one of the commands below.

### 2.1 Apple Silicon Mac Users

Many conda packages are not available for the Apple silicon processor (ARM), only for the Intel processors. 

However, you can create an Intel conda environment with a simple additional flag (<a href="https://blog.rtwilson.com/how-to-create-an-x64-intel-conda-environment-on-your-apple-silicon-mac-arm-conda-install/" target="_blank">original instructions</a>):

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake.yaml --name snakemake_tutorial_BST281 --platform osx-64 
```

### 2.2 All Other Users

```bash
cd snakemake_tutorial_BST281

conda env create -f envs/snakemake.yaml --name snakemake_tutorial_BST281
```

## 3. Install Visual Studio Code (Optional)

Jupyter doesn't color snakemake syntax, which can be annoying while coding. VS Code does, however, which makes coding and debugging easier.

After you've installed VS Code, install <a href="https://marketplace.visualstudio.com/items?itemName=Snakemake.snakemake-lang" target="_blank">Snakemake Language</a> to highlight syntax in your scripts.

# In Class

## 1. Running the Workflow

```bash
cd snakemake_tutorial_BST281

# activate the environment
conda activate snakemake_tutorial_BST281

# change the number of cores and RAM available for your local machine
snakemake --snakefile snakefile --use-conda --conda-frontend conda --configfile config.yaml --cores 8 --resources mem_mb=8000
```
