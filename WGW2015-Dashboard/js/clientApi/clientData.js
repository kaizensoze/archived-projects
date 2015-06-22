/*
File: clientData.js
Description: Loads & polls data from Soso's Client API for creating the dashboard items.
Author: JC Nesci
*/

var clientData = (function() {

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Variables.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	var that = {};
	var usMapJSON;
	var countsInterval = null;
	// countsData is the data used for barcharts.
	var countsData = {};
	// stateCountsData is the data used for the map of colored states based on vote count.
	var stateCountsData = {};
	// geoEventsData is the data used for the map showing live markers of where new events are coming from on the map.
	var geoEventsData = [];
	//TODO: getCountsData is the data used for the tweets appearing live on the map.
	var isFirstDataLoad = true;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Functions.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	var loadAllData = function() {

		// Load the US map JSON at start.
		d3.json("data/us-named.json", function(error, us) {

			usMapJSON = cleanUsMapJSON( us );

			// Repeatedly check realtime API data.
		  countsInterval = window.setInterval( function(){ checkData() } , 2000);

		});

	}

	// Remove states that we know we are not using in the Sosowgw.js API.
	var cleanUsMapJSON = function( iUsMapJSON ) {

		for ( var i = 0; i < iUsMapJSON.objects.states.geometries.length; i++ ) {

			var curStateName = iUsMapJSON.objects.states.geometries[ i ].properties.name;
			if ( curStateName == "District of Columbia"
				|| curStateName == "Puerto Rico"
				|| curStateName == "Virgin Islands of the United States" ) {

				iUsMapJSON.objects.states.geometries.splice( i, 1 );
				i = i - 1;

			}
		}

		return iUsMapJSON;
	}

	// Check all data endpoints for new data.
	// All the team data we are using is from the data we receive from the sosowgw class.
	var checkData = function() {

		// console.log( "- - - - - - - - - - - - - - - - - - - - - - -" );
		// console.log( "clientData- checkData- on 2 second interval" );
		// console.log( "- - - - - - - - - - - - - - - - - - - - - - -" );

		// Data source #1.
		checkCounts();

		// Data source #2.
		checkStateCounts();

		// Data source #3.
		checkGeoEvents();

		// Cheap/temporary solution to displaying graphs when all data is ready.
		window.setTimeout( displayGraphs, 5000 );

	}

	var getUsMapJSON = function() {
		return usMapJSON;
	}

	// Check getCounts for data used to build barcharts.
	var checkCounts = function() {

		// Use this stringify then parse back to object hack to create a copy of the object received from getCounts(),
		// so we do not modify the object in sosowgw.js (since everything in JS in pass-by-reference).
		var countsJSON = JSON.parse(JSON.stringify( sosowgw.getCounts() ))
		// console.log( "countsJSON:" );
	 //  console.log( countsJSON );

	  countsData = parseCountsJSON( countsJSON );

	  // console.log( "countsData:" );
	  // console.log( countsData );

	}

	var checkStateCounts = function() {

		// console.log( "* * * * * * * * * * * * * * * *" );

		var stateCountsJSON = JSON.parse(JSON.stringify( sosowgw.getStateCounts() ))
		// console.log( "stateCountsJSON:" );
		// console.log( stateCountsJSON );

	  stateCountsData = parseStateCountsJSON( stateCountsJSON );

	  // console.log( "stateCountsData:" );
	  // console.log( stateCountsData );

	}

	var checkGeoEvents = function() {

		// console.log( "* * * * * * * * * * * * * * * *" );

		// getGeoEvents() returns an array of objects.
		// Exmaple: Object {team: "seahawks", username: "PeaceoutR", name: "Rachel Schovajsa", location: Array[2], time: "Tue Dec 23 20:39:12 +0000 2014"}
		var geoEventsJSON = sosowgw.getGeoEvents();
		// console.log( "geoEventsJSON:" );
		// console.log( geoEventsJSON );

		geoEventsData = geoEventsData.concat( geoEventsJSON );

	}

	var displayGraphs = function() {

			// console.log( "displayGraphs- START! ----------------- *" )

			// Display barcharts when ready.
			if ( isFirstDataLoad ) {
		  	isFirstDataLoad = false;
		  	// On first load, display specific team(s).
			  clientPageController.setTeam( "team-a", "seahawks-game" );
			  clientPageController.setTeam( "team-b", "broncos-game" );
		  } else {
		  	// The rest of the time, refresh the current teams.
		  	clientPageController.setTeam();
		  }

	}

	var parseCountsJSON = function( iCountsJSON ) {

		var temp = {};

		for ( stream in iCountsJSON ) {
			temp[ stream ] = {};
			temp[ stream ].graphDataHours = createGraphDataHours( stream, iCountsJSON[stream] );
			temp[ stream ].graphDataDays = createGraphDataDays( stream, iCountsJSON[stream] );
		}

	  return temp;
	}

	var parseStateCountsJSON = function( iStateCountsJSON ) {

		var temp = {};

		for ( stream in iStateCountsJSON ) {
			temp[ stream ] = {};
			temp[ stream ] = createMapData( stream, iStateCountsJSON[stream] );
		}

		return temp;
	}

	var createMapData = function( iStreamName, iStreamJSON ) {

		var data = {};
		data.stream = iStreamName;
		data.mapData = iStreamJSON.days[ iStreamJSON.days.length-1 ];
		data.team = iStreamJSON.team;
		data.mapName = "Day Map";

		return data;
	}

	var createGraphDataDays = function( iStreamName, iStreamJSON ) {

		var data = {};
		data.stream = iStreamName;
		data.graphData = iStreamJSON.days;
		data.team = iStreamJSON.team;
		data.graphName = "Days";

		return data;
	}

	var createGraphDataHours = function( iStreamName, iStreamJSON ) {

		// Create array of 24 hours, all with 0 count.
		var graphData = [];
		for ( var i = 0; i < 24; i++ ) {
			var nullData = { count: "0", hour: i.toString() };
			graphData.push( nullData );
		}

		// console.log( "1) createGraphDataHours- graphData "+ iStreamName +":" );
		// console.log( graphData );

		// Fill in the hours we have in the last 24 hour cycle from the JSON.
		// Iterate backwards as the last object in the JSON is the most recent hour.
		// hoursAvailableInLastDay = parseInt( iStreamJSON.hours[ iStreamJSON.hours.length-1 ].hour );
		// console.log( "createGraphDataHours- hoursAvailableInLastDay: " + hoursAvailableInLastDay );
		for ( var i = iStreamJSON.hours.length-1; i >= 0; i-- ) {

			var curHour = parseInt( iStreamJSON.hours[ i ].hour );
			var curCount = iStreamJSON.hours[ i ].count;

			// console.log( "----- i: "+ i );
			// console.log( "---- curHour: "+ curHour );
			// console.log( "--- curCount: "+ curCount );

			// Stuff the hour count from the latest hour down to the 0 hour.
			graphData[ curHour ].count = curCount;
			// Exit once we've encountered the first 0 hour.
			if ( curHour == 0 ) {
				// console.log( "% % % % % % % % % % %    BREAK    % % % % % % % % % % % %" );
				break;
			}

			// console.log( "-- graphData[ "+ curHour +" ]: ");
			// console.log( graphData[ curHour ] );
		}

		// console.log( "2) createGraphDataHours- graphData "+ iStreamName +":" );
		// console.log( graphData );

		// Format the object we're sending to the graphing function.
		var data = {};
		data.stream = iStreamName;
		data.graphData = graphData;
		data.team = iStreamJSON.team;
		data.graphName = "Hours since 7PM";

		// clientGraphView.createGraph( data );

		return data;
	}

	// Get the graphing datasets for the specified team.
	var getDatasetsForTeam = function( iTeam ) {
		return countsData[ iTeam ];
	}

	// Get data objects for 2 teams, sorted equally per graph type.
	// Example result: teamA[0] graph type = current-hour-in-minutes && teamB[0] graph type = current-hour-in-minutes, teamA[1] graph type = current-day-in-hours && teamB[1] graph type = current-day-in-hours, etc.
	var getCombinedDatasetsForTeams = function( iTeamA, iTeamB ) {

		var dataForTeamA = countsData[ iTeamA ];
		var dataForTeamB = countsData[ iTeamB ];

		// console.log( "data- getCombinedDatasetsForTeams -dataForTeamA:" );
		// console.log( dataForTeamA );
		// console.log( "data- getCombinedDatasetsForTeams -dataForTeamB:" );
		// console.log( dataForTeamB );

		var sortedDataForTeamA = [];
		var sortedDataForTeamB = [];

		// Make sure the graph data is in order so A's and B's data for the same graph are at the same index.
		for ( graphDataType in dataForTeamA ) {
			sortedDataForTeamA.push( dataForTeamA[ graphDataType ] );
			sortedDataForTeamB.push( dataForTeamB[ graphDataType ] );
		}

		// console.log( "data- getCombinedDatasetsForTeams -sortedDataForTeamA:" );
		// console.log( sortedDataForTeamA );
		// console.log( "data- getCombinedDatasetsForTeams -sortedDataForTeamB:" );
		// console.log( sortedDataForTeamB );

		return { teamA: sortedDataForTeamA, teamB: sortedDataForTeamB };
	}

	// Get today's total vote for specified team, by adding up all counts in graphDataHours.
	var getTotalHourVotesToday = function( iTeam ) {

		var arrayHourCounts = _.pluck( countsData[ iTeam ].graphDataHours.graphData, "count" );
		var totalVoteToday = _.reduce( arrayHourCounts, function(memo, num){ return memo + num; }, 0);

		return totalVoteToday;
	}

	// Get today's total vote by taking the most recent day from graphDataDays.
	var getTotalDayVotesToday = function( iTeam ) {

		var data = countsData[ iTeam ].graphDataDays.graphData;
		var dayCountToday = data[ data.length-1 ].count;

		return dayCountToday;
	}

	var clearCountsInterval = function() {
		clearInterval( countsInterval );
	}

	var getMapDataForTeam = function( iTeam ) {
		return stateCountsData[ iTeam ];
	}

	// Format the team data for the map graph. Always returns a single formatted object.
	// If both teams are provided, creates a single combined formatted object.
	var formatDataForMap = function( iDataTeamA, iDataTeamB ) {

		// console.log( "*********************************** *" );
		// console.log( "formatDataForMap" );

		var formattedData = [];

		// Combine data from both teams for each state.
		for ( state in iDataTeamA.mapData.states ) {

			if ( iDataTeamB != undefined ) {

				// console.log( "-----------------------" );

				var curState = iDataTeamA.mapData.states[state];
				var curStateName = curState.name;
				var curStateInDataTeamB = _.findWhere( iDataTeamB.mapData.states, { name: curStateName } );

				formattedData[ curStateName ] = {};
				var d = formattedData[ curStateName ];
				d.teamACount = curState.count;
				d.teamBCount = curStateInDataTeamB.count;
				d.diffCount = ( curState.count - curStateInDataTeamB.count );
				d.leadingStream = d.diffCount >= 0 ? ( d.diffCount == 0 ? "none" : iDataTeamA.stream ) : iDataTeamB.stream;
				d.leadingTeam = d.diffCount >= 0 ? ( d.diffCount == 0 ? "none" : iDataTeamA.team ) : iDataTeamB.team;

				// console.log( curState );
				// console.log( curStateName );
				// console.log( curStateInDataTeamB );
				// console.log( formattedData[state] );

			} else {

				var curState = iDataTeamA.mapData.states[state];
				var curStateName = curState.name;

				formattedData[ curStateName ] = {};
				var d = formattedData[ curStateName ];
				d.teamACount = curState.count;

			}

		}

		// console.log( "*********************************** formatDataForMap" );
		// console.log( formattedData );

		return formattedData;
	}

	// Get minimum count difference (ie. the leading amount) between Team A and B.
	var getMinDiffCount = function( iFormattedMapData ) {

		var min = _.chain( iFormattedMapData )
			.values()
			.pluck( "diffCount" )
			.min()
			.value();

		// console.log( "**************************** getMinDiffCount" );
		// console.log( _.chain(iFormattedMapData).values().pluck("diffCount").value() );
		// console.log( min );

		return min;
	}

	// Get max count difference (ie. the leading amount) between Team A and B.
	var getMaxDiffCount = function( iFormattedMapData ) {

		var max = _.chain( iFormattedMapData )
			.values()
			.pluck( "diffCount" )
			.max()
			.value();

		// console.log( "**************************** getMaxDiffCount" );
		// console.log( _.chain(iFormattedMapData).values().pluck("diffCount").value() );
		// console.log( max );

		return max;
	}

	// Return the max count for when there's only 1 team on the map.
	var getMaxCount = function( iFormattedMapData ) {

		var max = _.chain( iFormattedMapData )
			.values()
			.pluck( "teamACount" )
			.map( function(num){ return parseInt( num ); } )
			.max()
			.value();

		// console.log( "**************************** getMaxCount" );
		// console.log( _.chain(iFormattedMapData).values().pluck("teamACount").map( function(num){ return parseInt( num ); } ).value() );
		// console.log( max );

		return max;

	}

	// Return live geo tweets data from last poll.
	var getGeoEventsData = function() {

		return geoEventsData;

	}

	var emptyGeoEventsData = function() {

		geoEventsData = [];

	}

	// Set stream mode in Sosowgw's client API.
	// Options:
	// setStreamMode("dev") -> use the dev streams, which are more numerous than the production streams.
	// setStreamMode("production") -> use the production streams, which are fewer and cleaner.
	var setStreamMode = function( iStreamMode ) {

		// console.log( "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *" );
		// console.log( "clientData- setStreamMode- iStreamMode = "+ iStreamMode );
		// console.log( "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *" );

		if ( iStreamMode === "dev" ) {
			sosowgw.useDev( true );
		}
		else if ( iStreamMode === "production" ) {
			sosowgw.useDev( false );
		}

	}

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Public Interface.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	that.loadAllData = loadAllData;
	that.clearCountsInterval = clearCountsInterval;
	that.getDatasetsForTeam = getDatasetsForTeam;
	that.getCombinedDatasetsForTeams = getCombinedDatasetsForTeams;
	that.getTotalHourVotesToday = getTotalHourVotesToday;
	that.getTotalDayVotesToday = getTotalDayVotesToday;
	that.getMapDataForTeam = getMapDataForTeam;
	that.getUsMapJSON = getUsMapJSON;
	that.formatDataForMap = formatDataForMap;
	that.getMinDiffCount = getMinDiffCount;
	that.getMaxDiffCount = getMaxDiffCount;
	that.getMaxCount = getMaxCount;
	that.getGeoEventsData = getGeoEventsData;
	that.emptyGeoEventsData = emptyGeoEventsData;
	that.setStreamMode = setStreamMode;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	return that;

}());

