FROM condaforge/mambaforge:latest
LABEL io.github.snakemake.containerized="true"
LABEL io.github.snakemake.conda_env_hash="7834531ef9a038f4813d09f652b45c3daaa45ed98bc8568f1269f4606d755605"

# Step 1: Retrieve conda environments

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.10.0/bio/sra-tools/fasterq-dump/environment.yaml
#   prefix: /conda-envs/85633ff8bea713d372cb9152f291c3a8
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - sra-tools >2.9.1
#     - pigz >=2.6
#     - pbzip2 >=1.1
#     - snakemake-wrapper-utils =0.3
RUN mkdir -p /conda-envs/85633ff8bea713d372cb9152f291c3a8
ADD https://github.com/snakemake/snakemake-wrappers/raw/v1.10.0/bio/sra-tools/fasterq-dump/environment.yaml /conda-envs/85633ff8bea713d372cb9152f291c3a8/environment.yaml

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
RUN mkdir -p /conda-envs/81349e987b92efdd9c42d5622123e303
COPY envs/r.yaml /conda-envs/81349e987b92efdd9c42d5622123e303/environment.yaml

# Conda environment:
#   source: envs/sortmerna.yaml
#   prefix: /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134
#   channels:
#       - bioconda
#       - defaults
#   dependencies:
#       - sortmerna =4.3.4
RUN mkdir -p /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134
COPY envs/sortmerna.yaml /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.10.0/bio/fastp/environment.yaml
#   prefix: /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - fastp =0.20
RUN mkdir -p /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787
ADD https://github.com/snakemake/snakemake-wrappers/raw/v1.10.0/bio/fastp/environment.yaml /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/fastqc/environment.yaml
#   prefix: /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - fastqc ==0.11.9
RUN mkdir -p /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8
ADD https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/fastqc/environment.yaml /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/salmon/index/environment.yaml
#   prefix: /conda-envs/e5f19ce92781182c0a011e25d50bd1c9
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - salmon ==1.8.0
RUN mkdir -p /conda-envs/e5f19ce92781182c0a011e25d50bd1c9
ADD https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/salmon/index/environment.yaml /conda-envs/e5f19ce92781182c0a011e25d50bd1c9/environment.yaml

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
RUN mkdir -p /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10
ADD https://github.com/snakemake/snakemake-wrappers/raw/v1.12.0/bio/salmon/quant/environment.yaml /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v3.2.0/bio/multiqc/environment.yaml
#   prefix: /conda-envs/a74c0ac65c84ed438731c3397703af31
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - multiqc =1.18
RUN mkdir -p /conda-envs/a74c0ac65c84ed438731c3397703af31
ADD https://github.com/snakemake/snakemake-wrappers/raw/v3.2.0/bio/multiqc/environment.yaml /conda-envs/a74c0ac65c84ed438731c3397703af31/environment.yaml

# Step 2: Generate conda environments

RUN mamba env create --prefix /conda-envs/81349e987b92efdd9c42d5622123e303 --file /conda-envs/81349e987b92efdd9c42d5622123e303/environment.yaml && \
    mamba env create --prefix /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134 --file /conda-envs/b3a58c9dd8d8c7ef4943a32053eca134/environment.yaml && \
    mamba env create --prefix /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787 --file /conda-envs/ead20a3f8bbfa36fbb2e0c3f905c1787/environment.yaml && \
    mamba env create --prefix /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8 --file /conda-envs/573927d1a2f1de4bfdd03a5385f50ed8/environment.yaml && \
    mamba env create --prefix /conda-envs/e5f19ce92781182c0a011e25d50bd1c9 --file /conda-envs/e5f19ce92781182c0a011e25d50bd1c9/environment.yaml && \
    mamba env create --prefix /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10 --file /conda-envs/f1527a5e21168384a2a6f09fa6ab5f10/environment.yaml && \
    mamba env create --prefix /conda-envs/a74c0ac65c84ed438731c3397703af31 --file /conda-envs/a74c0ac65c84ed438731c3397703af31/environment.yaml && \
    mamba env create --prefix /conda-envs/85633ff8bea713d372cb9152f291c3a8 --file /conda-envs/85633ff8bea713d372cb9152f291c3a8/environment.yaml && \
    mamba clean --all -y

