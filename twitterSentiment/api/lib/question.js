
// dependencies
var _ = require("underscore");
var Q = require("q");
var nano = require("nano");
var moment = require('moment');
var request = require("request");

// config file
var config = require(__dirname + "/../../config.json");

// database connection (couchdb)
var db = nano(config.couch.slave.url);

/**
 * Adjusts the params accordingly (applies any defaults, etc.)
 * 
 * @param  {Object} requestParams Request params object.
 * @return {Object}               The adjusted request params object.
 */
exports.adjustRequestParams = function(requestParams) {
  // apply defaults for any params not provided

  // design name
  requestParams.designName = "question";

  // type
  if (!requestParams.type) {
    requestParams.type = "confidence";
  }

  // time
  if (!requestParams.time) {
    requestParams.time = "day";
  }

  // allow aliases for original start/end params: start/stop, begin/end
  if (!requestParams.start && requestParams.begin) {
    requestParams.start = requestParams.begin;
  }
  if (!requestParams.end && requestParams.stop) {
    requestParams.end = requestParams.stop;
  }

  if (requestParams.frame === "current" || (!requestParams.num && !requestParams.start && !requestParams.end)) {
    requestParams.frame = "current";
  }

  // num
  if (!requestParams.num) {
    requestParams.num = 1;
  }

  // apply limit flag
  if (!requestParams.start && !requestParams.end) {
    requestParams.applyLimit = true;
  }

  // get timezone offset
  var offset = moment().zone();

  // start
  var startProvided = false;
  var startCopy;
  if (!requestParams.start) {
    if (requestParams.end) {
      var decrementAmount = amountToDecrementBy2(requestParams.time);
      requestParams.start = moment(requestParams.end, "YYYY-MM-DDTHH:mm").clone().subtract(decrementAmount[0], requestParams.num * decrementAmount[1]);
    } else {
      requestParams.start = moment(0); // 01/01/1970
      requestParams.start = moment(requestParams.start.valueOf() - (5-(offset/60))*60*60*1000);
    }
  } else {
    startProvided = true;
    requestParams.start = moment(requestParams.start, "YYYY-MM-DDTHH:mm");
    startCopy = requestParams.start.clone();
  }

  // end
  var endDate;
  var endProvided = false;
  var now = moment(moment().valueOf() - (5-(offset/60))*60*60*1000);
  if (!requestParams.end) {
    if (startProvided) {
      var timeToAdd = amountToDecrementBy2(requestParams.time); // reuse util function
      endDate = requestParams.start.clone().add(timeToAdd[0], requestParams.num * timeToAdd[1]);
    } else {
      endDate = now.clone();
    }
  } else {
    endProvided = true;
    endDate = moment(requestParams.end, "YYYY-MM-DDTHH:mm");
  }

  // set end date to now if provided end date is in the future
  var startOfCurrentMinute = now.clone().startOf("minute");
  if (endDate.isAfter(startOfCurrentMinute)) {
    endDate = startOfCurrentMinute;
  }

  // if end date falls within current unit of time, don't include current unit of time (ignore if current frame requested)
  var startOfDate;
  if (requestParams.frame === "current") {
    startOfDate = getStartOfDate(now.clone(), "min");
  } else {
    startOfDate = getStartOfDate(now.clone(), requestParams.time);
  }
  if (!endDate.isBefore(startOfDate)) {
    endDate = startOfDate.clone().subtract("minutes", 1);
  }

  requestParams.end = endDate;

  // check if start/end dates make sense (if not, set start = end)
  var startEndDatesMakeNoSense = requestParams.start.isAfter(requestParams.end) || requestParams.end.isBefore(requestParams.start);
  if (startEndDatesMakeNoSense) {
    requestParams.start = requestParams.end.clone();
  }

  // if start/end dates don't make sense or fall solely within current unit of time [in prior mode], make a note to return no data
  if (requestParams.frame !== "current") {
    if (startEndDatesMakeNoSense || (requestParams.start.isSame(requestParams.end) && !startCopy.isBefore(startOfDate))) {
      requestParams.returnNothing = true;
    }
  }

  // exception for frame=current
  if (requestParams.frame === "current") {
    // ignore limit
    requestParams.applyLimit = false;

    // start date
    if (!startProvided) {
      var startOfDate = getStartOfDate(now.clone(), requestParams.time);
      requestParams.start = startOfDate;
    }
    
    // end date
    if (!endProvided) {
      if (requestParams.time === "min") {
        requestParams.end = startOfCurrentMinute.clone();
      } else {
        requestParams.end = startOfCurrentMinute.clone().subtract("minutes", 1);
      }
    }

    // do another [frame=current]-specific check to see that start/end make sense
    startEndDatesMakeNoSense = requestParams.start.isAfter(requestParams.end) || requestParams.end.isBefore(requestParams.start);
    if (startEndDatesMakeNoSense) {
      requestParams.start = requestParams.end.clone();
    }

    requestParams.time = "day";
  }

  // exception for type=confidence (gather an additional 15 minutes of [prefill] data)
  if (requestParams.type === "confidence") {
    var numPrefillUnits;
    if (requestParams.time === "min") {
      numPrefillUnits = 15;
    } else if (requestParams.time === "15min") {
      numPrefillUnits = 1;
    } else {
      numPrefillUnits = 0;
    }

    if (requestParams.applyLimit) {
      requestParams.num = parseInt(requestParams.num) + numPrefillUnits;
    } else {
      if (requestParams.time === "min" || requestParams.time === "15min") {
        requestParams.start.subtract("minutes", 15);
      }
    }
    requestParams.prefillAmount = numPrefillUnits;
  }

  // espn exception
  if (requestParams.question === "espn") {
    var thisMinute = startOfCurrentMinute.clone();
    var params = {
      "question": "espn",
      "type": "tweets",
      "time": "day",
      "num": 1,
      "start": thisMinute,
      "end": thisMinute
    };
    requestParams = params;
  }

  return requestParams;
};

