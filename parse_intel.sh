#!/bin/bash

#find the current archive for today
DATE=$(date --date="yesterday" +%Y%b%d)_canary.gz
FOLDER="/home/pi/Desktop"

KEY = $1

#gunzip to a temp location
gunzip -c $FOLDER/canarylogs/$DATE > $FOLDER/feeds/canary.log

#format the csv and parse data with jq
echo '"IP","Date","Port"' > $FOLDER/feeds/canarylogs
jq -r "[.src_host, .local_time, .dst_port] | @csv" $FOLDER/feeds/canary.log >> $FOLDER/feeds/canarylogs

#spit out all the separate lists of intel
echo "m4lwhere.org intelligence. Generated at `date`. All attackers from last 24 hours. Use of feeds indicates agreement to m4lwhere.org license." > $FOLDER/feeds/last_24h.txt
python3 /home/pi/1d_parse.py $FOLDER/feeds/canarylogs | sort | uniq | sed '/^$/d' >> $FOLDER/feeds/last_24h.txt
echo "m4lwhere.org intelligence. Generated at `date`. All attackers from last 7 days. Use of feeds indicates agreement to m4lwhere.org license." > $FOLDER/feeds/last_7d.txt
python3 /home/pi/7d_parse.py $FOLDER/feeds/canarylogs | sort | uniq | sed '/^$/d' >> $FOLDER/feeds/last_7d.txt
echo "m4lwhere.org intelligence. Generated at `date`. All attackers from last 30 days. Use of feeds indicates agreement to m4lwhere.org license." > $FOLDER/feeds/last_30d.txt
python3 /home/pi/30d_parse.py $FOLDER/feeds/canarylogs | sort | uniq | sed '/^$/d' >> $FOLDER/feeds/last_30d.txt
echo "m4lwhere.org intelligence. Generated at `date`. All attackers from last year. Use of feeds indicates agreement to m4lwhere.org license." > $FOLDER/feeds/last_year.txt
python3 /home/pi/1y_parse.py $FOLDER/feeds/canarylogs | sort | uniq | sed '/^$/d' >> $FOLDER/feeds/last_year.txt

#create proto specific intel
echo "m4lwhere.org intelligence. Generated at `date`. All SSH attackers from last 7 days. Use of feeds indicates agreement to m4lwhere.org license." > $FOLDER/feeds/ssh_attacks.txt
python3 /home/pi/ssh_parse.py $FOLDER/feeds/canarylogs | sort | uniq | sed '/^$/d' >> $FOLDER/feeds/ssh_attacks.txt
echo "m4lwhere.org intelligence. Generated at `date`. All redis attackers from last 7 days. Use of feeds indicates agreement to m4lwhere.org license." > $FOLDER/feeds/redis_attacks.txt
python3 /home/pi/redis_parse.py $FOLDER/feeds/canarylogs | sort | uniq | sed '/^$/d' >> $FOLDER/feeds/redis_attacks.txt
echo "m4lwhere.org intelligence. Generated at `date`. All SIP attackers from last 7 days. Use of feeds indicates agreement to m4lwhere.org license." > $FOLDER/feeds/sip_attacks.txt
python3 /home/pi/sip_parse.py $FOLDER/feeds/canarylogs | sort | uniq | sed '/^$/d' >> $FOLDER/feeds/sip_attacks.txt

#upload to site

scp -i $KEY $FOLDER/feeds/last_24h.txt ubuntu@m4lwhere.org:/var/www/html/feeds/last_24h.txt
scp -i $KEY $FOLDER/feeds/last_7d.txt ubuntu@m4lwhere.org:/var/www/html/feeds/last_7d.txt
scp -i $KEY $FOLDER/feeds/last_30d.txt ubuntu@m4lwhere.org:/var/www/html/feeds/last_30d.txt
scp -i $KEY $FOLDER/feeds/last_year.txt ubuntu@m4lwhere.org:/var/www/html/feeds/last_year.txt
scp -i $KEY $FOLDER/feeds/ssh_attacks.txt ubuntu@m4lwhere.org:/var/www/html/feeds/ssh_attacks.txt
scp -i $KEY $FOLDER/feeds/redis_attacks.txt ubuntu@m4lwhere.org:/var/www/html/feeds/redis_attacks.txt
scp -i $KEY $FOLDER/feeds/sip_attacks.txt ubuntu@m4lwhere.org:/var/www/html/feeds/sip_attacks.txt