rm -r necro
rm tmpFile
alias xx="./.bashrc"
alias e="exit"
while true; do
        clear
        echo "$msg"
        echo " "
        echo "r: to access router"
        echo "p: to access server"
        echo "l: local access to server"
        echo "w: peform system wipe"
        echo "e: drop into shell"
        echo "x: toggle"
        echo "u: update"
        echo "i: info from server"
        
        read a
        if [[ "$a" == "p" ]]; then
                ssh -vv peter@89.100.27.100 -p 21 -i ~/.ssh/id_rsa.nopass
        if [[ "$a" == "i" ]]; then
                ssh peter@89.100.27.100 -p 21 -i ~/.ssh/id_rsa.nopass "/scripts/status"
        elif [[ "$a" == "r" ]]; then
                ssh -vv root@192.168.1.2 -p 666 -i ~/.ssh/id_rsa.router
        elif [[ "$a" == "l" ]]; then
                ssh -vv peter@192.168.0.18 -p 666 -i ~/.ssh/id_rsa.nopass
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