/**
 * Validates the request params.
 * 
 * @param  {Object} requestParams Request params object.
 * @return {Boolean}              True or false depending on if the request params are valid.
 */
exports.validateRequestParams = function(requestParams) {
  // question
  var questions = ["game", "passing", "rushing", "defense", "fans", "espn"];
  if (!_.contains(questions, requestParams.question)) {
    return false;
  }

  // type
  var types = ["pos", "neg", "confidence", "tweets"];
  if (!_.contains(types, requestParams.type)) {
    return false;
  }

  // time
  var times = ["year", "month", "day", "hour", "15min", "min"];
  if (!_.contains(times, requestParams.time)) {
    return false;
  }

  // num
  if (isNaN(parseInt(requestParams.num))) {
    return false;
  }

  // start
  if (!requestParams.start.isValid()) {
    return false;
  }
  
  // end
  if (!requestParams.end.isValid()) {
    return false;
  }

  return true;
};

/**
 * Generates a view filters object from the request params object.
 * 
 * @param  {Object} requestParams Request params object.
 * @return {Object}               View filters object.
 */
exports.generateViewFiltersFromRequestParams = function(requestParams) {
  // default filters
  var filters = {
    group: true,
    descending: true
  };

  // time
  var timeIndex = ["year", "month", "day", "hour", "15min", "min"].indexOf(requestParams.time);
  filters.group_level = timeIndex + 1 + ["question", "team"].length;

  // num
  var num = parseInt(requestParams.num);
  // only limit results if start/end datetimes not provided
  if (requestParams.applyLimit) {
    filters.limit = num;
  }

  // start/end datetimes to array form
  filters.startkey = dateToArray(requestParams.start);
  filters.endkey = dateToArray(requestParams.end);

  // swap start and end keys since results are in descending order
  var temp = filters.startkey;
  filters.startkey = filters.endkey;
  filters.endkey = temp;

  // add question to beginning of start, end arrays
  filters.startkey.unshift(requestParams.question);
  filters.endkey.unshift(requestParams.question);

  return filters;
};

/**
 * Gets the data to be returned by the api for the given endpoint.
 * 
 * @param  {Object}   requestParams Request params object.
 * @param  {Object}   viewFilters   View filters object.
 * @param  {Function} done          Callback called once data is ready to be returned.
 */
