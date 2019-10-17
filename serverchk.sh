#!/bin/bash
# run this every minute or faster thru cron
# i like to run this script itself in a seperate tmux window
pgrep -fal /path/to/srcds
if [ $? -eq 1 ];
	then
		echo "TF2 server down! Restarting..."
		tmux kill-session -t tfSRV ; tmux new-session -d -s tfSRV ;
		tmux send-keys -t tfSRV "/path/to/tf.sh" ENTER
	else
		echo "TF2 server functional."
fi
