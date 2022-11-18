# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).

# Variables definition
indir=$1
outdir=$2
sampleid=$3

mkdir -p $outdir
cat $indir/${sampleid}* > $outdir/${sampleid}.fastq.gz