exports.getData = function(requestParams, viewFilters, done) {
  var question = requestParams.question;
  var type = requestParams.type;

  if (question === "espn") {
    getESPNData().then(function(counts) {
      var afc_count, nfc_count;

      for (var i=0; i < counts.length; i++) {
        var countLabel = counts[i][0];
        var count = counts[i][1];

        if (countLabel === "afc") {
          afc_count = count;
        } else {
          nfc_count = count;
        }
      }

      var espnData = {
        "question": "espn",
        "type": "tweets",
        "afc_team": "broncos",
        "nfc_team": "seahawks",
        "afc": afc_count,
        "nfc": nfc_count
      };
      done(espnData);
      return;
    });
    return;
  }

  // data set
  var dataSet = module.exports.createDataSet(requestParams, viewFilters);

  // afc view
  var afcViewFilters = clone(viewFilters);
  afcViewFilters.startkey.splice(1, 0, "afc");
  afcViewFilters.endkey.splice(1, 0, "afc");
  var afcViewPromise = module.exports.view("afc", requestParams, afcViewFilters);

  // nfc view
  var nfcViewFilters = clone(viewFilters);
  nfcViewFilters.startkey.splice(1, 0, "nfc");
  nfcViewFilters.endkey.splice(1, 0, "nfc");
  var nfcViewPromise = module.exports.view("nfc", requestParams, nfcViewFilters);

  // view promises
  var viewPromises = [afcViewPromise, nfcViewPromise];

  // wait on the view data and then process it
  Q.all(viewPromises).then(function(viewObjects) {
    // initialize data to be returned by API
    var data = {
      "question": question,
      "type": type,
      "afc_team": config.questions[question].afc,
      "nfc_team": config.questions[question].nfc
    };

    if (!requestParams.returnNothing) {
      // for each view, apply its data to the expected data set
      viewObjects.forEach(function(viewObject) {
        // view label (ex: afc, nfc)
        var viewLabel = viewObject.label;

        // view data
        var viewData = viewObject[viewLabel];

        // post process view data
        viewData = module.exports.postProcess(requestParams, viewData);

        // apply post processed view data to the data set
        var _dataSet = applyViewToDataSet(clone(dataSet), viewData);

        // exception for confidence per-min data
        if (requestParams.type === "confidence" && requestParams.fill !== "off") {
          _dataSet = zeroValsFilledIn(_dataSet, requestParams.prefillAmount);
        }

        // if data is grouped by minute, apply moving average to view data set
        if (requestParams.time === "min" && requestParams.smoothing === "on") {
          _dataSet = movingAverage(_dataSet, 3); // 7 min window (2n+1)
        }

        // if current frame requested, return one averaged data point for given timespan
        if (requestParams.frame === "current") {
          var val;

          // console.log();

          if (requestParams.type === "confidence") {
            var pos = 0;
            var neg = 0;
            for (var i=0; i < _dataSet.length; i++) {
              pos += isNaN(_dataSet[i].pos) ? 0 : _dataSet[i].pos;
              neg += isNaN(_dataSet[i].neg) ? 0 : _dataSet[i].neg;

              // console.log(_dataSet[i].time, _dataSet[i].pos, _dataSet[i].neg);
            }

            if (pos+neg === 0) {
              val = 0;
            } else {
              val = pos / (pos + neg);
            }
          } else {
            var sum = 0;
            for (var i=0; i < _dataSet.length; i++) {
              sum += _dataSet[i].value;
            }
            val = Math.round(sum);
          }

          _dataSet = val;
        }

        var dataObj = {};
        dataObj[viewLabel] = _dataSet;

        // add this view data set to data to be returned
        _.extend(data, dataObj);
      });
    }
    
    done(data);
  }).catch(function(error) {
    throw error;
  });
};

function getESPNData() {
  return Q.all([
    getESPNafc(),
    getESPNnfc()
  ]);
}

function getESPNafc() {
  var dfd = Q.defer();

  request('http://api.massrelevance.com/compare.json?streams=BristolDev/super-bowl-hashtag-battle-answer-2', function (error, response, body) {
    var json = JSON.parse(body);
    var afc_count = json.streams[0].count.approved;
    // console.log(afc_count);
    dfd.resolve(["afc", afc_count]);
  });

  return dfd.promise;
}

function getESPNnfc() {
  var dfd = Q.defer();

  request('http://api.massrelevance.com/compare.json?streams=BristolDev/super-bowl-hashtag-battle-answer-1', function (error, response, body) {
    var json = JSON.parse(body);
    var nfc_count = json.streams[0].count.approved;
    // console.log(nfc_count);
    dfd.resolve(["nfc", nfc_count]);
  });

  return dfd.promise;
}

/**
 * Creates a data set with expected time-indexed data points.
 * 
 * @param  {Object} requestParams Request params object.
 * @param  {Object} viewFilters   View filters object.
 * @return {Object}               The data set.
 */
