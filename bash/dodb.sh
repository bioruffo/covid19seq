echo "Using file: $1"
echo "db format: $2"
echo "Output dbname: $3"
echo "Removing spaces..."
sed '/^>/s/\s/_/g' $1 > $3.fa
sed -i '/^>/s/_$//g' $3.fa
echo "Creating database..."
makeblastdb -in $3.fa -dbtype $2 -out $3
echo "dodb.sh DONE!"
