

// add explain here?
var SentiStrength = require(__dirname + "/../algorithm/strategy/java-network/");

//process.stdin.resume();
//process.stdin.setEncoding('utf8');

var _ = require("underscore");
var util = require('util');
var readline = require('readline');
var Q = require("q");
var net = require("net");

var fs = require('fs');
var currIndex = 0;

// take in args
var jsonFile = process.argv[2];
var ssType = process.argv[3];
var startIndex = parseInt(process.argv[4],10);

if (!jsonFile) {
  console.log('Please pass the name of a JSON file.\nFormat: node check-sentistrength.js <filename> <generic/afc/nfc> <start ind>\n');
  process.exit(1);
}

if (!ssType||!isValidSentiStrength(ssType)){

  console.log('Please specify which SentiStrength engine to use, generic, afc, or nfc.\nFormat: node check-sentistrength.js <filename> <generic/afc/nfc> <start ind>\n');
  process.exit(1);

}


if (isInt(startIndex)){
	currIndex = startIndex;
}else{ currIndex = 0};


function isInt(n) {
   return typeof n === 'number' && n % 1 == 0;
}

function isValidSentiStrength(type) {
   return (type==="generic"||type==="afc"||type==="nfc");
}

var ss = [new SentiStrength(ssType)];


// spawn our processes
var promises = ss.map(function(ssObj) {
  return ssObj.spawnProcess();
});

console.log("");
console.log("Starting index at " + currIndex + ".");

console.log("Using " + ssType + " SentiStrength engine.");

var fileRoot = jsonFile.split('.')[0];
var savedEntriesFile = fileRoot + "_saved.txt";

console.log("Saved entries will be stored in " + savedEntriesFile + ".");

console.log("");
console.log("Press 'f' to move forward and 'd' to move backward through JSON entries.");
console.log("Type a number to show a specific entry.");
console.log("Press 's' to save an entry in a text file.");
console.log("Press 'c' to clear entire saved entry text file.");
console.log("Press 'q' to quit.");

console.log("");
console.log("Format is:");
console.log("#Index  PosSentiscore\tNegSentiscore\tDirtyCheck\tTweetText");


//get the file.
var data = fs.readFileSync(jsonFile, 'utf8');
var lines = data.split("\n");

var maxIndex = lines.length - 2;

if (lines.length < 0){

	console.log("Empty JSON file.  Exiting.");
	process.exit(1);
}

currIndex-=1;


 var consoleInput = readline.createInterface(process.stdin, process.stdout);

 consoleInput.on('line', function(text){

 	text.trim();

 	if (text === 'q') {

	  console.log("Exiting utility.");
    cleanup();
	  process.exit(0);

    }else if (text === 'f'){

    	if (currIndex + 1 < maxIndex)
    		currIndex++;
    	else
    		console.log("End of JSON file reached.");

    	parseJSONTweet(lines[currIndex]);

    }else if (text === 'd'){

    	if (currIndex > 0)
			currIndex--;
		else
			console.log("Beginning of JSON file reached");

		parseJSONTweet(lines[currIndex]);
    	
    }else if (text === 's'){

    	parseJSONTweet(lines[currIndex], false, true);
    	
    }else if (text === 'c'){

    	consoleInput.question("Are you sure you want to clear file " + savedEntriesFile + " (y/n) ?\n", function(answer){

    		if (answer==='y'){
    			console.log("Clearing " + savedEntriesFile);
    			fs.writeFile(savedEntriesFile, "", function(err) {

		if (err)
			console.log(err);
		});

    		}else if (answer==='n'){
    			console.log("Okay, I'll keep the file as is.\n");
    		}else{
    			console.log("You did not enter a valid choice.  Valid choices included 'y' to confirm or 'n' to cancel.");
    		}
    		
    	});

    
    }else{

    	text.replace(/[^0-9]/g, ''); 
    	var num = parseInt(text, 10);

    	if (isInt(num)){

    		if ((num > -1) && (num < maxIndex+1)){

    			console.log("Going to tweet #" + num + ".");
    			currIndex = num;
    			parseJSONTweet(lines[currIndex]);

    		}else{

    			console.log("Not a tweet within range.  Range is 0 to " + maxIndex);
    		}

    	}else{

    		console.log("Not a valid console option.  Type q to quit, s to save, f and d to navigate tweets.");
    	}

    }

 });


