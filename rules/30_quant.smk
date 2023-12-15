# build index on gene sequences

rule genes:
    input:
        genome = 'genome.fna.gz',
        annot = 'genome.gff.gz'
    output:
        'analysis/30_genes.fna.gz'
    conda:
        '../envs/r.yaml'
    script:
        '31_genes.R'


rule salmon_index:
    input:
        sequences = 'analysis/30_genes.fna.gz'
    output:
        directory('analysis/31_salmon_index')
    log:
        'logs/salmon/index.txt'
    threads: 4
    resources:
        mem_mb = '20GB'
    params:
        extra=" ".join(config['salmon_index_args'])
    wrapper:
        "v1.12.0/bio/salmon/index"


tasks.append('analysis/31_salmon_index')

################################################################################

# Configure input outputs dependent if SE or PE
if pair_end:
    salmon_in = {
        'r1': 'analysis/22_non-ribosomal_RNA/{name}_R1.fastq.gz',
        'r2': 'analysis/22_non-ribosomal_RNA/{name}_R2.fastq.gz',
        'index': 'analysis/31_salmon_index'
    }
    ###########################################################################
else:
    salmon_in = {
        'r': 'analysis/22_non-ribosomal_RNA/{name}.fastq.gz',
        'index': 'analysis/31_salmon_index'
    }

################################################################################

rule salmon:
    input:
        **salmon_in
    output:
        quant = 'analysis/32_salmon/{name}/quant.sf',
        flen = 'analysis/32_salmon/{name}/libParams/flenDist.txt',
        meta = 'analysis/32_salmon/{name}/aux_info/meta_info.json'
    log:
        'logs/salmon/{name}.log'
    threads: 4
    wrapper:
        'v1.12.0/bio/salmon/quant'


# Remember to run the respective tasks
tasks.extend(row_wise(
    'analysis/32_salmon/{name}/quant.sf',
    sample_files
))
