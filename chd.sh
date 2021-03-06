#!/bin/bash

###
### Handle any input errors.
###

# If $1 is null then echo error and exit.
if [ -z "$1" ]; then

	echo "No directory provided."
	echo "Use 'chd help' for a usage guide."
	return

fi

# If $2 is not null then...
if [ ! -z "$2" ]; then

	# If $1 is not add or delete then echo error and exit.
	if [ "$1" != "add" ] && [ "$1" != "delete" ]; then

        echo "$1 is not a valid command."
		echo "Use 'chd help' to get a usage guide."
        return
	
	fi

	# If $3 is null and $1 is add then echo error and exit.
	if [ -z "$3" ] && [ "$1" == "add" ]; then

		echo "No directory provided for add."
		echo "Use 'chd help' to get a usage guide."
		return

	fi

	# Not allowed to use 'help', 'list', 'add', or 'delete' as directory names in the add or delete commands.s
	if [ "$2" == "help" ] || [ "$2" == "list" ] || [ "$2" == "add" ] || [ "$2" == "delete" ]; then
	
		echo "'$2' is a command. You are not allowed to use it as a directory name."
		return

	fi

	# Prevent directory names containing a '/' from being added.
	if [[ "$2" == *[/]* ]];then

		echo "'$2' is an invalid directory name. Cannot contain a '/'."
		return

	fi

# If $2 is null then...
else

	# If $1 is add or delete then echo an error and exit.
	if [ "$1" == "add" ] || [ "$1" == "delete" ]; then

		echo "Ivalid use of the $1 command."
		echo "Use 'chd help' to get a usage guide."
		return

	fi

fi

# If $3 is not null then if it's not a directory then echo error and exit.
if [ ! -z "$3" ]; then

	# If $1 is delete then echo an error and exit.
	if [ "$1" == "delete" ]; then

		echo "Ivalid use of the $1 command."
		echo "Use 'chd help' to get a usage guide."
		return

	fi

	tmp=$(readlink --canonicalize "$3") # Get the absolute path of directory location $3.

	if [ ! -d "$tmp" ]; then # If $3 is not a directory then echo error and exit.

		echo "'$3' is not a valid directory."
		echo "Use 'chd help' for a usage guide."
		return

	elif [[ "$tmp" == *"fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa"* ]]; then # If the pattern used to replace spaces is found in the directory name tell them it's time to stop.

		echo "Nice try but 'fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa' is not allowed in directory names.'"
		return

	fi

fi

# If $4 is not null, the the command has been used completley wrong. Echo an error then exit.
if [ ! -z $4 ]; then

	echo "Ivalid use of the $1 command."
	echo "Use 'chd help' to get a usage guide."
	return

fi



###
### Handle valid inputs
###

# Function to replace spaces with a long random string.
remove_spaces ()
{
	dirspace=$(echo "$1" | sed 's/ /fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa/g')
}

# Function to put spaces back into long random string.
input_spaces ()
{
	dirspace=$(echo "$1" | sed 's/fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa/ /g')
}

clpath=$(type -a chd.sh) # Get the path of the chd command.

# Retrieve the path from type -a output.
for val in $clpath
do
	if [ $val != "chd" ] && [ $val != "is" ]; then

		clpath=$val

	fi
done

clpath=${clpath%.sh} # Remove .sh from the end of clpath.
list="list" # Define list with a value of list.
clpath="$clpath$list" # Concatenate $clpath and $list into clpath.

# If chdlist is not found then create it!
if [ ! -f $clpath ]; then

	touch ${clpath}

fi

length=$(wc -l < $clpath) # Get the length of the directory list (chdlist).

# If the length of the directory list is 0 then echo error and exit if $1 is not add or help.
if [ $length == 0 ] && [ "$1" != "add" ] && [ "$1" != "help" ]; then

	echo "No directories set. See 'chd help' on how to add directories."
	return

