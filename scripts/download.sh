#Variables definition
wd=~/decont
sample_url=$1
sample_dir=$2
uncompress=$3
filter=$4

echo "Downloading $(basename $sample_url .fastq.gz)..."
wget -c -P $sample_dir $sample_url
if [ "$?" -ne 0 ] # Checks if previous exit code is not equal to 0
then
    echo "Error in downloading file. Usage: bash $0"
    exit 1 
fi
echo "Done"
echo

if [ "$uncompress" == "yes" ]
then
	echo "Uncompressing database..."
	gunzip -k $sample_dir/$(basename $sample_url)
	echo "Filtering database..."
	cat $sample_dir/$(basename $sample_url .gz) | awk '{FS=">"; if (!/small nuclear/) print}' > tmp && mv tmp $wd/$sample_dir/$(basename $sample_url .gz)
	echo "Done"
fi
echo

if [ "$filter" == "small nuclear" ]
then
	echo "Filtering database..."
	cat $wd/$out_dir/$(basename $sample_url .gz) | awk '{FS=">"; if (!/small nuclear/) print}' > tmp && mv tmp $wd/$out_dir/$(basename $sample_url .gz)
	echo "Done"
fi
