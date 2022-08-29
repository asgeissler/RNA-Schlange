
rule plots:
    input:
        salmon = row_wise(
            'analysis/32_salmon/{name}/quant.sf',
            sample_files
        ),
        annot = 'genome.gff.gz'
    output:
        counts      = 'analysis/40_survey/counts.tsv',
        scatter     = 'analysis/40_survey/scatter-plots.png',
        bio         = 'analysis/40_survey/biotype-content.png',
        pca         = 'analysis/40_survey/pca.png',
        dge         = 'analysis/40_survey/putative-diff-expression.tsv',
        dge_summary = 'analysis/40_survey/putative-diff-expression-summary.tsv',
        heat        = 'analysis/40_survey/heatmap.png'
    params:
        # pass on the configuration
        **config['dge']
    conda:
        '../envs/r.yaml'
    script:
        '41_rscript.R'


tasks.append('analysis/40_survey/pca.png')
