echo "BLAST program: $1"
echo "BLAST database name: $2"
echo "Reference sequence: $3"
echo "Reference name: $4"
echo "Minimum match length: $5"
echo "Other BLAST options: $6"
echo "Other Python options: $7"

echo "Finding matches and opening HTML output..."
$1 -db $2 -query $3 -html -out $1_$4.html -num_descriptions 99999 -num_alignments 99999 $6
firefox $1_$4.html

echo "Creating tabular output..."
$1 -db $2 -query $3 -out $1_$4_tab.out -num_alignments 99999 -outfmt 6 $6
# This is equal to -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore"
# Add headers
echo -e "qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" | cat - $1_$4_tab.out > $1_$4_tab.tsv
rm $1_$4_tab.out
echo "Separating the sequencess of match length > $5..."
python3 ../python/fromfasta.py -i ./$2.fa -o $1_$4_selected.fa -b ./$1_$4_tab.tsv "3 >= $5 1" $7
echo "blastnsep DONE!"
