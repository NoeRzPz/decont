# Variables definition
file_url=$1
out_dir=$2
uncompress=$3
filter=$4

# Functions definition
file_name () { 
    echo "$(basename $file_url)" # Obtain file name from file_url variable
}

db_name () {
    echo "$(basename $file_url .gz)" # Remove .gz extension from file name
}

if [ -f "$file_url" ] # Check if first argument is a file
then
    echo "Downloading sequencing data files..."
    files_num=$(ls $out_dir/*.fastq.gz 2>/dev/null | wc -l) # Calculate files number, redirects stderr to null device file if there are no files within directory
    if [ "$files_num" -eq $(cat $file_url | wc -l) ] # Check if downloaded files number match urls number
    then
        echo "Files in $file_url already downloaded"
	exit 0
    fi
    wget -c -P $out_dir -i $file_url # Option continue to avoid duplicate files
    echo

    echo "Checking md5sum..."
    for url in $(cat $file_url)
    do
        md5sum -c <(echo $(curl ${url}.md5 | grep s_sRNA. | cut -d" " -f1) $out_dir/$(basename $url))
    done
    if [ "$?" -ne 0 ] # Exits if md5sum is not ok
    then
        echo "md5sum checked failed" && exit 1
    fi
else
    echo "Downloading $(file_name) file..."
    if [ -e $out_dir/$(file_name) ] # Check output existence
    then
	echo "File $(file_name) already downloaded"
	exit 0
    fi
    wget -P $out_dir $file_url
    echo

    echo "Checking $(file_name) md5sum..."
    md5sum -c <(echo $(curl ${file_url}.md5 | grep fasta.gz | cut -d" " -f1) $out_dir/$(file_name))
    if [ "$?" -ne 0 ] # Exits if md5sum is not ok
    then
        echo "md5sum checked failed" && exit 1
    fi
fi

if [ "$uncompress" == "yes" ] # Uncompress file only if third argument is yes
then
    echo
    echo "Uncompressing $(file_name) database..."
    gunzip -k $out_dir/$(file_name)
    echo "Done"
fi
echo

if [ "$filter" == "small nuclear" ] # Filter only if fourth argument is small nuclear
then
    echo "Filtering $(db_name) database..."
    seqkit grep -vrp "small nuclear" -n $out_dir/$(db_name) \
    > tmp && mv tmp $out_dir/$(db_name) # Save it with same file name
    echo "Done"
fi
