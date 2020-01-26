import os
import csv
from datetime import date
import requests

today = date.today()
today = today.strftime("%Y%b%d")
canarydate = today + "_canary.log"
print(canarydate)

#Clear the temp files incase the script was interrupted earlier
os.system('rm /home/pi/Desktop/canarylogs/temp.csv /home/pi/Desktop/canarylogs/pre_upload.csv /home/pi/Desktop/canarylogs/upload.csv')

#Setup the command to parse the logs by leaving them zipped, then call with os
setup = 'cat /home/pi/Desktop/canarylogs/' + canarydate + ' | jq -r "[.src_host, \"14\", .local_time, .dst_port] | @csv" | sort > /home/pi/Desktop/canarylogs/temp.csv'
run = os.system(setup)

#Open the temp csv created with the os call
with open('/home/pi/Desktop/canarylogs/temp.csv') as csvfile:
    reader = csv.reader(csvfile)
    iplist = list(reader)

#Create a new csv for the upload and put headers for file
os.system('echo IP,Categories,ReportDate,Comment > /home/pi/Desktop/canarylogs/pre_upload.csv')

#Define the number of IPs needed to be iterated through
length = len(iplist)
num = 0

#This is where the magic happens, iterates twice through the list for each IP and counts the occurances
for p in range(0,length):
    try:
        ip = iplist[p][0]
        if ip == iplist[p+1][0]:
            continue
        for i in range(0,length):
            if ip == iplist[i][0]:
                num = num + 1
        csvrow = ip + ',14,' + iplist[p][2] + ',\"Scanned ' + str(num) + ' times in the last 24 hours on port ' + iplist[p][3] + '\"'
        os.system('echo ' + csvrow + ' >> /home/pi/Desktop/canarylogs/pre_upload.csv')
        num = 0
    except:
        pass

#Check for home IP and remove it so I'm not reporting myself!! :)
r = requests.get('https://www.myexternalip.com/raw')
homeip = r.text
os.system('grep -v ' + homeip + ' /home/pi/Desktop/canarylogs/pre_upload.csv > /home/pi/Desktop/canarylogs/upload.csv')

#Send it up to AbuseIPDB and call it a day!
apikey = 'key'
uploads = 'curl https://api.abuseipdb.com/api/v2/bulk-report -F csv=@/home/pi/Desktop/canarylogs/upload.csv -H \"Key: ' + apikey + '\" -H \"Accept: application/json" >> /home/pi/Desktop/canarylogs/upload_log.json'
os.system(uploads)

#Done :)
exit()


