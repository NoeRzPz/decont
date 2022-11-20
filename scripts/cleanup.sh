# Script that removes created files
#It takes zero or more of the arguments: "data", "resources", "output", "logs"

if [ "$#" -eq 0 ] # If no arguments are passed, it deletes every file
then
	find data ~/decont -maxdepth 1 -type f ! \( -name urls -o -name .gitkeep -o -name .gitignore -o -name README.md \) -print
	find log out res -mindepth 1 ! -name .gitkeep -print
	echo "Everything has been deleted"
else
	# It stores all positional arguments (as separate strings) in a variable
	args=$@
fi

for arg in $args
do
	case $arg in # Use case statement to make decision
	"data") 
		find $arg -maxdepth 1 -type f ! \( -name urls -o -name .gitkeep \) -print
		echo "All $arg files deleted"
		;;
	"resources") find res -mindepth 1 ! -name .gitkeep -print
		echo "All resources deleted"
		;;
	"output") find out -mindepth 1 ! -name .gitkeep -print
		echo "All outputs deleted"
		;;
	"logs") 
		find log -mindepth 1 ! -name .gitkeep -print
		find ~/decont -maxdepth 1 -type f ! \( -name .gitignore -o -name README.md \) -print
		echo "All logs deleted"
		;;
	*) echo "$arg directory doesn't exist in this repository";;
	esac
done
