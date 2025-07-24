#!/bin/bash

# WARNING: this bit here is not ready to be uploaded yet. i dont know the manners or etiquette for posting on github.
# I need to edit this so that it can be used even if you haven't created the conda environment and stuff.
__conda_setup="$('/home/cjkimmel/miniconda3/condabin/conda' 'shell.bash' 'hook' 2> /dev/null)"
eval "$__conda_setup"
conda activate blast_clustalo_env

# make the directories for everything to go
mkdir -p blast_db blast_out hit_seqs cat_genes clustalo_out

# make the blast directories for the two scaffolds
makeblastdb -in genome/scaf04.fasta -dbtype nucl -out blast_db/scaf04_db
makeblastdb -in genome/scaf10.fasta -dbtype nucl -out blast_db/scaf10_db

# start the for loop that'll repeat this stuff for each gene
for gene in genes/sfc?.fasta; do
	# establish this variable that i'll type like 72 more times
        GENE_NAME=$(basename "$gene" .fasta)

	# run tblastx of the gene against both scaffolds individually
        tblastx -query "$gene" -db blast_db/scaf04_db -evalue 1 \
		-outfmt 6 -out "blast_out/${GENE_NAME}_vs_scaf04.txt"

	tblastx -query "$gene" -db blast_db/scaf10_db -evalue 1 \
		-outfmt 6 -out "blast_out/${GENE_NAME}_vs_scaf10.txt"

	# now you have 20 files in your blast_out directory. yippee.
	# since they're all from the same two scaffolds, the sequence ID means nothing. gotta grab the coordinates of the top hit.
        SCAF04_START=$(awk 'NR==1 {print $9}' "blast_out/${GENE_NAME}_vs_scaf04.txt")
	SCAF04_END=$(awk 'NR==1 {print $10}' "blast_out/${GENE_NAME}_vs_scaf04.txt")
	SCAF10_START=$(awk 'NR==1 {print $9}' "blast_out/${GENE_NAME}_vs_scaf10.txt")
	SCAF10_END=$(awk 'NR==1 {print $10}' "blast_out/${GENE_NAME}_vs_scaf10.txt")

	# there's probably a better way to do this but this makes sense to me. this flips the coordinates if the hit is a reverse sequence.
	if (($SCAF04_START > $SCAF04_END)); then
		TEMP_VAR=$SCAF04_START
		SCAF04_START=$SCAF04_END
		SCAF04_END=$TEMP_VAR
	fi
	if (($SCAF10_START > $SCAF10_END)); then
		TEMP_VAR=$SCAF10_START
		SCAF10_START=$SCAF10_END
		SCAF10_END=$TEMP_VAR
	fi

	# now we get to use samtools because i like it! make the indexes and then grab the hits' sequences.
	samtools faidx genome/scaf04.fasta
	samtools faidx genome/scaf10.fasta
	samtools faidx genome/scaf04.fasta "C_indica_scaffold_04:$SCAF04_START-$SCAF04_END" > "hit_seqs/${GENE_NAME}_scaf04_hit.txt"
	samtools faidx genome/scaf10.fasta "C_indica_scaffold_10:$SCAF10_START-$SCAF10_END" > "hit_seqs/${GENE_NAME}_scaf10_hit.txt"

	# now we finally get to concatenate and clustalate!
	cat "hit_seqs/${GENE_NAME}_scaf04_hit.txt" "$gene" > "cat_genes/${GENE_NAME}_scaf04_cat.fasta"
	cat "hit_seqs/${GENE_NAME}_scaf10_hit.txt" "$gene" > "cat_genes/${GENE_NAME}_scaf10_cat.fasta"

	clustalo -i "cat_genes/${GENE_NAME}_scaf04_cat.fasta" -o "clustalo_out/${GENE_NAME}_scaf04.aln" --outfmt=clu --force
	clustalo -i "cat_genes/${GENE_NAME}_scaf10_cat.fasta" -o "clustalo_out/${GENE_NAME}_scaf10.aln" --outfmt=clu --force

done
