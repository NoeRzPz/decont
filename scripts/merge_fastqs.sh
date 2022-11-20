# Variables definition
indir=$1
outdir=$2
sampleid=$3

mkdir -p $outdir
cat $indir/${sampleid}*.fastq.gz > $outdir/${sampleid}.fastq.gz
