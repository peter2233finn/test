#clear
tmp1="dhcpHosts"
tmp2="actionHost"
tmp3="allMacs"
function rexe(){
	ssh root@192.168.1.2 -p 666 -i ~/.ssh/id_rsa.router "$*"

}

function selectHost(){
	rexe "cat /tmp/dnsmasq.leases" > $tmp1
	while read i; do
	        array[$x]="$i"
	        echo "$x:/ $i"|awk 'BEGIN { FS="/"} ; {print $1 " " $NF}'
	        ((x++))
	done <<< $(cat $tmp1)
	echo Play which one?
	read n
	echo "${array[$n]}"|awk '{print $2}' > $tmp2
}

#rexe "cat /tmp/dnsmasq.leases |awk '{print $NF\" \"$3\" \"$4}'"


function blockHost(){
	selectHost
	cat $tmp2
	rexe "iptables -A macblock -m mac --mac-source $(cat $tmp2) -j DROP; "

}

function clearAll(){
	rexe 'cat /tmp/dnsmasq.leases'| awk '{print $2}' > $tmp3
	cmdstr=""
	while read m; do
		 cmdstr+="iptables -A macblock -m mac --mac-source $m -j ACCEPT; "
	done < "$tmp3"
	cmdstr+="iptables -F macblock; iptables -X macblock"
	rexe $cmdstr

}

function exeBlock(){
	rexe "iptables -A macblock -j RETURN; \
		iptables -I FORWARD 1 -j macblock; \
		iptables -I INPUT 1 -j macblock;"
	echo "iptables -A macblock -j RETURN; \
		iptables -I FORWARD 1 -j macblock; \
		iptables -I INPUT 1 -j macblock;"


}

while true; do
        clear
        echo "Blocker active. Query"
        echo "b: Block"
        echo "c: Clear"
        echo "a: Execute"
        read opt
        case "$opt" in
                c)
			clearAll
                        ;;
                b)
			blockHost
                        ;;
                a)
			exeBlock
                        ;;         
                e)
      break
                        ;;
        esac
done
