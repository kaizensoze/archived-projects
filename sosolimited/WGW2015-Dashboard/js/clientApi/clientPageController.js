/*
File: clientPageController.js
Description: function to set controls, click handlers, etc. on page.
Author: JC Nesci
*/

var clientPageController = (function(){

	var that = {};
	var teamA = "none";
	var teamB = "none";
	// var pollingInterval = null;

	var setup = function() {

		// Click func for Stream A dropdown.
		$("#team-a > .dropdown-menu > li > a").click(function(event) {

	    var selectedTeamId = $(this).attr("id");
	    console.log( "clientPageController- select Team A: "+ selectedTeamId );
	    setTeam( "team-a", selectedTeamId );

	  });

		// Click func for Stream B dropdown.
	  $("#team-b > .dropdown-menu > li > a").click(function(event) {

			var selectedTeamId = $(this).attr("id");
	    console.log( "clientPageController- select Team B: "+ selectedTeamId );
	    setTeam( "team-b", selectedTeamId );

	  });

	  // Click func for Stream Mode dropdown.
	  $("#stream-mode > .dropdown-menu > li > a").click(function(event) {

	  	var selectedStreamMode = $(this).attr("id");
	  	console.log( "clientPageController- select Stream Mode: "+ selectedStreamMode );
	  	setStreamMode( selectedStreamMode );

	  });

	}

	// Actions for when we select a stream mode in the navbar.
	var setStreamMode = function( iStreamMode ) {

		// Set label text in dropdown.
		var streamModeName = $("#stream-mode > .dropdown-menu > li > a#" + iStreamMode).text();
		$("#stream-mode .selected-mode").html( streamModeName );

		// Tell client API to change stream mode.
		clientData.setStreamMode( iStreamMode );

		// Add/remove streams in dropdowns depending on mode.
		if ( iStreamMode === "dev" ) {
			// Add seahawks-vast in the dropdowns.
			var newLiA = $( "<li><a id='seahawks-vast' href='#'>seahawks-vast</a></li>" ).appendTo("#team-a > .dropdown-menu");
			newLiA.find("a").click(function(event) {
		    setTeam( "team-a", $(this).attr("id") );
	    });
	    var newLiB = $( "<li><a id='seahawks-vast' href='#'>seahawks-vast</a></li>" ).appendTo("#team-b > .dropdown-menu");
			newLiB.find("a").click(function(event) {
		    setTeam( "team-b", $(this).attr("id") );
	    });
		}
		else if ( iStreamMode === "production" ) {
			// Remove seahawks-vast from the dropdowns.
			$(".streams > .dropdown-menu > li > a#seahawks-vast").remove();
			if ( teamA == "seahawks-vast" ) { setTeam( "team-a", "broncos-game" ); }
			if ( teamB == "seahawks-vast" ) { setTeam( "team-b", "broncos-game" ); }
		}

	}

	// Set a Team and create graphs accordingly.
	// The parameters are optional: if they are provided, we will use the new team(s),
	// but if they are not, we will re-use the current teams (used for polling).
	// Examples:
	// setTeam( "team-a", "seahawks-vast" );
	// setTeam( "team-b", "cardinals-game" );
	// setTeam();
	var setTeam = function( iTeamGroup, iTeam ) {

		// console.log( "clientPageController- setTeam: "+ iTeamGroup +", "+ iTeam );

		// Empty DOM items.
		emptyGraphContainer();
		emptyDailyTotalStats();
		emptyMapContainer();

		// If parameters are provided, use them; else, re-use the current teams (used for refreshing the page/polling).
		if ( iTeamGroup != undefined && iTeam != undefined ) {

			// Set to new team A or B.
			if ( iTeamGroup == "team-a" ) {
				teamA = iTeam;
			} else if ( iTeamGroup == "team-b" ) {
				teamB = iTeam;
			}

			// Set team label in dropdown.
			var selectedTeamName = $("#" + iTeamGroup + " > .dropdown-menu > li > a#" + iTeam).text();
			$("#" + iTeamGroup + " .selected-team").html( selectedTeamName );

		} else {
			// console.log( "* * * clientPageController- setTeam -PARAMETERS UNDEFINED : Re-use current teams." );
		}

		// If Team A is none, create only Team B graph.
		if ( teamA == "none" ) {

			var datasetsForTeamB = clientData.getDatasetsForTeam( teamB );
			for ( graphData in datasetsForTeamB ) {
				clientGraphView.createGraph( datasetsForTeamB[ graphData ] );
			}

			// Create map graph.
			var mapDataForTeamB = clientData.getMapDataForTeam( teamB );
			clientGraphView.createMap( mapDataForTeamB );

			// Show stats for the team(s) and recreate the vote btn click handler.
			clientPageView.displayStatsForOneStream( "team-b", teamB, clientData.getTotalDayVotesToday( teamB ) );
			setupVoteBtnClickHandler();

		}
		// If Team B is none, create only Team A graph.
		else if ( teamB == "none" ) {

			var datasetsForTeamA = clientData.getDatasetsForTeam( teamA );
			for ( graphData in datasetsForTeamA ) {
				clientGraphView.createGraph( datasetsForTeamA[ graphData ] );
			}

			// Create map graph.
			var mapDataForTeamA = clientData.getMapDataForTeam( teamA );
			clientGraphView.createMap( mapDataForTeamA );

			// Show stats for the team(s) and recreate the vote btn click handler.
			clientPageView.displayStatsForOneStream( "team-a", teamA, clientData.getTotalDayVotesToday( teamA ) );
			setupVoteBtnClickHandler();

		}
		// If neither are none, create Team A and Team B graphs.
		else {

			// Get the data for both teams, where graph types (ie. data-filter attr) are sorted to match.
			var combinedDatasetsForTeamsAB = clientData.getCombinedDatasetsForTeams( teamA, teamB );
			// Draw each combined graph by providing a matching data pair.
			for (var i = 0; i < combinedDatasetsForTeamsAB.teamA.length; i++) {
				clientGraphView.createGraph( combinedDatasetsForTeamsAB.teamA[ i ], combinedDatasetsForTeamsAB.teamB[ i ] );
			}

			// Create map of state counts.
			var mapDataForTeamA = clientData.getMapDataForTeam( teamA );
			var mapDataForTeamB = clientData.getMapDataForTeam( teamB );
			clientGraphView.createMap( mapDataForTeamA, mapDataForTeamB );

			// Show stats for the team(s) and recreate the vote btn click handler.
			clientPageView.displayStatsForTwoStreams( teamA, clientData.getTotalDayVotesToday( teamA ), teamB,  clientData.getTotalDayVotesToday( teamB ) );
			setupVoteBtnClickHandler();

		}

		// Always: Create map of live geo events.
		var geoEventsData = clientData.getGeoEventsData();
		clientGraphView.createGeoEventMap( geoEventsData );

	}

	var emptyGraphContainer = function() {
		$("#graph-container").empty();
	}

	var emptyDailyTotalStats = function(){
		$("#stats #mentions-day .stat-column").remove();
	}

	var emptyMapContainer = function() {
		// $("#map-container").empty();
		$("#map-container-counts").remove();
	}

	// Click func for vote buttons.
	var setupVoteBtnClickHandler = function() {

		$(".vote-btn").click(function(event) {
			var selectedTeamId = $(this).attr("id");

			var vote = {
			  team: selectedTeamId,
			  name: 'vote-from-soso-dashboard',
			  location: [61.216700, -149.900000]			// Anchorage, Alaska.
			};

			sosowgw.postVote(vote);

		});

	}

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Start.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	setup();

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Public Interface.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	that.setTeam = setTeam;

	return that;

})();
