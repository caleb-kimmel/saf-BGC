#!/bin/bash
#SBATCH -j bgc_clustalo
#SBATCH -o bgc_clustalo.o%j
#SBATCH --mail-user=cjkimmel@cougarnet.uh.edu
#SBATCH --mail-type=ALL
#SBATCH --ntasks-per-node=16 -N 1
#SBATCH -t 20:0:0
#SBATCH --mem-per-cpu=16GB

module load clustalo

clustalo -i BGC_reg_seqs.fasta --distmat-out=distmat.txt --guidetree-out=guidetree.dnd --full --use_kimura -o BGC_reg_seqs.aln --outfmt=clu --threads=16
