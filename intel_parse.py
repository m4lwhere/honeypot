import csv, sys
from datetime import *

def parse(days, new_file):

    days = sys.argv[1]
    new_file = sys.argv[2]

    now = datetime.now()
    old = now - timedelta(days = days)

    better_now = now.strftime("%F")
    better_old = old.strftime("%F")

    with open(new_file) as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if row['Date'] > better_old:
                print(row['IP'])