exports.createDataSet = function(requestParams, viewFilters) {
  // figure out how much time to subtract by on each iteration
  var dateArrayLength = ["year", "month", "day", "hour", "15min", "min"].indexOf(requestParams.time) + 1;
  var decrementAmount = amountToDecrementBy(dateArrayLength);

  // use end date if provided, otherwise end = now
  var endDate = moment(requestParams.end, "YYYY-MM-DDTHH:mm");

  // figure out how many data points to initialize with default value
  var numDataPoints;
  if (viewFilters.limit) {
    numDataPoints = viewFilters.limit;
  } else {
    // # data points = range between start and end date
    var diffUnit = decrementAmount[0];
    var startDate = requestParams.start;
    var endDate = requestParams.end;
    numDataPoints = endDate.diff(startDate, diffUnit);

    // for 15min case, further divide by 15 since the diff taken was in minutes
    if (decrementAmount[1] == 15) {
      var o = 0;
      while (numDataPoints-15 >= 0) {
        numDataPoints -= 15;
        o++;
      }
      numDataPoints = o;
    }

    // both start and end dates are inclusive so add 1
    numDataPoints += 1;
  }

  var defaultVal;
  if (requestParams.type === "confidence") {
    defaultVal = NaN;
  } else {
    defaultVal = 0;
  }

  // initialize object with data points for expected datetimes
  var dataSet = {};

  var d = dateToArray(endDate);
  d = d.slice(0, dateArrayLength);
  d = adjustDateArray(d);
  d = nullPad(d, ["year", "month", "day", "hour", "15min", "min"].length);
  dataSet[d] = {time:d, value:defaultVal};

  for (var i=0; i < numDataPoints-1; i++) {
    d = dateToArray(endDate.subtract(decrementAmount[0], decrementAmount[1]));
    d = d.slice(0, dateArrayLength);
    d = adjustDateArray(d);
    d = nullPad(d, ["year", "month", "day", "hour", "15min", "min"].length);
    dataSet[d] = {time:d, value:defaultVal};
  }

  return dataSet;
};

/**
 * Gets the data returned by a view.
 * 
 * @param  {String} label         A label associated with the view's data.
 * @param  {Object} requestParams Request params object
 * @param  {Object} viewFilters   View filters object
 * @return {Promise}              A promise that resolves to view's data.
 */
exports.view = function(label, requestParams, viewFilters) {
  var dfd = Q.defer();

  var designName = "question";
  var viewName = requestParams.type;
  var view = db.view(designName, viewName, viewFilters, function(err, body) {
    if (err) {
      dfd.reject(new Error(err));
    } else {
      var data = {};
      data.label = label;
      data[label] = body.rows;
      dfd.resolve(data);
    }
  });

  // console.log(unescape(view.uri.href));

  return dfd.promise;
};

/**
 * Post processes a view's data.
 * 
 * @param  {Object} requestParams Request params object.
 * @param  {Array} rows           View rows.
 * @return {Array}                Post-processed view rows.
 */
exports.postProcess = function(requestParams, rows) {
  rows.forEach(function(doc) {
    // rename "key" attribute to "time"
    doc.time = doc.key;
    delete doc.key;

    // remove question, conference from time array
    doc.time.splice(0,2);

    // adjust the time array so that month is 1-indexed
    doc.time = adjustDateArray(doc.time);

    // pad time array with null
    doc.time = nullPad(doc.time, ["year", "month", "day", "hour", "15min", "min"].length);

    // special case for confidence, since it returns an array
    if (doc.value instanceof Array) {
      // confidence = pos/(pos+neg)
      var pos = Math.round(doc.value[0]);
      var neg = Math.round(doc.value[1]);
      doc.value = pos / (pos + neg);

      if (requestParams.frame === "current") {
        doc.pos = pos;
        doc.neg = neg;
      }
    } else {
      // round value for tweets, pos, neg (result might be a float since scaled by coefficient)
      doc.value = Math.round(doc.value);
    }
  });

  return rows;
};

/**
 * Applies view data to a data set.
 * 
 * @param  {Object} dataSet  Data set object.
 * @param  {Array} viewData  View rows.
 * @return {Object}          Data set object containing applied view data.
 */
function applyViewToDataSet(dataSet, viewData) {
  // create date array to row mapping for view data
  var mapping = {}
  viewData.forEach(function(row) {
    mapping[row.time] = row;
  });

  // get list of keys from view data
  var rowDateKeys = _.keys(mapping);

  // get list of keys from view data set
  var dateKeys = _.keys(dataSet);

  // get intersection of datetime keys from view data and view data set
  var intersection = _.intersection(dateKeys, rowDateKeys);
  intersection.forEach(function(dateKey) {
    dataSet[dateKey] = mapping[dateKey];
  });

  dataSet = _.values(dataSet);
  return dataSet;
}

/**
 * Fills in confidence 0-values.
 * 
 * @param  {Array} dataSet data set
 * @return {Array}         filled in data set
 */
