#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's License found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 2013-10-11

# Modified by
# Version 


### Description 
# Goal is to 

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"

# Script Variables
TEMP=$(mktemp -t chart.XXXXX)
QUERY106=15
QUERY107=15
QUERY108=69
QUERY109=1
cat > "$TEMP".html <<EOF
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
          ['Snow Leopard', $QUERY106], ['Lion', $QUERY107], ['Mountain Lion', $QUERY108], ['Mavericks', $QUERY109]
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

# Script Functions

# Browser settings are saved in LaunchServices... which is a giant array.
for (( i = 1; i < 100; i++ )); do
    handler=`/usr/libexec/PlistBuddy -c "print :LSHandlers:${i}:LSHandlerURLScheme" ~/Library/Preferences/com.apple.LaunchServices.plist 2>&1`
    handler2=`/usr/libexec/PlistBuddy -c "print :LSHandlers:${i}:LSHandlerRoleAll" ~/Library/Preferences/com.apple.LaunchServices.plist 2>&1`
    [ "${handler}" == "http" ] && { browserPlist="${handler2}"; }
done

browser=`echo "${browserPlist}" | awk -F "." {'print $2'}`
if [[ "${browser}" == "google" ]]; then
  open -a /Applications/Google\ Chrome.app "$TEMP".html
elif [[ "${browser}" == "mozilla" ]]; then
  open -a /Applications/Firefox.app "$TEMP".html
else
  open -a /Applications/Safari.app "$TEMP".html
fi
