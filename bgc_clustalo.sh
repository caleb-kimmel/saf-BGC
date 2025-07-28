#!/bin/bash
#SBATCH -j bgc_clustalo
#SBATCH -o bgc_clustalo.o%j
#SBATCH --mail-user=cjkimmel@cougarnet.uh.edu
#SBATCH --mail-type=ALL
#SBATCH --ntasks-per-node=16 -N 1
#SBATCH -t 20:0:0
#SBATCH --mem-per-cpu=16GB

# WARNING: the time and memory allocations are not sufficient. PLEASE change before you run this code.
# I was worried that it would time out after like 12 hours and we wouldn't get our results and I was getting highly fluctuating info so I set it to 20 hrs.
# It took no more than 1 hour to finish. So please change the computing and time allocations.

module load clustalo

clustalo -i BGC_reg_seqs.fasta --distmat-out=distmat.txt --guidetree-out=guidetree.dnd --full --use_kimura -o BGC_reg_seqs.aln --outfmt=clu --threads=16
