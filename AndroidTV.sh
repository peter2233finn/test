# notice the / at end of directory
torrentDir="/data/data/com.termux/files/home/storage/downloads/Downloaded/"
torrentIncDir="/data/data/com.termux/files/home/storage/downloads/Downloading/"
movieDir="/storage/emulated/0/Movies/"

function checkactive(){
        z=$(ps aux|grep transmission|grep -v grep);[ -z "$z" ] && start
}

function vsleep(){
        function wait(){
                i=0
                while [[ $i -le $1 ]]; do
                        #for i in {0..$1}; do
                        printf "$i out of $1 sec"
                        sleep 1
                        printf "\r                                        \r"
                        ((i+=1))
                done
                printf "Done.             \n"
        }

        if [[ "$1" == *"m" ]]; then
                wait $((${1::-1}*60))
        elif [[ "$1" == *"h" ]]; then
                wait $((${1::-1}*60*60))
        else
                wait $1
        fi
}
function add(){
        checkactive
        echo "Magnet?"
        read toadd
        transmission-remote -a "$toadd"
        clear
        transmission-remote -l
        read shit
}

function action(){
        echo "What should I do?"
        echo "a: add torrent"
        echo "p: pause torrent"
        echo "s: start torrent"
        read act
        if [ ! -z "$act" ]; then
                clear
                echo "which one?"
                transmission-remote -l
                read n
        fi
        clear
        case "$act" in
                r)
                        transmission-remote -r "$n"
                        ;;
                p)
                        transmission-remote -S "$n"
                        ;;
                s)
                        transmission-remote -s "$n"
                        ;;
        esac
        clear
        if [ ! -z "$act" ]; then
                echo "Here is the result:"
                transmission-remote -l
                read shit
        fi
}

function start(){
        ps aux | grep -v grep |grep transmission-daemon
        transmission-daemon --logfile /data/data/com.termux/files/home/.log/t.log
        read shit
}



function monitor(){
        checkactive
        clear
        echo "Which one?"
        transmission-remote -l
        read n
        while true; do
                clear
                transmission-remote -l
                transmission-remote -t $n -f
                vsleep 9
                read -t1 x
                [ -z "$x" ] || break
        done
}


function delete(){
fileSort
x=0
while read i; do
        array[$x]="$i"
        echo "$x:/ $i" |awk 'BEGIN { FS="/"} ; {print $1" "$NF}'
        ((x++))
done <<< $(find "$movieDir" -type f)
echo "select which ones with a , seperating them"
read files

for f in $(echo $files|tr "," " "); do
        rm "${array[$f]}"
done
}

function fileSort(){
while read x; do
        mv "$x" "$movieDir"
done <<< $(find $torrentDir -type f|egrep -v "\.srt|\.txt|\.jpg|\.jpeg|\.png")
clear
}

function play(){
fileSort
x=0
echo "query?"
read q
while read i; do
        array[$x]="$i"
        echo "$x:/ $i"|awk 'BEGIN { FS="/"} ; {print $1 " " $NF}'
        ((x++))
done <<< $(find "$movieDir" "$torrentIncDir" -type f| grep -i "$q"|sort -h)
echo Play which one?
read n
echo am start -n org.videolan.vlc/org.videolan.vlc.gui.video.VideoPlayerActivity -d \'file:///${array[$n]}\' | sh

}

function jam(){
echo "You will have to reboot the TV. Are you sure? [y/n]"
read con
[ "$con" == "y" ] && (for i in {0..10000}; do am start -a android.intent.action.VIEW -d http://www.google.com & done)

}

function connect(){
        am start --user 0 -n com.termux/com.termux.app.TermuxActivity
        tmux a -t 1
}

function install(){
        curl https://raw.githubusercontent.com/peter2233finn/test/main/AndroidTV.sh > .bashrc
        termux-change-repo
        pkg install dropbear
         pkg install transmission
        mkdir .ssh
        
        # CHANGE THIS IS OTHER USER
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChiJgcoxsT4Ljov0a4I9NFcqwBJioE6kruPNmLFosLGjMpuWOwMgHYgzRqHsv1ILK+T9/JfnoQTcYt0MDsNYrWuwmb1NBq+90WRiN5JvjrNpK1OBrCnc5EGZVhO4cDfvlF8aikL2mvlPbwU2YbfFpW1OzPcCEbZxAgs2YXwtWtfC/EbGgmLGx/2oI1Zu7c2Z/rrFSLegRfXtC2UzuuI/P447M/s4+Py7apgDV33ZN87lTEAGMIF+Yi4s6zKaAMFO4D+s4wx+g9VK2i6m3jgZCg1DfIyJfJ5VzZRXBfvvcDnJRFA3CceXw4ADidNlixsQevyr0httpYBo63InhLnvXlv0IQa2Ht+nK01cGFiATmWCPGw5y0Te+XkgRdTeRqvfiaxjsIq+BbI4ESDtqURS4Ao8mQdmtai7Y5Svf4UWbbg9QUIFIqSk/nGk/UB1risWiFuLsxS6ScNqFEc6keNWEOKdAFAf7YbAg3khPTBmZud0DtQKI2ubYTjfVlBzwTsG8bGqpGyLVgr8kxfSbO7RJWOtvuhCb9EwvrCGTsO4wRWDxuYYi/gxnuu4Luswktg36QIly1DT6QgP7C8jvOs1IuOPS7TVQwLpKqmZ/i+UGvUwjr12YrRWmoTCr326uZieQqEjxhtHchUcwiAeouUaeO1BFg/RRACAbkz3YOoUU2JQ== peter@xxx" > .ssh/authorized_keys
}

while true; do
        clear
        echo "Welcome to the Android TV. What do you want to do?"
        echo "c: tmux CLI"
        echo "r: do action to torrent"
        echo "s: start"
        echo "a: add to torrent"
        echo "m: monitor a torrent"
        echo "p: play a torrent"
        echo "d: delete files"
        echo "j: jam TV"
        echo "e: shell"
        read opt
        case "$opt" in
                c)
                        connect
                        ;;
                r)
                        action
                        ;;
                s)
                        start
                        ;;
                m)
                        monitor
                        ;;
                p)
                        play
                        ;;
                j)
                        jam
                        ;;
                a)
                        echo XXX;add
                        ;;
                d)
                        delete
                        ;;
                i)
                        install
                        ;;
                e)
                        tmux detach || break
                        ;;
        esac
done
