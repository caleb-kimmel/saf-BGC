# saf-BGC

the grabbing_seqs.sh file has all the stuff for setting up the conda environments, grabbing fasta files, and setting up individual gene files. it creates two conda environments, one for antismash and one for everything else i've done so far. it grabs the genome files of P. poae PMA22, P. fluorescens IMGN2, and P. fluorescens SBW25. it also grabs the fasta file for the Safracin B BGC and for scaffolds 4 and 10 of C. indica APK2. It modifies the headers for those last 3 fasta files (to make the code much less painful later), and then uses the BGC sequence to create the fasta files for the individual genes.

the blast_clustalo_v3.sh file has a good deal of stuff i'll summarize later. ciao
