WGW2015-Server
==============

Node server for WhosGonnaWin campaign

## api endpoints

    http://wgwapi.com/streams

    http://wgwapi.com/counts
    http://wgwapi.com/currentCounts

    http://wgwapi.com/stateCounts
    http://wgwapi.com/currentStateCounts

    http://wgwapi.com/postVote

## params for count endpoints (examples)

    http://wgwapi.com/counts?team=seahawks&team=broncos
    http://wgwapi.com/counts?date=2014-12-19&date=2014-12-18
    http://wgwapi.com/counts?team=seahawks&date=2014-12-19&date=2014-12-18

## post vote
To test posting a vote, you can do `curl -X POST http://wgwapi.com/postVote --data "team=seahawks"` and then compare counts:

    http://wgwapi.com/counts
    http://wgwapi.com/counts?excludeDirectVotes=1
