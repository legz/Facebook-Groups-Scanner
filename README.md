

# Facebook Groups Scanner

*Facebook Groups Scanner* is a bash script that searches for keywords on Facebook Groups (no shit Sherlock!).

The script handles several groups (even private ones) and several keywords.



## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Dependencies

Nothing fancy:

- GNU bash (tried on Linux , version 4.3.11(1) )
- cURL (tried on Linux, version 7.35.0)

### Configuration
A few things need to be set for the script to work properly :
- Facebook account:

```Shell
login="your.login%40domain.tld"	# Yep, the @ is %40
password="*****" # I know, hardcoded password is bad. But Facebook API....meh.
```
- Facebook group(s):

```Shell
aGroups[facebook_group1_id]="Group 1 name"
aGroups[facebook_group2_id]="Group 2 name"
...
```
The Facebook group ID (or vanity URL) can be found in the group's URL.

For example, for the group "[Android Developers And Kotlin...](https://www.facebook.com/groups/883546485084033/) ":

```Shell
aGroups[883546485084033]="Android Developers And Kotlin Droidcon Github Library"
```

- Keyword(s):
```Shell
aKeywords=('keyword 1' 'keyword 2')
```

## Run the script
1. Run the script:
```
> ./FbGroupScanner.sh 
    01/31/18-00:02:12 - Start
    01/31/18-00:02:12 - Group: Group 1 name
    01/31/18-00:02:12 - Search for 'keyword 1'
    01/31/18-00:02:14 - Search for 'keyword 2'
    01/31/18-00:02:15 - Group: Group 2 name
    01/31/18-00:02:15 - Search for 'keyword 1'
    01/31/18-00:02:17 - Search for 'keyword 2'
    01/31/18-00:02:27 - End
```

2. Read the results: Open the `report-*-*.html` file

   
## TODO
- Insert data into a database (it will be much more easy to process report file that way)
- More data (author name, ~~publication date,~~ ~~link to posts~~, number of reactions, number of comment)
- ~~Better output format~~ (option for RSS maybe?)
- 'Diff' option to add only new entry (RSS in mind again)
