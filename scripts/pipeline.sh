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
for sid in $(ls data/*fastq.gz | xargs basename -a | cut -d"." -f1-3 | sort -u) #TODO
do
    echo "Merging sample $sid files..."
    bash scripts/merge_fastqs.sh data out/merged $sid
    echo "Done"
    echo
done


for fname in out/trimmed/*.fastq.gz
do
    bash scripts/decontaminate_sample.sh # TODO: run cutadapt for all merged files # TODO: run STAR for all trimmed files
done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
