# Purpoes:
# - Load Salmon output
# - Run DESeq
# - Display PCA

library(tidyverse)

# xs <- Sys.glob('analysis/32_salmon/*/quant.sf')
# annot <- 'genome.gff.gz'

xs <- unique(unlist(snakemake@input[['salmon']]))
annot <- unlist(snakemake@input[['annot']])

#out.counts <- 'foo.tsv'
#out.scatter <- 'foo.png'
#out.bio <- 'foo.png'
#out.pca <- 'foo.png'
#out.dge <- 'foo.tsv'
#out.dge.summary <- 'foo.tsv'
#out.heat <- 'foo.png'

out.counts <- unlist(snakemake@output[['counts']])
out.scatter <- unlist(snakemake@output[['scatter']])
out.bio <- unlist(snakemake@output[['bio']])
out.pca <- unlist(snakemake@output[['pca']])
out.dge <- unlist(snakemake@output[['dge']])
out.dge.summary <- unlist(snakemake@output[['dge_summary']])
out.heat <- unlist(snakemake@output[['heat']])

#ALPHA <- 0.05
#out.pca.dim <- '12x8'
#out.scatter.dim <- '20x20'
#out.bio.dim <- '8x6'

ALPHA <- unlist(snakemake@params[['alpha']])
out.pca.dim <- unlist(snakemake@params[['dim_pca']])
out.scatter.dim <- unlist(snakemake@params[['dim_scatter']])
out.bio.dim <- unlist(snakemake@params[['dim_biotype']])

################################################################################
# Parse input

xs %>%
  map(function(i) {
    x <- i %>% dirname %>% basename
    i %>%
      read_tsv() %>%
      select(ID = Name, NumReads) %>%
      rename(!! x := NumReads)
  }) %>%
  reduce(full_join, by = 'ID') -> dat

dat %>%
  select(- ID) %>%
  mutate_all(as.integer) %>%
  as.matrix() %>%
  magrittr::set_rownames(dat$ID) -> dat.mat

tibble(
  lib = colnames(dat.mat)
) %>%
  separate(lib, c('batch', 'sample', 'condition'),
           remove = FALSE, sep = '_') -> meta

################################################################################
# Load the rudimentary gene annotation provided

annot <- rtracklayer::import.gff3(annot)

annot %>%
  plyranges::filter(type == 'gene') %>%
  plyranges::select(ID, type, gene_biotype, Name, locus_tag) %>%
  as_tibble() %>%
  select(ID, biotype = gene_biotype, Name, locus_tag) -> genes

# Save for potential later use
genes %>%
  left_join(dat, 'ID') %>%
  write_tsv(out.counts)

################################################################################
# Scatter plot

dat %>%
  gather('lib', 'expr', - ID) %>%
  mutate(expr = log10(expr + 1)) -> expr

crossing(
  x = meta$lib,
  y = meta$lib
) %>%
  filter(x < y) %>%
  left_join(meta, c('x' = 'lib')) %>%
  inner_join(meta, c('y' = 'lib', 'condition')) %>%
  left_join(expr, c('x' = 'lib')) %>%
  left_join(expr, c('y' = 'lib', 'ID')) -> dat2

# Skip if there are no duplicates to do a scatter plot with
if(nrow(dat2) == 0) {
  ggplot() +
    annotate('text', 0, 0, label = 'No replicates for scatter plot available.') +
    theme_minimal(18)
} else {
  dat2$condition %>%
    unique %>%
    map(function(i) {
      dat2 %>%
        filter(condition == i) %>%
        mutate(nice = sprintf('x=%s\ny=%s', sample.x, sample.y)) %>%
        ggplot(aes(expr.x, expr.y)) +
        geom_point() +
        xlab('library x') +
        ylab('library y') +
        facet_wrap(~ nice) +
        theme_bw(18) +
        ggtitle(i, 'log10 scaled, with pseudo count')
    }) %>%
    invoke(.f = cowplot::plot_grid) -> p
}

# save plot according to the parameter in wxh values
wh.save <- function(p, path, param) {
  param %>%
    strsplit('x') %>%
    `[[`(1) %>%
    as.numeric %>%
    as.list %>%
    set_names(c('w', 'h')) %>%
    with(ggsave(path, p, width = w, height = h))
}

wh.save(p, out.scatter, out.scatter.dim)


################################################################################
# biotype content

