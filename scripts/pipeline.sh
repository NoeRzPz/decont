echo "-------- Starting pipeline at $(date +'%d %h %y, %r')... --------"

#Download all the files specified in data/filenames
for url in $(cat data/urls)
do
    bash scripts/download.sh $url data
    if [ "$?" -ne 0 ]
    then
        exit 1
    fi
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear"
if [ "$?" -ne 0 ]
then
    echo "Error in processing database."
    exit 1
fi
echo

# Index the contaminants file
echo "Running STAR index..."
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
if [ "$?" -ne 0 ]
then
    echo "Error in indexing database."
    exit 1
fi
echo "Done"
echo

# Merge the samples into a single file
for sid in $(ls data/*fastq.gz | xargs basename -a | cut -d"-" -f1 | sort -u)
do
    echo "Merging sample $sid files..."
    bash scripts/merge_fastqs.sh data out/merged $sid
    if [ "$?" -ne 0 ]
    then
        exit 1
    fi
    echo "Done"
    echo
done

echo "Running cutadapt..."
for fname in out/merged/*.fastq.gz
do
    sid=$(basename $fname .fastq.gz)
    echo "Trimming sample $sid..."
    mkdir -p out/trimmed
    mkdir -p log/cutadapt
    cutadapt \
        -m 18 \
        -a TGGAATTCTCGGGTGCCAAGG \
        --discard-untrimmed \
        -o out/trimmed/${sid}.trimmed.fastq.gz out/merged/${sid}.fastq.gz \
        > log/cutadapt/${sid}.log
    if [ "$?" -ne 0 ]
    then
        fail=1
    fi
done
if [ "$fail" -eq 1 ]
then
    echo "Error in running cutadapt"
    exit 1
fi
echo "Done"
echo

echo "Running STAR alignment..."
echo
for fname in out/trimmed/*.fastq.gz
do
    sid=$(basename $fname .trimmed.fastq.gz)
    echo "Decontaminating sample $sid..."
    mkdir -p out/star/${sid}
    STAR \
        --runThreadN 4 \
        --genomeDir res/contaminants_idx \
        --outReadsUnmapped Fastx  \
        --readFilesIn out/trimmed/${sid}.trimmed.fastq.gz \
        --readFilesCommand gunzip -c  \
        --outFileNamePrefix out/star/${sid}/
    if [ "$?" -ne 0 ]
    then
        mistake=1
    fi
done 
if [ "$mistake" -eq 1 ]
then
    echo "Error in running STAR"
    exit 1
fi
echo "Done"
echo

# create a single log file containing information from cutadapt and star logs
echo "Generating Log.out..."
for fname in log/cutadapt/*.log
do
    sid=$(basename $fname .log)
    echo "${sid}" >> Log.out
    cat log/cutadapt/${sid}.log | egrep "Reads with |Total basepairs" >> Log.out
    cat out/star/${sid}/Log.final.out | \
    egrep "reads %|% of reads mapped to (multiple|too)" >> Log.out
    if [ "$?" -ne 0 ]
    then
        echo "Error in creating Log.out"
	exit 1
    fi
    echo >> Log.out
done
echo "Done"
echo

echo "-------- Pipeline finished at $(date +'%d %h %y, %r')... --------"
