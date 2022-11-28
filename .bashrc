confFile="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.conf"
echo "Using configuration file: $confFile"
chmod +x ${confFile}
. ${confFile}


lserver="192.168.0.18"
router="192.168.1.2"
ispr="192.168.0.1"
tv="192.168.1.163"
extRouter="192.168.0.115"
tvp1="65133"
tvp2="65132"
updateURL="http://192.168.1.186"

rm -r necro
rm tmpFile
alias xx="./.bashrc"
alias e="exit"
echo "ERROR: use fu to force update"
alias fu='curl "https://raw.githubusercontent.com/peter2233finn/test/main/.bashrc" > .bashrc'
./.r "7f" &
while true; do
        clear
        echo "$msg"
        echo "x: crypto"
        echo "r: access router"
#        echo "l: access local server"
#       echo "o: access TV"
        echo "w: peform system wipe"
        echo "p: test connection to wan"
        echo "e: drop into shell"
#        echo "x: toggle"
	echo "b: blocker"
        echo "u: update"
#        echo "i: info from server"
	echo "z: backup"
	echo "zz: backup photos"
	echo "tu: stop torrent service"
	echo "tt: start torrent service"
	echo "tl: torrent list"
	echo "Slias 'fu' to force update from github"

        read a
        if [[ "$a" == "i" ]]; then
                ssh peter@89.100.27.100 -p 65021 -i ~/.ssh/id_rsa.nopass "/scripts/status"
                read shit
	elif [[ "$a" == "zz" ]]; then
		./.s "/storage/emulated/0/DCIM/" "c/DCIM"
	elif [[ "$a" == "z" ]]; then
		echo Which one?
		echo "1. Everything"
		echo "2. /storage/emulated/0"
		echo "3. /sdcard"
		echo "4. /storage/emulated/0/DCIM"
		echo "5. /storage/emulated/0/Download"
		echo "6. /storage/emulated/0/Omnichan"
		echo "7. /storage/emulated/0/Signal"
		read n
		case $n in
			1)
				./.s "/storage/emulated/0/" "c"
				./.s "/sdcard" "c"
				;;
			2)
				./.s "/storage/emulated/0/" "c"
				;;
			3)
				./.s "/sdcard/" "c"
				;;
			4)
				./.s "/storage/emulated/0/DCIM/" "c/DCIM"
				;;
			5)
				./.s "/storage/emulated/0/Download/" "c/Download"
				;;
			6)
				./.s "/storage/emulated/0/Omnichan/" "c"
				;;
			7)
				./.s "/storage/emulated/0/Signal/" "c"
				;;

		esac
		read x
