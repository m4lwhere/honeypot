#! /bin/bash

# Call this script with KEY, Username, IP, and Port

KEY = $1
USER = $2
IP = $3
PORT = $4

#Declare date var to format string
DATE=$(date --date="yesterday" +%Y%b%d)_canary.gz
DATE2=$(date +%Y%b%d)_canary.log

# Download the latest logs from AWS and date them
scp -i $KEY -P $PORT $USER@$IP:/home/$USER/archive/$DATE /home/pi/Desktop/canarylogs/$DATE

#Save only the activity from the previous day
zgrep $(date --date="yesterday" +%F) /home/pi/Desktop/canarylogs/$DATE >> /home/pi/Desktop/canarylogs/$DATE2