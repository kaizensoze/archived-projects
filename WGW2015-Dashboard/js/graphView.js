/*
File: graphView.js
Description: function to create graphs.
Author: JC Nesci
*/

var graphView = (function(){

	var that = {};

	function createGraph( iDataTeamA, iDataTeamB ) {

		// Team A data.
		var graphIndexA = iDataTeamA.graphIndex;
		var graphDataA = iDataTeamA.graphData;
		// Graph type should be the same for both teams. So when we check for graphTypeA we are assuming graphTypeB is the same.
		var graphTypeA = iDataTeamA.params["data-filter"];
		var graphNameA = iDataTeamA.params.name;
		var graphTeamA = iDataTeamA.params.team;
		var graphUrlA = iDataTeamA.params.url;

		// console.log( "createGraph- graphDataA #"+ graphIndexA +":" );
		// console.log( graphDataA );

		// Team B data.
		if ( iDataTeamB != undefined ) {
			// console.log("--------------- iDataTeamB NOT UNDEFINED !!!!");

			var graphDataB = iDataTeamB.graphData;
			var graphTypeB = iDataTeamB.params["data-filter"];
			var graphNameB = iDataTeamB.params.name;
			var graphTeamB = iDataTeamB.params.team;
			var graphUrlB = iDataTeamB.params.url;

			// console.log( "graphDataB:" );
			// console.log( graphDataB );
		}

		var margin = {top: 50, right: 50, bottom: 50, left: 50},
		    width = 960 - margin.left - margin.right,
		    height = 500 - margin.top - margin.bottom;
		var x = d3.scale.linear()
		    .range( [ 0, width ] );
		var y = d3.scale.linear()
		    .range( [ height, 0 ] );
		var xAxis = d3.svg.axis()
		    .scale(x)
		    .orient("bottom");
		var yAxis = d3.svg.axis()
		    .scale(y)
		    .orient("left")
		    .ticks(10)
		    .tickFormat(d3.format("d"));		// Display as integers.
	  var currentTime = null;
	  var domRow = $("<div id='graph-"+ graphIndexA +"' class='row'></div>").appendTo("#graph-container");
	  var domCol = $("<div class='col-md-12'></div>").appendTo(domRow);
	  var domHeader = $("<h2>"+ graphNameA +"</h2>").appendTo(domCol);
		var svg = d3.select(domCol[0]).append("svg")
		    .attr("width", width + margin.left + margin.right)
		    .attr("height", height + margin.top + margin.bottom)
		  .append("g")
		    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Adjust graph settings per graph type.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		// Select sub-dataset we'll use for the graph.
		if (graphTypeA == 'activity-minutes') {
			// Reset tick format to default.
			xAxis.tickFormat(null);
		}
		else if (graphTypeA == 'activity-hours') {
			// Set # of ticks.
			xAxis.ticks(graphDataA.length);
			// Reset tick format to default.
			xAxis.tickFormat(null);
		}
		else if ( graphTypeA == "current-hour-in-minutes" || graphTypeA == "current-day-in-hours" || graphTypeA == "current-week-in-hours" ) {
			// Set the timestrings to the ticks.
			xAxis.tickFormat( function( d, i ){
				return graphDataA.xValuesAsTimestring[d];
			});
		}

		// For Team B.
		if ( iDataTeamB != undefined ) {
			x.domain( [ 0, Math.max( graphDataA.mainGraphData.length, graphDataA.mainGraphData.length ) ] );
			y.domain( [ 0, Math.max( d3.max(graphDataA.mainGraphData, function(d) { return d.yValue; }), d3.max(graphDataB.mainGraphData, function(d) { return d.yValue; }) ) ] );
		} else {
		  x.domain( [ 0, graphDataA.mainGraphData.length ] );
		  y.domain( [ 0, d3.max(graphDataA.mainGraphData, function(d) { return d.yValue; }) ] );
		}

	  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	  // Draw stuff.
	  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	  svg.append("g")
	      .attr("class", "x axis")
	      .attr("transform", "translate(0," + height + ")")
	      .call(xAxis);

	  svg.append("g")
	      .attr("class", "y axis")
	      .call(yAxis)
	    .append("text")
	      .attr("transform", "rotate(-90)")
	      .attr("y", 6)
	      .attr("dy", ".71em")
	      .style("text-anchor", "end")
	      .text("Mentions");

    // Add the background for 'hour-cutoff' before creating the bars, so it is behind them, and doesn't prevent the mouseover.
    // Draw only 1 cutoff background, even if Team B is specified.
    if ( graphTypeA == "current-hour-in-minutes" ) {
    	var g = svg.append("g")
      		.attr("class", "hour-cutoff")
      		.attr("transform", "translate("+ x( graphDataA.curHourCutoffPosition ) +", 0)")
  		g.append("rect")
    			.attr("class", "background")
    			.attr("width", x( graphDataA.curMinutesSinceHour ) )
    			.attr("height", height);
		}
		else if ( graphTypeA == "current-day-in-hours" ) {
    	var g = svg.append("g")
      		.attr("class", "hour-cutoff")
      		.attr("transform", "translate("+ x( graphDataA.targetHourIndex ) +", 0)")
  		g.append("rect")
    			.attr("class", "background")
    			.attr("width", x( graphDataA.hoursBetweenTargetAndNow ) )
    			.attr("height", height);
		}

		// Always draw Team A's bars.
	  var barsTeamA = svg.append("g")
      		.attr("id", "bars-" + graphTeamA)
  		.selectAll(".bar")
	      .data(graphDataA.mainGraphData)
	    .enter().append("rect")
	      .attr("class", function(d){
	      	return ( "bar " + graphTeamA );
	      })
	      .attr("x", function( d, i ) { return x( d.xValue )+1; })
	      .attr("width", (width / graphDataA.mainGraphData.length)-2 )
	      .attr("y", function( d ) { return y( d.yValue ); })
	      .attr("height", function(d) { return height - y( d.yValue ); });

  	// If Team B is specified.
  	if ( iDataTeamB != undefined ) {

  		// Halve the width of the Team A bars already present.
  		barsTeamA
  			.attr("x", function( d, i ) { return x( d.xValue )+2; })
  			.attr("width", ( (width / graphDataA.mainGraphData.length) / 2 ) -2 );

  		// Draw Team B's bars (they're half of a full-width bar).
  		var barsTeamB = svg.append("g")
      		.attr("id", "bars-" + graphTeamA)
  		.selectAll(".bar")
	      .data(graphDataB.mainGraphData)
	    .enter().append("rect")
	      .attr("class", "bar " + graphTeamB )
	      .attr("x", function( d, i ) { return x( d.xValue ) + ( (width / graphDataA.mainGraphData.length) / 2 ); })
	      .attr("width", ( (width / graphDataA.mainGraphData.length) / 2 ) -2 )
	      .attr("y", function( d ) { return y( d.yValue ); })
	      .attr("height", function(d) { return height - y( d.yValue ); });
  	}

    // Add the rest of the content for 'hour-cutoff' (the marker, text, etc) and other stuff.
    if ( graphTypeA == "current-hour-in-minutes" ) {

    	// For Team A.
    	var g = svg.append("g")
      		.attr("class", "hour-cutoff")
      		.attr("transform", "translate("+ x( graphDataA.curHourCutoffPosition ) +", 0)");
    	g.append("rect")
    			.attr("class", "line")
    			.attr("width", 2)
    			.attr("height", height);

			var f = g.append("foreignObject")
			    .attr("width", 200)
			    .attr("height", 200)
			    .attr("x", function(d) {
			    	if ( graphDataA.curHourCutoffPosition >= 50 ) { return -200; }
			    	else { return 20; }
			    })
					.attr("y", 50)
			  .append("xhtml:p")
			    .style("font-size", "1.2rem");

	    f.html("<strong>Last hour mark:</strong><br>"+ graphDataA.curHour +":00"
	    	+"<br><strong>Minutes since hour:</strong><br>"+ graphDataA.curMinutesSinceHour
	    	+"<br><strong>Team A total since hour:</strong><br>"+ graphDataA.totalThisHour);

	    barsTeamA.on("mouseover", function ( d, i ) { showPopover.call(this, ("x (time) "+ graphDataA.xValuesAsTimestring[i] +"<br>x (index): "+ d.xValue +"<br>y: "+ d.yValue) ); })
        .on("mouseout", function (d) { removePopovers(); });

      // For Team B.
      if ( iDataTeamB != undefined ) {
		    f.html(f.html() + "<br><strong>Team B total since hour:</strong><br>"+ graphDataB.totalThisHour);

		    barsTeamB.on("mouseover", function ( d, i ) { showPopover.call(this, ("x (time) "+ graphDataB.xValuesAsTimestring[i] +"<br>x (index): "+ d.xValue +"<br>y: "+ d.yValue) ); })
          .on("mouseout", function (d) { removePopovers(); });
      }

    }
    if ( graphTypeA == "current-day-in-hours" ) {

    	// For Team A.
    	var g = svg.append("g")
      		.attr("class", "hour-cutoff")
      		.attr("transform", "translate("+ x( graphDataA.targetHourIndex ) +", 0)");
    	g.append("rect")
    			.attr("class", "line")
    			.attr("width", 2)
    			.attr("height", height);

			var f = g.append("foreignObject")
			    .attr("width", 200)
			    .attr("height", 200)
			    .attr("x", function(d) {
			    	if ( graphDataA.targetHourIndex >= 20 ) { return -200; }
			    	else { return 20; }
			    })
					.attr("y", 50)
			  .append("xhtml:p")
			    .style("font-size", "1.2rem");

	    f.html("<strong>Hours since "+ data.getDailyTargetHour() +":00:</strong><br>"+ graphDataA.hoursBetweenTargetAndNow
			    	+"<br><strong>Team A total since "+ data.getDailyTargetHour() +":00:</strong><br>"+ graphDataA.mentionsSinceTargetTotal);

	    barsTeamA.on("mouseover", function ( d, i ) { showPopover.call(this, ("x (time) "+ graphDataA.xValuesAsTimestring[i] +"<br>x (index): "+ d.xValue +"<br>y: "+ d.yValue) ); })
          .on("mouseout", function (d) { removePopovers(); });

      // For Team B.
      if ( iDataTeamB != undefined ) {
      	f.html(f.html() + "<br><strong>Team B total since "+ data.getDailyTargetHour() +":00:</strong><br>"+ graphDataB.mentionsSinceTargetTotal);

      	barsTeamB.on("mouseover", function ( d, i ) { showPopover.call(this, ("x (time) "+ graphDataB.xValuesAsTimestring[i] +"<br>x (index): "+ d.xValue +"<br>y: "+ d.yValue) ); })
          .on("mouseout", function (d) { removePopovers(); });
      }
    }
    if ( graphTypeA == "current-week-in-hours" ) {

    	// For Team A.
    	var g = svg.append("g")
      		.attr("class", "info-block");

			var f = g.append("foreignObject")
			    .attr("width", 200)
			    .attr("height", 200)
			    .attr("x", 50)
					.attr("y", 50)
			  .append("xhtml:p")
			    .style("font-size", "1.2rem");

	    f.html("<strong>Team A total in last 7 days:</strong><br>"+ graphDataA.mentionsInPastWeek);

	    barsTeamA.on("mouseover", function ( d, i ) { showPopover.call(this, ("x (time) "+ graphDataA.xValuesAsTimestring[i] +"<br>x (index): "+ d.xValue +"<br>y: "+ d.yValue) ); })
          .on("mouseout", function (d) { removePopovers(); });

      // For Team B.
      if ( iDataTeamB != undefined ) {
      	f.html(f.html() + "<br><strong>Team B total in last 7 days:</strong><br>"+ graphDataB.mentionsInPastWeek);

				barsTeamB.on("mouseover", function ( d, i ) { showPopover.call(this, ("x (time) "+ graphDataB.xValuesAsTimestring[i] +"<br>x (index): "+ d.xValue +"<br>y: "+ d.yValue) ); })
          .on("mouseout", function (d) { removePopovers(); });
      }
    }

	}

	function removePopovers() {
	  $('.popover').each(function() {
	    $(this).remove();
	  });
	}

	function showPopover( iContent ) {
	  $(this).popover({
	    placement: 'auto top',
	    container: 'body',
	    trigger: 'manual',
	    html : true,
	    content: function() {
	      return iContent }
	  });
	  $(this).popover('show')
	}

	that.createGraph = createGraph;

	return that;
})();