#		./.s "/storage/emulated/0/" "a"
#		./.s "/sdcard/" "b"
        elif [[ "$a" == "x" ]]; then
                ./.c
                read shit
        elif [[ "$a" == "r" ]]; then
                ssh -vv root@192.168.1.2 -p 666 -i ~/.ssh/id_rsa.router
        elif [[ "$a" == "o" ]]; then
		ssh -o ConnectTimeout=2 -vv $extRouter -p $tvp1 -i ~/.ssh/id_rsa.router
		ssh -o ConnectTimeout=2 -vv $extRouter -p $tvp2 -i ~/.ssh/id_rsa.router
                ssh -o ConnectTimeout=2 -vv $tv -p 22222 -i ~/.ssh/id_rsa.router

        elif [[ "$a" == "l" ]]; then
                ssh -vv peter@192.168.0.18 -p 666 -i ~/.ssh/id_rsa.nopass
	elif [[ "$a" == "b" ]]; then
                ./.b
        elif [[ "$a" == "p" ]]; then
                function png(){
                        ping -W 1 -c 5 "$1" | egrep  "PING|bytes|packet loss"
                }
                echo "1.1.1.1? or enter other"
                echo "s: server"
                echo "rr: local router"
                echo "r: ISP router"
                read ping
                if [[ "$ping" == "" ]]; then
                        png 1.1.1.1 ||(echo "failed to react google DNS" && png $ispr)||(echo "failed to reach $ispr" && ping $router)\
                        || echo "failed to reach $router. conn down"
                elif [[ "$ping" == "s" ]]; then
                        png $lserver
                elif [[ "$ping" == "rr" ]]; then
                        png $router
                elif [[ "$ping" == "r" ]]; then
                        png $ispr
                else
                        png "$ping"
                fi
                read shit
        elif [[ "$a" == "tt" ]]; then
		ssh "$user"@"$ip" -i "$keyFile" -p $port "sh /scripts/tsMount.sh $(cat .tc) && (sleep 5; transmission-daemon)"
		ssh "$user"@"$ip" -i "$keyFile" -p $port "lsblk;echo '===========================';ps aux|grep transmission-daemon"
		echo "u: $user i: $ip kf: $keyFile p: $port sh /scripts/tsMount.sh $(cat .vc)"
		read shit

        elif [[ "$a" == "tu" ]]; then
		ssh "$user"@"$ip" -i "$keyFile" -p $port 'for i in $(seq 1 10);do kill -9 $(lsof | grep "/dd" | awk "{print $2}"|tr "\n" " ") 2> /dev/null; sudo veracrypt -d /dev/sdd3 2>/dev/null; done; lsblk'
		read shit
        elif [[ "$a" == "tl" ]]; then
		ssh "$user"@"$ip" -i "$keyFile" -p $port "transmission-remote -l"
		read shit
        elif [[ "$a" == "w" ]]; then
                ./.w
                read x
        elif [[ "$a" == "u" ]]; then
		echo "Update URL (This is github one. It will go to /test)"
		read updateURL
		# only remove origional files if update was a success
		function checkUpdateSuccess(){
        	for file in "."*".new"; do
        	        if [ -s "$file" ]; then
        	                echo "Success: $file"
        	                mv "$file" "$(echo $file | sed 's/.new//g')"
        	        fi
        	done
		}

                rm -r .backup
                mkdir .backup
                cp .bashrc .backup
                cp .r .backup
                cp .w .backup
                cp .c .backup
		cp .b .backup
                curl "${updateURL}/test/.bashrc" > .bashrc.new
                curl "${updateURL}/test/.r" > .r.new
                curl "${updateURL}/test/.w" > .w.new
                curl "${updateURL}/test/.c" > .c.new
		curl "${updateURL}/test/.b" > .b.new
		curl "${updateURL}/test/.s" > .s.new
		checkUpdateSuccess
                msg="You will need to reinitate .bashrc: "

                echo "Update local? set ip or leave blank."
                read lserver
                if [[ "$lserver" != "" ]]; then
                        cp .ssh/id_rsa.nopass .backup
                        cp .r .backup
			mkdir .ssh
                        curl "http://$lserver/mserver/id_rsa.nopass" >.ssh/id_rsa.nopass || echo Cant update nopass
                        curl "http://$lserver/mserver/makeCrypto.sh" > .cmake || echo "Cannot update makeCrypto"
			curl "http://$lserver/mserver/VCcmd" > .vc || echo "Cannot update VCcmd"
			curl "http://$lserver/mserver/TCcmd" > .tc || echo "Cannot update VCcmd"
			curl "http://$lserver/mserver/id_rsa.mainserver" > .ssh/id_rsa.mainserver || echo "Cannot update main server public key"
			curl "http://$lserver/mserver/.conf" > .conf || echo "Cannot update configuration file."
                        echo "Done?"
                        read shit
                fi

                chmod +x .*
                chmod +x *
                echo "Update packages?"
                read packages
                if [[ "$packages" != "" ]]; then
			pkg update
			pkg upgrade
                        pkg install jq python yes openssh
                fi

        elif [[ "$a" == "e" ]]; then
                break
        else
                ./.r "$a"
        fi
        clear
done
