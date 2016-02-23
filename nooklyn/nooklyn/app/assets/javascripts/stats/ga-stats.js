window.onload = function(){

  if ($('#sessions-graph').length < 1) {
    return;
  }

  // rental applications

  var rentalAppsGraph = document.getElementById("rental-applications-graph").getContext("2d");

  var rentalAppsData = {
    labels: ["Jan-2014", "Feb-2014", "Mar-2014", "Apr-2014", "May-2014", "Jun-2014", "Jul-2014", "Aug-2014", "Sep-2014", "Oct-2014", "Nov-2014", "Dec-2014", "Jan-2015", "Feb-2015", "Mar-2015", "Apr-2015", "May-2015", "Jun-2015", "Jul-2015", "Aug-2015", "Sep-2015", "Oct-2015", "Nov-2015", "Dec-2015","Jan-2016"],
    datasets: [
      {
        label: "Users",
        fillColor : "rgba(34,34,34,1)",
        strokeColor : "rgba(255,192,58,1)",
        pointColor : "rgba(255,255,255,1)",
        pointStrokeColor : "#333",
        pointHighlightFill : "#fff",
        pointHighlightStroke : "rgba(255,192,58,1)",
        data: [182,155,184,274,413,317,516,528,257,274,165,203,167,226,270,424,609,657,959,853,459,382,314,247,381]
      }
    ]
  };
  window.rentalAppsLine = new Chart(rentalAppsGraph).Line(rentalAppsData, {
    scaleLineColor: "#55505b",
    scaleFontColor: "#55505b",
    scaleOverride: true,
    scaleShowLabels: false,
    scaleSteps: 10,
    scaleStepWidth: 100,
    scaleFontSize: 11,
    responsive: true
  });


  // User Growth

  var userlineGraph = document.getElementById("user-line-graph").getContext("2d");
  var gradient = userlineGraph.createLinearGradient(0, 0, 0, 680);
  gradient.addColorStop(0, 'rgba(54,54,54, .5)')
  gradient.addColorStop(0.5, 'rgba(54,54,54, .25)');
  gradient.addColorStop(1, 'rgba(54,54,54, 0)');

  var userData = {
    labels: ["Jan-2013", "Feb-2013", "Mar-2013", "Apr-2013", "May-2013", "Jun-2013", "Jul-2013", "Aug-2013", "Sep-2013", "Oct-2013", "Nov-2013", "Dec-2013", "Jan-2014", "Feb-2014", "Mar-2014", "Apr-2014", "May-2014", "Jun-2014", "Jul-2014", "Aug-2014", "Sep-2014", "Oct-2014", "Nov-2014", "Dec-2014", "Jan-2015", "Feb-2015", "Mar-2015", "Apr-2015", "May-2015", "Jun-2015", "Jul-2015", "Aug-2015", "Sep-2015", "Oct-2015", "Nov-2015", "Dec-2015","Jan-2016"],
    datasets: [
      {
        label: "Users",
        fillColor : "rgba(34,34,34,1)",
        strokeColor : "rgba(255,192,58,1)",
        pointColor : "rgba(255,255,255,1)",
        pointStrokeColor : "#333",
        pointHighlightFill : "#fff",
        pointHighlightStroke : "rgba(255,192,58,1)",
        data: [24, 32, 37, 40, 79, 293, 505, 666, 832, 945, 1009, 1064, 1178, 1301, 1448, 1626, 1849, 2264, 3249, 4220, 4953, 5651, 6178, 6989, 7374,7922,8645,9747,11050,12296,13958,15593,16747,17722,18712,19743,21217]
      }
    ]
  };
  window.usersLine = new Chart(userlineGraph).Line(userData, {
    scaleLineColor: "#55505b",
    scaleFontColor: "#55505b",
    scaleOverride: true,
    scaleShowLabels: false,
    scaleSteps: 15,
    scaleStepWidth: 1500,
    scaleFontSize: 11,
    responsive: true
  });

  // Sessions

  var sessionsGraph = document.getElementById("sessions-graph").getContext("2d");
  var sessionsData = {
    labels: ["Jan-2013", "Feb-2013", "Mar-2013", "Apr-2013", "May-2013", "Jun-2013", "Jul-2013", "Aug-2013", "Sep-2013", "Oct-2013", "Nov-2013", "Dec-2013", "Jan-2014", "Feb-2014", "Mar-2014", "Apr-2014", "May-2014", "Jun-2014", "Jul-2014", "Aug-2014", "Sep-2014", "Oct-2014", "Nov-2014", "Dec-2014", "Jan-2015", "Feb-2015", "Mar-2015", "Apr-2015", "May-2015", "Jun-2015", "Jul-2015", "Aug-2015", "Sep-2015", "Oct-2015", "Nov-2015", "Dec-2015","Jan-2016"],
    datasets : [
      {
        label: "Sessions",
        fillColor : "rgba(34,34,34,1)",
        strokeColor : "rgba(255,192,58,1)",
        pointColor : "rgba(255,255,255,1)",
        pointStrokeColor : "#333",
        pointHighlightFill : "#fff",
        pointHighlightStroke : "rgba(255,192,58,1)",
        data : [2809,4268,6742,8930,11841,12241,14706,13969,11641,9634,6681,6856,9475,10319,12281,15770,18366,18462,25951,26781,20745,17564,16622,15325,16810,18067,31817,48468,58112,55330,73391,72625,52163,43176,40560,39339,56739]
      }
    ]
  }

  window.sessionsLine = new Chart(sessionsGraph).Line(sessionsData, {
    scaleLineColor: "#55505b",
    scaleFontColor: "#55505b",
    scaleOverride: true,
    scaleShowLabels: false,
    scaleSteps: 15,
    scaleStepWidth: 5000,
    scaleFontSize: 11,
    responsive: true
  });

  // Pageviews

  var pvGraph = document.getElementById("pv-graph").getContext("2d");
  var pvData = {
    labels: ["Jan-2013", "Feb-2013", "Mar-2013", "Apr-2013", "May-2013", "Jun-2013", "Jul-2013", "Aug-2013", "Sep-2013", "Oct-2013", "Nov-2013", "Dec-2013", "Jan-2014", "Feb-2014", "Mar-2014", "Apr-2014", "May-2014", "Jun-2014", "Jul-2014", "Aug-2014", "Sep-2014", "Oct-2014", "Nov-2014", "Dec-2014", "Jan-2015", "Feb-2015", "Mar-2015", "Apr-2015", "May-2015", "Jun-2015", "Jul-2015", "Aug-2015", "Sep-2015", "Oct-2015", "Nov-2015", "Dec-2015","Jan-2016"],
    datasets : [
      {
        label: "Pageviews",
        fillColor : "rgba(34,34,34,1)",
        strokeColor : "rgba(255,192,58,1)",
        pointColor : "rgba(255,255,255,1)",
        pointStrokeColor : "#333",
        pointHighlightFill : "#fff",
        pointHighlightStroke : "rgba(255,192,58,1)",
        data : [17035,24643,41132,51774,69679,74852,84325,76496,64023,61242,42757,41247, 56050,70766,90959,110764,122965,135893,194900,195734,147691,123157,115157,115231, 124519,133410,233132,326415,368245,397118,513736,446143,307020,266555,245059,238463,321985]
      }
    ]
  }

  window.pvLine = new Chart(pvGraph).Line(pvData, {
    scaleLineColor: "#55505b",
    scaleFontColor: "#55505b",
    scaleOverride: true,
    scaleShowLabels: false,
    scaleSteps: 15,
    scaleStepWidth: 50000,
    scaleFontSize: 11,
    responsive: true
  });

  var genderGraph = document.getElementById("gender-graph").getContext("2d");

  var genderData = [
    {
      value: 54.8,
      color:"#222",
      highlight: "#f1e577",
      label: "Female"
    },
    {
      value: 45.2,
      color: "#333",
      highlight: "#f1e577",
      label: "Male"
    }
  ]
  window.genderPie = new Chart(genderGraph).Pie(genderData, {
    segmentStrokeColor: "#333"
  });

  var ageGraph = document.getElementById("age-graph").getContext("2d");

  var ageData = [
    {
      value: 64.85,
      color:"#222",
      highlight: "#f1e577",
      label: "25-34"
    },
    {
      value: 18.13,
      color: "#333",
      highlight: "#f1e577",
      label: "18-24"
    },
    {
      value: 9.05,
      color: "#444",
      highlight: "#f1e577",
      label: "35-44"
    },
    {
      value: 3.38,
      color: "#555",
      highlight: "#f1e577",
      label: "45-54"
    },
    {
      value: 3.07,
      color: "#666",
      highlight: "#f1e577",
      label: "55-64"
    },
    {
      value: 1.51,
      color: "#777",
      highlight: "#f1e577",
      label: "65+"
    }
  ]
  window.agePie = new Chart(ageGraph).Pie(ageData, {
    segmentStrokeColor: "#333"
  });

}
