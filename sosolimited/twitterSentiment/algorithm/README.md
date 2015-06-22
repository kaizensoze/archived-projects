# Algorithm Server

The algorithm server grabs tweets from the DataSift firehose, passes them through SentiStrength, and inserts the results into a CouchDB database. It uses the NodeJS-Consume package, written by DataSift ([http://github.com/datasift/NodeJS-Consumer](http://github.com/datasift/NodeJS-Consumer)).  
It also uses [promises](https://github.com/kriskowal/q#the-beginning).

**NOTE: The server connects to live DataSift streams and uses up credit, so only leave the server running in the background if you intend to test it over time.**

The DataSift account is capped at 500k interactions per 24 hours.

## Updating a DataSift stream
The config.json file contains a list of datasift streams to be consumed. Updating a stream involves updating the (1) hash, (2) CSDL, and (3) DPU. You'll find these on the datasift site.

1. Go to [http://datasift.com/streams](http://datasift.com/streams) and select the updated stream. On the stream's info page, you'll find the updated stream hash (if not you can click on the "Consume via API" button.)
2. While still on the stream's info page, click on the "Share CSDL" button to get the CSDL. (JSON doesn't allow multiline strings so you'll need to adjust the format to an array).
3. You'll find the DPU on the stream's info page on the left hand side.

After updating the datasift section of the config, check that it matches up with the questions section. When running the server, it'll validate the provided CSDL and make sure the provided DPU matches the actual.

## Running the server
`node algorithm`

(Use `supervisor algorithm` instead on the server to ensure it's always running.)

## Adding a question
Add the question to the questions section of the config, specifying the afc and nfc team names, and the sentistrength types. The team names need to match the name of the sentistrength data folder (data-[team_name]/). The possible sentistrength types are "afc", "nfc", and "generic".

Add the question-related streams to the datasift section of the config.