dat %>%
  gather('lib', 'x', - ID) %>%
  left_join(genes, 'ID') %>%
  group_by(lib, biotype) %>%
  summarize(x = sum(x)) %>%
  group_by(lib) %>%
  mutate(total = sum(x)) %>%
  ungroup %>%
  mutate(prop = x / total * 100) %>%
  ggplot(aes(lib, prop, fill = biotype)) +
  ggsci::scale_fill_jama() +
  geom_bar(stat = 'identity', position = 'stack') +
  xlab(NULL) +
  ylab('Library content %') +
  theme_bw(18) +
  theme(axis.text.x = element_text(angle = 90)) -> p.bio

wh.save(p.bio, out.bio, out.bio.dim)

################################################################################
# DESeq2

# consider batch, but only if there is more than one
nrbatch <- meta %>%
  pull(batch) %>%
  unique %>%
  length()

if (nrbatch > 1) {
  design <- ~ condition + batch
} else {
  design <- ~ condition
}

# Ignore condition if there are not replicates.
# Otherwise DEseq2's dispersion estimation fails
meta %>%
  count(condition) %>%
  filter(n == 1) %>%
  nrow -> no.reps
if (no.reps > 0) {
  design <- ~ 1
}

DESeq2::DESeqDataSetFromMatrix(
  countData = dat.mat,
  colData = meta,
  design = design
) %>%
  DESeq2::DESeq() -> des


################################################################################
# PCA

des.blog <- DESeq2::rlog(des, blind = TRUE)

# do both `returnData` options to preserve variance info in axis
pca   <- DESeq2::plotPCA(des.blog, c('condition'), 100, returnData = TRUE) %>%
  separate(name, c('batch', 'sample', 'cond2'), sep = '_')
pca.p <- DESeq2::plotPCA(des.blog, c('condition'), 100, returnData = FALSE)

# manually remove points and the redraw below to have larger points and shapes
pca.p$layers[[1]]  <- NULL

# Choose color scale relative to number of conditions
meta %>%
  select(condition) %>%
  unique %>%
  nrow -> n.conds
if (n.conds <= 10) {
  f.color <- ggsci::scale_color_npg(name = 'condition')
} else {
  # not as pretty but should handle more colors for lots of conditions
  f.color <- scale_color_viridis_d(name = 'condition')
  # f.color <- ggsci::scale_color_gsea(name = 'condition')
}
  

pca.p +
  geom_point(aes(shape = batch, color = condition),
             size = 5,
             data = pca) +
  ggrepel::geom_label_repel(aes(PC1, PC2, label = sample),
                            data = pca, show.legend = FALSE) +
  f.color +
  theme_bw(18) -> p2

wh.save(p2, out.pca, out.pca.dim)

################################################################################
# Quick DGE analysis

if (identical(design, ~ 1)) {
  print(paste(
    'Created empty files for quick DGE analysis due to missing replicates',
    'in at least one condition'
  ))
  # Make empty files for Snakemake to complete
  file.create(out.dge)
  file.create(out.dge.summary)
  file.create(out.heat)
} else {
  foo <- meta %>% pull(condition) %>% unique
  
  crossing(a = foo, b = foo) %>%
    filter(a < b) %>%
    group_by_all() %>%
    do(x = {
      grp <- .
      print( c('condition', grp$a, grp$b))
      DESeq2::results(
        des,
        contrast = c('condition', grp$a, grp$b),
        alpha = ALPHA,
        tidy = TRUE
      ) %>%
        as_tibble() %>%
        mutate(comparison = sprintf('%s v. %s', grp$a, grp$b)) %>%
        rename(ID = row) %>%
        left_join(genes, 'ID') %>%
        select(ID, biotype, Name, locus_tag, comparison, everything())
    }) %>%
    ungroup %>%
    unnest(x) %>%
    select(- a, - b) -> dge
  
  
  dge %>%
    filter(padj <= ALPHA) %>%
    count(comparison, biotype) %>%
    spread(biotype, n, fill = 0) -> dge.summary
  
  write_tsv(dge, out.dge)
  write_tsv(dge.summary, out.dge.summary)
  ################################################################################
  # Some sort of heatmap
  
  cnt.mat <- SummarizedExperiment::assay(DESeq2::normTransform(des))
  
  dge %>%
    filter(padj <= ALPHA) %>%
    pull(ID) %>%
    unique -> mask
  
  pheatmap::pheatmap(
    cnt.mat[mask, ],
    scale = 'row',
    show_rownames = FALSE,
    color = colorRampPalette(rev(
      RColorBrewer::brewer.pal(n = 5, name = "RdBu")))(59),
    filename = out.heat
  )


}