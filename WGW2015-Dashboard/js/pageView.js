/*
File: pageView.js
Description: function to set various view element on page.
Author: JC Nesci
*/

var pageView = (function(){

	var that = {};

	var displayStatsForOneStream = function( iTeamGroup, iTeam, iTeamStats ) {

		// console.log( "displayStatsForOneStream- "+ iTeamGroup +", "+ iTeam +", "+ iTeamStats );

		var domRow = $( "#stats #mentions-day" );
		var domCol = $( "<div id='"+ iTeamGroup +"' class='col-md-6 stat-column'></div>" ).appendTo(domRow);
		var domTotalRow = $( "<div class='row'></div>" ).appendTo(domCol);
	  var domTotalCol = $("<div class='col-md-12'>"+
											  	"<h1 class='total "+ iTeam +"'>"+ iTeamStats.totalThisDay +"</h1>"+
											  	"<p>"+ iTeam +" daily total</p>"+
											  	"<p class='subtitle'>= Total since "+ data.getDailyTargetHour() +":00 + Total since hour</p>"+
											  	"<p class='subtitle'>= "+ iTeamStats.mentionsSinceTargetTotal +" + "+ iTeamStats.totalThisHour +" = "+ iTeamStats.totalThisDay +"</p>"+
										  	"</div>").appendTo(domTotalRow);
	}

	var displayStatsForTwoStreams = function( iTeamA, iTeamStatsA, iTeamB, iTeamStatsB ) {

		// console.log( "displayStatsForTwoTeams-- "+ iTeamA +", "+ iTeamB );

		displayStatsForOneStream( "team-a", iTeamA, iTeamStatsA );
		displayStatsForOneStream( "team-b", iTeamB, iTeamStatsB );

		var dailyTotalVoteDifference = iTeamStatsA.totalThisDay - iTeamStatsB.totalThisDay;
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

		var statsGroupA = $("#team-a.stat-column");
		var leadingByA = 	$("<div class='row leading-by "+ iTeamA +"'>"+
													"<div class='col-md-2'>"+
														"<img class='team-logo' src='img/"+ getTeamNameForStream( iTeamA ) +"_logo.png' />"+
													"</div>"+
													"<div class='col-md-10'>"+
														"<p>"+ iTeamA +"</p>"+
														textA +
													"</div>"+
												"</div>").appendTo(statsGroupA);

		var statsGroupB = $("#team-b.stat-column");
		var leadingByB = 	$("<div class='row leading-by "+ iTeamB +"'>"+
													"<div class='col-md-2'>"+
														"<img class='team-logo' src='img/"+ getTeamNameForStream( iTeamB ) +"_logo.png' />"+
													"</div>"+
													"<div class='col-md-10'>"+
														"<p>"+ iTeamB +"</p>"+
														textB +
													"</div>"+
												"</div>").appendTo(statsGroupB);
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
