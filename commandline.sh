# Download the spike protein sequence from: https://www.ncbi.nlm.nih.gov/genbank/sars-cov-2-seqs/
# Save it in NCBI_seqs as: 'spike_YP_009724390.1.fa'

PROTSEQ="../../NCBI/NCBI_seqs/spike_YP_009724390.1.fa"
# NAME will be used in fileand directory names
NAME="spike"
# MIN_LENGTH is used for the minimum alignment length filter.
# The value of 1000 aa would be for the spike that's 1273 aa; must change it for other proteins.
MIN_LENGTH=1000


# Download protein sequences as multiFASTA from: https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?SeqType_s=Protein&VirusLineage_ss=Severe%20acute%20respiratory%20syndrome%20coronavirus%202%20(SARS-CoV-2),%20taxid:2697049
# i.e. save them in the NCBI_seqs directory as: 'NCBI_protein_30mar20_2645prots_sequences.fasta'

# Create a BLAST database from protein sequences downloaded from NCBI on 30/03
cd NCBI
mkdir blast_$NAME'_ncbi'
cd blast_$NAME'_ncbi'
bash ../../bash/dodb.sh ../NCBI_seqs/NCBI_protein_30mar20_2645prots_sequences.fasta prot ncbiprot


# Find matches to spike protein
# In the Python script, '--p True' will purge (remove) sequences with indetermined aa's or N's
bash ../../bash/blastnsep.sh blastp ncbiprot $PROTSEQ $NAME $MIN_LENGTH '' '-p True'
#232 sequences returned

#Aligning with Clustal Omega (or use the website)
clustalo -i blastp_$NAME'_selected.fa' -o blastp_$NAME'_selected.aln' --outfmt=clu --force
#Open in Jalview, if opened from the website then save as .aln


cd ../..


## USING TBLASTN TO SEARCH WITHIN GISAID HIGH-QUALITY NUCLEOTIDE SEQUENCES

# Download protein sequences as multiFASTA from Gisaid
# i.e. save them in the Gisaid_seqs directory as: 'gisaid_cov2020_sequences-30mar20_HiCovOnly_2179.fasta'

# Create a BLAST database from NUCLEOTIDE sequences downloaded from GISAID on 30/03
cd Gisaid
mkdir blast_$NAME'_gisaid'
cd blast_$NAME'_gisaid'
bash ../../bash/dodb.sh ../Gisaid_seqs/gisaid_cov2020_sequences-30mar20_HiCovOnly_2179.fasta nucl gisnuc

# Find matches to spike protein
# WE NEED TO USE '-seg no' TO AVOID LOSING THE FIRST 11 AMINOACIDS!
# In the Python script, '-t True -p True' will translate sequences and purge (remove) sequences with indetermined aa's or N's
bash ../../bash/blastnsep.sh tblastn gisnuc $PROTSEQ $NAME $MIN_LENGTH '-seg no' '-t True -p True'
#1933 sequences returned

#Aligning with Clustal Omega (or use the website)
echo Better align this one via website: tblastn_$NAME'_selected.fa'
#clustalo -i tblastn_$NAME'_selected.fa' -o tblastn_$NAME'_selected.aln' --outfmt=clu --force
#Open in Jalview, if opened from the website then save as .aln

# Compare with other species
#mkdir interspecies
#cd interspecies
#cat ../NCBI_seqs/spike_YP_009724390.1.fa ../NCBI_seqs/SARS_spike_NP_828851.1 > CoV-2_vs_SARS.fa
#clustalo -i ./CoV-2_vs_SARS.fa -o CoV-2_vs_SARS.aln --outfmt=clu --force
#Or use a BLAST search as input: online blastp the protein vs refseq proteins, then download all alignments from the results page.

