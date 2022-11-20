# Variables definition
indir=$1
outdir=$2
sampleid=$3

if [ -e $outdir/${sampleid}.fastq.gz ] # Check if output already exists
then
    echo "Merged $sampleid file already exists"
    exit 0	
fi

mkdir -p $outdir
cat $indir/${sampleid}*.fastq.gz > $outdir/${sampleid}.fastq.gz
