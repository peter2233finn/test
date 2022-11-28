#confFile="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.conf"
#echo "Using configuration file: $confFile"
#chmod +x ${confFile}
#. ${confFile}

printf "Starting wipe\n"
ctr=0
offSet=0
while (( ctr != wipeRuns ))
do
	# creates the temporary file
	offCtr=0
	for i in {0..$wipes}
		do
		printf "Creating tmp file.\n"
		# do a charecter offset so it doesnt wipe over itself identically
		while (( offSet > offCtr ))
		do
			printf "A" >> $wipeFile
			((offCtr++))
		done

		# create tempoary block
		for i in $(seq 1 $blockSize)
		do
			printf "$wipeStr" >> tmpFile
		done
	done

	((ctr++))
	offCtr=0
	((offSet++))
	errorCtr=0

	# create the folder
	mkdir $wipeFolder
	printf "Folder $wipeFolder created.\n"
	printf "Starting wipe now.\n"
	fileCtr=0
	while (( errorCtr < 20 ))
	do
    		# Will copy the file until 20 errors accor (Assumption is that memory is full)
		cp tmpFile $wipeFolder/$wipeFile.$fileCtr || (( errorCtr++))
		((fileCtr++))
		sleep $rest
		printf "Wipe number: $ctr/$wipeRuns file: $fileCtr created\n"
	done
	printf "Not enough memory to create any more files. Will fill up the remaining space/n"
	while true
	do
		printf $wipeStr >> $wipeFolder/$wipeFile || break

	done
	echo "Completed first round."
	echo "Setting block to 1/100th the origional size"
	printf "$wipeStr" > tmpFile
	for i in $(seq 1 $(($blockSize/100)))
	do
		printf "$wipeStr" >> tmpFile
	done

	echo "Done. Starting the remaining filler wipe"
	errorCtr=0
	while (( errorCtr < 20 ))
	do
    		# Will copy the file until 20 errors accor (Assumption is that memory is full)
		cp tmpFile $wipeFolder/$wipeFile.$fileCtr.filler || (( errorCtr++))
		((fileCtr++))
		sleep $rest
		printf "Wipe filler number: $ctr/$wipeRuns file: $fileCtr created\n"
	done
	rm $wipeFile
	rm -r $wipeFolder
	rm tmpFile
	printf "completed wipe: $ctr/$wipeRuns \n"
done
printf "All done\n"
