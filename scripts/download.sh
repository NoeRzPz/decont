#Variables definition
file_url=$1
out_dir=$2
uncompress=$3
filter=$4
gunzipfile=$(basename $file_url .gz)

echo "Downloading $(basename $file_url) file..."
wget -c -P $out_dir $file_url
if [ "$?" -ne 0 ] # Control structure for previous exit code
then
    echo "Error in downloading file"
    exit 1
fi
echo

if [ "$uncompress" == "yes" ]
then
    echo "Uncompressing $(basename $file_url .fasta.gz) database..."
    gunzip -k $out_dir/$(basename $file_url)
    if [ "$?" -ne 0 ]
    then
        echo "Error in uncompressing file."
        exit 1
    fi
    echo "Done"
fi
echo

if [ "$filter" == "small nuclear" ]
then
    echo "Filtering $(basename $file_url .fasta.gz) database..."
    seqkit grep -v -r -p "small nuclear" -n $out_dir/$gunzipfile \
    > tmp && mv tmp $out_dir/$gunzipfile
    if [ "$?" -ne 0 ]
    then
        echo "Error in fitering file."
        exit 1
    fi
    echo "Done"
fi
