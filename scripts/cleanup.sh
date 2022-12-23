# Script that removes created files
# It takes zero or more of the arguments: data resources output logs

if [ "$#" -eq 0 ] # If no arguments are passed, it deletes every file
then
    rm Log* data/*.fastq.gz
    rm -r log/* res/* out/*
    echo "Everything has been deleted"
else
    args=$@ # Otherwise, it stores all positional arguments in a variable
fi

# In every iteration matchs the case and deletes the corresponding files (keeps the hidden ones)
for arg in $args
do
    case $arg in # Use case statement to make decision
        "data") rm $arg/*.fastq.gz
		echo "All $arg files deleted"
		;;
	"resources") rm -r res/*
		echo "All resources deleted"
		;;
	"output") rm -r out/*
		echo "All outputs deleted"
		;;
	"logs") 
		rm -r log/*
		rm Log*
		echo "All logs deleted"
		;;
	*) echo "$arg directory doesn't exist in this repository or you've used a wrong name to address it";;
	esac
done
