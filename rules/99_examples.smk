################################################################################
################################################################################

# Example 1
# A single-end RNA-seq experiment in
# Synechococcus sp. PCC 7002
#
# Data: From SRA project SRP069025
# Long-Term Acclimation to Iron Limitation Reveals New Insights in Metabolism
# Regulation of Synechococcus sp. PCC7002
# S Blanco-Ameijeiras, C Cosio and CS Hassler
# Front. Mar. Sci., 02 August 2017
# https://doi.org/10.3389/fmars.2017.00247
rule example_SE:
    output:
        'sra-SE.csv'
        # side effect
        # genome.{fna,gff}.gz
    shell:
        """
cat > sra-SE.csv << EOF
run,condition
SRR3132697,10-9-nM-Fe
SRR3132696,10-9-nM-Fe
SRR3132695,10-9-nM-Fe
SRR3132694,0-41-nM-Fe
SRR3132693,0-41-nM-Fe
SRR3132692,0-41-nM-Fe
SRR3132691,0-04-nM-Fe
SRR3132690,0-04-nM-Fe
SRR3132689,0-04-nM-Fe
SRR3132688,0-003-nM-Fe
SRR3132687,0-003-nM-Fe
SRR3132686,0-003-nM-Fe
EOF

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/019/485/GCA_000019485.1_ASM1948v1/GCA_000019485.1_ASM1948v1_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/019/485/GCA_000019485.1_ASM1948v1/GCA_000019485.1_ASM1948v1_genomic.gff.gz
mv GCA_000019485.1_ASM1948v1_genomic.fna.gz genome.fna.gz
mv GCA_000019485.1_ASM1948v1_genomic.gff.gz genome.gff.gz
        """

################################################################################
################################################################################

# Example 2
# A paired-end RNA-seq experiment in
# Bacillus subtilis 168
# Data: SRA project SRP056317
# NusA-dependent transcription termination prevents misregulation of global gene expression
# S Mondal, AV Yakhnin, A Sebastian, I Albert, P Babitzke
# Nat Microbiol. 2016 Jan 11; 1: 15007
# https://doi.org/10.1038/nmicrobiol.2015.7
rule example_PE:
    output:
        'sra-PE.csv'
        # side effect
        # genome.{fna,gff}.gz
    shell:
        """
cat > sra-PE.csv << EOF
run,condition
SRR1918928,Plus-NusA
SRR1918929,Plus-NusA
SRR1918930,Plus-NusA
SRR1918931,Plus-NusA
SRR1918932,Plus-NusA
SRR1918933,Plus-NusA
SRR1918934,No-NusA
SRR1918935,No-NusA
SRR1918936,No-NusA
SRR1918937,No-NusA
SRR1918938,No-NusA
SRR1918939,No-NusA
EOF

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/045/GCF_000009045.1_ASM904v1/GCF_000009045.1_ASM904v1_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/045/GCF_000009045.1_ASM904v1/GCF_000009045.1_ASM904v1_genomic.gff.gz
mv GCF_000009045.1_ASM904v1_genomic.fna.gz genome.fna.gz
mv GCF_000009045.1_ASM904v1_genomic.gff.gz genome.gff.gz
        """

