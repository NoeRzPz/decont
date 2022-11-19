#Download all the files specified in data/filenames
for url in $(cat data/urls) #TODO
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear"#TODO

# Index the contaminants file
echo "Running STAR index..."
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
echo

# Merge the samples into a single file
for sid in $(ls data/*fastq.gz | xargs basename -a | cut -d"-" -f1 | sort -u) #TODO
do
    echo "Merging sample $sid files..."
    bash scripts/merge_fastqs.sh data out/merged $sid
    echo "Done"
    echo
done

# run cutadapt for all merged files and STAR for all trimmed files
# create a single log file containing information from cutadapt and star logs
echo "Starting sample decontamination..."
echo
for fname in out/merged/*.fastq.gz
do
    sid=$(basename $fname .fastq.gz)
    echo "Decontaminating sample $sid..."
    bash scripts/decontaminate_sample.sh $sid
    echo "Done"
    echo 
done 

