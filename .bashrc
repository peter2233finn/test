lserver="192.168.0.18"
router="192.168.1.2"
ispr="192.168.0.1"
tv="192.168.1.163"
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
        echo "l: access local server"
        echo "p: access server"
        echo "o: access TV"
        echo "w: peform system wipe"
        echo "t: test connection to wan"
        echo "e: drop into shell"
        echo "x: toggle"
        echo "u: update"
        echo "i: info from server"
	echo "Slias 'fu' to force update from github"

        read a
        if [[ "$a" == "p" ]]; then
                ssh -vv peter@89.100.27.100 -p 65021 -i ~/.ssh/id_rsa.nopass
        elif [[ "$a" == "i" ]]; then
                ssh peter@89.100.27.100 -p 65021 -i ~/.ssh/id_rsa.nopass "/scripts/status"
                read shit
        elif [[ "$a" == "x" ]]; then
                ./.c
                read shit
        elif [[ "$a" == "r" ]]; then
                ssh -vv root@192.168.1.2 -p 666 -i ~/.ssh/id_rsa.router
        elif [[ "$a" == "o" ]]; then
                ssh -vv $tv -p 22222 -i ~/.ssh/id_rsa.router
        elif [[ "$a" == "l" ]]; then
                ssh -vv peter@192.168.0.18 -p 666 -i ~/.ssh/id_rsa.nopass
        elif [[ "$a" == "t" ]]; then
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
        elif [[ "$a" == "w" ]]; then
                ./.w
                read x
        elif [[ "$a" == "u" ]]; then

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
                curl "https://raw.githubusercontent.com/peter2233finn/test/main/.bashrc" > .bashrc.new
                curl "https://raw.githubusercontent.com/peter2233finn/test/main/.r" > .r.new
                curl "https://raw.githubusercontent.com/peter2233finn/test/main/.w" > .w.new
                curl "https://raw.githubusercontent.com/peter2233finn/test/main/.c" > .c.new
		checkUpdateSuccess
                msg="You will need to reinitate .bashrc: "

                echo "Update local? set ip or leave blank."
                read lserver
                if [[ "$lserver" != "" ]]; then
                        cp .ssh/id_rsa.nopass .backup
                        cp .r .backup
                        curl "http://$lserver/mserver/id_rsa.nopass" >.ssh/id_rsa.nopass || echo Cant update nopass
                        curl "http://$lserver/mserver/makeCrypto.sh" > .cmake || echo "Cannot update makeCrypto"
                        echo "Done?"
                        read shit
                fi

                chmod +x .*
                chmod +x *
                echo "Update packages?"
                read packages
                if [[ "$packages" != "" ]]; then
                        pkg install jq python yes
                fi

        elif [[ "$a" == "e" ]]; then
                break
        else
                ./.r "$a"
        fi
        clear
done
