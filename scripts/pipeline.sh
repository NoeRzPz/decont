echo "-------- Starting pipeline at $(date +'%d %h %y, %r')... --------"
echo

# Stop execution when having a non-zero status and trap errors giving line number
set -e
trap 'echo Error at about $LINENO' ERR

# Download all the files specified in data/filenames
bash scripts/download.sh data/urls data
echo

# Download the contaminants fasta file, uncompress it, and filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear"
echo

# Index the contaminants file
echo "Running STAR index..."
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
echo "Done"
echo

# Merge the samples into a single file
for sid in $(ls data/*fastq.gz | xargs basename -a | cut -d"-" -f1 | sort -u)
do
    echo "Merging sample $sid files..."
    bash scripts/merge_fastqs.sh data out/merged $sid
    echo "Done"
    echo
done

echo "Running cutadapt..."
for fname in out/merged/*.fastq.gz
do
    sid=$(basename $fname .fastq.gz)
    if [ -e out/trimmed/${sid}.trimmed.fastq.gz ] # Check output already exists
    then
	echo "$sid already trimmed"
	continue	
    fi
    echo "Trimming sample $sid..."
    mkdir -p out/trimmed
    mkdir -p log/cutadapt
    cutadapt \
        -m 18 \
        -a TGGAATTCTCGGGTGCCAAGG \
        --discard-untrimmed \
        -o out/trimmed/${sid}.trimmed.fastq.gz out/merged/${sid}.fastq.gz \
        > log/cutadapt/${sid}.log
done
echo

echo "Running STAR alignment..."
echo
for fname in out/trimmed/*.fastq.gz
do
    sid=$(basename $fname .trimmed.fastq.gz)
    if [ -e out/star/$sid/ ] # Check output already exists
    then
        echo "$sid already aligned"
        continue	
    fi
    echo "Decontaminating sample $sid..."
    mkdir -p out/star/${sid}
    STAR \
        --runThreadN 4 \
        --genomeDir res/contaminants_idx \
        --outReadsUnmapped Fastx  \
        --readFilesIn out/trimmed/${sid}.trimmed.fastq.gz \
        --readFilesCommand gunzip -c  \
        --outFileNamePrefix out/star/${sid}/
done 
echo "Done"
echo

# Create a single log file containing information from cutadapt and star logs
echo "Generating Log.out..."

if [ -e Log.out ] # Check output already exists
then
    echo "Log file already exists"
    exit 0
fi

for fname in log/cutadapt/*.log
do
    sid=$(basename $fname .log)
    echo "${sid}" >> Log.out
    cat log/cutadapt/${sid}.log | egrep "Reads with |Total basepairs" >> Log.out
    cat out/star/${sid}/Log.final.out | \
    egrep "reads %|% of reads mapped to (multiple|too)" >> Log.out
    echo >> Log.out
done
echo "Done"
echo

echo "-------- Pipeline finished at $(date +'%d %h %y, %r')... --------"
