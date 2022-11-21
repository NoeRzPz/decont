#Variables definition
file_url=$1
out_dir=$2
uncompress=$3
filter=$4
datafiles=($out_dir/*.fastq.gz) # Store files as an array

if [ -f "$file_url" ] # Check if first argument is a file
then
    echo "Downloading sequencing data files..."
    if [[ -e ${datafiles[0]} && -e ${datafiles[3]} ]] # Check output existence
    then
        echo "File $file_url already downloaded"
        exit 0
    fi
    wget -P $out_dir -i $file_url
    echo

    echo "Checking md5sum..."
    for url in $(cat $file_url)
    do
        md5sum -c <(echo $(curl ${url}.md5 | grep s_sRNA. | cut -d" " -f1) $out_dir/$(basename $url))
    done
else
    echo "Downloading $(basename $file_url) file..."
    if [ -e $out_dir/$(basename $file_url) ] # Check output existence
    then
        echo "File $(basename $file_url) already downloaded"
	exit 0
    fi
    wget -P $out_dir $file_url
    echo

    echo "Checking $(basename $file_url) md5sum..."
    md5sum -c <(echo $(curl ${file_url}.md5 | grep fasta.gz | cut -d" " -f1) $out_dir/$(basename $file_url))
fi
echo

#echo "Downloading $(basename $file_url) file..."
#if [ -e $out_dir/$(basename $file_url) ] # Check output existence
#then
#    echo "File $(basename $file_url) already downloaded"
#    exit 0
#fi
#wget -P $out_dir $file_url

#echo "Checking $(basename $file_url) md5sum..."
#md5sum -c <(echo $(curl ${file_url}.md5 | grep fasta.gz | cut -d" " -f1) $out_dir/$(basename $file_url))
#echo

if [ "$uncompress" == "yes" ] # Uncompress file only if third argument is yes
then
    echo "Uncompressing $(basename $file_url .fasta.gz) database..."
    gunzip -k $out_dir/$(basename $file_url)
    echo "Done"
fi
echo

if [ "$filter" == "small nuclear" ] # Filter only if fourth argument is small nuclear
then
    echo "Filtering $(basename $file_url .fasta.gz) database..."
    seqkit grep -v -r -p "small nuclear" -n $out_dir/$(basename $file_url .gz) \
    > tmp && mv tmp $out_dir/$(basename $file_url .gz)
    echo "Done"
fi
