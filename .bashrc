lserver="192.168.0.18"
router="192.168.1.2"
ispr="192.168.0.1"
rm -r necro
rm tmpFile
alias xx="./.bashrc"
alias e="exit"
echo "ERROR: use fu to force update"
alias fu="curl "https://raw.githubusercontent.com/peter2233finn/test/main/.bashrc" > .bashrc"
while true; do
        clear
        echo "$msg"
        echo "c: crypto"
        echo "r: to access router"
        echo "p: to access server"
        echo "l: local access to server"
        echo "w: peform system wipe"
        echo "t: test connection to wan"
        echo "e: drop into shell"
        echo "x: toggle"
        echo "u: update"
        echo "i: info from server"

        read a
        if [[ "$a" == "p" ]]; then
                ssh -vv peter@89.100.27.100 -p 21 -i ~/.ssh/id_rsa.nopass
        elif [[ "$a" == "i" ]]; then
                ssh peter@89.100.27.100 -p 21 -i ~/.ssh/id_rsa.nopass "/scripts/status"
                read shit
        elif [[ "$a" == "c" ]]; then
		./.c
        elif [[ "$a" == "r" ]]; then
                ssh -vv root@192.168.1.2 -p 666 -i ~/.ssh/id_rsa.router
        elif [[ "$a" == "l" ]]; then
                ssh -vv peter@192.168.0.18 -p 666 -i ~/.ssh/id_rsa.nopass
        elif [[ "$a" == "t" ]]; then
                function png(){
                        ping -W 1 -c 5 "$1" | egrep  "PING|bytes|packet loss"
                }
                echo "8.8.8.8? or enter other"
                echo "s: server"
                echo "rr: local router"
                echo "r: ISP router"
                read ping
                if [[ "$ping" == "" ]]; then
                        png 8.8.8.8 ||(echo "failed to react google DNS" && png $ispr)||(echo "failed to reach $ispr" && ping $router)\
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
                mkdir .backup
                yes|mv * .backup
                yes|mv .* .backup
                cp -r .backup/.ssh .
                curl "https://raw.githubusercontent.com/peter2233finn/test/main/.bashrc" > .bashrc
                curl "https://raw.githubusercontent.com/peter2233finn/test/main/.r" > .r
                curl "https://raw.githubusercontent.com/peter2233finn/test/main/.w" > .w
                curl "https://raw.githubusercontent.com/peter2233finn/test/main/.c" > .c
                msg="You will need to reinitate .bashrc: "

		echo "Update local? set ip or leave blank."
		read lserver
		if [[ "$lserver" != "" ]]; then
		        curl "http://$lserver/mserver/id_rsa.nopass">.ssh/id_rsa.nopass || echo Cant update nopass
		        curl "http://$lserver/mserver/makeCrypto.sh" >> .c || echo "Cannot update makeCrypto"
			echo "Done?"
			read shit
		fi

                chmod +x .*
                chmod +x *

        elif [[ "$a" == "e" ]]; then
                break
        else
                ./.r "$a"
        fi
        clear
done
