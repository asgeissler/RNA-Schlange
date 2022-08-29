# Helper script to extract the nt sequences of all genes for
# salmon to build an index on

genome <- unlist(snakemake@input[['genome']])
annot <- unlist(snakemake@input[['annot']])
out <- unlist(snakemake@output)

library(tidyverse)
library(Biostrings)
library(plyranges)

genome <- readDNAStringSet(genome)
annot <- rtracklayer::import.gff3(annot)

names(genome) <- str_remove(names(genome), ' .*$')

annot %>%
  filter(type == 'gene') %>%
  select(ID) -> genes

seqs <- BSgenome::getSeq(genome, genes)
names(seqs) <- genes$ID

writeXStringSet(seqs, out, compress = TRUE)

