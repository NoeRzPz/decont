#Variables definition
genomefile=$1
outdir=$2

STAR \
    --runThreadN 4 \
    --runMode genomeGenerate \
    --genomeDir $outdir \
    --genomeFastaFiles $genomefile \
    --genomeSAindexNbases 9
