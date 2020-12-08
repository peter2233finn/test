rm -r necro
rm tmpFile
alias xx="./.bashrc"
alias e="exit"
while true; do
        clear
        echo "r: to access router"
        echo "p: to access pi server"
        echo "w: peform system wipe"
        echo "e: drop into shell"
        read a
        if [[ "$a" == "p" ]]; then
                ssh -vv peter@89.100.27.100 -p 21 -i ~/.ssh/id_rsa.nopass
        elif [[ "$a" == "r" ]]; then
                ssh -vv root@192.168.1.2 -p 666 -i ~/.ssh/id_rsa.router
        elif [[ "$a" == "w" ]]; then
                ./wipe.sh
        elif [[ "$a" == "e" ]]; then
                break
        else
                ./.r "$a"
        fi
        read x
        clear
done
