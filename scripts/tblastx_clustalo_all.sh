#!/bin/bash

# WARNING: this bit here is not ready to be uploaded yet. i dont know the manners or etiquette for posting on github.
# I need to edit this so that it can be used even if you haven't created the conda environment and stuff.
__conda_setup="$('/home/cjkimmel/miniconda3/condabin/conda' 'shell.bash' 'hook' 2> /dev/null)"
eval "$__conda_setup"
conda activate kitchen_sink

# establish the directory variables
BASE_DIR="tblastx_clustalo_all"
DB_DIR="$BASE_DIR/blast_db"
BLAST_DIR="$BASE_DIR/blast_out"
HITS_DIR="$BASE_DIR/hit_seqs"
CAT_DIR="$BASE_DIR/cat_genes"
ALIGN_DIR="$BASE_DIR/clustalo_out"

# make the directories for everything to go
mkdir -p "$DB_DIR" "$BLAST_DIR" "$HITS_DIR" "$CAT_DIR" "$ALIGN_DIR"

for scaffold in scaffolds/scaf*.fasta; do
	# establish the scaffold variable
	SCAFFOLD_NAME=$(basename "$scaffold" .fasta)
	sed -i "s/^>.*/>${SCAFFOLD_NAME}/" "$scaffold"

	scaf_db="$DB_DIR/${SCAFFOLD_NAME}_db"

	# create the scaffold's blast database and samtools index for later
	makeblastdb -in "$scaffold" -dbtype nucl -out "$scaf_db"
	samtools faidx "$scaffold"

	for gene in genes/sfc?.fasta; do
		# establish the gene variable
		GENE_NAME=$(basename "$gene" .fasta)

		# establish the file path variables.
		blast_output="$BLAST_DIR/${GENE_NAME}_vs_${SCAFFOLD_NAME}.txt"
		hit_seq="$HITS_DIR/${GENE_NAME}_${SCAFFOLD_NAME}_hit.txt"
		cat_seqs="$CAT_DIR/${GENE_NAME}_${SCAFFOLD_NAME}_cat.fasta"
		clustalo_output="$ALIGN_DIR/${GENE_NAME}_${SCAFFOLD_NAME}.aln"


		# run tblastx of the gene against the scaffold
		tblastx -query "$gene" -db "$scaf_db" -evalue 1 -outfmt 6 -out "$blast_output"

		# check if the tblastx run had any results
		if [ -s "$blast_output" ]; then
			# grab the target sequence coords of the top hit
			SEQ_START=$(awk 'NR==1 {print $9}' "$blast_output")
			SEQ_END=$(awk 'NR==1 {print $10}' "$blast_output")

			# flip the coords if the hit is on the reverse strand
			if (($SEQ_START > $SEQ_END)); then
				TEMP_VAR=$SEQ_START
				SEQ_START=$SEQ_END
				SEQ_END=$TEMP_VAR
			fi

			# grab the hit's sequence using samtools
			samtools faidx "$scaffold" "${SCAFFOLD_NAME}:$SEQ_START-$SEQ_END" > "$hit_seq"

			# now we concatenate and clustalate!
			cat "$hit_seq" "$gene" > "$cat_seqs"

			clustalo -i "$cat_seqs" -o "$clustalo_output" --outfmt=clu --force
		else
			echo "TBLASTX search of ${GENE_NAME} vs ${SCAFFOLD_NAME} returned no hits."
		fi
	done
done

# this last bit here creates a table showing the stats of all the top hits for each gene against each scaffold.
# ultimately it makes a .csv file you can open up in excel or whatever. hopefully.
echo "Making the TBLASTX top hits table."

OUTPUT_FILE="$BASE_DIR/tblastx_table.csv"

echo "gene,scaffold,%_identity,evalue,length,mismatches" > "$OUTPUT_FILE"

for file in "$BLAST_DIR"/*.txt; do
	# grab the name of the gene and scaffold for the first two columns
	FILE_NAME=$(basename "$file" .txt)
	GENE_NAME=${FILE_NAME%%_vs_*}
	SCAFFOLD_NAME=${FILE_NAME##*_vs_}

	if [ -s "$file" ]; then
		# grab the % identity, e-value, alignment length, and # of mismatches of the top hit.
		awk -v gene="$GENE_NAME" -v scaffold="$SCAFFOLD_NAME" 'NR==1 {printf "%s,%s,%.3f,%s,%d,%d\n", gene, scaffold, $3, $11, $4, $5}' "$file" >> "$OUTPUT_FILE"
	else
		# if the tblastx search was empty, this just spews out "n/a".
		echo "$GENE_NAME,$SCAFFOLD_NAME,N/A,N/A,N/A,N/A" >> "$OUTPUT_FILE"
	fi
done

echo "Finished making the TBLASTX top hits table."
