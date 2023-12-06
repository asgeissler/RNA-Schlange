Bootstrap: docker
From: condaforge/mambaforge:latest
Stage: spython-base

%files
envs/r.yaml /conda-envs/81349e987b92efdd9c42d5622123e303/environment.yaml
envs/sortmerna.yaml /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134/environment.yaml
%labels
io.github.snakemake.containerized="true"
io.github.snakemake.conda_env_hash="a7fe2a16e9866840f4ea59de785ed1e458e3a64ef378116ecaf1d2317e653e13"
%post

# Step 1: Retrieve conda environments

# Conda environment:
#   source: envs/r.yaml
#   prefix: /conda-envs/81349e987b92efdd9c42d5622123e303
#   channels:
#       - conda-forge
#       - bioconda
#       - defaults
#   dependencies:
#       - r-base
#       - r-cowplot
#       - r-essentials >= 4.0
#       - r-ggrepel
#       - r-ggsci
#       - r-magick
#       - r-pheatmap
#       - r-rcolorbrewer
#       - r-tidyverse
#       - bioconductor-biostrings
#       - bioconductor-bsgenome
#       - bioconductor-deseq2
#       - bioconductor-plyranges
#       - bioconductor-rtracklayer
mkdir -p /conda-envs/81349e987b92efdd9c42d5622123e303

# Conda environment:
#   source: envs/sortmerna.yaml
#   prefix: /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134
#   channels:
#       - bioconda
#       - defaults
#   dependencies:
#       - sortmerna =4.3.4
mkdir -p /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.10.0/bio/fastp/environment.yaml
#   prefix: /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - fastp =0.20
mkdir -p /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787
wget https://github.com/snakemake/snakemake-wrappers/raw/v1.10.0/bio/fastp/environment.yaml -O /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/fastqc/environment.yaml
#   prefix: /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - fastqc ==0.11.9
mkdir -p /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8
wget https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/fastqc/environment.yaml -O /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/multiqc/environment.yaml
#   prefix: /conda-envs/fd1008dfa88a4500724e3596f62f8bff
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - multiqc =1.12
mkdir -p /conda-envs/fd1008dfa88a4500724e3596f62f8bff
wget https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/multiqc/environment.yaml -O /conda-envs/fd1008dfa88a4500724e3596f62f8bff/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/salmon/index/environment.yaml
#   prefix: /conda-envs/e5f19ce92781182c0a011e25d50bd1c9
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - salmon ==1.8.0
mkdir -p /conda-envs/e5f19ce92781182c0a011e25d50bd1c9
wget https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/salmon/index/environment.yaml -O /conda-envs/e5f19ce92781182c0a011e25d50bd1c9/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/salmon/quant/environment.yaml
#   prefix: /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - salmon ==1.8.0
#     - gzip ==1.11
#     - bzip2 ==1.0.8
mkdir -p /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10
wget https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/salmon/quant/environment.yaml -O /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10/environment.yaml

# Step 2: Generate conda environments

mamba env create --prefix /conda-envs/81349e987b92efdd9c42d5622123e303 --file /conda-envs/81349e987b92efdd9c42d5622123e303/environment.yaml && \
mamba env create --prefix /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134 --file /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134/environment.yaml && \
mamba env create --prefix /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787 --file /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787/environment.yaml && \
mamba env create --prefix /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8 --file /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8/environment.yaml && \
mamba env create --prefix /conda-envs/fd1008dfa88a4500724e3596f62f8bff --file /conda-envs/fd1008dfa88a4500724e3596f62f8bff/environment.yaml && \
mamba env create --prefix /conda-envs/e5f19ce92781182c0a011e25d50bd1c9 --file /conda-envs/e5f19ce92781182c0a011e25d50bd1c9/environment.yaml && \
mamba env create --prefix /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10 --file /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10/environment.yaml && \
mamba clean --all -y
%runscript
exec /bin/bash "$@"
%startscript
exec /bin/bash "$@"
