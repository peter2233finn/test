rm -r necro
rm tmpFile
alias xx="./.bashrc"
alias e="exit"
echo "ERROR: use fu to force update"
alias fu="curl "https://raw.githubusercontent.com/peter2233finn/test/main/.bashrc" > .bashrc"
while true; do
        clear
        echo "$msg"
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
        elif [[ "$a" == "r" ]]; then
                ssh -vv root@192.168.1.2 -p 666 -i ~/.ssh/id_rsa.router
        elif [[ "$a" == "l" ]]; then
                ssh -vv peter@192.168.0.18 -p 666 -i ~/.ssh/id_rsa.nopass
        elif [[ "$a" == "t" ]]; then
                echo "8.8.8.8? or enter other"
                read ping
                if [[ "$ping" == "" ]]; then
                        ping -c 5 8.8.8.8
                else
                        ping -c 5 "$ping"
                fi
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
                msg="You will need to reinitate .bashrc: " 
                chmod +x .*
                chmod +x *
        elif [[ "$a" == "e" ]]; then
                break
        else
                ./.r "$a"
        fi
        clear
done
