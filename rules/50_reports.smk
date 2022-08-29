# Bundle reports and output into multiqc reports
# The output of FastQC are in separate entries, because
# they would be too difficult to interpret in a mixture

# the input files for the reports depend on the type
if pair_end:
    in_before = 'analysis/15_fastqc/10_raw/{name}_{pair}_fastqc.zip'
    in_after = 'analysis/15_fastqc/12_clean/{name}_{pair}_fastqc.zip'
else:
    in_before = 'analysis/15_fastqc/10_raw/{name}_fastqc.zip'
    in_after = 'analysis/15_fastqc/12_clean/{name}_fastqc.zip'


rule multi_qc_before:
    input:
        row_wise(in_before, sample_files)
    output:
        'analysis/50_fastqc_before/multiqc.html'
    log:
        'logs/multiqc/fastqc-before.log'
    wrapper:
        'v1.12.0/bio/multiqc'


tasks.append('analysis/50_fastqc_before/multiqc.html')

################################################################################

rule multi_qc_after:
    input:
        row_wise(in_after, sample_files)
    output:
        'analysis/51_fastqc_after/multiqc.html'
    log:
        'logs/multiqc/fastqc-before.log'
    wrapper:
        'v1.12.0/bio/multiqc'


tasks.append('analysis/51_fastqc_after/multiqc.html')

################################################################################

rule multi_main:
    input:
        row_wise(
            'analysis/13_report/{name}-fastp.json',
            sample_files
        ),
        row_wise(
            'logs/sortmerna/{name}.txt',
            sample_files
        ),
        row_wise(
            'analysis/32_salmon/{name}/aux_info/meta_info.json',
            sample_files
        ),
        row_wise(
            'analysis/32_salmon/{name}/libParams/flenDist.txt',
            sample_files
        )
    output:
        "analysis/53_main_multiqc/multiqc.html"
    log:
        "logs/multiqc/fastqc-before.log"
    wrapper:
        "v1.12.0/bio/multiqc"



tasks.append('analysis/53_main_multiqc/multiqc.html')
