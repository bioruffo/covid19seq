echo "BLAST program: $1"
echo "BLAST database name: $2"
echo "Reference sequence: $3"
echo "Minimum match length: $4"
echo "Other BLAST options: $5"
echo "Other Python options: $6"

echo "Finding matches and opening HTML output..."
$1 -db $2 -query $3 -html -out $1.html -num_descriptions 99999 -num_alignments 99999 $5
firefox $1.html

echo "Creating tabular output..."
$1 -db $2 -query $3 -out $1_tab.out -num_alignments 99999 -outfmt 6 $5
# This is equal to -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore"
# Add headers
echo -e "qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" | cat - $1_tab.out > $1_tab.tsv
rm $1_tab.out
echo "Separating the sequencess of match length > $4..."
python3 ../python/fromfasta.py -i ./$2.fa -o $1_selected.fa -b ./$1_tab.tsv "3 >= $4 1" $6
echo "blastnsep DONE!"
