$(function() {

  $('#damp-graph').each(function() {

    function LineChart(divSelector) {
      var _this = this;

      this.chart = d3.select(divSelector).append("svg");
      this.data = null;

      this.render = function() {

        var chart = _this.chart;
        chart.select("g").remove();

        var margin = {top: 20, right: 60, bottom: 30, left: 50},
        aspectRatio = 980 / 400,
        chartContainer = d3.select('#damp-graph'),
        containerWidth = chartContainer.node().getBoundingClientRect().width,
        width = containerWidth - margin.left - margin.right,
        height = (containerWidth / aspectRatio) - margin.top - margin.bottom;

        var parseDate = d3.time.format("%Y-%m-%d").parse;
        var formatDate = d3.time.format("%d-%b");
        var bisectDate = d3.bisector(function(d) { return d.date; }).left;

        var x = d3.time.scale()
          .range([0, width]);

        var y = d3.scale.linear()
          .range([height, 0]);

        var xAxis = d3.svg.axis()
          .scale(x)
          .orient("bottom")
          .ticks(d3.time.month, 2)
          .tickFormat(d3.time.format('%b %Y'));

        var yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .outerTickSize(0);

        var line = d3.svg.line()
          .x(function(d) { return x(d.date); })
          .y(function(d) { return y(d.amount); });

        chart.attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom);

        drawingArea = chart.append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var lineSvg = drawingArea.append("g");

        var focus = drawingArea.append("g")
          .style("display", "none");

        if (_this.data) {
          renderData();
        } else {
          d3.csv("/matrix/statistics/daily_active_mate_profiles.csv", type, function(error, data) {
            if (error) throw error;
            _this.data = data;
            renderData();
          });
        }

        function renderData() {
          var data = _this.data;
          x.domain(d3.extent(data, function(d) { return d.date; }));
          y.domain(d3.extent(data, function(d) { return d.amount; }));

          drawingArea.append("g")
              .attr("class", "x axis")
              .attr("transform", "translate(0," + height + ")")
              .call(xAxis);

          drawingArea.append("g")
              .attr("class", "y axis")
              .call(yAxis);

          lineSvg.append("path")
              .datum(data)
              .attr("class", "line")
              .attr("d", line)

          focus.append("line")
            .attr("class", "x")
            .style("stroke", "#FFFFFF")
            .style("stroke-dasharray", "3,3")
            .style("opacity", 0.5)
            .attr("y1", 0)
            .attr("y2", height);

          focus.append("circle")
            .attr("class", "y")
            .style("fill", "#FFFFFF")
            .style("stroke", "#FFFFFF")
            .attr("r", 4);

          focus.append("text")
            .attr("class", "y1")
            .attr("dx", 8)
            .attr("dy", "-.3em");

          focus.append("text")
            .attr("class", "y2")
            .attr("dx", 8)
            .attr("dy", "1em");

          drawingArea.append("rect")
            .attr("width", width)
            .attr("height", height)
            .style("fill", "none")
            .style("pointer-events", "all")
            .on("mouseover", function() { focus.style("display", null); })
            .on("mouseout", function() { focus.style("display", "none"); })
            .on("mousemove", mousemove);

          function mousemove() {
            var x0 = x.invert(d3.mouse(this)[0]),
              i = bisectDate(data, x0, 1),
              d0 = data[i - 1],
              d1 = data[i],
              d = x0 - d0.date > d1.date - x0 ? d1: d0;

              focus.select("circle.y")
                .attr("transform", "translate(" + x(d.date) + "," +
                                                  y(d.amount) + ")");

              focus.select(".x")
                .attr("transform",
                      "translate(" + x(d.date) + ", 0)");

              focus.select("text.y1")
                .attr("transform", "translate(" + x(d.date) + "," + y(d.amount) + ")")
                .text(d.amount);

              focus.select("text.y2")
                .attr("transform", "translate(" + x(d.date) + "," + y(d.amount) + ")")
                .text(formatDate(d.date));
          }
        }

        function type(d) {
          d.date = parseDate(d.date);
          d.amount = +d.amount;
          return d;
        }

        d3.select(window).on("resize", function() {
          _this.render();
        });
      }
    }

    chart = new LineChart("#damp-graph");
    chart.render();
  });
});