function saveTweet(data){

	console.log("Saving tweet " + currIndex);

	var line = "#" + currIndex + ": " + ssType + " " + data.sentiment[0] + "\t" + data.sentiment[1] + " \t" + "Dirty=" + data.sentiment[3] + "\t" + data.twitter.text + "\n";
	fs.appendFile(savedEntriesFile, line, function(err) {

		if (err)
			console.log(err);
	});


}

function printTweet(data, typeInd){

	console.log("#" + currIndex + ": " + ssType + " " + data.sentiment[0] + "\t" + data.sentiment[1] + " \t" + "Dirty=" + data.sentiment[3] + "\t" + data.sentiment[5]);

}

  function parseJSONTweet(jsonLine, print, save) {

   print = typeof print !== 'undefined' ? print : true;
   save = typeof save !== 'undefined' ? save : false;

  try {

  	var tweetData = JSON.parse(jsonLine);

  }catch (err){

  	console.log("Bad JSON line.  Updating maxIndex");
  	maxIndex--;

  }

  try {
    //var interaction = tweetData.data;
    var tweet = tweetData.twitter;

    if (tweet.text) {

      var ind = 0;

       _.each(ss, function(ssObj) {
       ssObj.analyzeVerbose(tweet.text).then(function(sentiment){


        if (!sentiment[3]) {
        // assuming the dirty words list for all sentistrength instances are the same
        sentiment[3] = ssObj.checkDirty(tweet.user.name + tweet.user.screen_name);  
        
        }  

        var twitter = {};
        twitter.id = tweet.id;
        twitter.created_at = tweet.created_at;
        twitter.text = tweet.text;

        // Create document from stream data we want
        var data = {
          
          _id: twitter.id + "_" + ssType,
          twitter: twitter,
          sentiment: sentiment
        
        };

       if (print)
                printTweet(data, ind);
        
        if (save)
                saveTweet(data, ind);

        ind++;
        
      });
      


      });


       


   }
  } catch (err) {
    console.log("Received data with unexpected format. Skipping. error:", err)
  }

  }


SentiStrength.prototype.normalizeEnergyVerbose = function(data) {
  // Contains the positive and negative energy amounts
  var returnvals = [];
  data = data.replace("[result: max + and - of any sentence]","");
  var energy = data.trim().split(" ");
  
  console.log("normalizing energy verbose!");
  //console.log(data);

  // Format:
  //
  // energy[0] = positive energy (int)
  // energy[1] = negative energy (int)
  // energy[2] = array of form
  // [ {word:"love", value:3},
  //   {word:"hate", value:-4},
  //   …
  // ]
  
  // Ensure each index is an integer
  returnvals[0] = parseInt(energy[0], 10)-1;
  returnvals[1] = parseInt(energy[1], 10)+1;
  returnvals[2] = this.parseEnergyWords(data);
  returnvals[3] = this.checkDirty(data);
  returnvals[4] = this.type;

  var taggedTweet = "";
  for (var i=2; i<energy.length; i++){
    taggedTweet+=energy[i] + " ";
  }

  returnvals[5] = taggedTweet;

  return returnvals;
}

SentiStrength.prototype.analyzeVerbose = function(msg) {

  var _this = this;
  var deferred = Q.defer();

  msg += " .";

  var socket = net.connect(this.port, function() {
    socket.write("GET /" + msg + "\n");
  });

  socket.on("data", function(data) {
    deferred.resolve( _this.normalizeEnergyVerbose(data.toString()) );
  });

  // Ensure errors can be accounted for...
  socket.on("error", function(err) {
    deferred.reject(new Error("Unable to connect to socket for sentistrength:"+_this.type));
  });

  return deferred.promise;
};


function cleanup() {
  _.each(ss, function(ssObj) {
    ssObj.cleanup();
  });
}

process.on('exit', function() {
   cleanup();
});

// triggered when killing program via Ctrl+C
process.on('SIGINT', function() {
   process.exit();
});