function zeroValsFilledIn(dataSet, prefillAmount) {
  var lastValidVal;

  // remove the prefill and set lastValidVal to latest non-NaN value in the prefill
  var prefill = dataSet.splice(dataSet.length-prefillAmount, prefillAmount);
  var lastValidPrefillRow = _.find(prefill, function(row) {
    return row.value !== null && !isNaN(row.value);
  });

  if (lastValidPrefillRow) {
    lastValidVal = lastValidPrefillRow.value;
  } else {
    lastValidVal = 0;  // this shouldn't happen in production but if it does it'll show a higher prefillAmount needs to be used
  }

  for (var i=dataSet.length-1; i >= 0; i--) {
    var val = dataSet[i].value;
    if (val !== null && !isNaN(val)) {
      lastValidVal = val;
    } else {
      dataSet[i].value = lastValidVal;
    }
  }

  return dataSet;
}

/**
 * Applies moving average to view rows.
 * 
 * @param  {Array} rows  View rows.
 * @param  {int} n       Number of neighboring data points on a given side for setting window to apply moving average (2n+1).
 * @return {Array}       View rows with moving average applied.
 */
function movingAverage(rows, n) {
  var averagedRows = [];

  rows.forEach(function(doc, i) {
    var cur_window = rows.slice(i-n, i+n+1);

    var cur_window_values = _.map(cur_window, function(obj) {
      return obj.value;
    });
    var sum = _.reduce(cur_window_values, function(a, b) { return a + b; }, 0);

    var result_value = sum / cur_window.length;
    if (isNaN(result_value)) { result_value = doc.value; }

    // clone the object and modify its value
    var copy = clone(doc);
    copy.value = result_value;

    averagedRows.push(copy);
  });

  return averagedRows;
}

/**
 * Figures out how much time to decrementy by on each iteration
 * given the length of the date array.
 * 
 * @param  {int} dateArrayLength    Length of date array input.
 * @return {Array}                  Array containing the type of time unit and the amount.
 */
function amountToDecrementBy(dateArrayLength) {
  // year, month, day, hour, 15min, min

  switch (dateArrayLength) {
    case 1:
      return ["years", 1];
    case 2:
      return ["months", 1];
    case 3:
      return ["days", 1];
    case 4:
      return ["hours", 1];
    case 5:
      return ["minutes", 15];
    case 6:
      return ["minutes", 1];
  }
}

function amountToDecrementBy2(timeParam) {
  // year, month, day, hour, 15min, min

  switch (timeParam) {
    case "year":
      return ["years", 1];
    case "month":
      return ["months", 1];
    case "day":
      return ["days", 1];
    case "hour":
      return ["hours", 1];
    case "15min":
      return ["minutes", 15];
    case "min":
      return ["minutes", 1];
  }
}

/**
 * Get the start of time (not start param) for now
 * for given time param.
 * 
 * @param  {[type]} timeParam The time param
 */
function getStartOfDate(now, timeParam) {
  var startOfDate;
  switch (timeParam) {
    case "day":
      startOfDate = now.startOf("day");
      break;
    case "hour":
      startOfDate = now.startOf("hour");
      break;
    case "15min":
      var fifteenMinIndex = dateToArray(now)[4];
      startOfDate = now.startOf("hour").add("minutes", fifteenMinIndex * 15);
      break;
    default:
      startOfDate = now.startOf("minute");
  }

  return startOfDate;
}

/**
 * Converts a date object to an array.
 * 
 * @param  {Object} date Date object
 * @return {Array}       Date object as an array
 */
function dateToArray(date) {
  var year = date.year();
  var month = date.month();
  var day = date.date();
  var hour = date.hour();
  var minute = date.minute();
  var customMinute = Math.floor(minute / 15);

  return [year, month, day, hour, customMinute, minute];
}

/**
 * Adjusts a date array so that its month is 1-indexed.
 * 
 * @param  {Array} dateArray  Date array
 * @return {Array}            Adjusted date array
 */
function adjustDateArray(dateArray) {
  if (dateArray.length >= 2) {
    dateArray[1]++;
  }
  return dateArray;
}

/**
 * Null pads a date array to size toSize.
 * 
 * @param  {Array} dateArray  Date array
 * @param  {int} toSize       Size to pad array to
 * @return {Array}            Padded date array
 */
function nullPad(dateArray, toSize) {
  var copy = clone(dateArray);
  var amountToPad = toSize - dateArray.length;
  for (var i=0; i < amountToPad; i++) {
    copy.push(null);
  }
  return copy;
}

/**
 * Clones an object.
 * 
 * @param  {Object} obj Object to be cloned
 * @return {Object}     Cloned object
 */
function clone(obj) {
  return JSON.parse(JSON.stringify(obj));
}
