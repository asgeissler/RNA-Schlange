# Ribosomal RNA removal
#


# Configure input outputs dependent if SE or PE
if pair_end:
    ribo_in = {
        'reads': [
            'analysis/12_clean/{name}_R1.fastq.gz',
            'analysis/12_clean/{name}_R2.fastq.gz'
        ]
    }
    ribo_out = {
        'log': 'logs/sortmerna/{name}.txt',
        'ribo': [
            'analysis/21_ribosomal_RNA/{name}_R1.fastq.gz',
            'analysis/21_ribosomal_RNA/{name}_R2.fastq.gz',
        ],
        'keep': [
            'analysis/22_non-ribosomal_RNA/{name}_R1.fastq.gz',
            'analysis/22_non-ribosomal_RNA/{name}_R2.fastq.gz'
       ]
    }
    ribo_extra = '--paired_in --out2'

    # sortmerna's output for PE data cannot be explicitly specified, only
    # the prefix. Therefore the commands for placing the output into the
    # right place is:
    ribo_save = """
        mv $tmp/ribo_fwd.fq.gz {}
        mv $tmp/ribo_rev.fq.gz {}

        mv $tmp/keep_fwd.fq.gz {}
        mv $tmp/keep_rev.fq.gz {}
        """.format(
            *ribo_out['ribo'],
            *ribo_out['keep']
        )

    ###########################################################################
else:
    ribo_in = {
        'reads': [
            'analysis/12_clean/{name}.fastq.gz'
        ]
    }
    ribo_out = {
        'log': 'logs/sortmerna/{name}.txt',
        'ribo': [
            'analysis/21_ribosomal_RNA/{name}.fastq.gz'
        ],
        'keep': [
            'analysis/22_non-ribosomal_RNA/{name}.fastq.gz'
       ]
    }
    ribo_extra = ''
    # Place non-ribosomal RNA
    ribo_save = """
        mv $tmp/ribo.fq.gz {}

        mv $tmp/keep.fq.gz {}
        """.format(
            *ribo_out['ribo'],
            *ribo_out['keep']
          )

################################################################################
# Parameters to use the reference database and reads in sortmerna

ref_in = [ 'analysis/20_db/{}.fasta'.format(i) \
           for i in config['sortmerna']        ]

ref_par = ' '.join( '-ref {}'.format(i) \
                    for i in ref_in     )

# explicitly link the rule to the db to make sure it exists beforehand
ribo_in['ref'] = ref_in

reads_par = ' '.join( '-reads {}'.format(i)     \
                      for i in ribo_in['reads'] )

################################################################################
# Download rRNA db
#
rule ribo_db:
    output:
        'analysis/20_db/{db}.fasta'
    shell:
        """
        url='https://github.com/biocore/sortmerna/raw/master/data/rRNA_databases/{wildcards.db}.fasta'
        cd analysis/20_db
        wget $url
        """

tasks.extend( 'analysis/20_db/{}.fasta'.format(i) \
              for i in config['sortmerna']        )

################################################################################

rule ribo_removal:
    input:
        # link reads and reference as specified above
        # Though the parameterization is in the *_par variables
        **ribo_in
    output:
        **ribo_out
    params:
        ref = ref_par,
        extra = ribo_extra,
        # unlike the other parameters the wildcards need to be replaced
        # for the reads and save command
        reads = lambda wildcards: reads_par.format(**wildcards),
        save = lambda wildcards: ribo_save.format(**wildcards)
    conda: '../envs/sortmerna.yaml'
    threads: 8
    shell:
        """
        tmp=$(mktemp -d)
        sortmerna                 \
            {params.extra}        \
            {params.ref}          \
            {params.reads}        \
            --workdir $tmp        \
            --fastx               \
            --threads {threads}   \
            --other $tmp/keep     \
            --aligned $tmp/ribo

        mv $tmp/ribo.log {output.log}

        {params.save}

        rm -rf $tmp
        """

################################################################################
# add tasks for all samples

tasks.extend(row_wise(ribo_out['ribo'][0], sample_files))
