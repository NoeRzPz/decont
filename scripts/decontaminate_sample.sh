#Variable definition
sampleid=$1

echo "Running cutadapt..."
mkdir -p out/trimmed
mkdir -p log/cutadapt
cutadapt \
    -m 18 \
    -a TGGAATTCTCGGGTGCCAAGG \
    --discard-untrimmed \
    -o out/trimmed/${sampleid}.trimmed.fastq.gz out/merged/${sampleid}.fastq.gz \
    > log/cutadapt/${sampleid}.log
echo

echo "Running STAR alignment..."
mkdir -p out/star/${sampleid}
STAR \
    --runThreadN 4 \
    --genomeDir res/contaminants_idx \
    --outReadsUnmapped Fastx  \
    --readFilesIn out/trimmed/${sampleid}.trimmed.fastq.gz \
    --readFilesCommand gunzip -c  \
    --outFileNamePrefix out/star/${sampleid}/
echo

echo "Creating log file..."
echo "${sampleid}" >> Log.out
cat log/cutadapt/${sampleid}.log | egrep "Reads with |Total basepairs" >> Log.out
cat out/star/${sampleid}/Log.final.out | egrep "reads %|% of reads mapped to (multiple|too)"  >> Log.out
echo >> Log.out
echo
