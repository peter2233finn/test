ip="192.168.0.33"
portDir="64338"

function switch(){
# This lets you toggle the relays.
	        ip="192.168.0.33"
	        portDir="64338"
	function numFormat(){
		if [[ $1 -le 9 ]]; then
		#       echo less than 10
		        q="0$1"
		else
		#       echo more than 10
		        q="$1"
		fi
		echo "$q"
	}

	function state() {
	        x=()
	        ddd=$(numFormat $1)
	        for i in {1..4};do
        x+=$(curl --silent http://$ip/$portDir/43 |sed 's/ <font color="#FF0000">//g'|sed 's/&nbsp&nbsp<\/font>//g'|grep -oh "Relay-......."|sed 's/<fo/ON/g'| grep -v Relay-ALL| grep "$(numFormat $1)") 2> /dev/null > /dev/null
	        done
	        echo $x
	}


	yyy=$(state "$1")
	r=$(($1*2))
	r=$((r-1))

	if [[ $yyy == *"OFF"* ]]; then
	        fq=$(numFormat $r)
	        echo "CURRENT STATE IS ON"
	        curl "http://192.168.0.33/64338/$fq" > /dev/null 2> /dev/null
	else
	        fq=$(numFormat $((r-1)) )
	        echo "CURRENT STATE IS OFF"
	        curl "http://192.168.0.33/64338/$fq" > /dev/null 2> /dev/null
	fi
	kill -9 $(ps aux | grep curl| grep "$ip"| tr "\n" " ") 2> /dev/null > /dev/null
}

function compileMode(){
clear

echo "Compile mode:"
echo "s     = sleep WORKING"
echo "n o/f = turn on/off"
echo "e     = execute WORKING"
echo "c     = cancel WORKING"
function vsleep(){
	function wait(){
	i=0
	while [[ $i -le $1 ]]; do
	#for i in {0..$1}; do
	        printf "$i out of $1 sec"
	        sleep 1
	        printf "\r                          \r"
	        ((i+=1))
	done
	}

	if [[ "$1" == *"m" ]]; then
	        wait $((${1::-1}*60))
	elif [[ "$1" == *"h" ]]; then
	        wait $((${1::-1}*60*60))
	else
	        wait $1
	fi
}

function execute(){
        clear
        printf "Executing:\n\n"
        IFS=',' read -r -a cmdArr <<< "$*"
        x=1

        for i in ${cmdArr[@]}; do
                echo "$x $i" | tr "-" " " | sed 's/doAction/Set/g'
                ((x++))
        done

        x=0
        printf "Completed:\n"

        for i in ${cmdArr[@]}; do
                printf "\r                        \r"
                cmd=$(echo "$i" | tr "-" " ")
                $cmd
                ((x++))
                printf "Step: $x\n"
        done
        printf "\n"
}

function preCompile(){
        execute $(echo "$@"|tr "-" " "|tr "," ";" | sed 's/do;/do /g'|sh |tr " " "-"|tr "\n" ",")
}

comp=""
while true; do
        read zzz

        # cancel
        if [[ "$zzz" == "c" ]]; then
                break
        elif [[ "$zzz" == "ef" ]]; then
                comp=$comp"done,"
        elif [[ "$zzz" == "f"* ]]; then
                loops=${zzz#?}
                comp=$comp"for-i-in-{1..$loops};-do,"
        elif [[ "$zzz" == "e" ]]; then
                preCompile "$comp"
                comp=""
                break

# this will execute during sleep due to number
        elif [[ $zzz =~ [0-9] ]] && [[ "$zzz" != "s"* ]]; then
                comp=$comp"echo-doAction-$zzz,"
        elif [[ "$zzz" == "s"* ]]; then
                comp=$comp"echo-vsleep-${zzz:1},"
        fi
done
}

	function activeSwitcher(){
	clear
	while true;do
		echo "e to exit"
		echo "Press Enter toggle"
		date +%R
		read q
		if [[ "$q" == "e" ]]; then
			break
		else
			clear
			switch  $1
		fi
	done
	exit
	}

function doAction() {
rrr=$1

# add 0 for on, 1 for off
# Also -1 because it starts at 0
lastChar="${rrr: -1}"
number="${rrr: : -1}"
relayNum="${rrr: : -1}"
number=$((number-1))

# Multiply by 2 because each relay needs two numbers
# too turn on and off

number=$((number*2))

#echo "Num $number"
#echo "lchar $lastChar"



if [[ "$lastChar" == "o" ]];then
#       echo "Relay on"
        number=$((number+1))

elif [[ "$lastChar" == "f" ]];then
        number=$number
#       echo "Relay off"
elif [[ "$lastChar" == "y" ]]; then
	activeSwitcher $relayNum
elif [[ "$rrr" == "x" ]]; then
	echo "Toggle mode. Relay num?"
	read rnum
	while [[ "$shit" != "e" ]]; do
		if [[ "$shit" == "" ]]; then	
			switch  $rnum
		fi
		read shit
	done
	
elif [[ "$lastChar" == "x" ]]; then
	switch  $relayNum
	exit
elif [[ "$rrr" == "c" ]];then
        compileMode
elif [[ "$rrr" == "ss" ]];then
        function showStatus() {
                for i in {1..4};do
                        curl --silent http://$ip/$portDir/43 |sed 's/ <font color="#FF0000">//g'|sed 's/&nbsp&nbsp<\/font>//g'|grep -oh "Relay-......."|sed 's/<fo/ON/g'| grep -v Relay-ALL
                done
        }
        showStatus | sort
	read shit
else
        echo "Error"
	exit
fi

#echo "finel num is: $number"

# Get length of string. add a 0 of it on less than 10
if [[ $(echo "$number" | wc -m) == "2" ]]; then
#       echo "Adding 0 as single digit"
        number="0"$number
fi

#echo "$ip/30000/$number"
curl "$ip/$portDir/$number" 2> /dev/null 1> /dev/null

}

if [[ "$*" == "a" ]];then

echo all XX
        for i in {1..16}; do
        # skip 1,9
        doAction "$i""$2"
        done

else
        # parse and do actions
        for i in "$@" ; do
                doAction $i
        done
fi
