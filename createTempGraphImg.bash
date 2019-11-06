#!/bin/bash
 
mysql -u sensor --password=XXX --skip-column-names -e "SELECT UNIX_TIMESTAMP(CONVERT_TZ(timeStamp, '+00:00', @@global.time_zone)),data FROM sensor.event where ((timeStamp >=NOW() - INTERVAL 2 DAY) AND (name like '%Luminance%'));" | sed 's/\t/;/g;s/\n//g' > /home/krikar/scripts/data/luminance.csv

mysql -u sensor --password=XXX --skip-column-names -e "SELECT UNIX_TIMESTAMP(CONVERT_TZ(timeStamp, '+00:00', @@global.time_zone)),data FROM sensor.event where ((timeStamp >=NOW() - INTERVAL 2 DAY) AND (name like '%uterummetTemperature%'));" | sed 's/\t/;/g;s/\n//g;s/ °C//' > /home/krikar/scripts/data/tempUterummet.csv

mysql -u sensor --password=XXX --skip-column-names -e "SELECT UNIX_TIMESTAMP(CONVERT_TZ(timeStamp, '+00:00', @@global.time_zone)),data FROM sensor.event where ((timeStamp >=NOW() - INTERVAL 2 DAY) AND (name like '%outdoorTemperature%'));" | sed 's/\t/;/g;s/\n//g;s/ °C//' > /home/krikar/scripts/data/tempOutside.csv

mysql -u sensor --password=XXX --skip-column-names -e "SELECT UNIX_TIMESTAMP(CONVERT_TZ(timeStamp, '+00:00', @@global.time_zone)),data FROM sensor.event where ((timeStamp >=NOW() - INTERVAL 2 DAY) AND (name like '%vardagsrummetTemperature%'));" | sed 's/\t/;/g;s/\n//g;s/ °C//' > /home/krikar/scripts/data/tempInside.csv


# Define title of the plot and print last date of plotting
TITLE="Temperatures and luminance until `date +%F\ %T`"
 
# To correct UNIX epoch date and gnuplot epoch date, we have to substract $EPOCH_OFFSET
#EPOCH_OFFSET=946684800
 
# Get UNIX epoch date
#TODAY="`date +%s`"
 
# Correct offset to 2000-01-01 00:00:00
#TODAY=$(expr $TODAY - $EPOCH_OFFSET)
 
# We want to plot values from 24 h
#YESTERDAY="`date +%s --date="-1 day"`"
 
# Correct offset to 2000-01-01 00:00:00
#YESTERDAY=$(expr $YESTERDAY - $EPOCH_OFFSET)
 
/usr/bin/gnuplot << EOF
 
# Data file uses semikolon as a separator
set datafile separator ';'
 
# Title of the plot
set title "$TITLE"
 
# We want a grid
set grid
 
# Ignore missing values
#set datafile missing "NaN"
 
# X-axis label
set xlabel "Date/Time (CET)"
 
# set X-axis range to current date only
#set xrange ["$YESTERDAY":"$TODAY"]
 
# Y-axis ranges 
set autoscale y
 
# Y2-axis ranges
set autoscale y2
 
# place ticks on second Y2-axis
set y2tics border
 
# Title for Y-axis
set ylabel "Temperature (C)"
 
# Title for Y2-axis
set y2label "Luminance"
 
# Define that data on X-axis should be interpreted as time
set xdata time
 
# Time in log-file is given in Unix format
set timefmt "%s"
 
# Display notation for time
set format x "%H"    # Display time in 24 hour notation on the X axis
 
# generate a legend which is placed underneath the plot
set key outside bottom center box title "RasPi Sensor Data"
 
# output into png file
set terminal png large
set output "/var/www/html/plot.png"
 
# read data from files and generate plot
plot "/home/krikar/scripts/data/tempInside.csv"    using 1:2 title "Indoor temperature (C)"    with lines, \
     "/home/krikar/scripts/data/tempOutside.csv"   using 1:2 title "Outside temperature (C)"   with lines, \
     "/home/krikar/scripts/data/tempUterummet.csv" using 1:2 title "Uterummet temperature (C)" with lines, \
     "/home/krikar/scripts/data/luminance.csv"     using 1:2 title "Luminance"                 with lines axes x1y2\
# end of script
EOF