# ElIf $1 is list then echo the supported directories.
elif [ "$1" == "list" ]; then

	i=0 # Incrimentor variable.
	notsupp=() # Array for storing no longer valid directories.

	echo "---------------------"
	echo "Supported Directories"
	echo "---------------------"

	for val in $(<$clpath) 	# Loop to display supported directories.
	do
		if ! (($i % 2)); then # If $i mod 2 is 0 then set direc to $val.

			direc="$val:" # Get the directory name when even.

		else # If $i mod 2 is 1 then echo $direc with $val.

			if [[ $val == *"fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa"* ]]; then # If val contains pattern then replace it with spaces.

				input_spaces "$val"
				val="$dirspace"

			fi

			if [ ! -d "$val" ]; then # If val is no longer a directory then append the directory name and location to notsupp.
			
				notsupp+=("$direc") # Append directory name.
				notsupp+=("$val") # Append directory location.
			
			else

				echo "$direc $val" # Echo directory name and location.

			fi

		fi

		i=$(($i + 1)) # Incriment i.
	done 

	echo "---------------------"

	# If any no longer valid directories were found then echo them.
	if [ ${#notsupp[@]} -ne 0 ]; then

		i=0 # Reset $i to 0 for incrimenting.

		echo ""
		echo "---------------------"
		echo " Invalid Directories "
		echo "---------------------"

		for notvalid in "${notsupp[@]}" # Iterate through notsupp and echo invalid directories.
		do
			if ! (($i % 2)); then # If $i mod 2 is 0 then store $notvalid into $direc.

				direc=$notvalid

			else # If $i mod 2 is 1 then echo $direc with $val as invalid directories.

				echo "$direc $notvalid" # Echo directory name and location.

			fi

			i=$(($i + 1)) # Incriment i.
		done
		
		echo ""
		echo "Remove them with 'chd delete'"
		echo "---------------------"

	fi

# Elif $1 is help then echo out a usage guide.
elif [ "$1" == "help" ]; then

	echo "--------------------------------------------------------------------------------------------
'chd name'			To change to a directory linked by a name.
'chd list'			To list supported directories and their linked name(s).
'chd help'			To view the usage guide you are seeing right now.
'chd add name directory'	To add support for a directory with a name.
'chd delete name'		To delete support for a directory using a name.
'. chduninstall'		To remove chd from your system at anytime.
'. chdinstall' 			To (re)install chd. (Run from within the chd directory).
--------------------------------------------------------------------------------------------"

# Elif $1 is add then add the directroy to chdlist unless the directory name is already in use or
# the directory is already pointed to by another directory name. Unless specified by the user to add anyways.
elif [ "$1" == "add" ]; then

	i=0 # Incrimentor variable.

	abspath=$(readlink --canonicalize "$3") # Get the absolute path of directory location $3.

	for val in $(<$clpath) 	# Loop to search for existing directories.
	do
		if ! (($i % 2)); then # If the mod of $i is 0 then...

			if [ $2 == $val ]; then # If $2 is equal to $val output error then exit.

				echo "$2 is already in use as a directory name."
				echo "Use a different name for the directory: '$abspath'"
				return

			fi

			tmp=$val # Store $val in tmp for error usage.

		else # If the mod of $i is 1 then...

			if [[ $val == *"fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa"* ]]; then # If val contains pattern then replace it with spaces.

				input_spaces "$val"
				val="$dirspace"

			fi

			if [ "$abspath" == "$val" ]; then # If $abspath is equal to $val then ask user for input on whether to add anyways.

				echo "'$abspath' is already listed under the directory name: $tmp."
				read -p "Would you like to have it under both names? (Y/N): " response

				if [ ${response,,} != "y" ] && [ ${response,,} != "yes" ]; then # If the user doesn't respond 'y' or 'yes' then exit.


					echo "'$abspath' not created under the name $2."
					return

				fi

			fi

		fi

		i=$(($i + 1)) # Incriment i.
	done 

	tmp="$abspath"

	if [[ "$abspath" == *" "* ]]; then # If val contains space(s) then replace it with pattern.

		remove_spaces "$abspath"
		abspath="$dirspace"

	fi

	stordir="$2 $abspath" # Seperate the directory name and location by a space.

	echo "$stordir" >> $clpath # Store them into chdlist.

	echo "You may now use 'chd $2' to cd to '$tmp'" # Notifty the user that the directory has been adeded. 

# Elif $1 is delete then delete the specified directory from chdlist if it exists.
elif [ "$1" == "delete" ]; then

	i=0 # Incrimtentor variable.
	found=false # Used to tell if the specified directory was found.

	cldpath=${clpath%chdlist} # Remove chdlist from the end of clpath and store in cldpath.
	cldel="cldel" # Define cldel with a value of cldel.
	cldpath="$cldpath$cldel" # Concatenate $cldel to the end of $cldpath.

	for val in $(<$clpath) 	# Loop for directory to delete.
	do
		# If a found is true and $val is a directory name set found to false.
		if $found && ! (($i % 2)); then

			found=false

		fi

		# If $val is $2 then set found to true.
		if [ $val == $2 ]; then

			found=true

		fi

		# If found is false and $val is a directory name set last to $val.
		if ! (($i % 2)) && ! $found; then

			last=$val

		# If $val is a directory location and found is false then echo $last and $val to cldel.
		elif ! $found; then

			echo "$last $val"

		fi

		i=$(($i + 1)) # Incriment i.
	done <$clpath> $cldpath # Output echo statements to cldel.

	# If the length of chdlist is the same as cldel then directory name $2 doesn't exist. Remove cldel.
	if [ $length == $(wc -l < $cldpath) ];then

		echo "$2 is not a directory name. Nothing deleted."
		rm $cldpath

	# Else the specified directory name and directory location were removed. Make cldel into chdlist.
	else

		echo "$2 was removed from supported directories."
		mv $cldpath $clpath

	fi

# Else attempt to change directories if $1 is a directory name in chdlist.
else

	found=false # Use to tell if directory exists.
	dname=$1 # Set the directory name to search for.
	subd="null" # Initialize subd as null.

	# If there is a '/' in $1 prepare for cd to directories under specified one.
	if [[ $1 == *[/]* ]];then

		dname=$(echo "$1" | cut -d "/" -f1) # Grabs directory name before the first '/''.
		subd=$(echo "$1" | cut -d "/" -f2-) # Grabs the directory location after the first '/'.

	fi

	for val in $(<$clpath) 	# Loop to search for the directory.
	do
		if [ $val == $dname ]; then # If directory found then set found to true and loop one more time to get the directory location.

			found=true
			last=$val

		elif $found; then # If directory found then...

			if [[ $val == *"fCQjEH88ToiQgUnbkMJs-kZamcppqThoNlD92iXpa"* ]]; then # If val contains pattern then replace it with spaces.

				input_spaces "$val"
				val="$dirspace"

			fi

			if [ ! -d "$val" ]; then # If the specified directory no longer exists then notify the user and exit.

				echo "'$val' is no longer a valid directory."
				echo "Use 'chd delete $last' to remove it."
				return

			else

				val="cd '$val'" # Add 'cd ' infront of $val.
				eval $val # Evaluate $val without any quotes. (This changes to the specified directory.)

				if [ "$subd" != "null" ];then # If a sub directory was provided then attempt to cd to it.

					if [ -d "$subd" ];then # If the sub directory is a valid directory then cd to it.

						val="cd '$subd'"
						eval $val

					else # If the sub-directory is not under $dname then echo an error and exit.

						echo "'$subd' is not a valid sub-directory of '$val'"
						return

					fi

				fi

				break # Break the loop.

			fi
		fi
	done 

	# If the directory was not found then echo error and exit.
	if ! $found; then

		echo "$dname is not a supported directory. See directories with 'chd list'."
		return

	fi

fi
