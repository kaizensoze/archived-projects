
// dependencies
var _ = require("underscore");
var url = require('url');
var express = require("express");
var redis = require("redis");

// config file
var config = require(__dirname + "/../config.json");

// api libs
var apis = {
  question: require(__dirname + "/lib/question.js")
};

// create the express server
var app = express();

// redis client
var redisClient = redis.createClient.apply(undefined, config.redis.connection);
// redis.debug_mode = true;

redisClient.on("error", function (err) {
  console.log(err);
});

// enable CORS
app.all('*', function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");
  next();
});

/**
 * Sends data.
 * 
 * @param  {Object} res    The response object.
 * @param  {Object} params The params object.
 * @param  {Object} data   The data to send.
 */
function send(res, params, data) {
  // return JSONP if callback provided
  if (params.callback) {
    return res.send(params.callback + "(" + JSON.stringify(data) + ");");
  }
  return res.send(data);
}

/**
 * Sets up a route for each endpoint path.
 * 
 * @param  {String} name The name of the api lib to use.
 * @param  {String} path The api endpoint path.
 */
function setupRoute(name, path) {
  var api = apis[name];

  // create api endpoint
  app.get(path, function(req, res) {
    // request params
    var urlParts = url.parse(req.url, true);
    var requestParams = _.defaults({}, req.params, urlParts.query);

    // adjust request params
    requestParams = api.adjustRequestParams(requestParams);

    // validate request params and send 404 if they're not valid
    var paramsValid = api.validateRequestParams(requestParams);
    if (!paramsValid) {
      res.send(404);
      return;
    }

    // console.log();
    // console.log(requestParams.start.toString());
    // console.log(requestParams.end.toString());

    // console.log(requestParams);

    // generate view filters from request params
    var viewFilters = api.generateViewFiltersFromRequestParams(requestParams);

    // console.log(viewFilters);

    // check if query data is cached
    var key = clone(viewFilters);

    key["design"] = requestParams.designName;
    if (requestParams.type) {
      key["view"] = requestParams.type;
    }
    if (requestParams.frame) {
      key["frame"] = requestParams.frame;
    }
    if (requestParams.returnNothing) {
      key["returnNothing"] = requestParams.returnNothing;
    }

    key = JSON.stringify(key);

    // console.log(key);

    redisClient.get(key, function(err, value) {
      try {
        // if cached, send cached data
        if (value && requestParams.caching !== "off") {
          // console.log('cache hit');
          send(res, requestParams, JSON.parse(value));
          return;
        }

        // otherwise, retrieve data from database
        
        // console.log('cache miss');

        api.getData(requestParams, viewFilters, function(data) {
          // cache data
          redisClient.set(key, JSON.stringify(data));

          // send data
          send(res, requestParams, data);
        });
      } catch (err) {
        res.send(500);
        // res.send(err);
      }
    });
  });
}

// routes
setupRoute("question", "/:question/:type?");

// listen on given port in config
app.listen(process.env.PORT || config.api.port);

// Allows the master process to kill this sub process
process.on("message", function(msg) {
  switch (msg.cmd) {
    case "kill":
      process.exit(0);
      break;
  }
});

function clone(obj) {
  return JSON.parse(JSON.stringify(obj));
}
