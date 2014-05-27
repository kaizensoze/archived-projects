<?php
$page = 'challenge_instances';
include('header.php');

global $challengeMgr;
$baseChallenges = $challengeMgr->getChallengesByType(null);
$challengeInstances = $challengeMgr->getChallengeInstances();
$rewards = $rewardMgr->getRewards();

$summaries = $challengeMgr->getChallengeSummaries();

$machineTypeList = new MachineManager();
$machineTypeList = $machineTypeList->getTypeList();

if(isset($_GET["challengeId"])) {
    $challengeId = $_GET["challengeId"];
?>
<script type="text/javascript">
    $(document).ready(function() {
        //edit_challenge(get_challenge(<?= $challengeId ?>));
    });
</script>
<?php } ?>

<script type="text/javascript">
    var baseChallengesJson = <?= json_encode($baseChallenges); ?>;
    var challengeInstanceJson = <?= json_encode($challengeInstances); ?>;
    var rewardsJson = <?= json_encode($rewards); ?>;

	var page = {}; //hold elements on page, on domready
	
	//model container, only for new challenges 
	function ChallengeInstance() {
		this.id = -1;
		this.name = "";
		this.challengeId = -1;
		this.rewardId = -1;
		this.challengeQuantity = null;
		this.active = 0;
	}
	
	function ChallengeInstancesViewModel() {
		var self = this;
		self.baseChallenges = ko.observableArray(baseChallengesJson);
		self.challengeInstances = ko.observableArray(challengeInstanceJson);
		self.rewards = ko.observableArray(rewardsJson);
		
		self.chosenChallengeData = ko.observable();
		
		self.addChallenge = function() {
			self.chosenChallengeData(new ChallengeInstance());
			page.editChallenge.show();
			$.scrollTo('#edit-challenge', 400);
		}
		
		self.removeChallenge = function(challenge) {
			if(confirm("Are you sure you want to delete this challenge instance?")) {
				self.challengeInstances.remove(challenge);
				fbExecuteAction({
					sAction : 'deleteChallengeInstance',
					oAjaxSettings : {
						data: {
							id : challenge.id
						},
						success : function(response) {
							self.challengeInstances.remove(challenge);
						}
					}
				});
			}
		}
		
		self.editChallenge = function(challenge) {
			console.log(challenge);
			self.chosenChallengeData(challenge); // Stop showing a folder
			page.editChallenge.show();
		};
		
		self.validateChallenge = function(challenge) {
			var hasError = false;
			$("#error").html('');
			console.log(challenge);
			
			if(challenge.name == "") {
				self.error('Enter a name');
				hasError = true;
			}
			if(typeof challenge.challengeId == 'undefined') {
				self.error("Choose a challenge");
				hasError = true;
			}
			if(typeof challenge.rewardId == 'undefined') {
				self.error("Choose a reward");
				hasError = true;
			}
			if(challenge.challengeQuantity == null) {
				self.error("Choose a challenge quantity");
				hasError = true;
			}
			return hasError;
		}
		
		self.saveChallenge = function(challenge) {
			//validation
			var hasError = self.validateChallenge(challenge);
			if(hasError)
				return;
			
			fbExecuteAction({
				sAction : 'saveChallengeInstance',
				oAjaxSettings : {
					data: {
						id : challenge.id,
						name : challenge.name,
						challengeId: challenge.challengeId,
						rewardId : challenge.rewardId,
						challengeQuantity: challenge.challengeQuantity,
						active : challenge.active
					},
					success : function(response) {
						if(challenge.id == -1) {
							challenge = $.parseJSON(response);
						}
						self.challengeInstances.remove(challenge);
						self.challengeInstances.push(challenge);
						page.editChallenge.hide();
					}
				}
			});
		}
		
		self.error = function(msg) {
			$("#error").append(msg + "<br/>");
		}
		
		self.cancelChallenge = function() {
			page.editChallenge.hide();
		}
		
		self.getChallengeName = function(id) {
			var c = $.grep(self.baseChallenges(), function(n, i) {
				if(n.id == id)
					return n;
			})[0];
			return c == null ? "" : c.name;
		}
		
		self.getRewardName = function(id) {
			var r = $.grep(self.rewards(), function(n, i) {
				if(n.id == id)
					return n;
			})[0];
			return r == null ? "" : r.name;
		}
		
		self.getChallengeQuantity = function(type) {
			if(type == 0) {
				return "Single";
			} else if (type == 1) {
				return "Group";
			}
		}
	}
	
	$("document").ready(function() {
		page.editChallenge = $("#edit-challenge");
		page.error = $("#error");
		
		ko.applyBindings(new ChallengeInstancesViewModel());
	});
