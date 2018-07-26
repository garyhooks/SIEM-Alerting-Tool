#!/usr/bin/env bash
#
# Publish Date: 24th July 2018
# Author: Gary Hooks
# Licence: GNU GPL

ips_not_known="ips_not_known.txt"

tidy_up()
{
	rm -rf ./log_results/*
	rm -rf all_ips.txt
	rm -rf ready.txt
}

parse_file() 
{
	
	for ip in $( cat /var/log/auth.log | grep "Failed password for" | grep -v "message repeated" | cut -d " " -f 13 | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.[0-9]{1,3}' )
	do
		
		echo $ip >> all_ips.txt

	done
		
	while read -r ip;
	do
		echo $ip >> ./log_results/$ips_not_known
	done < "all_ips.txt"


}


create_report()
{
	cat log_results/ips_not_known.txt | sort | uniq -c | sort -nr > ./log_results/results.txt
	cat ./log_results/results.txt | awk '{ OFS=" " } { print $1, $2 }' >> ready.txt

	now_date=$(date +%A' '%d' '%B' '%Y)
	
	echo "<!DOCTYPE html>" > ./log_results/results.html
	echo "<html lang='en-US'>" >> ./log_results/results.html
	echo "<head>" >> ./log_results/results.html
	echo "<title>$now_date</title>" >> ./log_results/results.html
	echo "<link rel='stylesheet' href='css/bootstrap.css'>" >> ./log_results/results.html
	echo "</head>" >> ./log_results/results.html
	echo "<body>" >> ./log_results/results.html

	echo "<table class='table table-hover'>" >> ./log_results/results.html
	echo "<thead class='thead-dark'>" >> ./log_results/results.html
	echo "<tr>" >> ./log_results/results.html
	echo "<th scope='col' style='width: 200px; background: #212629; color: #FFFFFF;'> Number of attempts made </th>" >> ./log_results/results.html
	echo "<th scope='col' style='width: 200px; background: #212629; color: #FFFFFF;'> IP Address </th>" >> ./log_results/results.html
	echo "<th scope='col' style='width: 200px; background: #212629; color: #FFFFFF;'> Map </th>" >> ./log_results/results.html
	echo "<th scope='col' style='width: 200px; background: #212629; color: #FFFFFF;'> Whois </th>" >> ./log_results/results.html
	echo "<th scope='col' style='width: 200px; background: #212629; color: #FFFFFF;'> Google </th>" >> ./log_results/results.html
	echo "</tr>" >> ./log_results/results.html
	echo "</thead>" >> ./log_results/results.html

	echo "<tr> <td> &nbsp; </td> <td> &nbsp; </td> </tr>" >> ./log_results/results.html

	while read -r line;
	do

		occurrences=$(echo $line | awk '{ print $1 }' )
		ip=$(echo $line | awk '{ print $2 }' )

		echo "<tr>" >> ./log_results/results.html
		echo "<td> $occurrences </td>" >> ./log_results/results.html
		echo "<td> $ip </td>" >> ./log_results/results.html 
		echo "<td> <a href='http://www.infosniper.net/index.php?ip_address=$ip&k=&map_source=1&overview_map=1&lang=1&map_type=1&zoom_level=7' target='_blank'>Map</a> </td>" >> ./log_results/results.html 
		echo "<td> <a href='http://whois.domaintools.com/$ip' target='_blank'>Whois</a> </td>" >> ./log_results/results.html 
		echo "<td> <a href='https://www.google.com/search?q=$ip' target='_blank'>Google</a> </td>" >> ./log_results/results.html 
		echo "</tr>" >> ./log_results/results.html

	done < "ready.txt"

	echo "</table>" >> ./log_results/results.html
	

	echo "</body>" >> ./log_results/results.html
	echo "</html>" >> ./log_results/results.html
	
	mv ./log_results/results.html /var/www/yourwebsite/results.html

}


tidy_up
parse_file
create_report
