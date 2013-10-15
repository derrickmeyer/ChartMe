#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Jeremy Matthews - Courtesy of Stony River Technologies
# Version 1.0.0 - 2013-10-11

# Modified by
# Version - Initial

# Base Variables that are potentially used for all scripts.
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"

# Script Variables
MY_JSS_ADDY="/Library/Preferences/com.jamfsoftware.jamf.plist"
if [ -e ${MY_JSS_ADDY} ]
  then
    JSS_FULL_URL=$( /usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url )
    JSS_API_URL="${JSS_FULL_URL}JSSResource/"
    echo "Using Built-in JSS Settings"
    else
    ## if the file doesn't exist you must manually populate the JSS Address ##
    JSS_FULL_URL="https://www.myjss.com:8443/"
    JSS_API_URL="${JSS_FULL_URL}JSSResource/"
    echo "Using Manual JSS Settings"
fi

##Declaration of War (and variables)
JSS_REQUESTED_SUBITEM="computers"
JSS_FULL_URL="${JSS_API_URL}${JSS_REQUESTED_SUBITEM}"
CURL_OPTIONS="-sk -H \"Accept: application/xml\""
JSON_OR_XML="XML"
JSS_ID="your_jss_username
JSS_PASS="_your_jss_password"
## preserved variables below for debugging
MY_TMPFILE_INPUT="/tmp/$RANDOM.xml"
MY_TMPFILE_FINAL="/tmp/$RANDOM.xml"

# Script Functions
## Note that validation functions are offline so we don't encounter a network threshold error while using the "Guthrie" network
validate () {
	[ "${JSS_FIRST_URL}" == "JSSResource/" ] && { echo -n -e "JSS FQDN (with port and slash at the end): "; read JSS_FIRST_URL; }
	[ "${JSS_ID}" == "" ] && { echo -n -e "JSS Username: "; read JSS_ID; }
	[ "${JSS_PASS}" == "" ] && { echo -n -e "JSS Password: "; read -s JSS_PASS; }

	echo "Running ${SCRIPTNAME} with these settings"
	echo -e "\t${JSS_FIRST_URL}"
	echo -e "\t${JSS_ID}"
##	echo -e "\t${JSS_PASS}"	##never uncomment this unless you have to debug
}

chartMe () {

	## perform initial pull of computers and get the IDs using curl and XPATH
	string=`curl ${CURL_OPTIONS} -u ${JSS_ID}:${JSS_PASS} $JSS_FULL_URL -X GET | xpath '(/computers/computer/id)'`
	## use sed to strip out the tags and put into separate lines for pretty-print
	string2=`echo "${string}" | sed 's/\<\/id>/\<\/id>\'$'\n/g' | sed 's/\<id>//g' | sed 's/\<\/id>//g'`
	##echo "$string2"

	## get ready to setup a simple command to grab each separate line item and create a custom pull for the data
	END_URL="^-X GET"
	END_URL3="'(/computer/hardware/os_version)'"

	## perform a scoped pull of the os_version information so we can then parse the data stream for relevant info
	IFS=$'\n'; 
	arr=("$string2"); 
	for i in ${arr[@]}; do 
		##echo "mine" $i; 
		string33=`curl -sk -H \"Accept: application/xml\" -u ${JSS_ID}:${JSS_PASS} $JSS_FULL_URL/id/$i ${END_URL} | xpath '(/computer/hardware/os_version)'`
		string44=`echo "${string33}" | sed 's/\<\/id>/\<\/os_version>\'$'\n/g' | sed 's/\<os_version>//g' | sed 's/\<\/os_version>//g'`
		echo "$string44" >> "${MY_TMPFILE_INPUT}"
	done
		
	leopardResultsCount=`awk '{ print $1}' "${MY_TMPFILE_INPUT}" | cut -c 1-4 | sort -n | uniq -c | sort -k2 -n | sed -e 's/^[ \t]*//' | grep 10.5 | cut -d \  -f 1`
	snowLeopardResultsCount=`awk '{ print $1}' "${MY_TMPFILE_INPUT}" | cut -c 1-4 | sort -n | uniq -c | sort -k2 -n | sed -e 's/^[ \t]*//' | grep 10.6 | cut -d \  -f 1`
	lionResultsCount=`awk '{ print $1}' "${MY_TMPFILE_INPUT}" | cut -c 1-4 | sort -n | uniq -c | sort -k2 -n | sed -e 's/^[ \t]*//' | grep 10.7 | cut -d \  -f 1`
	mountainLionResultsCount=`awk '{ print $1}' "${MY_TMPFILE_INPUT}" | cut -c 1-4 | sort -n | uniq -c | sort -k2 -n | sed -e 's/^[ \t]*//' | grep 10.8 | cut -d \  -f 1`
	mavericksResultsCount=`awk '{ print $1}' "${MY_TMPFILE_INPUT}" | cut -c 1-4 | sort -n | uniq -c | sort -k2 -n | sed -e 's/^[ \t]*//' | grep 10.9 | cut -d \  -f 1`
	
	## sanity and integrity check to ensure the variable returned from the previous function is, in fact, a number and not complete garbage
	re='^[0-9]+$'
	if ! [[ $leopardResultsCount =~ $re ]] ; then
   		leopardResultsCount=0
	fi
	re='^[0-9]+$'
	if ! [[ $snowLeopardResultsCount =~ $re ]] ; then
   	   	snowLeopardResultsCount=0
	fi
	re='^[0-9]+$'
	if ! [[ $lionResultsCount =~ $re ]] ; then
   		lionResultsCount=0
	fi
	re='^[0-9]+$'
	if ! [[ $mountainLionResultsCount =~ $re ]] ; then
   		mountainLionResultsCount=0
	fi
	re='^[0-9]+$'
	if ! [[ $mavericksResultsCount =~ $re ]] ; then
   		mavericksResultsCount=0
	fi
	
	##DEBUG
	##echo -e "leopard is $leopardResultsCount"
	##echo -e "snow leopard is $snowLeopardResultsCount"
	##echo -e "lion is $lionResultsCount"
	##echo -e "mountain lion is $mountainLionResultsCount"
	##echo -e "mavericks is $mavericksResultsCount"
	
##prep chart creation
TEMP=$(mktemp -t chart.XXXXX)
cat > $TEMP <<EOF
<html>
  <head>
    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">

      // Load the Visualization API and the piechart package.
      google.load('visualization', '1.0', {'packages':['corechart']});

      // Set a callback to run when the Google Visualization API is loaded.
      google.setOnLoadCallback(drawChart);

      // Callback that creates and populates a data table,
      // instantiates the pie chart, passes in the data and
      // draws it.
      function drawChart() {

        // Create the data table.
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Title');
        data.addColumn('number', 'Value');
        data.addRows([
          ['Leopard', $leopardResultsCount], ['Snow Leopard', $snowLeopardResultsCount], ['Lion', $lionResultsCount], ['Mountain Lion', $mountainLionResultsCount], ['Mavericks', $mavericksResultsCount]
          ]);

        // Set chart options
        var options = {'title':'OS X Systems',
                       'width':900,
                       'height':900};

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
  </head>

  <body>
    <!--Div that will hold the pie chart-->
    <div id="chart_div"></div>
  </body>
</html>
EOF



# open browser
case $(uname) in
   Darwin)
      open -a /Applications/Firefox.app $TEMP
      ;;

   Linux|SunOS)
      firefox $TEMP
      ;;
 esac

}

##validate ##offline due to reasons mentioned above
chartMe

exit 0;
