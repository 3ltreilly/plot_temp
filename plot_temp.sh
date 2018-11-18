#!/bin/bash -x

#bla="AH SR AT BH"
#bla_hum="AH_hum BH_hum"

bla="AH AT SR BH"
bla_hum="AH_hum BH_hum"

#bla="BH"
#bla_hum="BH_hum"

#clean up files
for delme in $bla
do
	rm -rf $delme
	rm -rf "$delme"_date
	rm -rf "$delme"_hum
	rm -rf "$delme"_new_date
done

for the_file in $@
do
	for data in $bla
	do
		grep "${data}" "$the_file" | grep 'TEMP' | gsed -e s/TEMP// -e 's/:[0-9][0-9] +0000//' -e "s/,"${data}",/ /" >>"${data}"
		grep "${data}" "$the_file" | grep 'RHUM' | gsed -e s/RHUM// -e 's/:[0-9][0-9] +0000//' -e "s/,"${data}",/ /" >>"${data}"_hum
		
	done
		
done
echo $bla

#convert from C to F
for data in $bla
do
	#deal with temp files
	gawk '{print 32+9/5*$5}' ${data} > ${data}_temp
	gawk '{print $1,$2,$3,$4 "UTC"}' ${data} > ${data}_date
	
	#deal with hum files
	gawk '{print $5}' ${data}_hum > ${data}_hum_temp
	gawk '{print $1,$2,$3,$4 "UTC"}' ${data}_hum > ${data}_hum_date
	
	#convert to EST time
	rm -f ${data}*_new_date.txt
	cat ${data}*_new_date.txt
	gdate -f "${data}_date" "+%d %b %Y %H:%M" > ${data}_new_date
	gdate -f "${data}_hum_date" "+%d %b %Y %H:%M" > ${data}_hum_new_date

	
	#add date and temp files together
	gawk 'FNR==NR{a[NR]=($1);next}{ print $1,$2,$3,$4,a[FNR]}' ${data}_temp ${data}_new_date > ${data}
	gawk 'FNR==NR{a[NR]=($1);next}{ print $1,$2,$3,$4,a[FNR]}' ${data}_hum_temp ${data}_hum_new_date > ${data}_hum

done

gnuplot -persist <<EOF
#set datafile separator ","
set xdata time
set key left
set timefmt '%d %b %Y %H:%M'
#            16-Dec-2016-05:04 12.92
set format x "%H:%M"
set autoscale y
set autoscale y2
set grid
set ylabel "temp"
set y2label "hum"
set y2tics
set ytics 5
#set y2range[40:65]
plot for [data in "$bla"] data using 1:5 title data# with lines
#set term x11 1
replot for [dataH in "$bla_hum"] dataH using 1:5 title dataH axes x1y2 with lines
EOF

#clean up files
#for delme in $bla
#do
#	rm -rf $delme
#	rm -rf "$delme"_date
#	rm -rf "$delme"_hum
#	rm -rf "$delme"_new_date
#	rm -rf "$delme"_temp
#done
#
#for delme in $bla_hum
#do
#	rm -rf $delme
#	rm -rf "$delme"_date
#	rm -rf "$delme"_hum
#	rm -rf "$delme"_new_date
#	rm -rf "$delme"_temp
#done

