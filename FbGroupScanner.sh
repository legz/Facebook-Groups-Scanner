#!/bin/bash

# Account settings
login="XXX"	# ie:name%40gmail.com (yes, %40 instead of @)
password="XXX"

### Parameters
postClassId="_6-e5"

### Script init
init () {
	echo -e "$(date "+%D-%T") - Start"
	reportDate=$(date "+%Y%m%d-%H%M")
	
	# Groups delcaration
	declare -gA aGroups
	aGroups[facebook_group1_id]="Facebook group 1 name"
	aGroups[facebook_group2_id]="Facebook group 2 name"

	# Keywords declaration
	# example: aKeywords=('keyword1' 'keyword2')
	aKeywords=('application' 'vocal')

	# Set a proper user-agent for the script
	userAgent="Facebook Groups Scanner/1.0 (+https://github.com/legz/Facebook-Groups-Scanner)"
}

### Functions
scan () {
	# Set cookie (if needed)
	expirationDate=0
	today=$(date "+%s")
	if [[ -f cookies.txt ]]; then expirationDate=$(cat cookies.txt | grep -oP "[0-9]*(?=\tc_user\t)"); fi
	if [[ $today -gt $expirationDate ]]; then
		echo -e "$(date "+%D-%T") - Set/update cookies"
		curl -s -m 10 --cookie cookies.txt --cookie-jar cookies.txt "https://www.facebook.com" > /dev/null
		curl -s -m 10 --cookie cookies.txt --cookie-jar cookies.txt -A "$userAgent" -d "email=$login&pass=$password&timezone=-60&locale=en_US&login_source=login_bluebar" --compressed 'https://www.facebook.com/login/device-based/regular/login/?login_attempt=1&lwv=111' > login1.tmp
		curl -s -m 10 --cookie cookies.txt --cookie-jar cookies.txt -A "$userAgent" --compressed 'https://www.facebook.com/' > login2.tmp
	fi

	# Init report file
	echo '<html> <head> <meta charset="UTF-8"> </head> <body>' > report-$reportDate.html
	echo "<h1>Group search report - $(date "+%d/%m/%y")</h1>" >> report-$reportDate.html

	# Groups loop
	for group in "${!aGroups[@]}"; do
		echo -e "$(date "+%D-%T") - Group: ${aGroups[$group]}"
		echo "<h2>Group: ${aGroups[$group]}<a href=\"https://www.facebook.com/groups/$group/\">+</a></h2>" >> report-$reportDate.html

		# Keywords loop
		for keyword in ${aKeywords[@]}; do
			keywordSearchUrl="https://www.facebook.com/groups/$group/search/?query=${keyword}&epa=FILTERS&filters=eyJycF9jaHJvbm9fc29ydCI6IntcIm5hbWVcIjpcImNocm9ub3NvcnRcIixcImFyZ3NcIjpcIlwifSJ9"
			echo -e "$(date "+%D-%T") - Search for '$keyword'"
			echo "<h3>Keyword: $keyword<a href=\"$keywordSearchUrl\">+</a></h3>" >> report-$reportDate.html
			curl -s -m 10 --cookie cookies.txt --cookie-jar cookies.txt -A "$userAgent" "$keywordSearchUrl" > group.html.tmp
			cat group.html.tmp | grep -ioP "${postClassId}.{0,6000}" > extract_post.tmp		# -i for case insensitive

			while read post; do
				postPermalink=$(echo $post | grep -ioP "(?<=a href=\").{1,100}permalink.{1,100}(?=\" )")
				postDate=$(echo $post | grep -ioP "(?<=$postPermalink).{1,200}>.{1,20}(?=</a>)" | cut -d">" -f2-)
				postText=$(echo $post | grep -ioP "(?<=$postPermalink).{1,1000}?(?=</div></div>)" | rev | cut -d">" -f1 | rev) # .{1,1000}? : the "?" is for "the smallest possble match"
				echo "<div>" >> report-$reportDate.html
				echo "<a href=\"https://facebook.com$postPermalink\">$postDate</a>" >> report-$reportDate.html
				echo ": $postText" >> report-$reportDate.html
				echo "</div>" >> report-$reportDate.html
			done < extract_post.tmp
		done # end keywords loop
	done # end groups loop
	echo "</body></html>">> report-$reportDate.html
}

### Run script
init
# TODO : options for keywords
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

rm -f *.tmp
echo -e "$(date "+%D-%T") - End"

