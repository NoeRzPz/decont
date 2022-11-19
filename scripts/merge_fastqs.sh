# Variables definition
indir=$1
outdir=$2
sampleid=$3

mkdir -p $outdir
cat $indir/${sampleid}*.fastq.gz > $outdir/${sampleid}.fastq.gz
if [ "$?" -ne 0 ] # Control structure for previous exit code
then
    echo "Error in merging files."
    exit 1
fi
