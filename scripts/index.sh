#Variables definition
genomefile=$1
outdir=$2

STAR \
    --runThreadN 4 \
    --runMode genomeGenerate \
    --genomeDir $outdir \
    --genomeFastaFiles $genomefile \
    --genomeSAindexNbases 9
if [ "$?" -ne 0 ] # Control structure for previous exit code
then
    echo "Error in indexing database."
    exit 1
fi

