# Variables definition
genomefile=$1
outdir=$2

if [ -e $outdir ] # Check if output already exists
then
    echo "Index already exists"
    exit 0	
fi

STAR \
    --runThreadN 4 \
    --runMode genomeGenerate \
    --genomeDir $outdir \
    --genomeFastaFiles $genomefile \
    --genomeSAindexNbases 9

