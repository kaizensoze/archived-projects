/*
File: clientGraphView.js
Description: function to create graphs.
Author: JC Nesci
*/

var clientGraphView = (function(){

	var that = {};
	var usMapJSON = null;

	var createGraph = function( iDataTeamA, iDataTeamB ) {

		// console.log( "clientGraphView- createGraph- iDataTeamA:" );
		// console.log( iDataTeamA );

		// Team A data.
		var graphDataA = iDataTeamA.graphData;
		var graphNameA = iDataTeamA.graphName;
		var graphTeamA = iDataTeamA.team;
		var graphStreamA = iDataTeamA.stream;
		// Team B data.
		if ( iDataTeamB != undefined ) {
			var graphDataB = iDataTeamB.graphData;
			var graphNameB = iDataTeamB.graphName;
			var graphTeamB = iDataTeamB.team;
			var graphStreamB = iDataTeamB.stream;
			// console.log( "----------------------- graphDataB:" );
			// console.log( graphDataB );
		}

		// Graph dimensions.
		var margin = {top: 50, right: 50, bottom: 50, left: 50},
		    width = 960 - margin.left - margin.right,
		    height = 500 - margin.top - margin.bottom;

    // Setup time formatting for X axis.
    if ( graphNameA == "Days" ) {
    	// Date format for organizing the data.
    	var dateFormat = d3.time.format( "%Y-%m-%d" );
    	// Date format for displaying the date on the axis.
    	var dateDisplayFormat = d3.time.format( "%d" );
    } else if ( graphNameA == "Hours since 7PM" ) {
    	var dateFormat = d3.time.format( "%H" );
    	var dateDisplayFormat = d3.time.format( "%H" );
    }

    var	parseDate = dateFormat.parse;

    // Setup scales.
  	var x = d3.scale.ordinal()
	    .rangeRoundBands( [ 0, width ], 0.1 );

		var y = d3.scale.linear()
		    .range( [ height, 0 ] );

    // Setup axes.
    var xAxis = d3.svg.axis()
	    .scale(x)
	    .orient("bottom")
	    .tickFormat( dateDisplayFormat );

		var yAxis = d3.svg.axis()
		    .scale(y)
		    .orient("left")
		    .ticks(10)
		    .tickFormat(d3.format("d"));		// Display as integers.

	  var currentTime = null;
	  var domRow = $("<div class='row'></div>").appendTo("#graph-container");
	  var domCol = $("<div class='col-md-12'></div>").appendTo(domRow);
	  var domHeader = $("<h2>"+ graphNameA +"</h2>").appendTo(domCol);

	  // Create the main graph container.
		var svg = d3.select(domCol[0]).append("svg")
		    .attr("width", width + margin.left + margin.right)
		    .attr("height", height + margin.top + margin.bottom)
		  .append("g")
		    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    // console.log( "createGraph- graphDataA for "+ graphTeamA +":" );
    // console.log( graphDataA );

	  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	  // Clean the data.
	  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	  graphDataA.forEach( function(d) {

	  	if ( graphNameA == "Days" ) {
			  d.day = parseDateIfNecessary( d.day, parseDate );
		  } else if ( graphNameA == "Hours since 7PM" ) {
			  d.hour = parseDateIfNecessary( d.hour, parseDate );
		  }

	  	d.count = +d.count;
	  });

	  if ( iDataTeamB != undefined ) {
  	  graphDataB.forEach( function(d) {

  	  	if ( graphNameB == "Days" ) {
  			  d.day = parseDateIfNecessary( d.day, parseDate );
  		  } else if ( graphNameB == "Hours since 7PM" ) {
  			  d.hour = parseDateIfNecessary( d.hour, parseDate );
  		  }

  	  	d.count = +d.count;
  	  });
	  }

		// console.log( "createGraph- graphDataA for "+ graphTeamA +":" );
		// console.log( graphDataA );

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	  // Setup domains.
	  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	  if ( iDataTeamB != undefined ) {

			var graphDataBothStreams = _.union( graphDataA, graphDataB );
			x.domain( graphDataBothStreams.map(function(d) {
		  	if ( graphNameA == "Days" ) {
			  	return d.day;
			  } else if ( graphNameA == "Hours since 7PM" ) {
			  	return d.hour;
			  }
		  }));

		  y.domain( [ 0, d3.max(graphDataBothStreams, function(d){ return d.count; }) ] );

	  } else {

		  x.domain( graphDataA.map(function(d) {
		  	if ( graphNameA == "Days" ) {
			  	return d.day;
			  } else if ( graphNameA == "Hours since 7PM" ) {
			  	return d.hour;
			  }
		  }));

		  y.domain( [ 0, d3.max( graphDataA, function(d){ return d.count; } ) ] );

		}

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	  // Draw axes.
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
	      .attr("y", 3)
	      .attr("dy", "0.71em")
	      .style("text-anchor", "end")
	      .text("Mentions");

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Draw the bars.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// NB: Always draw Team A's bars. Team B's bars are optional.
	  var barsTeamA = svg.append("g")
      		.attr("id", "bars-" + graphTeamA)
  		.selectAll(".bar")
	      .data(graphDataA)
	    .enter().append("rect")
	      .attr("class", "bar " + graphTeamA)
	      .attr("x", function(d) {
	      	if ( graphNameA == "Days" ) {
		      	return x( d.day );
		      } else if ( graphNameA == "Hours since 7PM" ) {
		      	return x( d.hour );
		      }
	      })
	      .attr("width", x.rangeBand() )
	      .attr("y", function(d) { return y( d.count ); })
	      .attr("height", function(d) { return height - y( d.count ); });

    // Setup mouseover tooltips.
    barsTeamA.on("mouseover", function(d) { showPopover.call(this, ("mentions: "+ d.count) ); });
	  barsTeamA.on("mouseout", function(d) { removePopovers(); });

		if ( iDataTeamB != undefined ) {

			// Halve the width of the Team A bars already present.
  		barsTeamA
  			.attr("width", x.rangeBand() / 2 );

			// Draw Team B's bars (they're half of a full-width bar).
			var barsTeamB = svg.append("g")
	      		.attr("id", "bars-" + graphTeamB)
	  		.selectAll(".bar")
		      .data(graphDataB)
		    .enter().append("rect")
		      .attr("class", "bar " + graphTeamB)
		      .attr("x", function(d) {
		      	if ( graphNameB == "Days" ) {
			      	return ( x( d.day ) + (x.rangeBand()/2) );
			      } else if ( graphNameB == "Hours since 7PM" ) {
			      	return ( x( d.hour ) + (x.rangeBand()/2) );
			      }
		      })
		      .attr("width", x.rangeBand()/2 )
		      .attr("y", function(d) { return y( d.count ); })
		      .attr("height", function(d) { return height - y( d.count ); });

      // Setup mouseover tooltips.
	    barsTeamB.on("mouseover", function(d) { showPopover.call(this, ("mentions: "+ d.count) ); });
		  barsTeamB.on("mouseout", function(d) { removePopovers(); });

    }

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// For some graphs, display an info block in graph.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if ( graphNameA == "Hours since 7PM" ) {

    	// For Team A.
    	var g = svg.append("g")
      		.attr("class", "info-block");

			var f = g.append("foreignObject")
			    .attr("width", 200)
			    .attr("height", 200)
			    .attr("x", 50)
					.attr("y", 0)
			  .append("xhtml:p")
			    .style("font-size", "1.2rem");

	    f.html("<strong>Team A hours total:</strong><br>"+ clientData.getTotalHourVotesToday( graphStreamA ) );

      // For Team B.
      if ( iDataTeamB != undefined ) {
      	f.html(f.html() + "<br><strong>Team B hours total:</strong><br>"+ clientData.getTotalHourVotesToday( graphStreamB ) );
      }
    }

	}

	// Parse the date string if it hasn't already been parsed into a date object.
	// If this isn't the first graph we are drawing, the date might already have been parsed previously.
	var parseDateIfNecessary = function( iDate, iParseFunction ) {
  	if ( typeof iDate != "object" ) {
	  	return iParseFunction( iDate );
	  } else {
	  	return iDate;
	  }
	}

	var removePopovers = function() {
	  $('.popover').each(function() {
	    $(this).remove();
	  });
	}

	var showPopover = function( iContent ) {
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

	var createMap = function( iDataTeamA, iDataTeamB ) {

		// console.log( "createMap- iDataTeamA:" );
		// console.log( iDataTeamA );
		// console.log( "createMap- iDataTeamB:" );
		// console.log( iDataTeamB );

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Setup data.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		// Team A data.
		var mapDataA = iDataTeamA.mapData;
		var mapNameA = iDataTeamA.mapName +" for "+ mapDataA.day;
		var mapTeamA = iDataTeamA.team;
		var mapStreamA = iDataTeamA.stream;
		// Team B data.
		if ( iDataTeamB != undefined ) {
			var mapDataB = iDataTeamB.mapData;
			var mapNameB = iDataTeamB.mapName;
			var mapTeamB = iDataTeamB.team;
			var mapStreamB = iDataTeamB.stream;
			// console.log( "----------------------- graphDataB:" );
			// console.log( graphDataB );
		}

		// Load the US map data, if not already done.
		if ( usMapJSON === null ) {
			usMapJSON = clientData.getUsMapJSON();
		}

		// Format our team data for graphing.
		var formattedMapData = clientData.formatDataForMap( iDataTeamA, iDataTeamB );
		if ( iDataTeamB != undefined ) {
			var maxDiffCount = clientData.getMaxDiffCount( formattedMapData );
			var minDiffCount = clientData.getMinDiffCount( formattedMapData );
		} else {
			var maxCount = clientData.getMaxCount( formattedMapData );
		}

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Utility functions.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		// Get state fill color, based on the lead one team has over the other.
		var getFillColorTwoTeams = function( iTeamACount, iTeamBCount ) {

			iTeamACount = parseInt( iTeamACount );
			iTeamBCount = parseInt( iTeamBCount );
			var domain = iTeamACount + iTeamBCount;
			var minColorA = d3.scale.linear().domain([0,1]).range(["white", getTeamColor( mapTeamA ) ])( 0.08 );
			var minColorB = d3.scale.linear().domain([0,1]).range(["white", getTeamColor( mapTeamB ) ])( 0.08 );
			var colorScaleA = d3.scale.pow().exponent(0.2).domain([ 0, maxDiffCount ]).range([ minColorA, getTeamColor( mapTeamA ) ]);
			var colorScaleB = d3.scale.pow().exponent(0.2).domain([ 0, minDiffCount ]).range([ minColorB, getTeamColor( mapTeamB ) ]);
			var diff = iTeamACount - iTeamBCount;

			// console.log("------------------ & * &");
			// console.log( "iTeamACount: " + iTeamACount );
			// console.log( "iTeamBCount: " + iTeamBCount );
			// console.log( "diff: " + diff );
			// console.log( "domain: " + domain );

			var result;
			if ( diff > 0 ) {
				result = colorScaleA( diff );

				// console.log( "1)" );
				// console.log( "colorScaleA:" );
				// console.log( colorScaleA.domain() );
				// console.log( "colorScaleB:" );
				// console.log( colorScaleB.domain() );
			}
			else if ( diff < 0 ) {
				// result = colorScaleB( Math.abs( diff ) );
				result = colorScaleB( diff );

				// console.log( "2)" );
				// console.log( "colorScaleA:" );
				// console.log( colorScaleA.domain() );
				// console.log( "colorScaleB:" );
				// console.log( colorScaleB.domain() );
			}
			// If both states are tied...
			else if ( diff == 0 ) {
				// If the tie is not 0 / 0.
				//TODO: change this to a hashing pattern.
				if ( iTeamACount > 0 && iTeamBCount > 0 ) {
			 		// result = "silver";

			 		svg.append('defs')
			 		  .append('pattern')
			 		    .attr('id', 'crosshatch')
			 		    .attr('patternUnits', 'userSpaceOnUse')
			 		    // .attr('width', 4)
			 		    // .attr('height', 4)
			 		    .attr('width', 6)
			 		    .attr('height', 6)
			 		  .append('path')
			 		    // .attr('d', 'M-1,3 l2,2 M0,0 l4,4 M3,-1 l2,2')
			 		    .attr('d', 'M-1,5 l2,2 M0,0 l6,6 M5,-1 l2,2')
			 		    .attr('stroke', "silver")
			 		    .attr('stroke-width', 1);

	 		    return "url('#crosshatch')";
			 	}
			 	// If the tie is 0 / 0.
			 	else if ( iTeamACount == 0 && iTeamBCount == 0 ) {
			 		result = "white";
			 	}
			}

			// console.log( "result:" );
			// console.log( result );

			return result;
		}

		var getFillColorOneTeam = function( iTeamACount ) {

			var minColor = d3.scale.linear().domain([0,1]).range(["white", getTeamColor( mapTeamA ) ])( 0.08 );
			var colorScale = d3.scale.pow().exponent(0.2).domain([ 0, maxCount ]).range([ minColor, getTeamColor( mapTeamA ) ]);

			var result;
			if ( iTeamACount == 0 ) {
		 		result = "white";
		 	} else {
				result = colorScale( iTeamACount );
			}

			return result;
		}

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Create map.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		var width = 960,
		    height = 500;

		var projection = d3.geo.albersUsa()
		    .scale(1000)
		    .translate([width / 2, height / 2]);

		var path = d3.geo.path()
		    .projection(projection);


    var domRow = $("<div id='map-container-counts' class='row'></div>").appendTo("#map-container");
	  var domCol = $("<div class='col-md-12'></div>").appendTo(domRow);
	  var domHeader = $("<h2>"+ mapNameA +"</h2>").appendTo(domCol);

	  // Create the main graph container.
		var svg = d3.select(domCol[0]).append("svg")
		    .attr("id", "map-us")
		    .attr("width", width)
		    .attr("height", height);

		// map-country gives a background for the whole country.
		var countryGroup = svg.append("g")
		   .attr("id", "map-country")
		 .append("path")
		   .datum( topojson.feature(usMapJSON, usMapJSON.objects.land) )
		     .attr("class", "country-stroke")
		     .attr("d", path);

		var statesGroup = svg.append("g")
		 .attr("id", "map-states");

		// states-fill is for background for individual states.
		var stateFills = statesGroup.selectAll("path")
				.data( topojson.feature(usMapJSON, usMapJSON.objects.states).features )
			.enter().append("path")
				.attr("class", function(d) {
					// Team as class name supplies the default team color for the state, but it should be overwritten by getFillColorTwoTeams().
					// We keep this code in case getFillColorTwoTeams() fails, for some reason.
					if ( iDataTeamB != undefined ) {
						return ("states-fill " + formattedMapData[ d.properties.name ].leadingTeam);
					} else {
						return ("states-fill " + mapTeamA);
					}
				})
				.attr("d", path)
				.style("fill", function(d) {
					if ( iDataTeamB != undefined ) {
						var color = getFillColorTwoTeams( formattedMapData[ d.properties.name ].teamACount, formattedMapData[ d.properties.name ].teamBCount );
						return color;
					}
					else {
						var color = getFillColorOneTeam( formattedMapData[ d.properties.name ].teamACount );
						return color;
					}
				});

		// states-borders is a single path that draws borders of all states.
		statesGroup.append("path")
		 .datum(topojson.mesh(usMapJSON, usMapJSON.objects.states, function(a, b) { return a !== b; }))
		    .attr("class", "states-borders")
		    .attr("d", path);

		// HTML text labels for each state.
		// svg.append("g")
		//     .attr("class", "text-states")
		//   .selectAll("text-states")
		//     .data(topojson.feature(usMapJSON, usMapJSON.objects.states).features)
		//   .enter().append("foreignObject")
		//       .attr("width", 150)
		//       .attr("height", 20)
		//       .attr("transform", function(d) { return "translate(" + path.centroid(d) + ")"; })
		//     .append("xhtml:p")
		//       .attr("class", "text-content")
		//       .html(function(d) {
		//         return "<p>" + d.properties.name + "</p>";
		//       });

		// Setup mouseover tooltips.
		stateFills.on("mouseover", function(d) {
			if ( iDataTeamB != undefined ) {

				showPopover.call(this,
					"<div class='map-state-popover-content'>"+
						"<p class='title-state'>" + d.properties.name + "</p>"+
						"<p class='mentions'>"+
							"<span class='"+ mapStreamA +"'>"+ formattedMapData[ d.properties.name ].teamACount + "</span>"+
							" / "+
							"<span class='"+ mapStreamB +"'>"+ formattedMapData[ d.properties.name ].teamBCount + "</span>"+
						"</p>"+
						"<p class='"+ formattedMapData[ d.properties.name ].leadingStream +"'>"+ formattedMapData[ d.properties.name ].leadingStream +" leads by "+ Math.abs( formattedMapData[ d.properties.name ].diffCount ) +"</p>"+
					"</div>"
				);

			} else {

				showPopover.call(this,
					"<div class='map-state-popover-content'>"+
						"<p class='title-state'>" + d.properties.name + "</p>"+
						"<p class='mentions'>"+
							"<span class='"+ mapStreamA +"'>"+ formattedMapData[ d.properties.name ].teamACount + "</span>"+
						"</p>"+
					"</div>"
				);

			}
		});
		stateFills.on("mouseout", function(d) { removePopovers(); });

	}

	var createGeoEventMap = function( iGeoEventsData ) {

		// console.log( "- - - - - - - - - - - - - - - - - - - - - - - ***" );
		// console.log( "createGeoEventMap- iGeoEventsData:" );
		// console.log( iGeoEventsData );

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Setup data.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		// Map data.
		var mapData = iGeoEventsData;

		mapData.forEach(function(d) {
      d.location[0] = +d.location[0];
      d.location[1] = +d.location[1];
    });

		// Load the US map data, if not already done.
		if ( usMapJSON === null ) {
			usMapJSON = clientData.getUsMapJSON();
		}

		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		// Create map.
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		var width = 960,
			    height = 500;

		var projection = d3.geo.albersUsa()
			    .scale(1000)
			    .translate([width / 2, height / 2]);

    // Create the map for the first time.
		if ( d3.select("#map-us-geo-events").empty() ) {

			var path = d3.geo.path()
			    .projection(projection);

	    var domRow = $("<div id='map-container-geo-events' class='row'></div>").appendTo("#map-container");
		  var domCol = $("<div class='col-md-12'></div>").appendTo(domRow);
		  var domHeader = $("<h2>Live Geo Events</h2>").appendTo(domCol);

		  // Create the main graph container.
			var svg = d3.select(domCol[0]).append("svg")
			    .attr("id", "map-us-geo-events")
			    .attr("width", width)
			    .attr("height", height);

			// map-country gives a background for the whole country.
			var countryGroup = svg.append("g")
			   .attr("id", "map-country")
			 .append("path")
			   .datum( topojson.feature(usMapJSON, usMapJSON.objects.land) )
			     .attr("class", "country-stroke")
			     .attr("d", path);

			var statesGroup = svg.append("g")
			 .attr("id", "map-states");

			// states-fill is for background for individual states.
			var stateFills = statesGroup.selectAll("path")
					.data( topojson.feature(usMapJSON, usMapJSON.objects.states).features )
				.enter().append("path")
					.attr("class", "states-fill")
					.attr("d", path);

			// states-borders is a single path that draws borders of all states.
			statesGroup.append("path")
			 .datum(topojson.mesh(usMapJSON, usMapJSON.objects.states, function(a, b) { return a !== b; }))
			    .attr("class", "states-borders")
			    .attr("d", path);

	    // Create groupd for markers (ie. dots) of new live events.
	    var eventMarkersGroup = svg.append("g")
			 .attr("id", "map-event-markers");

		 // Create a button to clear the current event markers from the data & the map.
		 var button = $("<button class='btn btn-default' id='button-map-geo-reset'>Clear Geo Events</button>").appendTo( domCol );
		 button.on("click", function() {
		   clientData.emptyGeoEventsData();
		 });

		}

		// For all subsequent times, update the current data with the newly provided data.
    var markers = d3.select("#map-event-markers").selectAll(".marker")
      .data( mapData );

    // We need a custom index that starts at 0 for each map redraw, so we can delay & stagger the transition animations for each marker.
	  var newMarkerIndex = 0;

    markers.enter().append("circle")
      .attr("class", function(d) { return ( "marker "+ d.team ); })
      .attr("cx", function(d) { return projection( [ d.location[1], d.location[0] ] )[0]; })
      .attr("cy", function(d) { return projection( [ d.location[1], d.location[0] ] )[1]; })
      .attr("r", 50)
      .style("opacity", 0)
      // For every new circle, start with a large, pale circle, and shrink it to a small opaque one.
      .transition()
      	.delay( function(){
      		newMarkerIndex = newMarkerIndex + 1;
      		return ( newMarkerIndex * 800 ); } )
        .duration( 10000 )
        .attr("r", 5 )
        .style("opacity", 1 );

    markers.exit().remove();

    // Setup mouseover tooltips.
    markers.on("mouseover", function(d) {

  		showPopover.call(this,
  			"<div class='map-geo-popover-content'>"+
  				"<p class='team "+ d.team +"'>Team: " + d.team + "</p>"+
  				"<p><strong>Name:</strong> " + d.name + "</p>"+
  				"<p><strong>Username:</strong> " + d.username + "</p>"+
  				"<p><strong>Time:</strong> " + d.time + "</p>"+
  				"<p><strong>Text:</strong> " + d.text + "</p>"+
  			"</div>"
  		);

    });
    markers.on("mouseout", function(d) { removePopovers(); });

	}

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Public Interface.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	that.createGraph = createGraph;
	that.createMap = createMap;
	that.createGeoEventMap = createGeoEventMap;

	return that;

})();
