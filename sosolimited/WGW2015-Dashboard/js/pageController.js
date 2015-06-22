/*
File: pageController.js
Description: function to set controls, click handlers, etc. on page.
Author: JC Nesci
*/

var pageController = (function(){

	var that = {};
	var teamA = "none";
	var teamB = "none";
	var pollingInterval = null;

	var setup = function() {

		// Click func for Stream A dropdown.
		$("#team-a > .dropdown-menu > li > a").click(function(event) {

	    var selectedTeamId = $(this).attr("id");
	    setTeam( "team-a", selectedTeamId );

	    console.log( "pageController- select Team A: "+ selectedTeamId );
	  });

		// Click func for Stream B dropdown.
	  $("#team-b > .dropdown-menu > li > a").click(function(event) {

	    var selectedTeamId = $(this).attr("id");
	    setTeam( "team-b", selectedTeamId );

	    console.log( "pageController- select Team B: "+ selectedTeamId );
	  });

	  // Start the polling to auto refresh the page continuously.
	  startPolling();

	}

	// Set a Team and create graphs accordingly.
	// The parameters are optional: if they are provided, we will use the new team(s),
	// but if they are not, we will re-use the current teams (used for polling).
	// Examples:
	// setTeam( "team-a", "seahawks-vast" );
	// setTeam( "team-b", "cardinals-game" );
	// setTeam();
	var setTeam = function( iTeamGroup, iTeam ) {

		console.log( "pageController- setTeam: "+ iTeamGroup +", "+ iTeam );

		// Empty DOM items.
		emptyGraphContainer();
		emptyDailyTotalStats();

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
			console.log( "* * * pageController- setTeam -PARAMETERS UNDEFINED : Re-use current teams." );
		}

		// If Team A is none, create only Team B graph.
		if ( teamA == "none" ) {

			var datasetsForTeamB = data.getDatasetsForTeam( teamB );
			for (var i = 0; i < datasetsForTeamB.length; i++) {
				graphView.createGraph( datasetsForTeamB[i] );
			}

			pageView.displayStatsForOneStream( "team-b", teamB, data.getStatsForTeam( teamB ) );

		}
		// If Team B is none, create only Team A graph.
		else if ( teamB == "none" ) {

			var datasetsForTeamA = data.getDatasetsForTeam( teamA );
			for (var i = 0; i < datasetsForTeamA.length; i++) {
				graphView.createGraph( datasetsForTeamA[i] );
			}

			// pageView.displayStatsForOneStream( "team-a", teamA, datasetsForTeamA[0].statsData );
			pageView.displayStatsForOneStream( "team-a", teamA, data.getStatsForTeam( teamA ) );

		}
		// If neither are none, create Team A and Team B graphs.
		else {

			// Get the data for both teams, where graph types (ie. data-filter attr) are sorted to match.
			var combinedDatasetsForTeamsAB = data.getCombinedDatasetsForTeams( teamA, teamB );
			// Draw each combined graph by providing a matching data pair.
			for (var i = 0; i < combinedDatasetsForTeamsAB.teamA.length; i++) {
				graphView.createGraph( combinedDatasetsForTeamsAB.teamA[ i ], combinedDatasetsForTeamsAB.teamB[ i ] );
			}

			pageView.displayStatsForTwoStreams( teamA, data.getStatsForTeam( teamA ), teamB,  data.getStatsForTeam( teamB ) );

			// console.log( "combinedDatasetsForTeamsAB:" );
			// console.log( combinedDatasetsForTeamsAB );

		}

	}

	var emptyGraphContainer = function() {
		$("#graph-container").empty();
	}

	var emptyDailyTotalStats = function(){
		$("#stats #mentions-day .stat-column").remove();
	}

	var startPolling = function(){
		pollingInterval = window.setInterval( function(){ data.loadAllData() }, 5000 );
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
