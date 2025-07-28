#!/bin/bash

# i want to antismash!!!!!

conda activate antismash_env

# making the necessary directory
mkdir -p antismash_out 

# just the same code four times but for each genome (and then the bgc). i added all the bells and whistles too
antismash --output-dir antismash_out/pma22 \
	--genefinding-tool prodigal --knownclusterblast \
	--mibig --clusterblast --subclusterblast \
	--clusterhmmer --pfam2go --tfbs --asf --rre \
	--tigrfam --genefunctions \
	genome/PMA22_genome.gbk

antismash --output-dir antismash_out/imgn2 \
	--genefinding-tool prodigal --knownclusterblast \
	--mibig --clusterblast --subclusterblast \
	--clusterhmmer --pfam2go --tfbs --asf --rre \
	--tigrfam --genefunctions \
	genome/IMGN2_genome.gbk

antismash --output-dir antismash_out/sbw25 \
	--genefinding-tool prodigal --knownclusterblast \
	--mibig --clusterblast --subclusterblast \
	--clusterhmmer --pfam2go --tfbs --asf --rre \
	--tigrfam --genefunctions \
	genome/SBW25_genome.gbk

antismash --output-dir antismash_out/bgc \
	--genefinding-tool prodigal --knownclusterblast \
	--mibig --clusterblast --subclusterblast \
	--clusterhmmer --pfam2go --tfbs --asf --rre \
	--tigrfam --genefunctions \
	genome/safBGC.gbk
