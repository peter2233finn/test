confFile="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.conf"
echo "Using configuration file: $confFile"
chmod +x ${confFile}
. ${confFile}

remoteSync="/ee/phone/${2}/"

echo "finding correct folder..."
ssh "$user"@"$ip" -i "$keyFile" -p $port "sh /scripts/phoneBackup.sh $(cat .vc)"
#Break=$(ssh "$user"@"$ip" -i "$keyFile" -p $port "lsblk|grep '/ff'" || exit)

ssh "$user"@"$ip" -i "$keyFile" -p $port "lsblk"

echo Continue?
read shit
if [[ "$shit" != *"y"* ]]; then
	ssh "$user"@"$ip" -i "$keyFile" -p $port "sh /scripts/phoneBackupEnd.sh" &
	exit
fi
function cleanFiles(){
	rm .tmpLocalFile .tmpRemoteFile .toCreateDirTree .toCreateDirTree2 .toCreateDirTreeFinal
	clear
}
function progress(){
        printf "\r"
        echo -n "$1 out of $2 files processed."
}
clear
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 1; done
  return 0
}

# unset IFS in case it's at weird value.
unset IFS


echo "Gathering list of directories for both the local device..."
p=1; total="???"
cleanFiles

# Add the local directory tree to .tmpLocalFile file
find $localSync -type f| sed "s/$(echo $localSync|sed 's/\//\\\//g')//g" | while read f; do
	echo "$f" >> .tmpLocalFile
	progress $p $total
	((p++))
done

# Load this file into an array called localFile
localFile=()
while read i; do
	localFile+=("$i")
done < .tmpLocalFile
rm .tmpLocalFile
echo ".. Done!"

# Get the remote directory tree and put them into the file: .tmpRemoteFile
echo "Gathering the remote file structure..."
(ssh -p "$port" "$user"@"$ip" -i "$keyFile" "find $remoteSync -type f" > .tmpRemoteFile || (echo "SSH Connection failed."; exit 5))

# local the remote directory tree into array called remoteFile
remoteFile=()
while read i; do
	remoteFile+=( $(echo "$i" | sed "s/$(echo $remoteSync|sed 's/\//\\\//g')//g"))
done < .tmpRemoteFile
rm .tmpRemoteFile
echo "Done!"


# Find what is in the localFile and NOT in remoteFile
# Loca the differances into array called toSync
# reverse this process for oppsite sync
toSync=()
echo "Checking which files need to be uploaded..."
p=1; total=${#localFile[@]}
for l in "${localFile[@]}"; do
	progress $p $total
	if $(containsElement "$l" "${remoteFile[@]}") ; then
		toSync+=("$l")
	fi
	((p++))
done
echo "Done!"

# peform calculations to create directories that may not exist
# Remove the last value after the final /
# Place into file called .toCreateDirTree
# remove duplicates from .toCreateDirTree and put into file .toCreateDirTree2
echo "Creating the directory structure..."
pathStr=""
createDir=()
p=1; total=${#toSync[@]}

for i in "${toSync[@]}"; do
	echo "${remoteSync}${i}"|awk 'NF{NF-=1}1' FS='/' OFS='/' >> .toCreateDirTree
	((p++))
done
cat .toCreateDirTree |sort|uniq > .toCreateDirTree2



# Create directories
# plade a ' around each name to avoid problems with spaces ect
while read x; do printf "\'$x\' " >> .toCreateDirTreeFinal; done < .toCreateDirTree2
ssh -p "$port" "$user"@"$ip" -i "$keyFile" "mkdir -p $(cat .toCreateDirTreeFinal)" 2> /dev/null
echo "Done!"

# Start syncing the files using SCP
echo "Syncing ${#toSync[@]} files..."
p=1; total=${#toSync[@]}
for x in "${toSync[@]}"; do
	ldir="$(echo ${localSync}${x}|sed 's/\/ /\//g'|sed 's/\/\//\//g' )"
	rdir=$(echo "${remoteSync}${x}"|awk 'NF{NF-=1}1' FS='/' OFS='/'|sed 's/\/ /\//g'|sed 's/\/\//\//g')
#	echo "local: $ldir renote: $rdir" 
	rdir+="/"
progress $p $total
	scp -P "$port" -i "$keyFile" "$ldir" "$user"@"$ip":"$rdir" #2> /dev/null > /dev/null
	((p++))
done
echo "All Done!"
read shit
ssh "$user"@"$ip" -i "$keyFile" -p $port "sh /scripts/phoneBackupEnd.sh" &
# clean up the remaining files.
cleanFiles
