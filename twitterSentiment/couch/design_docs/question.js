
module.exports = {
  _id: "_design/question",

  views: {

    pos: {
      map: function(doc) {
        // get GMT-0500 date regardless of server's time zone
        var n = Date.parse(doc.twitter.created_at);
        var offset = new Date().getTimezoneOffset();
        var date = new Date(n - (5-(offset/60))*60*60*1000);
        
        var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        var hour = date.getHours();
        var minute = date.getMinutes();
        var customMinute = Math.floor(minute / 15);

        var question = doc.question;
        var team = doc.team;

        var pos = doc.sentiment[0];
        var coefficient = doc.coefficient;

        if (pos > 0) {
          emit([question, team, year, month, day, hour, customMinute, minute], pos*coefficient);
        }
      },
      reduce: "_sum"
    },

    neg: {
      map: function(doc) {
        // get GMT-0500 date regardless of server's time zone
        var n = Date.parse(doc.twitter.created_at);
        var offset = new Date().getTimezoneOffset();
        var date = new Date(n - (5-(offset/60))*60*60*1000);
        
        var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        var hour = date.getHours();
        var minute = date.getMinutes();
        var customMinute = Math.floor(minute / 15);

        var question = doc.question;
        var team = doc.team;

        var neg = doc.sentiment[1];
        var coefficient = doc.coefficient;

        if (neg < 0) {
          emit([question, team, year, month, day, hour, customMinute, minute], Math.abs(neg)*coefficient);
        }
      },
      reduce: "_sum"
    },

    confidence: {
      map: function(doc) {
        // get GMT-0500 date regardless of server's time zone
        var n = Date.parse(doc.twitter.created_at);
        var offset = new Date().getTimezoneOffset();
        var date = new Date(n - (5-(offset/60))*60*60*1000);
        
        var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        var hour = date.getHours();
        var minute = date.getMinutes();
        var customMinute = Math.floor(minute / 15);

        var question = doc.question;
        var team = doc.team;

        var pos = doc.sentiment[0];
        var neg = doc.sentiment[1];

        var coefficient = doc.coefficient;

        emit([question, team, year, month, day, hour, customMinute, minute], [pos*coefficient, Math.abs(neg)*coefficient]);
      },
      reduce: function(keys, values, rereduce) {
        var pos = sum(values.map(function(value) {
          return value[0];
        }));
        var neg = sum(values.map(function(value) {
          return value[1];
        }));
        return [pos, neg];
      }
    },

    tweets: {
      map: function(doc) {
        // get GMT-0500 date regardless of server's time zone
        var n = Date.parse(doc.twitter.created_at);
        var offset = new Date().getTimezoneOffset();
        var date = new Date(n - (5-(offset/60))*60*60*1000);
        
        var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        var hour = date.getHours();
        var minute = date.getMinutes();
        var customMinute = Math.floor(minute / 15);

        var question = doc.question;
        var team = doc.team;

        var coefficient = doc.coefficient;

        emit([question, team, year, month, day, hour, customMinute, minute], 1*coefficient);
      },
      reduce: "_sum"
    }
    
  }
};
