#!/bin/bash

# making the necessary directories
mkdir genome genes

# gotta set up the necessary conda environments. (i was advised not to put antismash in the kitchen sink)
conda create -n kitchen_sink -c conda_forge -c bioconda samtools blast clustalo entrez-direct
conda create -n antismash_env -c bioconda antismash

# now for the real preparation. that was just preparation prep.
conda activate kitchen_sink

# grabbing the genomes i used
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/014/930/995/GCF_014930995.1_ASM1493099v1/GCF_014930995.1_ASM1493099v1_genomic.fna.gz && \
gzip -d GCF_014930995.1_ASM1493099v1_genomic.fna.gz && \
mv GCF_014930995.1_ASM1493099v1_genomic.fna genome/PMA22_genome.fasta

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/038/447/645/GCF_038447645.1_ASM3844764v1/GCF_038447645.1_ASM3844764v1_genomic.fna.gz && \
gzip -d GCF_038447645.1_ASM3844764v1_genomic.fna.gz && \
mv GCF_038447645.1_ASM3844764v1_genomic.fna genome/IMGN2_genome.fasta

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/225/GCF_000009225.2_ASM922v1/GCF_000009225.2_ASM922v1_genomic.fna.gz && \
gzip -d GCF_000009225.2_ASM922v1_genomic.fna.gz && \
mv GCF_000009225.2_ASM922v1_genomic.fna genome/SBW25_genome.fasta

# grabbing the safracin bgc and the two C. indica scaffolds (4 and 10) that we identified
wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=AY061859.1&rettype=fasta&retmode=text" -O genome/safBGC.fasta

wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=JARFTL010000004.1&rettype=fasta&retmode=text" -O genome/scaf04.fasta

wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=JARFTL010000010.1&rettype=fasta&retmode=text" -O genome/scaf10.fasta

# getting the genome files in .gbk format so that antismash will run
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/014/930/995/GCF_014930995.1_ASM1493099v1/GCF_014930995.1_ASM1493099v1_genomic.gbff.gz && \
gzip -d GCF_014930995.1_ASM1493099v1_genomic.gbff.gz && \
mv GCF_014930995.1_ASM1493099v1_genomic.gbff genome/PMA22_genome.gbk

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/038/447/645/GCF_038447645.1_ASM3844764v1/GCF_038447645.1_ASM3844764v1_genomic.gbff.gz && \
gzip -d GCF_038447645.1_ASM3844764v1_genomic.gbff.gz && \
mv GCF_038447645.1_ASM3844764v1_genomic.gbff genome/IMGN2_genome.gbk

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/225/GCF_000009225.2_ASM922v1/GCF_000009225.2_ASM922v1_genomic.gbff.gz && \
gzip -d GCF_000009225.2_ASM922v1_genomic.gbff.gz && \
mv GCF_000009225.2_ASM922v1_genomic.gbff genome/SBW25_genome.gbk

efetch -db nucleotide -format gbwithparts -id AY061859.1 > genome/safBGC.gbk

# changing the header of these fasta files so my code works in the future
sed -i 's/^>.*/>safBGC/' genome/safBGC.fasta
sed -i 's/^>.*/>scaf04/' genome/scaf04.fasta
sed -i 's/^>.*/>scaf10/' genome/scaf10.fasta
sed -i 's/^>.*/>IMGN2_genome/' genome/IMGN2_genome.fasta
sed -i 's/^>.*/>SBW25_genome/' genome/SBW25_genome.fasta

# creating the individual safracin gene files by using the coords listed in its genbank page and just snipping it out.
samtools faidx genome/safBGC.fasta
samtools faidx genome/safBGC.fasta safBGC:2870-5884 > genes/sfcA.fasta
samtools faidx genome/safBGC.fasta safBGC:5898-9089 > genes/sfcB.fasta
samtools faidx genome/safBGC.fasta safBGC:9093-13391 > genes/sfcC.fasta
samtools faidx genome/safBGC.fasta safBGC:13420-14472 > genes/sfcD.fasta
samtools faidx genome/safBGC.fasta safBGC:14537-14722 > genes/sfcE.fasta
samtools faidx genome/safBGC.fasta safBGC:14780-15847 > genes/sfcF.fasta
samtools faidx genome/safBGC.fasta safBGC:15933-16976 > genes/sfcG.fasta
samtools faidx genome/safBGC.fasta safBGC:17062-17604 > genes/sfcH.fasta
samtools faidx genome/safBGC.fasta safBGC:1669-2331 > genes/sfcI.fasta
samtools faidx genome/safBGC.fasta safBGC:150-1679 > genes/sfcJ.fasta

# creating the files for the SBW25 and IMGN2 regions of interest the same way.
samtools faidx genome/IGMN2_genome.fasta
samtools faidx genome/SBW25_genome.fasta
samtools faidx genome/IGMN2_genome.fasta IMGN2_genome:4011063-4094138 > genome/IMGN2_reg08.fasta
samtools faidx genome/IGMN2_genome.fasta IMGN2_genome:4834352-4887236 > genome/IMGN2_reg11.fasta
samtools faidx genome/IGMN2_genome.fasta SBW25_genome:2732627-2838158 > genome/SBW25_reg04.fasta
samtools faidx genome/IGMN2_genome.fasta SBW25_genome:3508015-3584310 > genome/SBW25_reg05.fasta
samtools faidx genome/IGMN2_genome.fasta SBW25_genome:4820788-4873678 > genome/SBW25_reg11.fasta
