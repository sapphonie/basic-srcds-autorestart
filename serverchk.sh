#!/bin/bash
# server checker

ping 103.214.111.90 -c 2 -i .25 &> /dev/null
if [ $? -ne 0 ];
then
    echo "MAIN IP DOWN! NOT CHECKING!"
    exit 1
fi
ping 1.1.1.1 -c 2 -i .25 &> /dev/null
if [ $? -ne 0 ];
then
    echo "CANNOT ACCESS INTERNET! NOT CHECKING!"
    exit 2
fi
ping google.com -c 2 -i .25 &> /dev/null
if [ $? -ne 0 ];
then
    echo "DNS NONFUNCTIONAL! NOT CHECKING!"
    exit 4
fi

declare -a tfServerList=(
    "tfCOMP"
    "tfPUG1"
    "tfPUG2"
    "tfNOOB1"
    "tfMGE"
    "tfMGE_ELO1"
    "tfMGE_ELO2"
    "tfDM1"
    "tfDM2"
    "tfDM3"
    "tfDM4"
    "tfJUMP1"
    "tfBB1"
    "tfULTI1"
    "tfPUB"
    "tfBLAZER"
    )


for entry in "${tfServerList[@]}"; do
    if [[ "$entry" == *"RGL"* ]] || [[ "$entry" == *"PUG"* ]];
    then
        tfPath="/home/game/rglSRV/$entry/"
    elif [[ "$entry" == *"NOOB"* ]];
    then
        tfPath="/home/game/newbieSRV/$entry/"
    elif [[ "$entry" == *"BLAZE"* ]];
    then
        tfPath="/home/game/blazer/$entry/"
    else
        tfPath="/home/game/$entry/"
    fi

    pgrep -fal "$tfPath"tf2/srcds &> /dev/null
    if [ $? -ne 0 ];
        then
            echo -e "\e[31m$entry down! \e[39mRestarting..."
            tmux kill-session -t $entry ; tmux new-session -d -s $entry ;
            tmux send-keys -t $entry "$tfPath"tf.sh ENTER ;
        else
            if [[ $( echo ""$(awk '{print $1}' /proc/uptime)" / 60 < 30" | bc -l ) -eq 1 ]] || [[ $(echo "$(uptime | sed 's/,//g' | awk '{ print $8 }')" ">= 8" | bc -l) -eq 1 ]]
            then
                echo -e "\e[36m-> SYSTEM LOAD IS TOO HIGH OR MASTER WAS JUST RESTARTED!! SERVER PROCESS EXISTS BUT HAS NOT BEEN CHECKED WITH GAMEDIG!\e[39m"
            else
            # ugly
            ip=$(cat "$tfPath"tf.sh | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
            port=$(cat "$tfPath"tf.sh | grep -oE "\bport \b(.....)\b" | grep -oE "\b[0-9]{5}\b")
            for (( i=1; i<=5; i++ )); do
                #echo $ip
                #echo $port
                #echo "$ip":"$port"
                gamedig --type tf2 "$ip":"$port" | grep "Failed all" &> /dev/null
                if [ $? -ne 0 ]; # succeeded!
                then
                    echo -e "\e[32m$entry \e[39mfunctional."
                    break
                else
                    echo -e "\e[33m$entry not responding. \e[39mRechecking..."
                    sleep 5
                fi
                if [ $i -eq 5 ]
                then
                    echo -e "\e[31m$entry down! \e[39mRestarting..."
                    tmux kill-session -t $entry ; tmux new-session -d -s $entry ;
                    tmux send-keys -t $entry "$tfPath"tf.sh ENTER ;
                fi
            done
        fi
    fi
done

declare -a mcServerList=(
    "mcOLD"
    "mcNEW"
    "mcNAT"
    )

for mcEntry in "${mcServerList[@]}";
do
    if [[ "$mcEntry" == *"mcOLD" ]]; then
        mcPath="/home/game/mc/server_old/"
    elif [[ "$mcEntry" == *"mcNAT" ]]; then
        mcPath="/home/game/mc/serverNAT/"
    elif [[ "$mcEntry" == "mcNEW" ]]; then
        mcPath="/home/game/mc/server/"
    fi

pgrep -fal "$mcPath" &> /dev/null
if [ $? -ne 0 ];
    then
            echo -e "\e[31m$mcEntry down! \e[39mRestarting..."
            tmux kill-session -t $mcEntry ; tmux new-session -d -s $mcEntry ;
            tmux send-keys -t $mcEntry cd ' ' "$mcPath" ENTER
            tmux send-keys -t $mcEntry "$mcPath"mc.sh ENTER
    else
        if [[ $( echo ""$(awk '{print $1}' /proc/uptime)" / 60 < 30" | bc -l ) -eq 1 ]] || [[ $(echo "$(uptime | sed 's/,//g' | awk '{ print $8 }')" ">= 8" | bc -l) -eq 1 ]]
        then
            echo -e "\e[36m-> SYSTEM LOAD IS TOO HIGH OR MASTER WAS JUST RESTARTED!! SERVER PROCESS EXISTS BUT HAS NOT BEEN CHECKED WITH GAMEDIG!\e[39m"
    else
        # ugly
        ip=$(cat "$mcPath"server.properties | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
        port=$(cat "$mcPath"server.properties | grep -oE "\b(query\-port\=)\b(.....)\b" | grep -oE "\b[0-9]{5}\b")
        for (( i=1; i<=5; i++ )); do
            #echo $ip
            #echo $port
            #echo "$ip":"$port"
            gamedig --type minecraft "$ip":"$port" | grep "Failed all"
            if [ $? -ne 0 ]; # succeeded!
            then
                echo -e "\e[32m$mcEntry \e[39mfunctional."
                break
            else
                echo -e "\e[33m$mcEntry not responding. \e[39mRechecking..."
                sleep 5
            fi
            if [ $i -eq 5 ]
            then
                echo -e "\e[31m$mcEntry down! \e[39mRestarting..."
                tmux kill-session -t $mcEntry ; tmux new-session -d -s $mcEntry ;
                tmux send-keys -t $mcEntry cd ' ' "$mcPath" ENTER
                tmux send-keys -t $mcEntry "$mcPath"mc.sh ENTER
                fi
            done
        fi
    fi
done