</script>


<div class="help-blurb">
	<div class="controls"><a href="#" id="hide">hide</a></div>
	<span class="bold">Challenge instances</span> are created as a convenience to players.
	They bundle together challenge details and a reward, to act as a single-click "play and go" option. 
</div>

<div class="page">

<div class="col-left section" style="width: 800px;">
    <div class="section-title">
		Available Challenges
        <a class="button button-red col-right" id="add-new" data-bind="click: addChallenge" href="#">
			Add New
			<img src="../images/plus.png" width="8" height="8" alt="Plus sign" />
		</a>
    </div>
	
	<table class="table">
	<thead><tr>
        <th class="first">Name</th><th>Challenge</th><th>Reward</th><th>Quantity</th><th class="last">Active</th>
    </tr></thead>
	<tbody data-bind="foreach: challengeInstances">
		<tr>
			<td style="min-width: 200px; font-weight: bold;" data-bind="text: name"></td>
			<td style="min-width: 120px;" data-bind="text: $root.getChallengeName($data.challengeId)"></td>
			<td style="min-width: 160px;" data-bind="text: $root.getRewardName($data.rewardId)"></td>
			<td style="text-align: center;" data-bind="text: $root.getChallengeQuantity($data.challengeQuantity)"></td>
			<td style="text-align: center; max-width: 20px;" data-bind="text: $data.active == 1 ? 'yes' : '-'"></td>
			<td>
				<div class="buttons">
					<a data-bind="click: $root.editChallenge" href="#" class="edit button" id="<?= $c->id ?>">&nbsp;</a>
					<a data-bind="click: $root.removeChallenge" href="#" class="delete button" id="<?= $c->id ?>">&nbsp;</a>
				</div>
			</td>
		</tr>
	</tbody>
	</table>
</div>

<div class="fixer" style="height: 10px;"></div>
<div class="section" id="edit-challenge" data-bind="with: chosenChallengeData" style="display:none; width: 400px; margin: 20px 0px 0px 10px;">
	<div class="section-title">
		New Challenge Instance
	</div>
	
	<input type="hidden" data-bind="value: id" value="-1" id="challenge-id" />
	
	<span class="label" style="width: 120px;">Instance Name:</span>
		<input type="text" style="width: 200px;" data-bind="value: name" id="challenge-name" />
	<div class="fixer"></div>
	
	<span class="label col-left" style="width: 120px;">Challenge:</span>
		<select id="challenge" data-bind="options: $root.baseChallenges, optionsText: 'name', optionsValue: 'id', value: $data.challengeId, optionsCaption: 'Choose...'">
		</select>
	<div class="fixer"></div>
	
	<span class="label col-left" style="width: 120px;">Reward:</span>
		<select id="reward" data-bind="options: $root.rewards, optionsText: 'name', optionsValue: 'id', value: $data.rewardId, optionsCaption: 'Choose...'">
		</select>
	<div class="fixer"></div>
	
	<span class="label" style="width: 120px;">Quantity:</span>
		<input type="radio" class="col-left" name="quantity" id="quantity_single" value="0" data-bind="checked: challengeQuantity" />
		<span class="cb-label col-left">Single</span>
		<input type="radio" class="col-left" name="quantity" id="quantity_group" value="1" data-bind="checked: challengeQuantity" />
		<span class="cb-label col-left">Group</span>
	<div class="fixer"></div>
		
	<span class="label" style="width: 120px;">Active:</span>
		<input type="radio" class="col-left" name="active" id="active_yes" value="1" data-bind="checked: active" />
		<span class="cb-label col-left">Yes</span>
		<input type="radio" class="col-left" name="active" id="active_no" value="0" data-bind="checked: active" />
		<span class="cb-label col-left">No</span>
	<div class="fixer"></div>
	
	<div class="errors center" id="error"></div>
	
	<div class="fixer"></div>
	<div class="col-right" style="margin: 0px 10px 0px 0px;">
		<a class="button button-blue col-left" data-bind="click: $root.saveChallenge" id="save" href="#" style="width: 80px; margin-right: 5px;">Save</a>
		<a class="button button-blue col-left" data-bind="click: $root.cancelChallenge" id="cancel" href="#" style="width: 80px;">Cancel</a>
	</div>
	<div class="fixer"></div>
	<div class="fixer" style="height: 15px;"></div>
</div>

</div>

<?php
include('footer.php');
?>