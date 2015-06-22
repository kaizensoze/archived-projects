
var Q = require("q");
var net = require("net");
var spawn = require("child_process").spawn;
var fs = require("fs");
var config = require(__dirname + "/../../../config.json");

var regex1 = new RegExp(/\w*\[-?\d\]/g);
var regex2 = new RegExp(/\w*/);
var regex3 = new RegExp(/-?\d/);

// finding emoticons
var regex4 = new RegExp(/\s.{2,5}\[-?\d\semoticon\]/g); //using this to avoid false positives, 
// replace with \s\S{2,}\s\[-?\d\semoticon\] once sentistrength is updated
var regex5 = new RegExp(/\S{2,}/); //finds the emoticon and the space, once regex4 is used

/**
 * Creates SentiStrength instance for given team.
 * Uses generic SentiStrength if no team specified.
 * 
 * @param {String} team The team to process SentiStrength data for.
 */
function SentiStrength(team) {
  // team
  if (!team || team === "" || team === "generic") {
    this.team = "generic";
  } else {
    this.team = team;
  }

  // data path
  var teamPath = "";
  if (this.team !== "generic") {
    teamPath = "-"+this.team;
  }
  this.dataPath = "/resources/data"+teamPath+"/";

  // port
  this.port = config.sentistrength.next_available_port++;

  // dirty words list
  this.dirtyWords = fs.readFileSync(__dirname + this.dataPath + 'DirtyWords.txt').toString().split("\n");
}

/**
 * Spawn an underlying java process.
 * 
 * @return {Promise} A promise object determining whether or not the spawned java process succeeded.
 */
SentiStrength.prototype.spawnProcess = function() {
  var command = 'java';
  var args = [
    "-jar", 
    __dirname + "/resources/senti-strength.jar", "explain", "sentidata",
    __dirname + this.dataPath, "listen", this.port
  ];

  var _this = this;
  var dfd = Q.defer();

  var java = spawn(command, args);

  java.stdout.on('data', function(data) {
    _this.javaProcess = java;
    dfd.resolve(_this.javaProcess.pid);
  });

  java.stderr.on('data', function(data) {
    dfd.reject(new Error("Unable to create java process for sentistrength:"+_this.team));
  });

  return dfd.promise;
}

/**
 * Checks a string for dirty words based on sentistrength instance's dirty words list.
 * 
 * @param  {String} s The string to check for dirty words.
 * @return {Boolean} True or false depending on if the string contains dirty words.
 */
SentiStrength.prototype.checkDirty = function(s) {
  var searchS = s.replace(" ", "").toLowerCase();
  for (d in this.dirtyWords) {
      if (searchS.indexOf(this.dirtyWords[d]) != -1) {
          return true;
      }
  }
  return false;
}

/**
 * Parses a string for energy words.
 * 
 * @param  {String} s The string to parse for energy words.
 * @return {Array} An array of energy word mappings.
 */
SentiStrength.prototype.parseEnergyWords = function(s) {
  var energy = [];  // return array

  var pairs = s.match(regex1);
  
  for (p in pairs) {
      var word_match = pairs[p].match(regex2);
      
      var value_match = pairs[p].match(regex3);
              
      energy.push( {
          word:word_match[0], 
          value:parseInt(value_match[0],10)
      } );
  }
  
  var emoticons_pairs = s.match(regex4);
  
  for (p in emoticons_pairs) {
      var emoticon = emoticons_pairs[p].match(regex5);

      var value = emoticons_pairs[p].match(regex3);
      
      energy.push( {
          emoticon:emoticon[0], 
          value:parseInt(value[0],10)
      } );

  }

  return energy;
}

/**
 * Takes the returned sentistrength data and normalizes it.
 * 
 * @param  {String} data The sentistrength data.
 * @return {Array} An object with normalized sentistrength data.
 */
SentiStrength.prototype.normalizeEnergy = function(data) {
  // Contains the positive and negative energy amounts
  var returnvals = [];
  var energy = data.trim().split(" ");
  
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
  returnvals[4] = this.team;

  return returnvals;
}

/**
 * Run message against underlying sentistrength java process.
 * 
 * @param  {String} msg The message to pass through sentistrength.
 * @return {Promise} A promise object determining whether or not the sentistrength instance was able to connect to the underlying java process.
 */
SentiStrength.prototype.analyze = function(msg) {
  var _this = this;
  var dfd = Q.defer();

  msg += " .";

  var socket = net.connect(this.port, function() {
    socket.write("GET /" + msg + "\n");
  });

  socket.on("data", function(data) {
    dfd.resolve( _this.normalizeEnergy(data.toString()) );
  });

  // Ensure errors can be accounted for...
  socket.on("error", function(err) {
    dfd.reject(new Error("Unable to connect to socket for sentistrength:"+_this.team));
  });

  return dfd.promise;
};

/**
 * Kills the underlying java process.
 */
SentiStrength.prototype.cleanup = function() {
  if (this.javaProcess) {
    this.javaProcess.kill();
  }
};

module.exports = SentiStrength;
