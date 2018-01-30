#!/bin/bash


### Script init
init () {
	echo -e "$(date "+%D-%T") - Start"
	rm -f *.tmp
	# Account settings
	login="XXX"	# ie:name@gmail.com
	password="XXX"

	# Groups delcaration
	declare -gA aGroups
	aGroups[MoulinexCuisineCompanion]="Idées recettes, Cuisine Companion"
	aGroups[cookeojoieetbonnehumeur]="Recettes Cookeo dans la joie et la bonne humeur"
	aGroups[1714394322148881]="Moulinex Companion , Recette, Photos, Cuisine Et Partage A Vos Fourneaux"
	aGroups[ideesrecettescookeo]="Idées recettes COOKEO"

	# Keywords declaration
	aKeywords=('application' 'vocal')

	# Set a proper user-agent for the script
	userAgent="Facebook Groups Scanner/1.0 (+https://github.com/legz/Facebook-Groups-Scanner)"
}

### Functions
scan () {
	# Start a session (@TODO : use cookie without login if the cookie is still OK)
	curl -s -m 10 --cookie cookies.txt --cookie-jar cookies.txt "https://www.facebook.com" > /dev/null
	curl -s -m 10 --cookie cookies.txt --cookie-jar cookies.txt -A "$userAgent" -d "email=$login&pass=$password&timezone=-60&locale=en_US&login_source=login_bluebar" "https://www.facebook.com/login.php?login_attempt=1&lwv=110" > login.html.tmp
	
	# Groups loop
	for group in "${!aGroups[@]}"; do
		echo -e "$(date "+%D-%T") - Group: ${aGroups[$group]}"
		echo "Group: ${aGroups[$group]}" >> final.txt

		# Keywords loop
		for keyword in ${aKeywords[@]}; do
			echo -e "$(date "+%D-%T") - Search for '$keyword'"
			echo "Keyword: $keyword" >> final.txt
			curl -s -m 10 --cookie cookies.txt --cookie-jar cookies.txt -A "$userAgent" "https://www.facebook.com/groups/$group/search/?query=$keyword&filters_rp_chrono_sort=%7B%22name%22%3A%22chronosort%22%2C%22args%22%3A%22%22%7D" > group.html.tmp
			cat group.html.tmp | grep -ioP "(?<=(5;\">|\"1\">))[A-Za-z].{0,300}?$keyword.{0,500}?(?=<\/span>)" > output.tmp		# -i for case insensitive
			clean output.tmp >> final.txt
			echo " " >> final.txt 
		done
		echo "---" >> final.txt 
	done
}

# Basic function to clean output
clean () {
	cat $1 | sed "s/<\/a>&nbsp;<span>/ : /g" \
		   | sed "s/<a href.\+>\(.\+\)<\/a>/[\1]/g" \
		   | sed "s/<span .\+>//g" \
		   | sed "s/<br \/>//g" \
		   | perl -MHTML::Entities -pe 'decode_entities($_);'
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
