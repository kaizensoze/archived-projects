<?php
$page = 'reports';
include('header.php');
?>
<link rel="stylesheet" type="text/css" href="./chartbeat/main-492fc2124033ab346ead655d31af5e06.css">
<style>
.page { padding-top: 0px; }
</style>

<div class="page">


    <div id="dashboard" class="clearfix">

    

    

    <div id="dashboardMainWrap">

      

      <div id="timelineWidget">
        <div id="filterWidget" class="timelineBox">
          <div class="timelineBoxContents">          
            <span id="filterDomain">GroupSlots.com</span>
          </div>
        </div>

        <div style="float: right; cursor: pointer; padding: 5px 5px 3px; font-size: 8pt; color: #999">
          <span class="timelineOption" id="timelineToday" style="color: #0B6E97">Today</span> |
          <span class="timelineOption" id="timelineWeek">7 days</span> |
          <span class="timelineOption" id="timelineMonth">30 days</span>
        </div>

        <div class="timelineContainer clearfix">
          <div class="timelineBox">
            <div class="timelineBoxContents" id="timeDate">3:06:34 PM</div>
          </div>
          <div class="timelineControls clearfix">
            <div id="realTime" class="timeMode">Real-time</div>
            <div id="replayTime" class="timeMode timeModeSelected">Replay</div>
            <div id="replayControls" style="display: none; ">
              <table cellspacing="1" cellpadding="0">
                <tbody><tr>
                  <td>
                    <img id="timelineBack" src="./chartbeat/replay_l.png" valign="top">
                  </td>
                  <td>
                    <div id="timelinePause">Pause</div>
                  </td>
                  <td>
                    <img id="timelineFwd" src="./chartbeat/replay_r.png" valign="top">
                  </td>
                </tr>
              </tbody></table>
            </div>
          </div>        
          <div id="timeline" style="opacity: 1; ">
            <img src="./chartbeat/graph.png" />
         <div style="position: absolute; left: 467.2222222222222px; top: 0px; "><div style="position: absolute; background-color: rgb(11, 110, 151); width: 2px; height: 95px; left: 28px; top: 0px; opacity: 0.6; "></div><div style="position: absolute; width: 40px; height: 24px; cursor: pointer; left: 8px; top: 95px; "><img src="./chartbeat/cb_thumb.png"></div></div></div>
        </div>
      </div>

      <div id="filterContainer" style="display: none">
        <div id="clearFilter">&nbsp;<span id="clearFilterLink" style="font-size: 83%">clear</span></div>
        <span id="currentFilter">
        </span>
      </div>

      <div id="widgetArea">
        <div id="lhs">
          <div class="widget" id="countWidget" style="opacity: 1; ">
            <div class="widgetControls">
              <div id="countHelp" class="helpIcon"></div>
            </div>
            <div class="widgetTitle" id="countTitle">Active Users</div>
            <div id="countCount" style="font-size: 52px; ">-</div>
            <div style="position: relative" id="countGaugeContainer">
              <div id="countGauge">
              <img src="chartbeat/gauge.png"/></div>
              <table style="width: 100%">
                <tbody><tr>
                  <td width="50%">
                    <span class="ministatTitle">30-Day Min</span><br><span id="countMin" class="ministat">0</span>
                  </td>
                  <td width="50%">
                    <span class="ministatTitle">30-Day Max</span><br><span id="countMax" class="ministat">91</span>
                  </td>
                </tr>
              </tbody></table>
            </div>
            <div id="newReturning" title="click to select">
              <div id="newGauge" style="height: 10px; position: relative;"><div style="position: absolute; left: 0px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 5px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 10px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 15px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 20px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 25px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 30px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 35px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 40px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 45px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 50px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 55px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 60px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 65px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 70px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 75px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 80px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 85px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 90px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 95px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 100px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 105px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 110px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 115px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 120px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 125px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 130px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 135px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 140px; top: 0px; width: 3px; height: 10px; background-color: rgb(0, 0, 139); "></div><div style="position: absolute; left: 145px; top: 0px; width: 3px; height: 10px; background-color: rgb(173, 216, 230); "></div><div style="position: absolute; left: 150px; top: 0px; width: 3px; height: 10px; background-color: rgb(173, 216, 230); "></div><div style="position: absolute; left: 155px; top: 0px; width: 3px; height: 10px; background-color: rgb(173, 216, 230); "></div><div style="position: absolute; left: 160px; top: 0px; width: 3px; height: 10px; background-color: rgb(173, 216, 230); "></div><div style="position: absolute; left: 165px; top: 0px; width: 3px; height: 10px; background-color: rgb(173, 216, 230); "></div><div style="position: absolute; left: 170px; top: 0px; width: 3px; height: 10px; background-color: rgb(173, 216, 230); "></div><div style="position: absolute; left: 175px; top: 0px; width: 3px; height: 10px; background-color: rgb(173, 216, 230); "></div></div>
              <table style="width: 100%; margin-top: 10px">
                <tbody><tr>
                  <td width="50%">
                    <span class="ministatTitle">New</span><br>
                    <span class="ministat" id="countNew">39</span>
                  </td>
                  <td width="50%">
                    <span class="ministatTitle">Returning</span><br>
                    <span class="ministat" id="countReturning">11</span>
                  </td>
                </tr>
              </tbody></table>
            </div>
          </div>
          <div class="widget selectableWidget" id="engagementWidget" style="opacity: 1; ">
            <div class="widgetControls">
              <div id="engagementHelp" class="helpIcon"></div>
            </div>
            <div id="engagementTitle" class="widgetTitle">Engagement</div>
            <div id="rwiGauges">
              <div id="readGauge" class="gauge">
                <div class="ministatTitle">Reading</div>
                <div class="ministat" id="readValue">9</div>
                <img src="chartbeat/gauge_small1.png"/></div>
              <div id="writeGauge" class="gauge">
                <div class="ministatTitle">Writing</div>
                <div class="ministat" id="writeValue">1</div>
                <img src="chartbeat/gauge_small2.png"/></div>
            </div>
            <table style="margin-top: 16px">
              <tbody><tr>
                <td><div style="background-color: #B2ABD2; width: 10px; height: 10px"></div></td>
                <td class="ministatTitle">&nbsp;Idle&nbsp;</td>
                <td class="ministat" id="idleValue">40</td>
              </tr>
            </tbody></table>
            <br>
            <div id="visitLength" class="subwidget">            
              <div class="ministatTitle">Minutes on Page</div>
              <div id="visitLengthChart"><img src="chartbeat/mins_page.png"/></div>
            </div>
            <div id="scrollDepthContainer" class="subwidget" style="margin-top: 10px; display: none; ">
              <div class="ministatTitle">Scroll Depth</div>
              <!-- Scroll Depth -->
              <div id="scrollDepthWidget" class="scrollDepth subContainer">
                  <div class="group">
                      <span class="label">Page Top</span>
                      <div id="scrollDepthChart" class="chart"></div>
                      <span class="label">Page Bottom</span>
                  </div>
              </div>
            </div>
          </div>
          <div class="widget" id="perfWidget" style="opacity: 1; ">
            <div class="widgetControls">
              <div id="perfHelp" class="helpIcon"></div>
            </div>         
            <div class="widgetTitle" id="perfTitle">Site Performance</div>
            <div id="domloadGauge" class="gauge">
              <div class="ministatTitle">User Page Load</div>
              <div class="ministat"><span id="domloadValue">2</span> seconds</div>
              <div id="domloadCanvas" style="margin-top: 5px">
                <img src="./chartbeat/line_gauge.png" /></div>
            </div>
            <br><br><br>
            <div class="ministatTitle" id="domLoadTitle">Page Load Distribution</div>
            <div id="domLoadTimes">
                <img src="./chartbeat/page_distro.png" /></div>
            <br><br>
            <div id="srvloadGauge" class="gauge">
              <div class="ministatTitle">Server Load Time</div>
              <div class="ministat"><span id="srvloadValue">192</span> milliseconds</div>
              <div id="srvloadCanvas" style="margin-top: 5px">
                <img src="./chartbeat/line_gauge.png" />
              </div>
            </div>
          </div>
        </div>
        
        <div id="rhs">
          <div id="historyWidget" class="widget" style="display: none; ">
            <div class="widgetControls">
              <div title="Show More" id="historyExpand" class="moreIcon"></div>
            </div>
            <div class="widgetTitle" id="historyTitle">History</div>
            <div id="historyChart"><canvas width="725" height="60"></canvas></div>
            <div id="bigHistoryChart"><canvas width="725" height="190"></canvas></div>
          </div>

          <div class="widget" id="densityWidget" style="opacity: 1;">
            <div class="widgetControls">
              <div class="pausedMessage" id="densityPaused"></div>
              <div title="Show More" id="densityExpand" class="moreIcon"></div>
              <div id="densityHelp" class="helpIcon"></div>
            </div>
            <div class="widgetTitle" id="densityTitle">Top Pages</div>
            <div id="density" class="clearfix" style="height: 250px; ">
            <div title="/say-hello-to-dot" class="densityBox selectableControl" style="position: absolute; left: 0px; top: 87px; width: 218px; height: 65px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 214px; height: 45px; "><div class="concurrents" style="font-size: 21.599999999999998px; ">6</div><div class="title" style="font-size: 18px; line-height: 22.5px; ">Say hello to Dot!</div></div><canvas style="position: absolute; left: 2px; top: 52px; " width="214" height="11"></canvas></div></div><div title="/dotspots/" class="densityBox selectableControl" style="position: absolute; left: 0px; top: 0px; width: 218px; height: 65px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 214px; height: 45px; "><div class="concurrents" style="font-size: 21.599999999999998px; ">10</div><div class="title" style="font-size: 18px; line-height: 22.5px; ">GroupSlots Dotspots</div></div><canvas style="position: absolute; left: 2px; top: 52px; " width="214" height="11"></canvas></div></div><div title="/dotspots/U9D48BBK3Y25" class="densityBox selectableControl" style="position: absolute; left: 240px; top: 82px; width: 170px; height: 55px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 166px; height: 35px; "><div class="concurrents" style="font-size: 16.8px; ">3</div><div class="title" style="font-size: 14px; line-height: 17.5px; ">GroupSlots Dotspots</div></div><canvas style="position: absolute; left: 2px; top: 42px; " width="166" height="11"></canvas></div></div><div title="/" class="densityBox selectableControl" style="position: absolute; left: 240px; top: 0px; width: 170px; height: 60px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 166px; height: 40px; "><div class="concurrents" style="font-size: 19.2px; ">5</div><div class="title" style="font-size: 16px; line-height: 20px; ">Welcome to GroupSlots</div></div><canvas style="position: absolute; left: 2px; top: 47px; " width="166" height="11"></canvas></div></div><div title="/meet-lucy" class="densityBox selectableControl" style="position: absolute; left: 432px; top: 154px; width: 132px; height: 55px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 128px; height: 35px; "><div class="concurrents" style="font-size: 16.8px; ">3</div><div class="title" style="font-size: 14px; line-height: 17.5px; ">Meet Lucy</div></div><canvas style="position: absolute; left: 2px; top: 42px; " width="127" height="11"></canvas></div></div><div title="/dot.php" class="densityBox selectableControl" style="position: absolute; left: 432px; top: 77px; width: 132px; height: 55px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 128px; height: 35px; "><div class="concurrents" style="font-size: 16.8px; ">3</div><div class="title" style="font-size: 14px; line-height: 17.5px; ">Say hello to Dot!</div></div><canvas style="position: absolute; left: 2px; top: 42px; " width="127" height="11"></canvas></div></div><div title="/dotspots/7XS2X2RMU6Y5" class="densityBox selectableControl" style="position: absolute; left: 432px; top: 0px; width: 132px; height: 55px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 128px; height: 35px; "><div class="concurrents" style="font-size: 16.8px; ">3</div><div class="title" style="font-size: 14px; line-height: 17.5px; ">GroupSlots Dotspots</div></div><canvas style="position: absolute; left: 2px; top: 42px; " width="127" height="11"></canvas></div></div><div title="/dotspots/search?sort=date_added&amp;query=" class="densityBox selectableControl" style="position: absolute; left: 585.6px; top: 72px; width: 101px; height: 45px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 97px; height: 25px; "><div class="concurrents" style="font-size: 12px; ">1</div><div class="title" style="font-size: 10px; line-height: 12.5px; ">GroupSlots Dotspots</div></div><canvas style="position: absolute; left: 2px; top: 32px; " width="96" height="11"></canvas></div></div><div title="/dotspots/AW4G3U9XKXAD" class="densityBox selectableControl" style="position: absolute; left: 585.6px; top: 139px; width: 101px; height: 45px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 97px; height: 25px; "><div class="concurrents" style="font-size: 12px; ">1</div><div class="title" style="font-size: 10px; line-height: 12.5px; ">GroupSlots Dotspots</div></div><canvas style="position: absolute; left: 2px; top: 32px; " width="96" height="11"></canvas></div></div><div title="/dotspots/manage_uploads" class="densityBox selectableControl" style="position: absolute; left: 585.6px; top: 0px; width: 101px; height: 50px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 97px; height: 30px; "><div class="concurrents" style="font-size: 14.399999999999999px; ">2</div><div class="title" style="font-size: 12px; line-height: 15px; ">GroupSlots Dotspots</div></div><canvas style="position: absolute; left: 2px; top: 37px; " width="96" height="11"></canvas></div></div><div title="/dotspots/8S8W9326NU99" class="densityBox selectableControl" style="position: absolute; left: 240px; top: 159px; width: 170px; height: 55px; "><div style="position: relative; "><div class="titleContainer" style="left: 2px; top: 2px; width: 166px; height: 35px; "><div class="concurrents" style="font-size: 16.8px; ">3</div><div class="title" style="font-size: 14px; line-height: 17.5px; ">GroupSlots Dotspots</div></div><canvas style="position: absolute; left: 2px; top: 42px; " width="166" height="11"></canvas></div></div></div>
            <div id="densityKey" class="widgetFooter" style="padding: 0px 0px 5px 10px;">
            <span>Each </span><span>
            <img src="chartbeat/top_pages.png" /></span><span> = <strong>1</strong> active visit(s). <span class="hide"><strong>11 pages shown</strong> are <strong>80%</strong> of active visits.</span> <div style="position: relative; display: inline-block; width: 30px; height: 20px; "><div style="background-color: rgb(158, 202, 225); position: absolute; left: 0px; bottom: 0px; width: 2px; height: 10px; "></div><div style="background-color: rgb(158, 202, 225); position: absolute; left: 3px; bottom: 0px; width: 2px; height: 9px; "></div><div style="background-color: rgb(158, 202, 225); position: absolute; left: 6px; bottom: 0px; width: 2px; height: 8px; "></div><div style="background-color: rgb(158, 202, 225); position: absolute; left: 9px; bottom: 0px; width: 2px; height: 7px; "></div><div style="background-color: rgb(158, 202, 225); position: absolute; left: 12px; bottom: 0px; width: 2px; height: 6px; "></div><div style="background-color: rgb(204, 204, 204); position: absolute; left: 15px; bottom: 0px; width: 2px; height: 5px; "></div><div style="background-color: rgb(204, 204, 204); position: absolute; left: 18px; bottom: 0px; width: 2px; height: 4px; "></div><div style="background-color: rgb(204, 204, 204); position: absolute; left: 21px; bottom: 0px; width: 2px; height: 3px; "></div><div style="background-color: rgb(204, 204, 204); position: absolute; left: 24px; bottom: 0px; width: 2px; height: 2px; "></div><div style="background-color: rgb(204, 204, 204); position: absolute; left: 27px; bottom: 0px; width: 2px; height: 1px; "></div></div></span></div>
          </div>
          
          <div class="widget" id="sourcesWidget" style="opacity: 1; ">
            <div class="widgetControls">
              <span class="pausedMessage" id="sourcesPaused"></span>
              <div title="Show More" id="sourcesExpand" class="moreIcon"></div>
              <div id="sourcesHelp" class="helpIcon"></div>
            </div>
            <div class="widgetTitle" id="sourcesTitle">Traffic Sources</div>
            <div class="subwidget" style="padding-right: 30px">
              <div id="sourcePie"><img src="chartbeat/pie_graph.png"/><div></div></div>
            </div>
            <div id="topDomains">
              <table class="sourceHeader">
                <tbody><tr>
                  <td class="sliceListBox"><div style="background-color: #6baed6; width: 15px; height: 15px"></div></td>
                  <td class="sliceListTitle">Links</td>
                  <td class="sliceListCount" id="linkCount">7</td>
                  <td></td>
                </tr>
              </tbody></table>
              <div id="topDomainsList"><table class="subsubsliceTable" cellspacing="0"><tbody><tr><td class="subsliceTitle"><div class="focusLink " jsaction="selectDomain" jsvalue="0">GroupSlots.myshopify.com</div></td><td class="subsliceCount">3</td></tr><tr><td class="subsliceTitle"><div class="focusLink " jsaction="selectDomain" jsvalue="1">facebook.com</div></td><td class="subsliceCount">2</td></tr><tr><td class="subsliceTitle"><div class="focusLink " jsaction="selectDomain" jsvalue="2">businessinsider.com</div></td><td class="subsliceCount">1</td></tr><tr><td class="subsliceTitle"><div class="focusLink " jsaction="selectDomain" jsvalue="3">macworld.com</div></td><td class="subsliceCount">1</td></tr></tbody></table></div>
            </div>
            <div id="topSearches">
              <table class="sourceHeader">
                <tbody><tr>
                  <td class="sliceListBox"><div style="background-color: #74c476; width: 15px; height: 15px"></div></td>
                  <td class="sliceListTitle">Search</td>
                  <td class="sliceListCount" id="searchCount">1</td>
                  <td></td>
                </tr>
              </tbody></table>
              <div id="topSearchesList"><table class="subsubsliceTable"><tbody><tr><td class="subsliceTitle link" jsaction="selectSearch" jsvalue="0">GroupSlots</td><td class="subsliceCount">1</td></tr></tbody></table></div>
              <table class="sourceHeader">
                <tbody><tr>
                  <td class="sliceListBox"><div style="background-color: #fd8d3c; width: 15px; height: 15px"></div></td>
                  <td class="sliceListTitle">Direct</td>
                  <td class="sliceListCount" id="directCount">12</td>
                  <td></td>
                </tr>
              </tbody></table>
            </div>
            <div id="topPages" style="display: none; ">
            </div>
            <div id="pageDetails" style="display: none; ">
            <canvas style="background-color: white; position: relative; cursor: pointer; opacity: 1; " width="700" height="800"></canvas></div>
          </div>

          <div class="widget" id="usersWidget" style="opacity: 1; padding-bottom: 20px;">
            <div class="widgetControls">
              <div id="usersHelp" class="helpIcon"></div>
            </div>
            <div class="widgetTitle" id="usersTitle">Locations</div>
            <div id="map" class="subwidget"><div class="chartbeat-slippymap" style="cursor: move; "><div style="position: relative; overflow-x: hidden; overflow-y: hidden; width: 450px; height: 240px; ">
                <img src="chartbeat/world_map.png" style="margin: 10px 0px 0px 100px;"/>
            </div></div></div>
            <div id="mapList" class="subwidget"><table class="subsliceTable" style="background-color: white"><tbody><tr><td class="subsliceTitle">United States</td><td class="subsliceCount">35</td></tr><tr><td class="subsliceTitle">Canada</td><td class="subsliceCount">6</td></tr><tr><td class="subsliceTitle">Germany</td><td class="subsliceCount">2</td></tr><tr><td class="subsliceTitle">France</td><td class="subsliceCount">1</td></tr><tr><td class="subsliceTitle">Switzerland</td><td class="subsliceCount">1</td></tr><tr><td class="subsliceTitle">Israel</td><td class="subsliceCount">1</td></tr></tbody></table><br><br><table class="subsliceTable" style="background-color: white"><tbody><tr><td class="subsliceTitle">New York</td><td class="subsliceCount">6</td></tr><tr><td class="subsliceTitle">California</td><td class="subsliceCount">4</td></tr><tr><td class="subsliceTitle">Wisconsin</td><td class="subsliceCount">2</td></tr><tr><td class="subsliceTitle">Iowa</td><td class="subsliceCount">2</td></tr><tr><td class="subsliceTitle">Ohio</td><td class="subsliceCount">2</td></tr><tr><td class="subsliceTitle">Florida</td><td class="subsliceCount">1</td></tr></tbody></table><br><br></div>
            <div style="clear: both; height: 10px"></div>
          </div>

          <div class="widget" id="conversationWidget" style="opacity: 1; ">
            <div class="widgetControls">
              <div class="pausedMessage" id="conversationSettings" style="cursor: pointer">Settings</div>
              <div title="Show More" id="conversationExpand" class="moreIcon"></div>
              <div id="conversationHelp" class="helpIcon"></div>
            </div>
            <div id="conversationTitle" class="widgetTitle">
              Conversations
              <a href="http://twitter.com/" target="_blank">
                <img src="./chartbeat/powered-by-twitter-badge.gif" border="0" valign="bottom">
              </a>
            </div>
            <div id="conversationForm" style="display: none;">
              <input type="text" id="conversationField" size="50">
              <input type="submit" value="Change search terms" id="conversationSubmit">
            </div>
            <div id="tweetContents" style="overflow-y: hidden; "><div class="conversation clearfix">                  <a href="http://twitter.com/geertbesten" class="thumbnail" target="_blank">                    <img src="./chartbeat/profiel_foto_normal.jpg" alt="geertbesten&#39;s Profile Picture">                  </a>                  <a href="http://twitter.com/geertbesten" class="username" target="_blank">geertbesten</a>                  <span class="timestamp">34 minutes ago</span>                  <p>Gaaf ding: maak 360 graden panoramische video met GroupSlots Dot, een revolutionaire uitbreiding voor je iPhone! | http://t.co/peFmo7gZ | #fb</p>                </div><div class="conversation clearfix">                  <a href="http://twitter.com/jeffglasse" class="thumbnail" target="_blank">                    <img src="./chartbeat/Screen_Shot_2011-09-02_at_12.00.30_PM_normal.png" alt="jeffglasse&#39;s Profile Picture">                  </a>                  <a href="http://twitter.com/jeffglasse" class="username" target="_blank">jeffglasse</a>                  <span class="timestamp">3 hours ago</span>                  <p>Another amazing #dotspot from 360niseko: http://t.co/BJbMtxUm</p>                </div><div class="conversation clearfix">                  <a href="http://twitter.com/jeffglasse" class="thumbnail" target="_blank">                    <img src="./chartbeat/Screen_Shot_2011-09-02_at_12.00.30_PM_normal.png" alt="jeffglasse&#39;s Profile Picture">                  </a>                  <a href="http://twitter.com/jeffglasse" class="username" target="_blank">jeffglasse</a>                  <span class="timestamp">3 hours ago</span>                  <p>RT @GroupSlots: Now, in NYC, @jeffglasse is demoing Dot, at @JandR' World http://t.co/sD2vsVFr</p>                </div><div class="conversation clearfix">                  <a href="http://twitter.com/benmachado" class="thumbnail" target="_blank">                    <img src="./chartbeat/Picture_1_normal.png" alt="benmachado&#39;s Profile Picture">                  </a>                  <a href="http://twitter.com/benmachado" class="username" target="_blank">benmachado</a>                  <span class="timestamp">4 hours ago</span>                  <p>holy shit that is awesome - ly affordable RT @irleygirl: @benmachado ooh, seen this yet? http://t.co/JGK3OIee (via @GroupSlots)</p>                </div><div class="conversation clearfix">                  <a href="http://twitter.com/heliobentzen" class="thumbnail" target="_blank">                    <img src="./chartbeat/37117_1645716101917_1207348567_1788632_4851348_n_normal.jpg" alt="heliobentzen&#39;s Profile Picture">                  </a>                  <a href="http://twitter.com/heliobentzen" class="username" target="_blank">heliobentzen</a>                  <span class="timestamp">5 hours ago</span>                  <p>Alguém ja testou o GroupSlots pra fotos em 360º com iPhone? http://t.co/3jKolfK5</p>                </div></div>
          </div>

        </div> <!-- RHS -->
        <br clear="all">   
      </div> <!-- widget area -->
    
    </div> <!-- #dashboardMainWrap -->

    <div id="recentWidget">
      <div id="recentTitle" class="widgetTitle" style="display:none">Raw Hits</div>
      <div id="recent">
      
      </div>
    
    </div>      
    </div> <!-- dashboard -->
    <div style="position: absolute; display: none; "><b>Engagement</b><br><br>Reading visitors are people actively on your page; they've moved their mouse or scrolled down in the last few seconds.<br><br>Writing visitors are actively on your site and typing something.<br><br>Idle visitors are not active on your site and might have it in the background or have left their computer.<br><br><a class="tooltipLink" target="_blank" href="http://chartbeat.com/faq/#engagement">More Help</a></div><div style="position: absolute; display: none; "><b>Sources</b><br><br>This shows you where people are arriving from when they visit your site, including what searches they are using.<br><br>Clicking on a domain shows the history of traffic from that domain and the specific URLs users are coming from.<br><br><a class="tooltipLink" target="_blank" href="http://chartbeat.com/faq/#sources">More Help</a></div><div style="position: absolute; display: none; "><b>Locations</b><br><br>The top locations for your users. For large sites, this data may be sampled.</div><div style="position: absolute; display: none; "><b>Active Visits</b><br><br>Active visits are every page open by every visitor to your site right now.<br><br><a class="tooltipLink" target="_blank" href="http://chartbeat.com/faq/#activevisits">More Help</a></div><div style="position: absolute; display: none; "><b>Top pages</b><br><br>These are the top pages on your site, based on the number of people currently viewing them.</div><div style="position: absolute; display: none; "><b>Site Performance</b><br><br>User page load time is the time it takes from when a user starts to load your page until the initial page elements (images) are done loading. The histogram shows the distribution of these load times.<br><br>The server load time is the time to load the HTML of your home page, as measured by our servers on the East Coast of the United States.<br><br><a class="tooltipLink" target="_blank" href="http://chartbeat.com/faq/#performance">More Help</a></div><div style="position: absolute; display: none; "><b>Conversations</b><br><br>Recent tweets discussing or linking to your site. To change search terms, click on settings.</div><input type="text" name="history_state0" id="history_state0" style="display:none">


</div>

<script type="text/javascript">
    var recentEvents = $("#recent");
    var activeUsers = $("#countCount");
    
    $("document").ready(function() {
        updateEvents();
        updateActiveUsers();
        
        window.setInterval(function() {
            updateEvents();
            updateActiveUsers();
        }, 3000);
    });
    
    function updateEvents() {
        $.getJSON(url+"admin/service.php?action=get-events", function(data) {
            recentEvents.children().remove();
            for(var e in data) {
                var event = data[e];
                showEvent(event);
            }
        });
    }
    
    function showEvent(ev) {
        var div = $('<div class="entry">' +
                        '<a class="recentLink" href="groups.php?groupId=' + ev.group_id + '">' + ev.player_name + ' wins ' + ev.win_amount + '</a>' +
                        '<span class="meta">' + ev.time_created + '</span>' +
                    '</div>');
        recentEvents.append(div);
        
    }
    
    function updateActiveUsers() {
        $.getJSON(url+"admin/service.php?action=get-active-users", function(data) {
            activeUsers.text(data);
        });
    }

</script>

<?php
include('footer.php');

?>