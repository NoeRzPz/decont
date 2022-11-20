#Variables definition
file_url=$1
out_dir=$2
uncompress=$3
filter=$4

if [ -f "$file_url" ] # Check if first argument is a file
then
    echo "Downloading sequencing data files..."
    wget -c -P $out_dir -i $file_url
else
    echo "Downloading $(basename $file_url) file..."
    wget -c -P $out_dir $file_url
fi
echo

if [ "$uncompress" == "yes" ] # Uncompress file only if third argument is yes
then
    echo "Uncompressing $(basename $file_url .fasta.gz) database..."
    gunzip -k $out_dir/$(basename $file_url)
    echo "Done"
fi
echo

if [ "$filter" == "small nuclear" ]
then
    echo "Filtering $(basename $file_url .fasta.gz) database..."
    seqkit grep -v -r -p "small nuclear" -n $out_dir/$(basename $file_url .gz) \
    > tmp && mv tmp $out_dir/$(basename $file_url .gz)
    echo "Done"
fi
