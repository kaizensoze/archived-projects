  /*!
   * massrel-js 1.7.2
   *
   * Copyright 2014 Mass Relevance
   *
   * Licensed under the Apache License, Version 2.0 (the "License");
   * you may not use this work except in compliance with the License.
   * You may obtain a copy of the License at:
   *
   *    http://www.apache.org/licenses/LICENSE-2.0
   */
;(function(window, undefined) {

var massreljs;(function () { if (!massreljs || !massreljs.requirejs) {
if (!massreljs) { massreljs = {}; } else { require = massreljs; }
/**
 * almond 0.2.4 Copyright (c) 2011-2012, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/almond for details
 */
//Going sloppy to avoid 'use strict' string cost, but strict practices should
//be followed.
/*jslint sloppy: true */
/*global setTimeout: false */

var requirejs, require, define;
(function (undef) {
  var main, req, makeMap, handlers,
    defined = {},
    waiting = {},
    config = {},
    defining = {},
    hasOwn = Object.prototype.hasOwnProperty,
    aps = [].slice;

  function hasProp(obj, prop) {
    return hasOwn.call(obj, prop);
  }

  /**
   * Given a relative module name, like ./something, normalize it to
   * a real name that can be mapped to a path.
   * @param {String} name the relative name
   * @param {String} baseName a real name that the name arg is relative
   * to.
   * @returns {String} normalized name
   */
  function normalize(name, baseName) {
    var nameParts, nameSegment, mapValue, foundMap,
      foundI, foundStarMap, starI, i, j, part,
      baseParts = baseName && baseName.split("/"),
      map = config.map,
      starMap = (map && map['*']) || {};

    //Adjust any relative paths.
    if (name && name.charAt(0) === ".") {
      //If have a base name, try to normalize against it,
      //otherwise, assume it is a top-level require that will
      //be relative to baseUrl in the end.
      if (baseName) {
        //Convert baseName to array, and lop off the last part,
        //so that . matches that "directory" and not name of the baseName's
        //module. For instance, baseName of "one/two/three", maps to
        //"one/two/three.js", but we want the directory, "one/two" for
        //this normalization.
        baseParts = baseParts.slice(0, baseParts.length - 1);

        name = baseParts.concat(name.split("/"));

        //start trimDots
        for (i = 0; i < name.length; i += 1) {
          part = name[i];
          if (part === ".") {
            name.splice(i, 1);
            i -= 1;
          } else if (part === "..") {
            if (i === 1 && (name[2] === '..' || name[0] === '..')) {
              //End of the line. Keep at least one non-dot
              //path segment at the front so it can be mapped
              //correctly to disk. Otherwise, there is likely
              //no path mapping for a path starting with '..'.
              //This can still fail, but catches the most reasonable
              //uses of ..
              break;
            } else if (i > 0) {
              name.splice(i - 1, 2);
              i -= 2;
            }
          }
        }
        //end trimDots

        name = name.join("/");
      } else if (name.indexOf('./') === 0) {
        // No baseName, so this is ID is resolved relative
        // to baseUrl, pull off the leading dot.
        name = name.substring(2);
      }
    }

    //Apply map config if available.
    if ((baseParts || starMap) && map) {
      nameParts = name.split('/');

      for (i = nameParts.length; i > 0; i -= 1) {
        nameSegment = nameParts.slice(0, i).join("/");

        if (baseParts) {
          //Find the longest baseName segment match in the config.
          //So, do joins on the biggest to smallest lengths of baseParts.
          for (j = baseParts.length; j > 0; j -= 1) {
            mapValue = map[baseParts.slice(0, j).join('/')];

            //baseName segment has  config, find if it has one for
            //this name.
            if (mapValue) {
              mapValue = mapValue[nameSegment];
              if (mapValue) {
                //Match, update name to the new value.
                foundMap = mapValue;
                foundI = i;
                break;
              }
            }
          }
        }

        if (foundMap) {
          break;
        }

        //Check for a star map match, but just hold on to it,
        //if there is a shorter segment match later in a matching
        //config, then favor over this star map.
        if (!foundStarMap && starMap && starMap[nameSegment]) {
          foundStarMap = starMap[nameSegment];
          starI = i;
        }
      }

      if (!foundMap && foundStarMap) {
        foundMap = foundStarMap;
        foundI = starI;
      }

      if (foundMap) {
        nameParts.splice(0, foundI, foundMap);
        name = nameParts.join('/');
      }
    }

    return name;
  }

  function makeRequire(relName, forceSync) {
    return function () {
      //A version of a require function that passes a moduleName
      //value for items that may need to
      //look up paths relative to the moduleName
      return req.apply(undef, aps.call(arguments, 0).concat([relName, forceSync]));
    };
  }

  function makeNormalize(relName) {
    return function (name) {
      return normalize(name, relName);
    };
  }

  function makeLoad(depName) {
    return function (value) {
      defined[depName] = value;
    };
  }

  function callDep(name) {
    if (hasProp(waiting, name)) {
      var args = waiting[name];
      delete waiting[name];
      defining[name] = true;
      main.apply(undef, args);
    }

    if (!hasProp(defined, name) && !hasProp(defining, name)) {
      throw new Error('No ' + name);
    }
    return defined[name];
  }

  //Turns a plugin!resource to [plugin, resource]
  //with the plugin being undefined if the name
  //did not have a plugin prefix.
  function splitPrefix(name) {
    var prefix,
      index = name ? name.indexOf('!') : -1;
    if (index > -1) {
      prefix = name.substring(0, index);
      name = name.substring(index + 1, name.length);
    }
    return [prefix, name];
  }

  /**
   * Makes a name map, normalizing the name, and using a plugin
   * for normalization if necessary. Grabs a ref to plugin
   * too, as an optimization.
   */
  makeMap = function (name, relName) {
    var plugin,
      parts = splitPrefix(name),
      prefix = parts[0];

    name = parts[1];

    if (prefix) {
      prefix = normalize(prefix, relName);
      plugin = callDep(prefix);
    }

    //Normalize according
    if (prefix) {
      if (plugin && plugin.normalize) {
        name = plugin.normalize(name, makeNormalize(relName));
      } else {
        name = normalize(name, relName);
      }
    } else {
      name = normalize(name, relName);
      parts = splitPrefix(name);
      prefix = parts[0];
      name = parts[1];
      if (prefix) {
        plugin = callDep(prefix);
      }
    }

    //Using ridiculous property names for space reasons
    return {
      f: prefix ? prefix + '!' + name : name, //fullName
      n: name,
      pr: prefix,
      p: plugin
    };
  };

  function makeConfig(name) {
    return function () {
      return (config && config.config && config.config[name]) || {};
    };
  }

  handlers = {
    require: function (name) {
      return makeRequire(name);
    },
    exports: function (name) {
      var e = defined[name];
      if (typeof e !== 'undefined') {
        return e;
      } else {
        return (defined[name] = {});
      }
    },
    module: function (name) {
      return {
        id: name,
        uri: '',
        exports: defined[name],
        config: makeConfig(name)
      };
    }
  };

  main = function (name, deps, callback, relName) {
    var cjsModule, depName, ret, map, i,
      args = [],
      usingExports;

    //Use name if no relName
    relName = relName || name;

    //Call the callback to define the module, if necessary.
    if (typeof callback === 'function') {

      //Pull out the defined dependencies and pass the ordered
      //values to the callback.
      //Default to [require, exports, module] if no deps
      deps = !deps.length && callback.length ? ['require', 'exports', 'module'] : deps;
      for (i = 0; i < deps.length; i += 1) {
        map = makeMap(deps[i], relName);
        depName = map.f;

        //Fast path CommonJS standard dependencies.
        if (depName === "require") {
          args[i] = handlers.require(name);
        } else if (depName === "exports") {
          //CommonJS module spec 1.1
          args[i] = handlers.exports(name);
          usingExports = true;
        } else if (depName === "module") {
          //CommonJS module spec 1.1
          cjsModule = args[i] = handlers.module(name);
        } else if (hasProp(defined, depName) ||
          hasProp(waiting, depName) ||
          hasProp(defining, depName)) {
          args[i] = callDep(depName);
        } else if (map.p) {
          map.p.load(map.n, makeRequire(relName, true), makeLoad(depName), {});
          args[i] = defined[depName];
        } else {
          throw new Error(name + ' missing ' + depName);
        }
      }

      ret = callback.apply(defined[name], args);

      if (name) {
        //If setting exports via "module" is in play,
        //favor that over return value and exports. After that,
        //favor a non-undefined return value over exports use.
        if (cjsModule && cjsModule.exports !== undef &&
          cjsModule.exports !== defined[name]) {
          defined[name] = cjsModule.exports;
        } else if (ret !== undef || !usingExports) {
          //Use the return value from the function.
          defined[name] = ret;
        }
      }
    } else if (name) {
      //May just be an object definition for the module. Only
      //worry about defining if have a module name.
      defined[name] = callback;
    }
  };

  requirejs = require = req = function (deps, callback, relName, forceSync, alt) {
    if (typeof deps === "string") {
      if (handlers[deps]) {
        //callback in this case is really relName
        return handlers[deps](callback);
      }
      //Just return the module wanted. In this scenario, the
      //deps arg is the module name, and second arg (if passed)
      //is just the relName.
      //Normalize module name, if it contains . or ..
      return callDep(makeMap(deps, callback).f);
    } else if (!deps.splice) {
      //deps is a config object, not an array.
      config = deps;
      if (callback.splice) {
        //callback is an array, which means it is a dependency list.
        //Adjust args if there are dependencies
        deps = callback;
        callback = relName;
        relName = null;
      } else {
        deps = undef;
      }
    }

    //Support require(['a'])
    callback = callback || function () {};

    //If relName is a function, it is an errback handler,
    //so remove it.
    if (typeof relName === 'function') {
      relName = forceSync;
      forceSync = alt;
    }

    //Simulate async callback;
    if (forceSync) {
      main(undef, deps, callback, relName);
    } else {
      //Using a non-zero value because of concern for what old browsers
      //do, and latest browsers "upgrade" to 4 if lower value is used:
      //http://www.whatwg.org/specs/web-apps/current-work/multipage/timers.html#dom-windowtimers-settimeout:
      //If want a value immediately, use require('id') instead -- something
      //that works in almond on the global level, but not guaranteed and
      //unlikely to work in other AMD implementations.
      setTimeout(function () {
        main(undef, deps, callback, relName);
      }, 4);
    }

    return req;
  };

  /**
   * Just drops the config on the floor, but returns req in case
   * the config return value is used.
   */
  req.config = function (cfg) {
    config = cfg;
    return req;
  };

  define = function (name, deps, callback) {

    //This module may not have dependencies
    if (!deps.splice) {
      //deps is not an array, so probably means
      //an object literal or factory function for
      //the value. Adjust args.
      callback = deps;
      deps = [];
    }

    if (!hasProp(defined, name) && !hasProp(waiting, name)) {
      waiting[name] = [name, deps, callback];
    }
  };

  define.amd = {
    jQuery: true
  };
}());
massreljs.requirejs = requirejs;massreljs.require = require;massreljs.define = define;
}
}());
massreljs.define('globals',{
  host: 'api.massrelevance.com'
, timeout: 10e3
, protocol: document.location.protocol === 'https:' ? 'https' : 'http'
, min_poll_interval: 5e3
, max_backoff_interval: 60e3
, backoff_rate: 1.8
, jsonp_param: 'jsonp'
});

massreljs.define('helpers',['./globals'], function(globals) {
  var exports = {}, _enc = encodeURIComponent;

  exports.step_through = function(data_list, enumerators, context) {
    data_list = exports.is_array(data_list) ? data_list : [data_list];
    var i = data_list.length - 1;
    if(i >= 0) {
      for(;i >= 0; i--) {
        var status = data_list[i];
        for(var j = 0, len = enumerators.length; j < len; j++) {
          enumerators[j].call(context, status);
        }
      }
    }
  };

  exports.extend = function(to_obj, from_obj) {
    var prop;
    for(prop in from_obj) {
      if(typeof(to_obj[prop]) === 'undefined') {
        to_obj[prop] = from_obj[prop];
      }
    }

    return to_obj;
  };

  exports.api_url = function(path, host) {
    host = host || globals.host;
    var port = globals.port,
        baseUrl = globals.protocol + '://' + host + (port ? ':' + port : '');

    return baseUrl + path;
  };

  exports.req = {};
  exports.req.supportsXhr2 = window.XMLHttpRequest  && 'withCredentials' in new XMLHttpRequest();
  exports.req.supportsCors = (exports.req.supportsXhr2 || 'XDomainRequest' in window);
  exports.req.supportsJSON = 'JSON' in window;
  exports.req.xdr = function(url, params, jsonp_prefix, obj, callback, error, method, body) {
    var req;
    var fulfilled = false;
    var timeout;

    if(!method) {
      method = 'GET';
    }

    var success = function(responseText) {
      fulfilled = true;

      var data;
      var problems = false;
      try {
        data = JSON.parse(responseText);
      }
      catch(e) {
        problems = true;
        fail(new Error('JSON parse error'));
      }

      if(!problems) {
        if(typeof callback === 'function') {
          callback(data);
        }
        else if(exports.is_array(callback) && callback.length > 0) {
          exports.step_through(data, callback, obj);
        }
      }
    };

    var fail = function(text) {
      fulfilled = true;
      if(typeof error === 'function') {
        error(text);
      }
    };

    // IE9 supports xhr, but not with xhr2 (w/ CORS)
    if(window.XMLHttpRequest && exports.req.supportsXhr2) {
      req = new XMLHttpRequest();
    }
    else if(window.XDomainRequest) {
      req = new XDomainRequest();
    }

    if(req) {
      req.open(method, url+'?'+exports.to_qs(params));
      req.timeout = globals.timeout;
      req.onerror = fail;
      req.onprogress = function(){ };
      req.ontimeout = fail;
      req.onload = function() {
        success(req.responseText);
      };

      req.send(body);

      timeout = setTimeout(function() {
        if(!fulfilled) {
         req.onerror = function() {};
         req.onprogress = function() {};
         req.ontimeout = function() {};
         req.onload = function() {};
         if(req.abort) {
           req.abort();
         }
         fail();
        }
      }, globals.timeout);
    }
    else {
      fail(new Error('CORS not supported'));
    }
  };

  exports.req.jsonp = function(url, params, jsonp_prefix, obj, callback, error) {
    var callback_id = jsonp_prefix+(++json_callbacks_counter);
    var fulfilled = false;
    var timeout;

    globals._json_callbacks[callback_id] = function(data) {
      if(typeof callback === 'function') {
        callback(data);
      }
      else if(exports.is_array(callback) && callback.length > 0) {
        exports.step_through(data, callback, obj);
      }

      delete globals._json_callbacks[callback_id];

      fulfilled = true;
      clearTimeout(timeout);
    };
    params.push([globals.jsonp_param, 'massrel._json_callbacks.'+callback_id]);

    var ld = exports.load(url + '?' + exports.to_qs(params));

    // in 10 seconds if the request hasn't been loaded, cancel request
    timeout = setTimeout(function() {
      if(!fulfilled) {
        globals._json_callbacks[callback_id] = function() {
          delete globals._json_callbacks[callback_id];
        };
        if(typeof error === 'function') {
          error();
        }
        ld.stop();
      }
    }, globals.timeout);
  };

  // alias for backwards compatability
  exports.jsonp_factory = exports.req.jsonp;

  var json_callbacks_counter = 0;
  globals._json_callbacks = {};
  exports.request_factory = function(url, params, jsonp_prefix, obj, callback, error) {
    if(exports.req.supportsCors && exports.req.supportsJSON) {
      exports.req.xdr(url, params, jsonp_prefix, obj, callback, error);
    }
    else {
      exports.req.jsonp(url, params, jsonp_prefix, obj, callback, error);
    }
  };

  exports.post_factory = function(url, params, body, jsonp_prefix, obj, callback, error) {
    if(exports.req.supportsCors && exports.req.supportsJSON) {
      exports.req.xdr(url, params, jsonp_prefix, obj, callback, error, "POST", body);
    }
    else {
      throw "POST not supported";
    }
  };

  exports.is_array = Array.isArray || function(obj) {
    return Object.prototype.toString.call(obj) === '[object Array]';
  };

  exports.is_number = function(obj) {
    return Object.prototype.toString.call(obj) === '[object Number]';
  };

  var root = document.getElementsByTagName('head')[0] || document.body;
  exports.load = function(url, fn) {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = url;

    // thanks jQuery! stole the script.onload stuff below
    var done = false;
    script.onload = script.onreadystatechange = function() {
      if (!done && (!this.readyState || this.readyState === "loaded" || this.readyState === "complete")) {
        done = true;
        // handle memory leak in IE
        script.onload = script.onreadystatechange = null;
        if (root && script.parentNode) {
          root.removeChild(script);
        }

        if(typeof fn === 'function') {
          fn();
        }
      }
    };

    // use insertBefore instead of appendChild to not efff up ie6
    root.insertBefore(script, root.firstChild);

    return {
      stop: function() {
        script.onload = script.onreadystatechange = null;
        if(root && script.parentNode) {
          root.removeChild(script);
        }
        script.src = "#";
      }
    };
  };

  exports.to_qs = function(params) {
    var query = [], val;
    if(params && params.length) {
      for(var i = 0, len = params.length; i < len; i++) {
        val = params[i][1];
        if(exports.is_array(val)) {
          // copy encoded vals from array into a
          // new array to make sure not to corruept
          // reference array
          var encVals = [];
          for(var j = 0, len2 = val.length; j < len2; j++) {
            encVals[j] = _enc(val[j] || '');
          }
          val = encVals.join(',');
        }
        else if(val !== undefined && val !== null) {
          val = _enc(val);
        }
        else {
          val = '';
        }
        query.push(_enc(params[i][0])+'='+ val);
      }
      return query.join('&');
    }
    else {
      return '';
    }
  };

  var rx_twitter_date = /\+\d{4} \d{4}$/;
  var rx_fb_date = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(\+\d{4})$/; // iso8601
  var rx_normal_date = /^(\d{4})-(\d\d)-(\d\d)T(\d\d)\:(\d\d)\:(\d\d)\.(\d{3})Z$/; // iso8601, no offset
  exports.fix_date = exports.fix_twitter_date = function(date) {
    // ensure we're dealing with a string, not a Date object
    date = date.toString();

    if (rx_twitter_date.test(date)) {
      date = date.split(' ');
      var year = date.pop();
      date.splice(3, 0, year);
      date = date.join(' ');
    }
    else if (rx_fb_date.test(date)) {
      date = date.replace(rx_fb_date, '$1/$2/$3 $4:$5:$6 $7');
    }
    else if (rx_normal_date.test(date)) {
      // IE7/8 can't handle the ISO JavaScript date format, so we convert
      date = date.replace(rx_normal_date, '$1/$2/$3 $4:$5:$6 +0000');
    }

    return date;
  };

  exports.parse_params = function(queryString) {
    queryString = queryString || window.location.search.substring(1);
    var raw = {};
    if (queryString.charAt(0) === '?') {
      queryString = queryString.substring(1);
    }
    if (queryString.length > 0) {
      queryString = queryString.replace(/\+/g, ' ');
      var queryComponents = queryString.split(/[&;]/g);
      for (var index = 0; index < queryComponents.length; index ++){
        var keyValuePair = queryComponents[index].split('=');
        var key = decodeURIComponent(keyValuePair[0]);
        var value = keyValuePair.length > 1 ? decodeURIComponent(keyValuePair[1]) : '';
        if (!(key in raw)) {
          raw[key] = value;
        } else {
          var existing_val = raw[key];
          if (typeof existing_val !== 'string') {
            raw[key].push(value);
          } else {
            raw[key] = [];
            raw[key].push(existing_val);
            raw[key].push(value);
          }
        }
      }
    }
    return raw;
  };

  exports.poll_interval = function(interval) {
    var min = globals.min_poll_interval;
    return Math.max(interval || min, min);
  };

  exports.poll_backoff = function(interval, consecutive_errors) {
    var max = globals.max_backoff_interval;
    // use the input interval if is already greater than the backoff
    // max, otherwise apply the backoff
    if(interval < max) {
      consecutive_errors = Math.max(consecutive_errors - 1, 0);
      interval = interval * Math.pow(globals.backoff_rate, consecutive_errors);
      interval = Math.min(interval || max, max);
    }

    return interval;
  };

  // returns a function that can be used to wrap other functions
  // this prevents a function wrapped from being invoked too many
  // times.
  exports.callback_group = function(max_call_count) {
    max_call_count = max_call_count || 1;
    var call_count = 0;
    var active = true;
    var wrapper = function(callback, context) {
      return function() {
        if(active) {
          if(call_count <= max_call_count) {
            return callback.apply(context || this, arguments);
          }
          else {
            throw new Error('Callback group max call count exceeded');
          }
        }
      };
    };

    wrapper.deactivate = function() {
      active = false;
    };

    return wrapper;
  };

  exports.timeParam = function(value, paramName, params, allowZeroOrNegative) {
    if(typeof(value) !== 'undefined') {
      if(value.getTime) {
        value = value.getTime() / 1000;
      }
      
      value = +value;
      if(!isNaN(value) && value > 0) {
        // bucket to closest minute
        value = Math.floor(value / 60) * 60;
        params.push([paramName, value]);
      }
      else if(!isNaN(value) && allowZeroOrNegative && value <= 0) {
        params.push([paramName, value]);
      }

    }
  };

  /*
   * takes a list of $.Deferred objects or a single $.Deferred object and returns a promise
   * the promise will be resolved when all the deferreds are no longer pending (i.e. resolved or rejected)
   * this is very similar to $.when, except that $.when will reject the promise if any of the deferreds are rejected
   */
  exports.always = function(deferreds) {
    var deferred = new $.Deferred();
    if (deferreds === undefined) {
      deferred.resolve();
      return deferred.promise();
    }

    if (deferreds.length === undefined) {
      deferreds = [deferreds];
    }

    var remaining = deferreds.length;

    var callback = function() {
      remaining--;
      if (remaining === 0) {
        deferred.resolve();
      }
    };

    $.each(deferreds, function() {
      this.always(callback);
    });

    return deferred.promise();
  };

  return exports;
});

massreljs.define('generic_poller_cycle',['./helpers'], function(helpers) {

  function GenericPollerCycle(skip, callback, errback) {
    this.cg = helpers.callback_group();
    this.skip = this.cg(skip);
    this.callback = this.cg(callback);
    this.errback = this.cg(errback);
    this._enabled = true;
  }

  GenericPollerCycle.prototype.enabled = function() {
    return this._enabled;
  };

  GenericPollerCycle.prototype.disable = function() {
    this.cg.deactivate();
    this._enabled = false;
  };

  return GenericPollerCycle;

});

massreljs.define('generic_poller',['./helpers', './generic_poller_cycle'], function(helpers, GenericPollerCycle) {

  function GenericPoller(object, opts) {
    var self = this,
        fetch = function() {
          if(enabled) {
            var cg = helpers.callback_group();
            var inner_again = cg(again);

            // success callback
            var success = function(data) {
              // reset errors count
              self.consecutive_errors = 0;
              GenericPoller.failure_mode = self.failure_mode = false;

              if(enabled) { // being very thorough in making sure to stop polling when told

                // call any filters that have been added to augment data
                for(var i = 0, len = self._filters.length; i < len; i++) {
                  data = self._filters[i].call(self, data);
                }

                // call each listener with the data
                // wrapping the data in [], the strep_through method
                // will not enumerate through each item directly
                helpers.step_through([data],  self._listeners, self);

                if(enabled) { // poller can be stopped in any of the above iterators
                  inner_again();
                }
              }
            };

            // error callback
            var fail = function() {
              self.consecutive_errors += 1;
              GenericPoller.failure_mode = self.failure_mode = true;
              inner_again(true);
            };

            cycle = new GenericPollerCycle(inner_again, success, fail);

            // fetch data
            self.fetch(object, self.opts, cycle);
          }
        },
        again = function(error) {
          var delay = helpers.poll_interval(self.frequency * 1000);
          if(error) {
            delay = helpers.poll_backoff(delay, self.consecutive_errors);
          }
          tmo = setTimeout(fetch, delay);
        },
        cycle = null, // keep track of last cycle
        enabled = false,
        tmo;

    this._listeners = [];
    this._filters = [];
    this.object = object;
    this.opts = opts || {};
    this.frequency = (this.opts.frequency || 30);
    this.alive_count = 0;
    this.consecutive_errors = 0;
    this.failure_mode = false;

    this.start = function() {
      if(!enabled) { // guard against multiple pollers
        enabled = true;
        fetch();
      }
      return this;
    };
    this.stop = function() {
      if(cycle) {
        cycle.disable();
        cycle = null;
      }
      clearTimeout(tmo);
      enabled = false;
      return this;
    };
  }

  GenericPoller.prototype.fetch = function(object, opts, cycle) {
    object.load(opts, cycle.callback, cycle.errback);
    return this;
  };

  GenericPoller.prototype.data = function(fn) {
    this._listeners.push(fn);
    return this;
  };

  GenericPoller.prototype.filter = function(fn) {
    this._filters.push(fn);
    return this;
  };

  // global failure flag
  // once one poller is in failure mode
  // we want to make all others switch to
  GenericPoller.failure_mode = false;

  return GenericPoller;
});

massreljs.define('poller_queue',['./helpers'], function(helpers) {

  function PollerQueue(poller, opts) {
    this.poller = poller;

    opts = helpers.extend(opts || {}, {
    });

    var queue = [];
    var callback = null;
    var locked = false;
    var lock_incr = 0;

    this.total = 0;
    this.enqueued = 0;
    this.count = 0;

    var self = this;
    poller.batch(function(statuses) {
      var len = statuses.length;
      var i = len - 1;
      for(; i >= 0; i--) { // looping through from bottom to top to queue statuses from oldest to newest
        queue.push(statuses[i]);
      }
      self.total += len;
      self.enqueued += len;

      step();
    });

    function step() {
      if(!locked && queue.length > 0 && typeof callback === 'function') {
        var lock_local = ++lock_incr;

        self.enqueued -= 1;
        self.count += 1;
        var status = queue.shift();
        locked = true;

        callback.call(self, status, function() {
          if(lock_local === lock_incr) {
            locked = false;
            setTimeout(step, 0);
          }
        });
      }
    }

    this.next = function(fn) {
      if(!locked && typeof fn === 'function') {
        callback = fn;
        step();
      }
    };
  }

  return PollerQueue;
});

massreljs.define('poller',['./helpers', './generic_poller', './poller_queue'], function(helpers, GenericPoller, PollerQueue) {

  function Poller(stream, opts) {
    GenericPoller.call(this, stream, opts);

    // alias object as streams
    this.stream = this.object;

    // add filter
    this.filter(this.filter_newer);

    opts = this.opts;
    this.newest_timestamp = opts.newest_timestamp || null;
    this.stay_realtime = 'stay_realtime' in opts ? !!opts.stay_realtime : true;
    this.hail_mary_mode = !!opts.hail_mary_mode;
    this.first = true;
  }

  helpers.extend(Poller.prototype, GenericPoller.prototype);

  // fetch data for Stream
  Poller.prototype.fetch = function(object, opts, cycle) {
    var self = this;
    var load_opts = {
      // prevents start_id from being include in query
      start_id: null
    };

    // if in "stay realtime" mode then
    // then poller should use "since_id"
    //
    // "since_id" gets statuses from the newest item in a stream
    // to "since_id" (exclusive) or until "limit" is reached.
    // statuses will be skipped in order to stay realtime
    //
    // "from_id" gets statuses from the provided id newer until
    // the newest status in stream is found or until "limit" is reached.
    // all statuses in a stream will be downloaded but it is likely
    // to not stay realtime
    var newer_id = this.stay_realtime ? 'since_id' : 'from_id';
    load_opts[newer_id] = self.since_id;

    // create load options
    opts = helpers.extend({}, opts);
    if(this.first) {
      opts = helpers.extend(opts.initial || {}, opts);
      delete opts.initial;
    }
    load_opts = helpers.extend(load_opts, opts);

    // remove since_id if the poller
    // is in a mode that prevents cursing
    // the via the API
    if(!this.cursorable()) {
      delete load_opts.since_id;
    }

    object.load(load_opts, function(statuses) {
      if(cycle.enabled()) { // only update cursors if poller cycle enabled
        // only invode hanlders is there are any statuses
        // this is for legacy reasons
        if(statuses && statuses.length > 0) {
          self.since_id = statuses[0].entity_id;

          if(!self.start_id) { // grab last item ID if it has not been set
            self.start_id = statuses[statuses.length - 1].entity_id;
          }
        }
        cycle.callback(statuses);

        // disable continuous polling if `timeframe`
        // param is present. You can't "poll" for new
        // data when you are in the past.
        if(load_opts.timeframe && self.first) {
          self.stop();
        }

        self.first = false;

      }
    }, cycle.errback);
    return this;
  };

  // Poller#batch callback will be invoked when there
  // is an array of statuses that is > 0
  // and be invoked with the entire array of statuses
  Poller.prototype.batch = function(fn) {
    return this.data(Poller.createEnumerator(fn, false));
  };

  // Poller#each callback will be invoked when there
  // is an array of statuses that is > 0
  // and be invoked once for each item in the array
  // from oldest status to newest statuse
  Poller.prototype.each = function(fn) {
    return this.data(Poller.createEnumerator(fn, true));
  };

  // creates a new queue with the poller
  Poller.prototype.queue = function(fn) {
    var queue = new PollerQueue(this);
    queue.next(fn);
    return this;
  };

  // gets "olders" statuses at bottom of stream
  // and knows how to cursor down without getting duplicates
  Poller.prototype.more = function(fn, error) {
    //TODO: build in a lock, so multiple "more" calls
    //are called sequentially instead of in parallel

    var self = this,
        fetch = function() {
          self.object.load(helpers.extend({
            start_id: self.start_id,

            // prevent since_id from being included in query
            since_id: null
          }, self.opts), function(statuses) {
            if(statuses.length > 0) {
              self.start_id = statuses[statuses.length - 1].entity_id;
              if(!self.since_id) {
                self.since_id = statuses[0].entity_id;
              }
            }
            fn.call(self, statuses);
          }, function() {
            // error
            if(typeof(error) === 'function') {
              error();
            }
          });
        };

    fetch();

    return this;
  };

  // the poller is cursorable if no special
  // mode is in place
  Poller.prototype.cursorable = function() {
    return !(GenericPoller.failure_mode || this.failure_mode || this.hail_mary_mode);
  };

  Poller.prototype.filter_newer = function(statuses) {
    statuses = Poller.filter_newer(statuses, this.newest_timestamp);
    if(statuses && statuses.length > 0) {
      this.newest_timestamp = statuses[0].queued_at;
    }
    return statuses;
  };


  // legacy method that used to "kick start"
  // a poller is there were network isssues
  // I handle this at the request level now
  // but leave as noop (basically) for now
  Poller.prototype.poke = function() { return this; };

  // creates an handler that will
  // invoke the given handler once for each tweet in the response
  // it will also only invoke given handler is there are 1 or more statuses (for legacy reasons)
  Poller.createEnumerator = function(fn, enumerateEach) {
    if(enumerateEach) {
      return function(statuses) {
        if(statuses && statuses.length > 0) {
          // strep through will invote the handler (fn)
          // from the oldest tweet (data.last) to the newest (data.first)
          helpers.step_through(statuses, [fn], this);
        }
      };
    }
    else {
      return function(statuses) {
        if(statuses && statuses.length > 0) {
          fn.call(this, statuses);
        }
      };
    }
  };

  Poller.filter_newer = function(statuses, newest_timestamp) {
    var sortable_prop = 'queued_at';
    if(statuses && statuses.length > 0) {
      var limit = this.limit || Infinity;

      // only use statuses the poller hasn't seen before
      if(newest_timestamp) {
        if(statuses[0][sortable_prop] <= newest_timestamp) {
          // if first/newest item in request is equal or older than
          // what the poller knows about, then there are no newer
          // statuses to display
          statuses = [];
        }
        else if(statuses[statuses.length - 1][sortable_prop] > newest_timestamp) {
          // if last/oldest item in request is newer than what the poller knows
          // then all statuses are new. we only care about making sure
          // statuses.length <= limit
          if(statuses.length > limit) {
            statuses.splice(this.limit, statuses.length - limit);
          }
        }
        else {
          // the last status the poller knows about is somewhere inside of the
          // of the requested statuses. grab the statuses that are newer than
          // what the poller knows about until there are no more statuses OR
          // we have collecte limit statuses
          var newerStatuses = [];

          for(var i = 0, len = statuses.length; i < len && newerStatuses.length < limit; i++) {
            var status = statuses[i];
            if(status[sortable_prop] > newest_timestamp) {
              newerStatuses.push(status);
            }
            else {
              break;
            }
          }

          statuses = newerStatuses;
        }
      }
      else if(statuses.length > limit) {
        statuses.splice(this.limit, statuses.length - limit);
      }
    }

    return statuses;
  };

  return Poller;
});

massreljs.define('meta_poller',['./helpers', './generic_poller'], function(helpers, GenericPoller) {

  function MetaPoller() {
    GenericPoller.apply(this, arguments);
  }

  helpers.extend(MetaPoller.prototype, GenericPoller.prototype);

  MetaPoller.prototype.fetch = function(object, options, cycle) {
    object.meta(options, cycle.callback, cycle.errback);
    return this;
  };

  // alias
  MetaPoller.prototype.each = MetaPoller.prototype.data;

  return MetaPoller;
});

massreljs.define('top_things_poller',['./helpers', './generic_poller'], function(helpers, GenericPoller) {

  /*
   * a relative time string is a string like '300s' or '-5m' or '24h' or '30d'.
   *
   * available opts:
   *   start: string|integer - relative time string or unix timestamp in
   *     seconds - lower bound on time of first bucket. when this number is
   *     smaller than 1000000000, it's treated instead as a number of buckets of
   *     size `resolution`.
   *   finish: string|integer - relative time string or unix timestamp in
   *     seconds - upper bound on time of last bucket, if this number is smaller
   *     than 1000000000, it's treated instead as a number of buckets of size
   *     `resolution`.
   *   resolution: string|integer - the size of each bucket as a relative time
   *     string, or as an integer number of seconds. must be divisble by 5
   *     minutes.
   *   limit: integer - the maximum number of things in each bucket
   *   thing: string - 'hashtags'|'urls'|'terms' - the thing that you want
   *     counts of
   */
  function TopThingsPoller (object, opts) {
    opts.thing = opts.thing || 'hashtags';

    // convert integer resoltions into seconds
    if (typeof opts.resolution === 'number') {
      opts.resolution = opts.resolution + 's';
    }

    GenericPoller.apply(this, arguments);
  }

  helpers.extend(TopThingsPoller.prototype, GenericPoller.prototype);

  TopThingsPoller.prototype.fetch = function (object, opts, cycle) {
    if (typeof opts.resolution === 'number') {
      opts.resolution = opts.resolution + 's';
    }

    object.topThings(opts, cycle.callback, cycle.errback);

    return this;
  };

  // convenience method for finding the most recent non-empty bucket
  TopThingsPoller.mostRecentBucket = function (data) {
    if (data.data && data.data.length > 0) {
      // find most recent bucket with data if one exists
      for (var i = data.data.length - 1; i >= 0; i--) {
        if (data.data[i].things && data.data[i].things.length > 0) {
          return data.data[i];
        }
      }

      if (i === -1) {
        return data.data[data.data.length - 1];
      }
    }

    return null;
  };

  // alias
  TopThingsPoller.prototype.each = TopThingsPoller.prototype.data;

  return TopThingsPoller;
});


massreljs.define('stream_keyword_insights',['./helpers', './generic_poller'], function(helpers, GenericPoller) {
  var _enc = encodeURIComponent;

  function StreamKeywordInsights(stream, defaults) {
    this.stream = stream;
    this.defaults = defaults || {};
  }
  StreamKeywordInsights.prototype.url = function() {
    return this.stream.keyword_insights_url();
  };
  StreamKeywordInsights.prototype.fetch = function(opts, fn, errback) {
    opts = helpers.extend({}, opts || {});
    opts = helpers.extend(opts, this.defaults);

    var params = this.params(opts);
    helpers.request_factory(this.url(), params, '_', this, function(data) {
      if(typeof(fn) === 'function') {
        fn.apply(this, arguments);
      }
    }, errback);
    return this;
  };
  StreamKeywordInsights.prototype.poller = function(opts) {
    var poller = new GenericPoller(this, opts);
    poller.fetch = function(object, opts, cycle) {
      return object.fetch(opts, cycle.callback, cycle.errback);
    };

    return poller;
  };
  StreamKeywordInsights.prototype.params = function(opts) {
    opts = opts || {};
    var params = [];

    if(opts.topics) {
      params.push(['topics', '1']);
    }
    if('start' in opts) {
      params.push(['start', opts.start]);
    }
    if('finish' in opts) {
      params.push(['finish', opts.finish]);
    }
    if(opts.resolution) {
      params.push(['resolution', opts.resolution]);
    }
    if(opts.countries) {
      params.push(['countries', opts.countries]);
    }

    return params;
  };

  return StreamKeywordInsights;
});

massreljs.define('stream_activity',['./helpers', './generic_poller'], function(helpers, GenericPoller) {
  var _enc = encodeURIComponent;

  function StreamActivity(stream, defaults) {
    this.stream = stream;
    this.defaults = defaults || {};
  }
  StreamActivity.prototype.url = function() {
    return helpers.api_url('/'+ _enc(this.stream.account) +'/'+ _enc(this.stream.stream_name) +'/activity.json');
  };
  StreamActivity.prototype.fetch = function(opts, fn, errback) {
    opts = helpers.extend({}, opts || {});
    opts = helpers.extend(opts, this.defaults);

    var params = this.params(opts);
    helpers.request_factory(this.url(), params, '_', this, function(data) {
      if(data && (!opts.verbose || opts.verbose === '0') && helpers.is_array(data.activity)) {
        var activity = data.activity;
        for(var i = 0, len = activity.length; i < len; i++) {
          var start = data.start + (data.period_size * i);
          activity[i] = helpers.extend(activity[i], {
            start: start,
            finish: Math.min(start + data.period_size, data.finish)
          });
        }
      }
      if(typeof(fn) === 'function') {
        fn.apply(this, arguments);
      }
    }, errback);
    return this;
  };
  StreamActivity.prototype.poller = function(opts) {
    var poller = new GenericPoller(this, opts);
    poller.fetch = function(object, opts, cycle) {
      return object.fetch(opts, cycle.callback, cycle.errback);
    };

    return poller;
  };
  StreamActivity.prototype.params = function(opts) {
    opts = opts || {};
    var params = [];

    if(opts.view) {
      params.push(['view', opts.view]);
    }
    else if(opts.topic) {
      params.push(['topic', opts.topic]);
    }
    helpers.timeParam(opts.start, 'start', params, true);
    helpers.timeParam(opts.finish, 'finish', params, true);
    if('periods' in opts) {
      params.push(['periods', opts.periods]);
    }
    if(opts.resolution) {
      params.push(['resolution', opts.resolution]);
    }
    if('tz_offset' in opts) {
      params.push(['tz_offset', opts.tz_offset]);
    }
    if(opts.encode) {
      params.push(['encode', opts.encode]);
    }
    params.push(['verbose', 0]);

    return params;
  };

  var predef = function(method, key, value) {
    StreamActivity.prototype[method] = function() {
      this.defaults[key] = value;
      return this;
    };
  };

  // view
  predef('approved', 'view', 'approved');
  predef('pending', 'view', 'pending');
  predef('rejected', 'view', 'rejected');

  // resolution
  predef('minutes', 'resolution', '1m');
  predef('ten_minutes', 'resolution', '10m');
  predef('hours', 'resolution', '1h');
  predef('days', 'resolution', '1d');


  return StreamActivity;

});

massreljs.define('stream',['./helpers', './poller', './meta_poller', './top_things_poller', './stream_keyword_insights', './stream_activity'], function(helpers, Poller, MetaPoller, TopThingsPoller, StreamKeywordInsights, StreamActivity) {
  var _enc = encodeURIComponent;

  function Stream() {
    var args = arguments.length === 1 ? arguments[0].split('/') : arguments;

    this.account = args[0];
    this.stream_name = args[1];

    this._enumerators = [];
  }
  Stream.prototype.stream_url = function() {
    return helpers.api_url('/'+ _enc(this.account) +'/'+ _enc(this.stream_name) +'.json');
  };
  Stream.prototype.meta_url = function() {
    return helpers.api_url('/'+ _enc(this.account) +'/'+ _enc(this.stream_name) +'/meta.json');
  };
  Stream.prototype.top_things_url = function(thing) {
    return helpers.api_url('/'+ _enc(this.account) +'/'+ _enc(this.stream_name) +'/top_' + thing + '.json');
  };
  Stream.prototype.keyword_insights_url = function(thing) {
    return helpers.api_url('/'+ _enc(this.account) +'/'+ _enc(this.stream_name) +'/keyword_insights.json');
  };
  Stream.prototype.load = function(opts, fn, error) {
    opts = helpers.extend(opts || {}, {
      // put defaults
    });

    var params = this.buildParams(opts);
    helpers.request_factory(this.stream_url(), params, '_', this, fn || this._enumerators, error);

    return this;
  };
  Stream.prototype.buildParams = function(opts) {
    opts = opts || {};
    var params = [];
    if(opts.limit) {
      params.push(['limit', opts.limit]);
    }
    if(opts.since_id) {
      params.push(['since_id', opts.since_id]);
    }
    else if(opts.from_id) {
      params.push(['from_id', opts.from_id]);
    }
    else if(opts.start_id || opts.start) {
      params.push(['start', opts.start_id || opts.start]);
    }
    if(opts.replies) {
      params.push(['replies', '1']);
    }
    if(opts.geo_hint) {
      params.push(['geo_hint', '1']);
    }
    if(opts.from) {
      params.push(['from', opts.from]);
    }
    if(opts.keywords) {
      params.push(['keywords', opts.keywords]);
    }
    if(opts.lang) {
      params.push(['lang', opts.lang]);
    }
    if(opts.network) {
      params.push(['network', opts.network]);
    }
    if(opts.timeline_search) {
      params.push(['timeline_search', '1']);
    }
    if(opts.page_links) {
      params.push(['page_links', '1']);
    }
    if(opts.klout) {
      params.push(['klout', '1']);
    }
    if(opts.timeframe) {
      helpers.timeParam(opts.timeframe.start, 'timeframe[start]', params);
      helpers.timeParam(opts.timeframe.finish, 'timeframe[finish]', params);
    }
    
    return params;
  };
  Stream.prototype.each = function(fn) {
    this._enumerators.push(fn);
    return this;
  };
  Stream.prototype.poller = function(opts) {
    return new Poller(this, opts);
  };
  Stream.prototype.meta = function() {
    var opts, fn, error;
    if(typeof(arguments[0]) === 'function') {
      fn = arguments[0];
      error = arguments[1];
      opts = {};
    }
    else if(typeof(arguments[0]) === 'object') {
      opts = arguments[0];
      fn = arguments[1];
      error = arguments[2];
    }
    else {
      throw new Error('incorrect arguments');
    }

    var params = this.buildMetaParams(opts);
    helpers.request_factory(this.meta_url(), params, 'meta_', this, fn, error);

    return this;
  };
  Stream.prototype.buildMetaParams = function(opts) {
    opts = opts || {};
    var params = [];
    if(opts.disregard) {
      params.push(['disregard', opts.disregard]);
    }
    if(opts.num_minutes) {
      params.push(['num_minutes', opts.num_minutes]);
    }
    if(opts.num_hours) {
      params.push(['num_hours', opts.num_hours]);
    }
    if(opts.num_days) {
      params.push(['num_days', opts.num_days]);
    }
    if(opts.num_trends) {
      params.push(['num_trends', opts.num_trends]);
    }
    if(opts.num_links) {
      params.push(['num_links', opts.num_links]);
    }
    if(opts.num_hashtags) {
      params.push(['num_hashtags', opts.num_hashtags]);
    }
    if(opts.num_contributors) {
      params.push(['num_contributors', opts.num_contributors]);
    }
    if(opts.top_periods) {
      params.push(['top_periods', opts.top_periods]);
    }
    if(opts.top_periods_relative) {
      params.push(['top_periods_relative', opts.top_periods_relative]);
    }
    if(opts.top_count) {
      params.push(['top_count', opts.top_count]);
    }
    if(opts.finish) {
      params.push(['finish', opts.finish]);
    }
    if(opts.networks) {
      params.push(['networks', '1']);
    }
    return params;
  };
  Stream.prototype.metaPoller = function(opts) {
    return new MetaPoller(this, opts);
  };
  Stream.prototype.keywordInsights = function(defaults) {
    return new StreamKeywordInsights(this, defaults);
  };
  Stream.prototype.topThings = function() {
    var opts, fn, error;
    if(typeof(arguments[0]) === 'function') {
      fn = arguments[0];
      error = arguments[1];
      opts = {};
    }
    else if(typeof(arguments[0]) === 'object') {
      opts = arguments[0];
      fn = arguments[1];
      error = arguments[2];
    }
    else {
      throw new Error('incorrect arguments');
    }

    var params = this.buildTopThingsParams(opts);
    helpers.request_factory(this.top_things_url(opts.thing), params, 'top_things_', this, fn, error);

    return this;
  };
  Stream.prototype.buildTopThingsParams = function(opts) {
    opts = opts || {};
    var params = [];
    if(opts.resolution) {
      var res;
      if (helpers.is_number(opts.resolution)) {
        //assume number of seconds
        res = opts.resolution + 's';
      }
      else {
        res = opts.resolution;
      }
      params.push(['resolution', res]);
    }
    if(opts.start) {
      params.push(['start', opts.start]);
    }
    if(opts.finish) {
      params.push(['finish', opts.finish]);
    }
    if(opts.limit) {
      params.push(['limit', opts.limit]);
    }
    if(opts.percent) {
      params.push(['percent', '1']);
    }
    return params;
  };
  Stream.prototype.topThingsPoller = function(opts) {
    return new TopThingsPoller(this, opts);
  };
  Stream.prototype.activity = function(defaults) {
    return new StreamActivity(this, defaults);
  };

  return Stream;

});

massreljs.define('account',['./helpers', './meta_poller'], function(helpers, MetaPoller) {
  var _enc = encodeURIComponent;

  function Account(user) {
    this.user = user;
  }
  Account.prototype.meta_url = function() {
    return helpers.api_url('/'+ _enc(this.user) +'.json');
  };
  Account.prototype.meta = function() {
    var opts, fn, error;
    if(typeof(arguments[0]) === 'function') {
      fn = arguments[0];
      error = arguments[1];
      opts = {};
    }
    else if(typeof(arguments[0]) === 'object') {
      opts = arguments[0];
      fn = arguments[1];
      error = arguments[2];
    }
    else {
      throw new Error('incorrect arguments');
    }

    var params = this.buildMetaParams(opts);
    helpers.request_factory(this.meta_url(), params, 'meta_', this, fn, error);

    return this;
  };
  Account.prototype.buildMetaParams = function(opts) {
    opts = opts || {};

    var params = [];
    if(opts.quick_stats) {
      params.push(['quick_stats', '1']);
    }
    if(opts.streams) {
      var streams = helpers.is_array(opts.streams) ? opts.streams : [opts.streams];
      params.push(['streams', streams.join(',')]);
    }
    if(opts.num_minutes) {
      params.push(['num_minutes', opts.num_minutes]);
    }
    if(opts.num_trends) {
      params.push(['num_trends', opts.num_trends]);
    }
    if(opts.start) {
      params.push(['start', opts.start]);
    }
    if(opts.finish) {
      params.push(['finish', opts.finish]);
    }

    return params;
  };
  Account.prototype.metaPoller = function(opts) {
    return new MetaPoller(this, opts);
  };
  Account.prototype.toString = function() {
    return this.user;
  };

  return Account;
});

massreljs.define('context',['./helpers'], function(helpers) {

  function Context(status) {
    this.status = status;

    this.source = {
      facebook: false,
      twitter: false,
      getglue: false,
      google: false,
      instagram: false,
      rss: false,
      message: false // from the 'massrelevance' network
    };

    this.known = false;
    this.intents = true;
  }

  Context.create = function (status, opts) {
    status = status || {}; // gracefully handle nulls
    var context = new Context(status);

    opts = helpers.extend(opts || {}, {
      intents: true,
      retweeted_by: true
    });

    context.intents = opts.intents;

    // flag the source in the map if it's a known source
    if (typeof context.source[status.network] !== 'undefined') {
      context.source[status.network] = context.known = true;
      context.sourceName = status.network;
    }

    if (status.network === 'google_plus') {
      context.source.google = context.known = true;
      context.sourceName = 'google';
    }

    // handle the 'massrelevance' network type
    if (status.network === 'massrelevance') {
      context.source.message = context.known = true;
      context.sourceName = 'message';
    }

    // for twitter, pull the retweeted status up and use it as the main status
    if (context.source.twitter && status.retweeted_status && opts.retweeted_by) {
      context.retweet = true;
      context.retweeted_by_user = status.user;
      context.status =  status.retweeted_status;
    }

    return context;
  };

  /*
   * attempt to extract a photo url
   * in the case of twitter, we may return a url which is not a photo, so double-check after you hit embedly
   */
  Context.prototype.getPhotoUrl = function() {
    if (this.photo_url !== undefined) {
      //return cached result
      return this.photo_url;
    }

    var ret = false;

    if (this.status && this.known) {
      if (this.source.twitter) {
        if (this.status.entities.media && this.status.entities.media.length) {
          var media = this.status.entities.media[0];
          ret = {
            url: media.media_url,
            width: media.sizes.medium.w,
            height: media.sizes.medium.h,
            link_url: media.url || media.expanded_url
          };
        }
        else if (this.status.entities.urls && this.status.entities.urls.length) {
          ret = {url: this.status.entities.urls[0].expanded_url || this.status.entities.urls[0].url};
        }
      }
      else if (this.source.facebook && ((this.status.type && this.status.type === 'photo') || (this.status.kind && this.status.kind === 'photo'))) {
        ret = {url: this.status.picture.replace(/_[st]./, '_n.')};
      }
      else if (this.source.google && this.status.object.attachments.length && this.status.object.attachments[0].objectType === 'photo') {
        ret = {url: this.status.object.attachments[0].fullImage.url};
      }
      else if (this.source.instagram && this.status.type === 'image') {
        ret = {url: this.status.images.standard_resolution.url};
      }
    }

    //cache result for later use
    this.photo_url = ret;
    return ret;
  };

  return Context;
});

massreljs.define('compare_poller',['./helpers', './generic_poller'], function(helpers, GenericPoller) {

  function ComparePoller() {
    GenericPoller.apply(this, arguments);
  }

  helpers.extend(ComparePoller.prototype, GenericPoller.prototype);

  ComparePoller.prototype.fetch = function(object, options, cycle) {
    object.load(options, cycle.callback, cycle.errback);
    return this;
  };

  // alias
  ComparePoller.prototype.each = ComparePoller.prototype.data;

  return ComparePoller;
});

massreljs.define('compare',['./helpers', './compare_poller'], function(helpers, ComparePoller) {
  function Compare(streams) {
    if(helpers.is_array(streams)) {
      // keep a copy of the array
      this.streams = streams.slice(0);
    }
    else if(typeof(streams) === 'string') {
      this.streams = [streams];
    }
    else {
      this.streams = [];
    }
  }

  Compare.prototype.compare_url = function() {
    return helpers.api_url('/compare.json');
  };

  Compare.prototype.buildParams = function(opts) {
    var params = [];

    opts = opts || {};

    if(opts.streams) {
      params.push(['streams', opts.streams]);
    }
    if(opts.target || opts.target >=0) {
      params.push('target', opts.target.toString());
    }

    return params;
  };

  Compare.prototype.load = function(opts, fn, error) {
    if(typeof(opts) === 'function') {
      error = fn;
      fn = opts;
      opts = null;
    }
    var params = this.buildParams(helpers.extend({
      streams: this.streams
    }, opts || {}));

    helpers.request_factory(this.compare_url(), params, 'meta_', this, fn, error);
    return this;
  };

  Compare.prototype.poller = function(opts) {
    return new ComparePoller(this, opts);
  };

  return Compare;
});

massreljs.define('intents',['./helpers'], function(helpers) {

  var intents = {
    base_url: 'https://twitter.com/intent/',
    params: {
      'text'            : '(string): default text, for tweet/reply',
      'url'             : '(string): prefill url, for tweet/reply',
      'hashtags'        : '(string): hashtag (or list with ,) without #, for tweet/reply',
      'related'         : '(string): screen name (or list with ,) without @, available for all',
      'in_reply_to'     : '(number): tweet id, only for reply',
      'via'             : '(string): screen name without @, tweet/reply',
      'tweet_id'        : '(number): tweet id, for retweet and favorite',
      'screen_name'     : '(string): only for user/profile',
      'user_id'         : '(number): only for user/profile',
      'original_referer': '(string): url to display with related ("www.yahoo.com suggests you follow:")'
    },
    // set an original referer if the current page is
    // iframed and there exists a referer
    original_referer:  window.top !== window.self && document.referrer || null
  };

  intents.url = function(type, options) {
    options = helpers.extend({}, options || {});

    // automatically use the referer if user has not set one
    // and we can safetly determine an original referer
    if (options.original_referer === undefined && intents.original_referer) {
      options.original_referer = intents.original_referer;
    }

    //make sure the original referer has http:// or https:// at the beginning, otherwise twitter will ignore it
    if (options.original_referer && !/^https?:\/\//.test(options.original_referer)) {
      options.original_referer = 'http://' + options.original_referer;
    }

    // Hack to work around:
    // https://twittercommunity.com/t/intent-clicked-from-within-uiwebview-in-twitter-ios-app-ignores-hashtags-parameter/24096
    // Test user agent to see if we're in a UIWebView in Twitter app and if we are and have hashtags defined, instead of
    // passing the hashtags parameter, manually append to text parameter.
    if (options.hashtags && /Twitter for iP/.test(navigator.userAgent)) {
      var newText = options.text ? [options.text] : [];

      // manually add URL to maintain same order if url and hashtags param were both present in intent
      if (options.url) {
        newText.push(options.url);
        delete options.url;
      }

      newText.push('#' + options.hashtags.split(/\s*,\s*/).join(' #').replace(/^\s+|\s+$/gm, ''));
      delete options.hashtags;

      options.text = newText.join(' ');
    }

    var params = [];
    for(var k in options) {
      params.push([k, options[k]]);
    }

    return intents.base_url+encodeURIComponent(type)+'?'+helpers.to_qs(params);
  };

  intents.tweet = function(options) {
    return intents.url('tweet', options);
  };

  intents.reply = function(in_reply_to, options) {
    options = options || {};
    options.in_reply_to = in_reply_to;
    return intents.tweet(options);
  };

  intents.retweet = function(tweet_id, options) {
    options = options || {};
    options.tweet_id = tweet_id;
    return intents.url('retweet', options);
  };

  intents.favorite = function(tweet_id, options) {
    options = options || {};
    options.tweet_id = tweet_id;
    return intents.url('favorite', options);
  };

  intents.user = function(screen_name_or_id, options) {
    options = options || {};

    // if it's an integer number, treat it as an id, else as a screen name
    if(/^\d+$/.test(screen_name_or_id + '')) {
      options.user_id = screen_name_or_id;
    }
    else {
      options.screen_name = screen_name_or_id;
    }
    return intents.url('user', options);
  };
  // alias
  intents.profile = intents.user;

  return intents;
});

massreljs.define('search',['require','./helpers'],function(require) {
  var helpers = require('./helpers');

  var Search = function(apiToken) {
    this.apiToken = apiToken;
  };

  Search.prototype.url = function() {
    return helpers.api_url('/search/search.json');
  };

  Search.prototype.fetch = function(params, fn, error) {
    params = this.buildQueryString(params);
    helpers.request_factory(this.url(), params, '_', this, fn, error);
    return this;
  };

  Search.prototype.buildQueryString = function(params) {
    var p = [];
    if(typeof(params.q) === 'string') {
      p.push(['q', params.q]);
    }
    if(params.filters) {
      p = p.concat(this.buildParams(params.filters, 'filter.'));
    }
    if(params.views) {
      var viewName;
      var view;
      for(viewName in params.views) {
        view = params.views[viewName];
        if(typeof(view) === 'boolean') {
          p.push(['view.'+viewName, view ? '1' : '0']);
        }
        else {
          p = p.concat(this.buildParams(view, 'view.'+viewName+'.'));
        }
      }
    }

    return p;
  };

  Search.prototype.buildParams = function(object, prefix) {
    prefix = prefix || '';
    var k;
    var value;
    var i;
    var params = [];
    for(k in object) {
      value = object[k];
      if(!helpers.is_array(value)) {
        value = [value];
      }

      for(i = 0, len = value.length; i < len; i++) {
        var innerValue = value[i];
        if(typeof(innerValue) === 'boolean') {
          innerValue = innerValue ? '1' : '0';
        }
        params.push([prefix+k, innerValue]);
      }
    }

    return params;
  };




  return Search;


});

massreljs.define('massrel',[
         './globals'
       , './helpers'
       , './stream'
       , './account'
       , './stream_keyword_insights'
       , './stream_activity'
       , './generic_poller'
       , './generic_poller_cycle'
       , './poller'
       , './meta_poller'
       , './top_things_poller'
       , './poller_queue'
       , './context'
       , './compare'
       , './compare_poller'
       , './intents'
       , './search'
       ], function(
         massrel
       , helpers
       , Stream
       , Account
       , StreamKeywordInsights
       , StreamActivity
       , GenericPoller
       , GenericPollerCycle
       , Poller
       , MetaPoller
       , TopThingsPoller
       , PollerQueue
       , Context
       , Compare
       , ComparePoller
       , intents
       , Search
       ) {

  // public API
  massrel.Stream = Stream;
  massrel.Account = Account;
  massrel.StreamKeywordInsights = StreamKeywordInsights;
  massrel.StreamActivity = StreamActivity;
  massrel.GenericPoller = GenericPoller;
  massrel.GenericPollerCycle = GenericPollerCycle;
  massrel.Poller = Poller;
  massrel.MetaPoller = MetaPoller;
  massrel.TopThingsPoller = TopThingsPoller;
  massrel.PollerQueue = PollerQueue;
  massrel.Context = Context;
  massrel.Compare = Compare;
  massrel.ComparePoller = ComparePoller;
  massrel.helpers = helpers;
  massrel.intents = intents;
  massrel.Search = Search;

  // change default host if "massrel[host]"
  // URL param is set
  var params = helpers.parse_params();
  if(params['massrel[host]']) {
    massrel.host = params['massrel[host]'];
  }

  return massrel;
});


// call massrel module
var globals = massreljs.require('./massrel');

var massrel = window.massrel;
if(typeof(massrel) === 'undefined') {
  massrel = window.massrel = globals;
} else {
  globals.helpers.extend(massrel, globals);
}

// If there's an external AMD loader defined, define this library in that context.
if (typeof define === 'function' && define.amd) {
  define(massrel);
}

})(window);
