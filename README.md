# Rostr
Rostr is a rails app that can be configured as a slack command to retrieve information from google spreadsheet and post it to Slack.

Currently, it is set up to read from on-call and anchor spreadsheet to return team on-call/anchor for the day. It can be used from Slack as follows:

1. `/whosoncall <team name>`
2. `/whosanchor <team name>` 
_(valid team names are CA, CS, UW)_

