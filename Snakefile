# some useful helper packages
import pandas as pd
import os
import re
import sys

from glob import glob
from inspect import cleandoc

# Snakemake options
from snakemake.utils import validate, min_version
min_version('7.9.0')

# Load configuration
configfile: 'config.yaml'

# reproducible container image for docker/singularity
containerized: 'oras://ghcr.io/asgeissler/rnaschlange:0.1'

################################################################################
################################################################################
# default state, determine in the large if-else block below
# although explicit declaration might not be needed for all variables
# these should help making clear upfront what the state variables are
# based on which corresponding rules are loaded
sample_files = None
sra_runs = None
examples = False
pair_end = None
download = False

# check which input files exist, and if everything seems complete
if os.path.isfile('samples.csv'):
    # Case 1: sample sheet file and fastq files given
    # 
    # load sample file
    sample_files = pd.read_csv('samples.csv')
    # found read files
    found_files = glob('data/*.fastq.gz')
    # the expected columns, 'pair' is optional
    expect = ['file', 'sample', 'condition', 'batch']

    if not all( i in sample_files.columns \
                for i in expect           ):
        raise Exception(cleandoc("""
            The sample.csv must contain the columns file, sample, batch,
            and condition.
            A column 'pair' is optional, used for pair-end reads.
            """))

    # are all files described?
    xs = ( 'data/' + i for i in sample_files['file'] )
    xs = set(xs).symmetric_difference(found_files)
    if len(xs) > 0:
        raise Exception(cleandoc("""
            The samples.csv and the *.fastq.gz file found in the folder data do
            not match. These entries either lack a file or do not have a sample
            entry:

            {}
            """).format(', '.join(xs)))

    # Finally, make sure the string content won't make problems
    ptn = re.compile('^[-A-Za-z0-9]*$')
    for i in ['sample', 'condition', 'batch']:
        if any( ptn.match(j) is None    \
                for j in sample_files[i]):
            raise Exception(cleandoc("""
                Please use only alpha numeric [A-Za-z0-9] and a '-' symbol in
                the batch, sample, and condition values.
                (No underscore or other special characters!)
                """))

    # pairs correctly noted
    if 'pair' in sample_files.columns:
        if set(sample_files['pair']) != {'R1', 'R2'}:
            raise Exception(cleandoc("""
                Please specify the read pairs in R1 and R2 values.
                """))

        x = sample_files.groupby('sample').size()
        if any(x != 2):
            raise Exception(cleandoc("""
                Please specify both read pairs for all samples.

                Missing for: {}
                """).format(', '.join(x.index[x != 2])))


    # select pair end mode if needed
    pair_end = 'pair' in sample_files.columns
    ############################################################################
elif len(glob('sra-*.csv')) > 0:
    # Case 2: List of SRA run ids given to download
    # 
    x = glob('sra-*.csv')
    if len(x) > 1:
        raise Exception('Please use only one sra-*.csv file')
    x = x[0]

    # select pair end mode if needed
    pair_end = 'PE' in x

    sra_runs = pd.read_csv(x)
    if set(sra_runs.columns) != {'run', 'condition'}:
        raise Exception(cleandoc("""
            Please use in your sra-*.csv the colum names run and conditions.
            """))

    # check special chars
    ptn = re.compile('^[-A-Za-z0-9]*$')
    if any( ptn.match(j) is None          \
            for j in sra_runs['condition']):
        raise Exception(cleandoc("""
            Please use only alpha numeric [A-Za-z0-9] and a '-' symbol in the
            condition values.
            (No underscore or other special characters!)
            """))
    ############################################################################
elif sys.argv[-1] in ['example_SE', 'example_PE']:
    # Case 3: User requested setup for an example case
    # 
    examples = True
    ############################################################################
else:
    # Case 4: Tell user that pipeline needs setup
    #
    raise Exception(cleandoc("""
        Please specify some sort of input. For instance with a samples.csv file.
        You may also add either a sra-SE.csv or sra-PE.csv to download
        single-end or paired-end data from SRA.
        
        Consider using the 'example_SE' or 'example_PE' rule to setup pipeline
        for some sample use cases.
        """))


# assert that genome sequence and annotation exist
if not examples:
    for i in ['genome.fna.gz', 'genome.gff.gz']:
        if not os.path.isfile(i):
            raise Exception('Please provide both genome.fna.gz and genome.gff.gz')

################################################################################
################################################################################

# Helper to write output/input of rules
def row_wise(x, df):
    "Expand wildcards in string x as a generator for data in df per row"
    return list(df.apply(
        lambda row: x.format(**row),
        axis = 1
    ))


# A helper list. All subsequent steps elements to it.
# Finally, the 'all' target will execute them
tasks = list()

################################################################################
# Sownload data

if not examples and sample_files is None:
    include: 'rules/00_sra.smk'

################################################################################
# Run pipeline but only if samples are already available (not just a
# download)

if not examples and sample_files is not None and not download:
    # In order to make all the in/output statements of all rules more concise
    # introduce a new column to sample_files
    # So, this is were '{name}' was defined
    sample_files['name'] = row_wise(
        '{batch}_{sample}_{condition}',
        sample_files
    )
    # Check md5 checksums for correctness of download
    include: 'rules/05_md5.smk'
    # Preprocess data by:
    # - Assigning pretty names
    # - Read filtering, trimming aso
    # - QC assessment
    include: 'rules/10_qc.smk'
    # remove ribosomal RNA
    include: 'rules/20_ribo.smk'
    # estimate expression counts on genes with salmon
    include: 'rules/30_quant.smk'
    # plot various quality overviews, eg PCA
    include: 'rules/40_plots.smk'
    # compile multiqc reports for everything
    include: 'rules/50_reports.smk'

################################################################################
# load example tasks if needed

if examples:
    include: 'rules/99_examples.smk'

################################################################################
# Finally, make sure all tasks collected so far get done
rule all:
    input:
        *tasks
