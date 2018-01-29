#!/bin/bash


### Script init
init () {
	echo -e "$(date "+%D-%T") - Start"
	rm -f *.tmp
	aKeywords=('application' 'vocal')
	login="XX"	# ie:name@gmail.com
	password="XX"
	userAgent="Facebook Groups Scanner/1.0 (+https://github.com/legz/Facebook-Groups-Scanner)"
}


### Functions
scan () {
	curl -s --cookie cookies.txt --cookie-jar cookies.txt "https://www.facebook.com" > /dev/null
	curl -s --cookie cookies.txt --cookie-jar cookies.txt -A "$userAgent" -d "email=$login&pass=$password&timezone=-60&locale=en_US&login_source=login_bluebar" "https://www.facebook.com/login.php?login_attempt=1&lwv=110" > login.html.tmp
	curl -s --cookie cookies.txt --cookie-jar cookies.txt -A "$userAgent" "https://www.facebook.com/groups/1714394322148881/search/?query=application&filters_rp_chrono_sort=%7B%22name%22%3A%22chronosort%22%2C%22args%22%3A%22%22%7D" > group.html.tmp

	cat group.html.tmp | grep -ioP '(?<=(5;">|"1">))[A-Za-z].{0,300}?application.{0,500}?(?=<\/span>)' > output.tmp		# -i for case insensitive
	cat output.tmp | sed "s/<\/a>&nbsp;<span>/ : /g" > outputClean1.tmp		# Use some tmp files because of how bash script works (can't cat and output in the same file if too quick)
	cat outputClean1.tmp | sed "s/<a href.\+>\(.\+\)<\/a>/[\1]/g" > outputClean2.tmp
	cat outputClean2.tmp | sed "s/<span .\+>//g" > outputClean3.tmp
	cat outputClean3.tmp | perl -MHTML::Entities -pe 'decode_entities($_);' > output.tmp

	echo "Results:"
	cat output.tmp
}


### Run script
init
# while getopts ":k:h" optname; do
#     case $optname in
#       k)	keyword=$OPTARG ;;
#       h)	echo "Available option :"
# 	        echo "	-k [keyword]	: Keyword searched in groups (ie: Application)"
# 	        exit 0 ;;
#       \?) 	echo "Invalid option -${OPTARG}. Try -h for help."; exit 1 ;;
#       :)	echo "Option -${OPTARG} requires an argument. Try -h for help."; exit 1 ;;
#       *)	echo "Unknown error while processing options"; exit 1 ;;
#     esac
# done

scan

echo -e "$(date "+%D-%T") - End"
