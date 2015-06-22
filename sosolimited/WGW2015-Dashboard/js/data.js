/*
File: Data.js
Description: Data used for creating graphs.
Author: JC Nesci
*/

var data = (function() {

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Variables.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	var that = {};
	var currentTime = null;
	var timezone = null;
	var targetHour = null;
	var allData = null;
	// Define each graph to display, and its associated datastream, etc.
	var dataset =
		[
			// Seahawks-vast graphs.
			{
				"name": "Last 60 minutes",
				"url": "http://api.massrelevance.com/sosowgw/seahawks-vast/meta.json?num_minutes=60",
				"data-filter": "current-hour-in-minutes",
				"team": "seahawks-vast"
			},
			{
				"name": "Last 24 hours",
				"url": "http://api.massrelevance.com/sosowgw/seahawks-vast/meta.json?num_hours=24",
				"data-filter": "current-day-in-hours",
				"team": "seahawks-vast"
			},
			{
				"name": "Last 7 days",
				"url": "http://api.massrelevance.com/sosowgw/seahawks-vast/meta.json?num_hours=240",
				"data-filter": "current-week-in-hours",
				"team": "seahawks-vast"
			},
			// Seahawks-game graphs.
			{
				"name": "Last 60 minutes",
				"url": "http://api.massrelevance.com/sosowgw/seahawks-game/meta.json?num_minutes=60",
				"data-filter": "current-hour-in-minutes",
				"team": "seahawks-game"
			},
			{
				"name": "Last 24 hours",
				"url": "http://api.massrelevance.com/sosowgw/seahawks-game/meta.json?num_hours=24",
				"data-filter": "current-day-in-hours",
				"team": "seahawks-game"
			},
			{
				"name": "Last 7 days",
				"url": "http://api.massrelevance.com/sosowgw/seahawks-game/meta.json?num_hours=240",
				"data-filter": "current-week-in-hours",
				"team": "seahawks-game"
			},
			// Eagles-game graphs.
			{
				"name": "Last 60 minutes",
				"url": "http://api.massrelevance.com/sosowgw/eagles-game/meta.json?num_minutes=60",
				"data-filter": "current-hour-in-minutes",
				"team": "eagles-game"
			},
			{
				"name": "Last 24 hours",
				"url": "http://api.massrelevance.com/sosowgw/eagles-game/meta.json?num_hours=24",
				"data-filter": "current-day-in-hours",
				"team": "eagles-game"
			},
			{
				"name": "Last 7 days",
				"url": "http://api.massrelevance.com/sosowgw/eagles-game/meta.json?num_hours=240",
				"data-filter": "current-week-in-hours",
				"team": "eagles-game"
			},
			// Cardinals-game graphs.
			{
				"name": "Last 60 minutes",
				"url": "http://api.massrelevance.com/sosowgw/cardinals-game/meta.json?num_minutes=60",
				"data-filter": "current-hour-in-minutes",
				"team": "cardinals-game"
			},
			{
				"name": "Last 24 hours",
				"url": "http://api.massrelevance.com/sosowgw/cardinals-game/meta.json?num_hours=24",
				"data-filter": "current-day-in-hours",
				"team": "cardinals-game"
			},
			{
				"name": "Last 7 days",
				"url": "http://api.massrelevance.com/sosowgw/cardinals-game/meta.json?num_hours=240",
				"data-filter": "current-week-in-hours",
				"team": "cardinals-game"
			},
			// Broncos-game graphs.
			{
				"name": "Last 60 minutes",
				"url": "http://api.massrelevance.com/sosowgw/broncos-game/meta.json?num_minutes=60",
				"data-filter": "current-hour-in-minutes",
				"team": "broncos-game"
			},
			{
				"name": "Last 24 hours",
				"url": "http://api.massrelevance.com/sosowgw/broncos-game/meta.json?num_hours=24",
				"data-filter": "current-day-in-hours",
				"team": "broncos-game"
			},
			{
				"name": "Last 7 days",
				"url": "http://api.massrelevance.com/sosowgw/broncos-game/meta.json?num_hours=240",
				"data-filter": "current-week-in-hours",
				"team": "broncos-game"
			},
			// Patriots-game graphs.
			{
				"name": "Last 60 minutes",
				"url": "http://api.massrelevance.com/sosowgw/patriots-game/meta.json?num_minutes=60",
				"data-filter": "current-hour-in-minutes",
				"team": "patriots-game"
			},
			{
				"name": "Last 24 hours",
				"url": "http://api.massrelevance.com/sosowgw/patriots-game/meta.json?num_hours=24",
				"data-filter": "current-day-in-hours",
				"team": "patriots-game"
			},
			{
				"name": "Last 7 days",
				"url": "http://api.massrelevance.com/sosowgw/patriots-game/meta.json?num_hours=240",
				"data-filter": "current-week-in-hours",
				"team": "patriots-game"
			},
			// Packers-game graphs.
			{
				"name": "Last 60 minutes",
				"url": "http://api.massrelevance.com/sosowgw/packers-game/meta.json?num_minutes=60",
				"data-filter": "current-hour-in-minutes",
				"team": "packers-game"
			},
			{
				"name": "Last 24 hours",
				"url": "http://api.massrelevance.com/sosowgw/packers-game/meta.json?num_hours=24",
				"data-filter": "current-day-in-hours",
				"team": "packers-game"
			},
			{
				"name": "Last 7 days",
				"url": "http://api.massrelevance.com/sosowgw/packers-game/meta.json?num_hours=240",
				"data-filter": "current-week-in-hours",
				"team": "packers-game"
			},

			// TODO: new names
			// barchart-hour-uptonow
			// barchart-day-uptonow
			// barchart-hours
			// barchart-minutes

		];

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Functions.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	// Set the entire app's timezone using a timezone name as found in /js/libs/moment-timezone-with-data-2010-2020.min.js
	var setTimezone = function( iTimezone ) {
		timezone = iTimezone;
		currentTime = moment().tz( timezone );
	}

	// Set the daily target cutoff hour (from 0 to 23) from which mentions are counted/cumulated.
	var setDailyTargetHour = function( iTargetHour ) {
		targetHour = iTargetHour;
	}
	var getDailyTargetHour = function() {
		return targetHour;
	}

	// Load the data from the dataset array.
	// The parameter is optional:
	// if it is provided, that means we also want to set Team A after the data is loaded (used for the first time we load the data),
	// but if it is not, we will re-display the current teams after the data is loaded (used for polling).
	var loadAllData = function( iInitialTeamA ) {

		// Setup the global time settings.
		setTimezone( 'America/Phoenix' );						// Set app's timezone to Mountain Time/Phoenix Arizona.
		setDailyTargetHour( 19 );										// 7:00 PM

		// Use Bostock's Queue.js to load all JSON and wait for all results to return before continuing.
		var q = queue();
		dataset.forEach(function(d) { q.defer(d3.json, d.url); });
		q.awaitAll(function(error, results) {

			// console.log("data- loadAllData- results:");
			// console.log(results);

			// Store the dataset params back into the result for reference.
			for (var i = 0; i < results.length; i++) {
				results[ i ][ "params" ] = {};
				results[ i ][ "params" ][ "name" ] = dataset[ i ][ "name" ];
				results[ i ][ "params" ][ "url" ] = dataset[ i ][ "url" ];
				results[ i ][ "params" ][ "data-filter" ] = dataset[ i ][ "data-filter" ];
				results[ i ][ "params" ][ "team" ] = dataset[ i ][ "team" ];
			}

			// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			// Create graph data depending on the graph type, by filtering result data.
			// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

			// Store results as public var.
			allData = results;

			for (var i = 0; i < allData.length; i++) {

				var result = allData[i];
				var graphData = {};
				graphData.mainData = [];

				if (result["params"]["data-filter"] == "activity-minutes") {
					graphData = createGraphDataActivityMinutes( result );
				}
				else if (result["params"]["data-filter"] == "activity-hours") {
					graphData = createGraphDataActivityHours( result );
				}
				else if (result["params"]["data-filter"] == "current-hour-in-minutes") {
					graphData = createGraphDataCurrentHourInMinutes( result );
				}
				else if (result["params"]["data-filter"] == "current-day-in-hours") {
					graphData = createGraphDataCurrentDayInHours( result );
				}
				else if (result["params"]["data-filter"] == "current-week-in-hours") {
					graphData = createGraphDataCurrentWeekInHours( result );
				}

				result.graphData = graphData;
				result.graphIndex = i;

			}

			// console.log("data- loadAllData- allData:");
			// console.log(allData);

			// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			// Display initial graphs now that data is built.
			// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

			// 1) Graphs.
			// If initial team is provided, that means we are loading data for the first time, and want to start by showing that team.
			if ( iInitialTeamA != undefined ) { pageController.setTeam( "team-a", iInitialTeamA ); }
			// If it isn't provided, we want to re-use the current teams (for polling).
			else { pageController.setTeam(); }

			// 2) Stats.
			pageView.displaySettings( timezone, currentTime.format("Z z"), targetHour );

		});

	}

	// Get the graphing datasets for the specified team.
	var getDatasetsForTeam = function( iTeam ) {

		var dataForTeam = _.filter( allData, function(d){
			return d.params.team == iTeam;
		});

		// console.log( "data- getDatasetsForTeam:" );
		// console.log( dataForTeam );

		return dataForTeam;

	}

	// Get data objects for 2 teams, sorted equally per graph type.
	// Example result: teamA[0] graph type = current-hour-in-minutes && teamB[0] graph type = current-hour-in-minutes, teamA[1] graph type = current-day-in-hours && teamB[1] graph type = current-day-in-hours, etc.
	var getCombinedDatasetsForTeams = function( iTeamA, iTeamB ) {
		var dataForTeamA = _.filter( allData, function(d){ return d.params.team == iTeamA; });
		var dataForTeamB = _.filter( allData, function(d){ return d.params.team == iTeamB; });

		// console.log( "data- getCombinedDatasetsForTeams -dataForTeamA:" );
		// console.log( dataForTeamA );
		// console.log( "data- getCombinedDatasetsForTeams -dataForTeamB:" );
		// console.log( dataForTeamB );

		var sortedDataForTeamA = [];
		var sortedDataForTeamB = [];

		_.each( dataForTeamA, function(element, index) {
			var graphType = element.params["data-filter"];
			sortedDataForTeamA.push( element );
			var elementWithSameTypeTeamB = _.find( dataForTeamB, function(d){ return graphType == d.params["data-filter"] } );
			sortedDataForTeamB.push( elementWithSameTypeTeamB );
		});

		// console.log( "data- getCombinedDatasetsForTeams -sortedDataForTeamA:" );
		// console.log( sortedDataForTeamA );
		// console.log( "data- getCombinedDatasetsForTeams -sortedDataForTeamB:" );
		// console.log( sortedDataForTeamB );

		return { teamA: sortedDataForTeamA, teamB: sortedDataForTeamB };
	}

	// Get the statsData property of a data object.
	var getStatsForTeam = function( iTeam ) {

		// All objects of the same team have the same stats, so just use the first one.
		var team = _.find( allData, function(d){
			return d.params.team == iTeam;
		});
		var teamStats = team.statsData;

		// console.log( "data- getStatsForTeam:" );
		// console.log( teamStats );

		return teamStats;
	}

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Functions: Graph data creation.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	var createGraphDataActivityMinutes = function( data ) {
		var graphData = {};
		graphData.mainGraphData = [];
		var mainGraphData = graphData.mainGraphData;
		var dataFiltered = data.activity.minute.approved;

		dataFiltered.forEach(function( d, i ) {
			mainGraphData.push( { "xValue": i, "yValue": d } );
		});

		mainGraphData.forEach(function( d ) {
			d.xValue = +d.xValue;
			d.yValue = +d.yValue;
		});

		return graphData;
	}

	var createGraphDataActivityHours = function( data ) {
		var graphData = {};
		graphData.mainGraphData = [];
		var mainGraphData = graphData.mainGraphData;
		var dataFiltered = data.activity.hourly.approved;

		dataFiltered.forEach(function( d, i ) {
			mainGraphData.push( { "xValue": i, "yValue": d } );
		});

		mainGraphData.forEach(function( d ) {
			d.xValue = +d.xValue;
			d.yValue = +d.yValue;
		});

		return graphData;
	}

	var createGraphDataCurrentHourInMinutes = function( data ) {

		var dataFiltered = data.activity.minute.approved;
		var mainGraphData = [];

		dataFiltered.forEach(function( d, i ) {
			mainGraphData.push( { "xValue": i, "yValue": d } );
		});

		mainGraphData.forEach(function( d ) {
			d.xValue = +d.xValue;
			d.yValue = +d.yValue;
		});

		// Create vars for marking the current hour, etc.
		var curMinutesSinceHour = currentTime.minutes();
		var curHourCutoffPosition = 60 - curMinutesSinceHour;
		var curHour = currentTime.hour();
		// Count number of mentions since the last hour mark.
		var dataSliceSinceHour = mainGraphData.slice( curHourCutoffPosition );
		var pluckMentionsOnly = _.pluck(dataSliceSinceHour, "yValue");
		var totalThisHour = _.reduce( pluckMentionsOnly, function(memo, num){ return memo + num; }, 0);

		// Build x-axis tick values to display time values instead of array index.
		// NB: Go all the way to mainGraphData.length+1 because the last tick mark to display with a timestring is 60, not 59.
		var xValuesAsTimestring = [];
		for ( var i = 0; i < (mainGraphData.length + 1); i++ ) {
			// console.log("----- "+ i);

			// 'd' is the index value shown on the current tick (from 0 to 60).
			// but ticks exist only for some of the values, not all.
			var nMinutesBeforeNow = (60 - i);
			var tickTime = currentTime.clone().subtract( nMinutesBeforeNow, "minutes" );
			var tickHour = tickTime.hour();
			var tickMinutes = tickTime.minutes().toString().length > 1 ? tickTime.minutes() : ("0"+tickTime.minutes().toString());

			xValuesAsTimestring[i] = ( tickHour +":"+ tickMinutes );
			// console.log( xValuesAsTimestring[i] );
		}

		// Calculate the total daily vote for the current team and store it in all data objects of the same team:
		// First find if another data object with the same team exists which has the other amount we need to calculate the total vote.
		// ( total daily vote = mentionsSinceTargetTotal + totalThisHour )
		// If that object exists, calculate the vote, and store it in all objects of the same team.
		var totalThisDay;
		_.each( allData, function(d){
			if ( (d.params.team == data.params.team) && (d.graphData != undefined) ) {
				if (d.graphData.mentionsSinceTargetTotal != undefined) {
					totalThisDay = totalThisHour + d.graphData.mentionsSinceTargetTotal;
				}
			}
		});
		_.each( allData, function(d){
			if ( d.params.team == data.params.team ) {
				if ( typeof d.statsData == "undefined" ) {
					d.statsData = {};
				}
				d.statsData.totalThisDay = totalThisDay;
				d.statsData.totalThisHour = totalThisHour;
			}
		});

		// Return all graph related data back to the data object.
		var graphData = {};
		graphData.mainGraphData = mainGraphData;
		graphData.xValuesAsTimestring = xValuesAsTimestring;
		graphData.curMinutesSinceHour = curMinutesSinceHour;
		graphData.curHourCutoffPosition = curHourCutoffPosition;
		graphData.curHour = curHour;
		graphData.totalThisHour = totalThisHour;

		return graphData;
	}

	var createGraphDataCurrentDayInHours = function( data ) {

		var dataFiltered = data.activity.hourly.approved;
		var mainGraphData = [];

		dataFiltered.forEach(function( d, i ) {
			mainGraphData.push( { "xValue": i, "yValue": d } );
		});

		mainGraphData.forEach(function( d ) {
			d.xValue = +d.xValue;
			d.yValue = +d.yValue;
		});

		// 1) Count number of hours between now and the last occurence of target hour (ex: 19:00/7:00PM).
		var curHour = currentTime.hour();
		var hoursBetweenTargetAndNow;
		if ( curHour >= targetHour ) { hoursBetweenTargetAndNow = curHour - targetHour; }
		else { hoursBetweenTargetAndNow = 24 - (targetHour - curHour); }
		// console.log( "hoursBetweenTargetAndNow: "+ hoursBetweenTargetAndNow );
		// 2) Get index of target hour in our array of 24 hours.
		var targetHourIndex = 24 - hoursBetweenTargetAndNow;
		// console.log( "targetHourIndex: "+ targetHourIndex );
		// 3) Slice subarray from index of target hour to now, and add up the mentions in it.
		var dataSliceSinceTarget = mainGraphData.slice( targetHourIndex );
		var mentionsSinceTargetArray = _.pluck( dataSliceSinceTarget, "yValue" );
		var mentionsSinceTargetTotal = _.reduce( mentionsSinceTargetArray, function(memo, num){ return memo + num; }, 0);

		// Build x-axis tick values to display time values instead of array index.
		// NB: Go all the way to mainGraphData.length+1 because the last tick mark to display with a timestring is 24, not 23.
		var xValuesAsTimestring = [];
		for ( var i = 0; i < (mainGraphData.length + 1); i++ ) {
			// console.log("----- "+ i);

			// 'd' is the index value shown on the current tick (from 0 to 24).
			// but ticks exist only for some of the values, not all.
			var nHoursBeforeNow = (24 - i);
			var tickTime = currentTime.clone().subtract( nHoursBeforeNow, "hours" );
			var tickDay = tickTime.date();
			var tickHour = tickTime.hour().toString().length > 1 ? tickTime.hour() : ("0"+tickTime.hour().toString());

			xValuesAsTimestring[i] = ( tickDay +" / "+ tickHour +":00" );
			// console.log( xValuesAsTimestring[i] );
		}

		// Calculate the total daily vote for the current team and store it in all data objects of the same team:
		// First find if another data object with the same team exists which has the other amount we need to calculate the total vote.
		// ( total daily vote = mentionsSinceTargetTotal + totalThisHour )
		// If that object exists, calculate the vote, and store it in all objects of the same team.
		var totalThisDay;
		_.each( allData, function(d){
			if ( (d.params.team == data.params.team) && (d.graphData != undefined) ) {
				if (d.graphData.totalThisHour != undefined) {
					totalThisDay = mentionsSinceTargetTotal + d.graphData.totalThisHour;
				}
			}
		});
		_.each( allData, function(d){
			if ( d.params.team == data.params.team ) {
				if ( typeof d.statsData == "undefined" ) {
					d.statsData = {};
				}
				d.statsData.totalThisDay = totalThisDay;
				d.statsData.mentionsSinceTargetTotal = mentionsSinceTargetTotal;
			}
		});

		// Return all graph related data back to the data object.
		var graphData = {};
		graphData.mainGraphData = mainGraphData;
		graphData.xValuesAsTimestring = xValuesAsTimestring;
		graphData.hoursBetweenTargetAndNow = hoursBetweenTargetAndNow;
		graphData.targetHourIndex = targetHourIndex;
		graphData.mentionsSinceTargetTotal = mentionsSinceTargetTotal;

		return graphData;
	}

	var createGraphDataCurrentWeekInHours = function( data ) {

		var dataFiltered = data.activity.hourly.approved;
		var mainGraphData = [];

		// console.log( "* * * * * * * * * * * * * * * * * * * * * * *" );

		// 1) Find the number of hours between now and the last occurence of target hour (ex: 19:00/7PM).
		var curHour = currentTime.hour();
		var hoursBetweenTargetAndNow;
		var isTargetInPreviousDay;
		if ( curHour >= targetHour ) {
			hoursBetweenTargetAndNow = curHour - targetHour;
			isTargetInPreviousDay = false;
		} else {
			hoursBetweenTargetAndNow = 24 - (targetHour - curHour);
			isTargetInPreviousDay = true;
		}

		// 2) Keep only the hours that comprise the last 7 days, starting from the last occurence target hour (ex: 19:00/7PM).
		var numHoursDesired = 7 * 24;
		arraySliceEnd = dataFiltered.length - hoursBetweenTargetAndNow;
		arraySliceStart = arraySliceEnd - numHoursDesired;
		// Now we have the array of the 168 hours we want.
		var dataFiltered = dataFiltered.slice( arraySliceStart, arraySliceEnd );
		// Group each 24 hour blocks into a day, to produce a dataset of 7 days.
		var blockSize = 24;
		var tempWeekData = [];
		for ( var i = 0; i < dataFiltered.length; i += blockSize ) {
	    var tempDaySlice = dataFiltered.slice( i, (i + blockSize) );
	    var tempDayTotal = _.reduce( tempDaySlice, function(memo, num){ return memo + num; }, 0 );
	    tempWeekData.push( tempDayTotal );
		}
		dataFiltered = tempWeekData;

		// console.log( "createGraphDataCurrentWeekInHours -dataFiltered:" );
		// console.log( dataFiltered );

		// Count total number of mentions in those past 7 days.
		var mentionsInPastWeek = _.reduce( dataFiltered, function(memo, num){ return memo + num; }, 0 );

		// console.log( "createGraphDataCurrentWeekInHours- mentionsInPastWeek: "+ mentionsInPastWeek );

		dataFiltered.forEach(function( d, i ) {
			mainGraphData.push( { "xValue": i, "yValue": d } );
		});

		mainGraphData.forEach(function( d ) {
			d.xValue = +d.xValue;
			d.yValue = +d.yValue;
		});

		// console.log( "createGraphDataCurrentWeekInHours- mainGraphData:" );
		// console.log( mainGraphData );

		// Build x-axis tick values to display the date instead of array index.
		// NB: Go all the way to mainGraphData.length+1 because the last tick mark to display is 1 past the length of the data.
		var xValuesAsTimestring = [];
		for ( var i = 0; i < (mainGraphData.length + 1); i++ ) {
			// console.log("----- "+ i);

			// If target hour is in the previous day, we need to move all day labels back by 1 day.
			if ( isTargetInPreviousDay ) {
				var nDaysBeforeNow = (7 - i) + 1;
			} else {
				var nDaysBeforeNow = (7 - i);
			}

			var tickTime = currentTime.clone().subtract( nDaysBeforeNow, "days" );
			var tickDayFormatted = tickTime.format( "MMM Do[, "+ targetHour +":00]" );

			// console.log( "tickDayFormatted: "+ tickDayFormatted );

			xValuesAsTimestring[i] = tickDayFormatted;
		}

		// Return all graph related data back to the data object.
		var graphData = {};
		graphData.mainGraphData = mainGraphData;
		graphData.xValuesAsTimestring = xValuesAsTimestring;
		graphData.mentionsInPastWeek = mentionsInPastWeek;

		return graphData;
	}

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Public Interface.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	that.allData = allData;
	that.loadAllData = loadAllData;
	that.setTimezone = setTimezone;
	that.setDailyTargetHour = setDailyTargetHour;
	that.getDailyTargetHour = getDailyTargetHour;
	that.getDatasetsForTeam = getDatasetsForTeam;
	that.getCombinedDatasetsForTeams = getCombinedDatasetsForTeams;
	that.getStatsForTeam = getStatsForTeam;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	return that;

}());

