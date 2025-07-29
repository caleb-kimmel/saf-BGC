#!/bin/bash

# This file is literally the exact same thing as tblastx_clustalo_v3.sh, except I swapped out the tblastx for blastn (and not megablast).
# That, and just making a different directory for everything too.

# WARNING: this bit here is not ready to be uploaded yet. i dont know the manners or etiquette for posting on github.
# I need to edit this so that it can be used even if you haven't created the conda environment and stuff.
__conda_setup="$('/home/cjkimmel/miniconda3/condabin/conda' 'shell.bash' 'hook' 2> /dev/null)"
eval "$__conda_setup"
conda activate kitchen_sink

# make the directories for everything to go
mkdir -p blastn_clustalo blastn_clustalo/blast_db blastn_clustalo/blast_out blastn_clustalo/hit_seqs blastn_clustalo/cat_genes blastn_clustalo/clustalo_out

# make the blast directories for the two scaffolds
makeblastdb -in genome/scaf04.fasta -dbtype nucl -out blastn_clustalo/blast_db/scaf04_db
makeblastdb -in genome/scaf10.fasta -dbtype nucl -out blastn_clustalo/blast_db/scaf10_db

# start the for loop that'll repeat this stuff for each gene
for gene in genes/sfc?.fasta; do
	# establish this variable that i'll type like 72 more times
        GENE_NAME=$(basename "$gene" .fasta)

	# run blastn of the gene against both scaffolds individually
	blastn -task blastn -query "$gene" -db blastn_clustalo/blast_db/scaf04_db -evalue 1 \
		-outfmt 6 -out "blastn_clustalo/blast_out/${GENE_NAME}_vs_scaf04.txt"

	blastn -task blastn -query "$gene" -db blastn_clustalo/blast_db/scaf10_db -evalue 1 \
		-outfmt 6 -out "blastn_clustalo/blast_out/${GENE_NAME}_vs_scaf10.txt"

	# these two if sections make sure there are hits in the blastn search against scaffold 4 or 10. they do the same sequence:
	# it grabs the start and end coords of the top hit sequence, then flips them if its in reverse.
	# then we use samtools to grab the hit's sequence. lastly, we concatenate and clustalate.
	if [ -s "blastn_clustalo/blast_out/${GENE_NAME}_vs_scaf04.txt" ]; then
		# now you have 10 files in your blast_out directory. yippee.
		# since they're all from the same scaffold, the sequence ID means nothing. gotta grab the coordinates of the top hit.
		SCAF04_START=$(awk 'NR==1 {print $9}' "blastn_clustalo/blast_out/${GENE_NAME}_vs_scaf04.txt")
		SCAF04_END=$(awk 'NR==1 {print $10}' "blastn_clustalo/blast_out/${GENE_NAME}_vs_scaf04.txt")

		# there's probably a better way to do this but this makes sense to me. this flips the coordinates if the hit is a reverse sequence.
		if (($SCAF04_START > $SCAF04_END)); then
			TEMP_VAR=$SCAF04_START
			SCAF04_START=$SCAF04_END
			SCAF04_END=$TEMP_VAR
		fi

		# now we get to use samtools because i like it! make the indexes and then grab the hits' sequences.
		samtools faidx genome/scaf04.fasta
		samtools faidx genome/scaf04.fasta "C_indica_scaffold_04:$SCAF04_START-$SCAF04_END" > "blastn_clustalo/hit_seqs/${GENE_NAME}_scaf04_hit.txt"

		# now we finally get to concatenate and clustalate!
		cat "blastn_clustalo/hit_seqs/${GENE_NAME}_scaf04_hit.txt" "$gene" > "blastn_clustalo/cat_genes/${GENE_NAME}_scaf04_cat.fasta"

		clustalo -i "blastn_clustalo/cat_genes/${GENE_NAME}_scaf04_cat.fasta" -o "blastn_clustalo/clustalo_out/${GENE_NAME}_scaf04.aln" --outfmt=clu --force
	else
		echo "BLASTN search of ${GENE_NAME} vs scaffold 4 returned no hits."
	fi

	if [ -s "blastn_clustalo/blast_out/${GENE_NAME}_vs_scaf10.txt" ]; then
		# now you have 10 more files in your blast_out directory. yippee.
		# since they're all from the same scaffold, the sequence ID means nothing. gotta grab the coordinates of the top hit.
		SCAF10_START=$(awk 'NR==1 {print $9}' "blastn_clustalo/blast_out/${GENE_NAME}_vs_scaf10.txt")
		SCAF10_END=$(awk 'NR==1 {print $10}' "blastn_clustalo/blast_out/${GENE_NAME}_vs_scaf10.txt")

		# there's probably a better way to do this but this makes sense to me. this flips the coordinates if the hit is a reverse sequence.
		if (($SCAF10_START > $SCAF10_END)); then
			TEMP_VAR=$SCAF10_START
			SCAF10_START=$SCAF10_END
			SCAF10_END=$TEMP_VAR
		fi

		# now we get to use samtools because i like it! make the indexes and then grab the hits' sequences.
		samtools faidx genome/scaf10.fasta
		samtools faidx genome/scaf10.fasta "C_indica_scaffold_10:$SCAF10_START-$SCAF10_END" > "blastn_clustalo/hit_seqs/${GENE_NAME}_scaf10_hit.txt"

		# now we finally get to concatenate and clustalate!
		cat "blastn_clustalo/hit_seqs/${GENE_NAME}_scaf10_hit.txt" "$gene" > "blastn_clustalo/cat_genes/${GENE_NAME}_scaf10_cat.fasta"

		clustalo -i "blastn_clustalo/cat_genes/${GENE_NAME}_scaf10_cat.fasta" -o "blastn_clustalo/clustalo_out/${GENE_NAME}_scaf10.aln" --outfmt=clu --force
	else
		echo "BLASTN search of ${GENE_NAME} vs scaffold 10 returned no hits."
	fi

done

# this last bit here creates a table showing the stats of all the top hits for each gene against both scaffolds.
# ultimately it makes a .csv file you can open up in excel or whatever. hopefully.
echo "Making the BLASTN top hits table."
OUTPUT_FILE="blastn_clustalo/blastn_table.csv"

echo "gene_vs_scaffold,%_identity,evalue,length,mismatches" > "$OUTPUT_FILE"

for file in blastn_clustalo/blast_out/sfc?_vs_scaf??.txt; do
	if [ -s "$file" ]; then
		FILE_NAME=$(basename "$file" .txt)
		awk -v name="$FILE_NAME" 'NR==1 {printf "%s,%.3f,%s,%d,%d\n", name, $3, $11, $4, $5}' "$file" >> "$OUTPUT_FILE"
	else
		# if the blastn search was empty, this just spews out "n/a".
		echo "$FILE_NAME,N/A,N/A,N/A,N/A" >> "$OUTPUT_FILE"
	fi
done
echo "Finished making the BLASTN top hits table."
