# API Server

The API server takes the tweet data inserted into the CouchDB database via the algorithm server and returns JSON.  
The server runs on port 4577.

## Running the server

`cd api && node index.js` or `node api`

## The endpoints

There are 8 questions and 4 endpoints per question, with the endpoint format being:

    /:question/pos
    /:question/neg
    /:question/confidence
    /:question/tweets

For each endpoint, you can pass 4 args:

    time: day|hour|15min|min (default: day)
    num: integer (default: 1)
    start: YYYY-MM-DDTHH:mm (default: 01/01/1970)
    end: YYYY-MM-DDTHH:mm (default: now)

The results returned are in descending order from most recent to least recent.  
NOTE: The results do not include the current unit of time.

### Example request/response

(assuming the current day is 11/05/2013)

1)

    http://localhost:4577/game/pos?time=day&num=1
    {
      “question”: “game”,
      “type”: “pos”,
      "afc_team": "<afc_team>",
      "nfc_team": "<nfc_team>",
      "afc": [
        {"time":[2013, 11, 04, null, null], "value":79}
      ],
      "nfc": [
        {"time":[2013, 11, 04, null, null], "value":29}
      ]
    }

2)

    http://localhost:4577/game/neg?time=day&num=3
    {
      “question”: “game”,
      “type”: “neg”,
      "afc_team": "<afc_team>",
      "nfc_team": "<nfc_team>",
      "afc": [
        {"time":[2013, 11, 04, null, null], "value":100},
        {"time":[2013, 11, 03, null, null], "value":50},
        {"time":[2013, 11, 02, null, null], "value":250}
      ],
      "nfc": [
        {"time":[2013, 11, 04, null, null], "value":90},
        {"time":[2013, 11, 03, null, null], "value":80},
        {"time":[2013, 11, 02, null, null], "value":70}
      ]
    }

3)

    http://localhost:4577/game/neg?time=day&start=2013-11-01T23:59&end=2013-11-04T00:00
    {
      “question”: “game”,
      “type”: “neg”,
      "afc_team": "<afc_team>",
      "nfc_team": "<nfc_team>",
      "afc": [
        {"time":[2013, 11, 04, null, null], "value":500},
        {"time":[2013, 11, 03, null, null], "value":100},
        {"time":[2013, 11, 02, null, null], "value":50},
        {"time":[2013, 11, 01, null, null], "value":250}
      ],
      "nfc": [
        {"time":[2013, 11, 04, null, null], "value":90},
        {"time":[2013, 11, 03, null, null], "value":80},
        {"time":[2013, 11, 02, null, null], "value":70},
        {"time":[2013, 11, 01, null, null], "value":20}
      ]
    }