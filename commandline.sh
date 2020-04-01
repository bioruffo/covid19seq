# Download the spike protein sequence from: https://www.ncbi.nlm.nih.gov/genbank/sars-cov-2-seqs/
# Save it in NCBI_seqs as: 'spike_YP_009724390.1.fa'

PROTSEQ="../NCBI_seqs/spike_YP_009724390.1.fa"

# Download protein sequences as multiFASTA from: https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?SeqType_s=Protein&VirusLineage_ss=Severe%20acute%20respiratory%20syndrome%20coronavirus%202%20(SARS-CoV-2),%20taxid:2697049
#Save them in the NCBI_seqs directory as: 'NCBI_protein_30mar20_2645prots_sequences.fasta'

# Create a BLAST database from protein sequences downloaded from NCBI on 30/03
mkdir blast_ncbi
cd blast_ncbi
bash ../bash/dodb.sh ../NCBI_seqs/NCBI_protein_30mar20_2645prots_sequences.fasta prot ncbiprot

# Find matches to spike protein
# In Python, '--p True' purge (remove) sequences with indetermined aa's or N's
bash ../bash/blastnsep.sh blastp ncbiprot $PROTSEQ 1000 '' '-p True'
#232 sequences returned

#Aligning with Clustal Omega (or use the website)
clustalo -i blastp_selected.fa -o blastp_selected.aln --outfmt=clu --force
#Open in Jalview, if opened from the website then save as .aln


cd ..


## USING BLASTX TO SEARCH WITHIN GISAID HIGH-QUALITY NUCLEOTIDE SEQUENCES

# Download protein sequences as multiFASTA from Gisaid
#Save them in the Gisaid_seqs directory as: 'gisaid_cov2020_sequences-30mar20_HiCovOnly_2179.fasta'

# Create a BLAST database from NUCLEOTIDE sequences downloaded from GISAID on 30/03
mkdir blast_gisaid
cd blast_gisaid
bash ../bash/dodb.sh ../Gisaid_seqs/gisaid_cov2020_sequences-30mar20_HiCovOnly_2179.fasta nucl gisnuc

# Find matches to spike protein
# WE NEED TO USE '-seg no' TO AVOID LOSING THE FIRST 11 AMINOACIDS!
# In Python, '-t True -p True' will translate sequences and purge (remove) sequences with indetermined aa's or N's
bash ../bash/blastnsep.sh tblastn gisnuc $PROTSEQ 1000 '-seg no' '-t True -p True'
#1933 sequences returned

#Aligning with Clustal Omega (or use the website)
clustalo -i tblastn_selected.fa -o tblastn_selected.aln --outfmt=clu --force
#Open in Jalview, if opened from the website then save as .aln
