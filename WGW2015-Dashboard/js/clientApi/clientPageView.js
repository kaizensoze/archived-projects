/*
File: clientPageView.js
Description: function to set various view element on page.
Author: JC Nesci
*/

var clientPageView = (function(){

	var that = {};

	var displayStatsForOneStream = function( iTeamGroup, iTeam, iTotalVoteToday ) {

		// console.log( "displayStatsForOneStream- "+ iTeamGroup +", "+ iTeam +", "+ iTotalVoteToday );

		var domRow = $( "#stats #mentions-day" );
		var domCol = $( "<div id='"+ iTeamGroup +"' class='col-md-6 stat-column'></div>" ).appendTo(domRow);
		var domColContent = $("<div class='row vote-title'>"+
														"<div class='col-md-12'>"+
													  	"<h1 class='total "+ iTeam +"'>"+ iTotalVoteToday +"</h1>"+
													  	"<p>"+ iTeam +"</p>"+
												  	"</div>"+
													"</div>"+
													"<div class='row vote-content'>"+
														"<div class='col-md-4 vote'>"+
															"<button type='button' id='"+ getTeamNameForStream( iTeam ) +"' class='btn vote-btn "+ iTeam +"'>Vote for "+ iTeam +"</button>"+
														"</div>"+
														"<div class='col-md-2'>"+
															"<img class='team-logo "+ iTeam +"' src='img/"+ getTeamNameForStream( iTeam ) +"_logo.png' />"+
														"</div>"+
													"</div>").appendTo(domCol);
	}

	var displayStatsForTwoStreams = function( iTeamA, iTotalVoteTodayA, iTeamB, iTotalVoteTodayB ) {

		// console.log( "displayStatsForTwoTeams-- "+ iTeamA +", "+ iTeamB );

		displayStatsForOneStream( "team-a", iTeamA, iTotalVoteTodayA );
		displayStatsForOneStream( "team-b", iTeamB, iTotalVoteTodayB );

		var dailyTotalVoteDifference = iTotalVoteTodayA - iTotalVoteTodayB;
		var absDifference = Math.abs( dailyTotalVoteDifference );
		if ( dailyTotalVoteDifference > 0 ) {
			var textA = "<p>leading by "+ absDifference +" votes</p>";
			var textB = "<p>trailing by "+ absDifference +" votes</p>";
		} else if ( dailyTotalVoteDifference < 0 ) {
			var textA = "<p>trailing by "+ absDifference +" votes</p>";
			var textB = "<p>leading by "+ absDifference +" votes</p>";
		} else {
			var textA = "<p>equal to "+ iTeamB +"</p>";
			var textB = "<p>equal to "+ iTeamA +"</p>";
		}

		var statsGroupA = $("#team-a.stat-column .vote-content");
		var leadingByA = $("<div class='col-md-6 leading-by "+ iTeamA +"'>"+
												"<p>"+ iTeamA +"</p>"+
												textA +
											"</div>").appendTo( statsGroupA );


		var statsGroupB = $("#team-b.stat-column .vote-content");
		var leadingByB = $("<div class='col-md-6 leading-by "+ iTeamB +"'>"+
												"<p>"+ iTeamB +"</p>"+
												textB +
											"</div>").appendTo( statsGroupB );
	}

	var displaySettings = function( iTimezoneName, iTimezoneOffset, iTargetHour ) {
		var domRow = $("#settings");
		domRow.empty();
		var domCol = $("<div class='col-md-12'>"+
											"<p>Timezone: "+ iTimezoneName +", "+ iTimezoneOffset +"</p>"+
											"<p>Target Cutoff Hour: "+ iTargetHour +":00</p>"+
										"</div>").appendTo(domRow);
	}

	var getTeamNameForStream = function( iStreamName ) {
		return iStreamName.substring( 0, iStreamName.indexOf("-") );
	}


	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Public Interface.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	that.displaySettings = displaySettings;
	that.displayStatsForOneStream = displayStatsForOneStream;
	that.displayStatsForTwoStreams = displayStatsForTwoStreams;

	return that;

})();
