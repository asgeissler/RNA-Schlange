
# Configure input outputs dependent if SE or PE
if pair_end:
    # Rule: pretty_name
    pretty_out = 'analysis/10_raw/{name}_{pair}.fastq.gz'
    #
    # Rule: fastp
    fastp_in = [
        'analysis/10_raw/{name}_R1.fastq.gz',
        'analysis/10_raw/{name}_R2.fastq.gz'
    ]
    fastp_out = {
        'failed':   'analysis/11_discarded/{name}.fastq.gz',
        'unpaired': 'analysis/11_unpaired/{name}.fastq.gz',
        'trimmed':  [
            'analysis/12_clean/{name}_R1.fastq.gz',
            'analysis/12_clean/{name}_R2.fastq.gz'
        ],
        'html':     'analysis/13_report/{name}.html',
        'json':     'analysis/13_report/{name}-fastp.json'
    }
    #
    # Remember to run the respective tasks
    tasks.extend(row_wise(
        'analysis/15_fastqc/10_raw/{name}_{pair}.html',
        sample_files
    ))
    tasks.extend(row_wise(
        'analysis/15_fastqc/12_clean/{name}_{pair}.html',
        sample_files
    ))
    ##########################################################################
    ##########################################################################
else:
    # Rule: pretty_name
    pretty_out = 'analysis/10_raw/{name}.fastq.gz'
    #
    # Rule: fastp
    fastp_in = ['analysis/10_raw/{name}.fastq.gz']
    fastp_out = {
        'failed':   'analysis/11_discarded/{name}.fastq.gz',
        'trimmed':  'analysis/12_clean/{name}.fastq.gz',
        'html':     'analysis/13_report/{name}.html',
        'json':     'analysis/13_report/{name}-fastp.json'
    }
    #
    # Remember to run the respective tasks
    tasks.extend(row_wise(
        'analysis/15_fastqc/10_raw/{name}.html',
        sample_files
    ))
    tasks.extend(row_wise(
        'analysis/15_fastqc/12_clean/{name}.html',
        sample_files
    ))

################################################################################

# Since the filename of a sample does not imply the sample/condition
# strings, the nice names need to be 'hard wired' per sample instead of a pretty
# rule, ala

#rule pretty_name:
#    input:
#        'data/{file}'
#    output:
#        pretty_out
#    shell:
#        """
#        ln -s $(pwd -L)/{input} {output}
#        """

if not os.path.exists('analysis/10_raw'):
    os.makedirs('analysis/10_raw')

    for ix, row in sample_files.iterrows():
        x = '{file}'.format(**row)
        y = pretty_out.format(**row)
        shell(f'ln -s $(pwd -L)/data/{x} {y}')


################################################################################

rule fastp:
    input:
        sample = fastp_in
    output:
        **fastp_out
    log:
        "logs/fastp/{name}.txt"
    params:
        extra=" ".join(config['fastp_args'])
    threads: 8
    wrapper:
        "v1.10.0/bio/fastp"

################################################################################

rule fastqc_unzip:
    input:
        "analysis/{dir}/{file}.fastq.gz"
    output:
        temp('analysis/{dir}_decompressed/{file}.fastq')
    shell:
        """
        gunzip -c {input} > {output}
        """

rule fastqc:
    input:
        "analysis/{dir}_decompressed/{file}.fastq"
    output:
        html = 'analysis/15_fastqc/{dir}/{file}.html',
        zip  = 'analysis/15_fastqc/{dir}/{file}_fastqc.zip'
        # the suffix _fastqc.zip is necessary for multiqc to find the file.
    params: "--quiet"
    log:
        "logs/fastqc/{dir}/{file}.txt"
    threads: 4
    wrapper:
        "v1.12.0/bio/fastqc"

################################################################################
################################################################################
