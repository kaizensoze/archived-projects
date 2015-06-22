<?php
$page = 'groups';
include('header.php');

$groupJson = json_encode($groupMgr->getGroups());
echo '<script type="text/javascript">var groups = ' . $groupJson . '</script>';

if(isset($_GET["groupId"])) {
$groupId = $_GET["groupId"]; ?>
<script type="text/javascript">
	$("document").ready(function() {
		showGroupDetails(<?= $groupId ?>);
	});
</script><?php } ?>
<div class="page">
	<div class="col-left section">
		<div class="section-title">Active Groups</div>
		<table class="table" id="group-table">
			<thead>
				<tr>
					<th>Group</th>
					<th>Challenge</th>
					<th>Members</th>
					<th>Balance</th>
					<th>Target</th>
					<th>Reward Total</th>
					<th>Started</th>
				</tr>
			</thead>
		</table>
	</div>
	<div class="fixer" style="height: 20px;"></div>
	<div id="group-details" class="hidden col-left section">
		<div class="details">
			<div class="title">
				Group <span id="group-id"></span>
				<div id="deleteGroup">DELETE</div>
			</div>
			<div class="details-inner">
				<div class="col-left" style="width: 240px;">
					<span class="label2 bold">Comp Selected:</span><br/><span class="text" id="comp-name"></span><br/>
					<span class="label2 bold">Time Started:</span> <span class="text" id="group-time-started"></span>
				</div>
				<div class="col-left" style="width: 24s0px;">
					<span class="label2 bold">Cost/Member:</span> <span class="text" id="comp-member-price"></span><br/>
				</div>
				<div class="fixer" style="height: 10px;"></div>
				<div id="progressbar" style="height: 1em;"></div>
				<div id="previousChallenges">
					<div class="fixer"></div>
				</div>
				<div class="fixer" style="height: 12px;"></div>
				<span class="label2 bold">Members:</span><br/>
				<div id="player-info">
					<span id="loading-members">Loading...</span>
				</div>
			</div>
			<div class="fixer"></div>
		</div>
	</div>
	<script type="text/javascript">
		$("document").ready(function() {
			showGroupData(groups);

			$('#deleteGroup').click(function(oEvent) {
				oEvent.preventDefault();

				if(confirm("Are you sure you want to delete this group and all of its players?")) {
					fbExecuteAction({
						sAction : 'deleteGroupByID',
						oAjaxSettings : {
							data : {group_id : $('#group-id').text()},
							success : function(sResponse) {
								if(sResponse === 'ERROR') {
									window.alert(this.sAction + ' failed');
									return;
								}
								window.location.reload();
							}
						}
					});
				}
			});
		});

		function get_group(id) {
			for(var g in groups) {
				var group = groups[g];
				if(group.id == id) {
					return group;
				}
			}
			return null;
		}

		//polled every x seconds to update group balance values
		function updateGroups() {
			$.getJSON(url+"admin/service.php?action=getGroups", function(data) {
				groups = data;
				//fill in table
				showGroupData(groups);

				//update details if any are showing
				var currGroupId = $("#group-id").text();
				if(currGroupId != null && currGroupId != '') {
					showGroupDetails(currGroupId);
				}
			});
		}

		function showGroupData(data) {
			var groupTable = $("#group-table");
			groupTable.find("tr.row").remove();

			for (var g in data) {
				var group = data[g];
				var dateStart = convertDate(group.time_created).toString("M-d-yyyy H:mm tt");
				var challengeExtra = "";
				if(group.challengeDetails == null) {
					var row = $(
						'<tr class="row">' +
							'<td><span><a class="group-edit" href="#" id="' + group.id + '" onclick="showGroupDetails(' + group.id  +'); return false;">Group ' + group.id + '</a></span></td>' +
							'<td></td>' +
							'<td></td>' +
							'<td class="balance"></td>' +
							'<td></td>' +
							'<td></td>' +
							'<td></td>' +
						'</tr>'
					);
				} else {
					if(group.challengeDetails.challenge.challengeType == 1) { //scavenger
						var totalSteps = group.challengeDetails.challenge.rules.length;
						challengeExtra = " (<b>step " + (parseInt(group.challengeDetails.tierNum)+1) + " of " + totalSteps + "</b>)";
					}
					var row = $(
						'<tr class="row">' +
							'<td><a class="group-edit" href="#" id="' + group.id + '" onclick="showGroupDetails(' + group.id  +'); return false;">Group ' + group.id + '</a></td>' +
							'<td>' + group.challengeDetails.challenge.name + challengeExtra + '</td>' +
							'<td>' + group.group_size + '</td>' +
							'<td class="balance">' +
								parseInt(group.challengeDetails.balance, 10).toLocaleString() +
								' (' + group.challengeDetails.balanceSum.toLocaleString() + ' total)' +
							'</td>' +
							'<td>' + parseInt(group.challengeDetails.target, 10).toLocaleString() + '</td>' +
							'<td>' + group.challengeDetails.totalRewardTarget.toLocaleString() + '</td>' +
							'<td>' + dateStart + '</td>' +
						'</tr>'
					);
				}
				groupTable.append(row);
			}
		}

		//store these stats outside functions so we can manipulate them across async calls.
		var groupTotalPlayers = 0;
		var currPlayerCount = 0;
		var userDivs = new Array();
		var players = null; //stores sequence of IDs so we can render them in the same order across subsequent calls

		function showGroupDetails(id) {
			var groupDetails = $("#group-details");
			var groupId = $("#group-id");
			var group = get_group(id);
			var dateStart = convertDate(group.time_created).toString("M-d-yyyy H:mm tt");

			// NOTE: uncomment below to show the single progress bar for the current step. comment out lines 172-193 to hide the other bars.
			/*
			 var progress = (group.challengeDetails.balance/group.challengeDetails.target) * 100.0;
			$("#progressbar").progressbar({
				value: progress
			});
			*/
			$("#progressbar").hide();

			var previousChallenges = $("#previousChallenges");
			if(group.previousChallenges.length == 0) {
				previousChallenges.hide();
			} else {
				previousChallenges.show();
				previousChallenges.children().remove();
				var total = group.previousChallenges.length;
				var idx = total-1;
				while(idx >= 0) {
					var pc = group.previousChallenges[idx];
					var text = $('<span class="text">Step ' + (parseInt(pc.tierNum)+1) + '</span>');
					var bar = $('<div class="progress"></div>');
					var barProgress = (pc.balance/pc.target) * 100.0;
					bar.progressbar({
						value: barProgress
					});
					previousChallenges.append(text);
					previousChallenges.append(bar);
					idx--;
				}
			}

			groupId.text(id);
			if(group.challengeDetails != null) {
				$("#comp-name").text(group.challengeDetails.reward.name);
				$("#comp-member-price").text(group.challengeDetails.reward.amount);
			}
			$("#group-time-started").text(dateStart);

			//these are global for use across async methods
			userDivs = new Array();
			groupTotalPlayers = group.players.length;
			players = group.players;

			var i = 0;
			for (key in group.players) {
				var player = group.players[key];
				var fbid = player.facebook_id;
				var sum = player.sum;

				var isLast = i == groupTotalPlayers-1;
				addUserDiv(player, isLast);

				i++;
			}

			if(groupDetails.hasClass('hidden')) {
				groupDetails.removeClass("hidden");
			}
		}

		function showUpdatedUserDivs() {
			//fill in player's facebook info
			var playerInfo = $("#player-info");
			playerInfo.children().remove();

			for (key in players) {
				var p = players[key];
				var fbid1 = p.facebook_id;

				for(var j=0; j<userDivs.length; j++) {
					var div = $(userDivs[j][0]);
					var fbid2 = div.attr('id');
					if(fbid1 == fbid2) {
						playerInfo.append(div);
					}
				}
			}
		}

		function addUserDiv(player, isLast) {
			//ie. https://graph.facebook.com/100003164261080
			if(player.sum == null)
				player.sum = '0';

			var img = "";
			if(player.facebook_id == null || player.facebook_id == '') {
				img = "../images/anon.png";
				player.facebook_id = "";
			} else {
				img = 'https://graph.facebook.com/' + player.facebook_id + '/picture';
			}

			var userDiv = $('<div class="user ' + (isLast == true ? 'last' : '') + '" id="' + player.facebook_id + '"></div>');
			var img = $('<img style="margin-left: 5px;" src="' + img + '"></img>');

			var appendAllInfo = function(response) {

			};

			if (player.facebook_id != null && player.facebook_id != '') {
				var url = "http://graph.facebook.com/" + player.facebook_id;
				$.getJSON(url, function(response) {
					var info = $('<div class="info col-left"><b>Name:</b> ' + response.first_name + ' ' + response.last_name + '<br/>' +
								 '<b>Card ID:</b> ' + player.card_id + '<br/>' +
								 '<b>Gender:</b> ' + response.gender + '<br/>' + '<b>Location:</b> ' + response.locale.replace('en_','') + '</div>');
					var sumDiv = $('<div class="sum col-left"><b>Total winnings:</b> ' + player.sum + '</div><div class="fixer"></div>');

					userDiv.append(img);
					userDiv.append(info);
					userDiv.append(sumDiv);

					userDivs.push(userDiv);

					currPlayerCount++;
					if(currPlayerCount == groupTotalPlayers) {
						showUpdatedUserDivs();
						userDivs = new Array();
						currPlayerCount = 0;
					}
				});
			} else {
				 var info = $('<div class="info col-left"><b>Name:</b> ' + player.name + '<br/>' + '</div>');
				 var sumDiv = $('<div class="fixer"></div>');

					userDiv.append(img);
					userDiv.append(info);
					userDiv.append(sumDiv);

					userDivs.push(userDiv);

					currPlayerCount++;
					if(currPlayerCount == groupTotalPlayers) {
						showUpdatedUserDivs();
						userDivs = new Array();
						currPlayerCount = 0;
					}
			}
		}
	</script>
	<?php include('footer.php'); ?>