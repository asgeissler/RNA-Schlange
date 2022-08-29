
# Choose PE or SE wrapper for download
if pair_end:
    # the input for the rule
    xs = ['data/{accession}_1.fastq.gz',
          'data/{accession}_2.fastq.gz']
    # for subsequent steps, the samples are
    x = sra_runs.rename(columns = {'run': 'sample'})
    x1 = x.eval('pair = "R1"')
    x1['file'] = row_wise('{sample}_1.fastq.gz', x1)
    x2 = x.eval('pair = "R2"')
    x2['file'] = row_wise('{sample}_2.fastq.gz', x2)
    sample_files = pd.concat([x1, x2])
    # make sure to download in all target
    tasks.extend(row_wise('data/{run}_1.fastq.gz', sra_runs))
else:
    # the input for the rule
    xs = ['data/{accession}.fastq.gz']
    # for subsequent steps, the samples are
    x = sra_runs.rename(columns = {'run': 'sample'})
    x['file'] = row_wise('{sample}.fastq.gz', x)
    sample_files = x
    # make sure to download in all target
    tasks.extend(row_wise('data/{run}.fastq.gz', sra_runs))


# declare sra download rule, dynamically per SE/PE
rule sra_download:
    output:
        # the wildcard name must be accession, pointing to an SRA number
        # the input was define in last if-else block
        *xs
    log:
        'logs/download/{accession}.txt'
    params:
        extra='--skip-technical'
    threads: 6  # defaults to 6
    wrapper:
        'v1.10.0/bio/sra-tools/fasterq-dump'


# write as samples.csv to prevent re-download
print(cleandoc("""
    INFO. samples.csv written to prevent re-download, but you might want
    to remove it again if the download failed due to
    e.g. network problems.

    Also, since SRA does not provide an easy way of assessing the batch
    each file was in, the are all set to 'batch1'.
    """))

sample_files['batch'] = 'batch1'

sample_files.to_csv('samples.csv', index = False)

# don't run rest of pipeline when downloading
download = True
