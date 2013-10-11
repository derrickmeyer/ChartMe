#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Jeremy Matthews
# Version 1.0.0 - 2013-10-11

# Modified by
# Version 


### Description 
# Goal is to 

# Base Variables that I use for all scripts.
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"

# Script Variables
MY_JSS_BASEURL=$( /usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url )
JSS_FIRST_URL="${MY_JSS_BASEURL}JSSResource/"
JSS_REQUESTED_SUBITEM="computers"
JSS_FULL_URL="${JSS_FIRST_URL}${JSS_REQUESTED_SUBITEM}"
CURL_OPTIONS="-sk -H \"Accept: application/xml\""
MY_TMPFILE="/tmp/$RANDOM.xml"
JSON_OR_XML="XML"
JSS_ID=""
JSS_PASS=""

# Script Functions
validate () {
	[ "${JSS_FIRST_URL}" == "JSSResource/" ] && { echo -n -e "JSS FQDN (with port and slash at the end): "; read JSS_FIRST_URL; }
	[ "${JSS_ID}" == "" ] && { echo -n -e "JSS Username: "; read JSS_ID; }
	[ "${JSS_PASS}" == "" ] && { echo -n -e "JSS Password: "; read JSS_PASS; }

	echo "Running ${SCRIPTNAME} with these settings"
	echo -e "\t${JSS_FIRST_URL}"
	echo -e "\t${JSS_ID}"
	echo -e "\t${JSS_PASS}"
}

chartMe () {
	##if [ "$JSON_OR_XML" = "JSON" ]
	##then
	##CURL_OPTIONS="-sk -H \"Accept: application/xml\""
	##else
	##CURL_OPTIONS="-sk -H \"Accept: application/xml\""
	##fi

	## perform initial pull of computers and get the IDs using XPATH
	string=`curl ${CURL_OPTIONS} -u ${JSS_ID}:${JSS_PASS} $JSS_FULL_URL -X GET | xpath '(/computers/computer/id)'`
	## use sed to strip out the tags and put into separate lines
	string2=`echo "${string}" | sed 's/\<\/id>/\<\/id>\'$'\n/g' | sed 's/\<id>//g' | sed 's/\<\/id>//g'`
	##echo "$string2"

	## get ready to setup a simple command to grab each separate line item and create a custom pull for the data

	END_URL="^-X GET"
	END_URL3="'(/computer/hardware/os_version)'"

	MAJOR_TAG=""
	MINOR_TAG=""
	##echo $BEG_URL "num" $END_URL


	IFS=$'\n'; 
	arr=("$string2"); 
	for i in ${arr[@]}; 
	do 
	##echo "mine" $i; 
	string33=`curl -sk -H \"Accept: application/xml\" -u ${JSS_ID}:${JSS_PASS} $JSS_FULL_URL/id/$i ${END_URL} | xpath '(/computer/hardware/os_version)'`
	string44=`echo "${string33}" | sed 's/\<\/id>/\<\/os_version>\'$'\n/g' | sed 's/\<os_version>//g' | sed 's/\<\/os_version>//g'`
	echo "$string44" >> ~/Desktop/YYY.xml
	echo "$string44" >> "${MY_TMPFILE}"
	done

	##works
	awk '{ print $1}' "${MY_TMPFILE}" | sort -n | uniq -c | sort -n > ~/Desktop/YYY.xml
	awk '{ print $1}' "${MY_TMPFILE}" | sort -n | uniq -c | sort -n > "${MY_TMPFILE}"

	##echo `awk '{arr[$1]++} END {for(i in arr) print i,arr[i]}' ~/Desktop/YYY.xml | sort -nr -k2`
}

validate
chartMe

exit 0;
