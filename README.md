# Rostr
Rostr is a rails app that can be configured with a slack command to retrieve information from google spreadsheet and post it to Slack.

Currently, it is set up to read from PDEV on-call spreadsheet to return team on-call for the current day. It can be used from Slack as follows:

1. `/whosoncall <ROID>` 
2. `/whosoncall <CA/CS/UW>`

#### Also in the works...
`/whosanchor <team name>`

