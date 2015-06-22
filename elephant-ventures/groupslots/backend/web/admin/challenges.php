<?php
$page = 'challenges';
include('header.php');

global $challengeMgr;
$challenges = $challengeMgr->getChallengesByType(ChallengeType::Scavenger);

$machineTypeList = new MachineManager();
$machineTypeList = $machineTypeList->getTypeList();

if(isset($_GET["challengeId"])) {
    $challengeId = $_GET["challengeId"];
?>
<script type="text/javascript">
    $(document).ready(function() {
        edit_challenge(get_challenge(<?= $challengeId ?>));
    });
</script>
<?php } ?>

<script type="text/javascript">
    var challenges = <?= json_encode($challenges); ?>;

    function get_challenge(id) {
        for(var c in challenges) {
            var challenge = challenges[c];
            if(challenge.id == id)
                return challenge;
        }
        return null;
    }

    function getChallengeRule(id) {
        for(var c in challenges) {
            var challenge = challenges[c];
            for(var r in challenge.rules) {
                var rule = challenge.rules[r];
                if(rule.id == id) {
                    return rule;
                }
            }
        }
    }

    function deleteChallengeRule(id) {
        for(var c in challenges) {
            var challenge = challenges[c];
            for(var r in challenge.rules) {
                var rule = challenge.rules[r];
                if(rule.id == id) {
                    challenge.rules.splice(r, 1);
                    var data = "action=deleteChallengeRule&ruleId=" + id;
                    App.Service.request({
                        data: data,
                        callback: function(response) {
                            edit_challenge(challenge);
                        }
                    });
                }
            }
        }
    }

    function updateChallengeRule(ruleId, challengeId, sortNum, amount, machine, timespan, dependency, isNew) {
		console.log("udpateChallengeRule: " + sortNum + ", new: " + isNew);
        for(var c in challenges) {
            var challenge = challenges[c];

            if(isNew) {
                if(challenge.id == challengeId) {
                    //add rule to the list
                    var newRule = { id: ruleId, name: name, amount: amount, machine: machine, orderNum: sortNum, timespan: timespan, dependency: dependency };
                    challenge.rules.push(newRule);
                }
            } else {
                //otherwise update the rule
                for(var r in challenge.rules) {
                    var rule = challenge.rules[r];
                    if(rule.id == ruleId) {
                        rule.amount = amount;
                        rule.machine = machine;
                        rule.timespan = timespan;
                        rule.dependency = dependency;
                    }
                }
            }
        }
    }
</script>

<div class="help-blurb">
	<div class="controls"><a href="#" id="hide">hide</a></div>
	<span class="bold">Challenges</span> are created for a group to choose from when starting to play.
    They may be setup with rule criteria which the group must meet before completing the challenge.
</div>

<div class="page">

<div class="col-left section" style="width: 450px;">
    <div class="section-title">
		Available Challenges
        <a class="button button-red col-right" id="add-new" href="#">
			Add New
			<img src="../images/plus.png" width="8" height="8" alt="Plus sign" />
		</a>
    </div>
    <table class="table">
        <thead><tr>
            <th>Name</th><th>Active</th>
        </tr></thead>
        <?php foreach($challenges as $c) { ?>
		<tr>
			<td style="width:250px; font-weight: bold;"><?= $c->name ?> (<?= $c->id ?>)</td>
			<td style="text-align: center; max-width: 20px;"><?= $c->active == true ? 'yes' : '-' ?></td>
			<td>
				<div class="buttons">
					<a href="#" class="edit button" id="<?= $c->id ?>">&nbsp;</a>
					<a href="#" class="delete button" id="<?= $c->id ?>">&nbsp;</a>
				</div>
			</td>
		</tr>
        <?php } ?>
    </table>
</div>

<div class="section col-left" style="width: 500px; margin-left: 20px;">
	<div id="add-new-form" class="hidden">
		<div class="section-title">Add New Challenge</div>
		<div class="fixer" style="height: 10px;"></div>
		<input type="hidden" value="-1" id="challenge-id" />
		<span class="label" style="width: 120px;">Challenge Name:</span>
		<input type="text" style="width: 200px;" id="challenge-name" value="Untitled" />
		<div class="fixer"></div>
		<span class="label" style="width: 120px;">Challenge Type:</span>
		<input checked="checked" name="ctype" type="radio" value="0" />
		<span class="cb-label">Regular</span>
		<input name="ctype" type="radio" value="1" />
		<span class="cb-label">Scavenger Hunt</span>
		<div class="hidden">
			<input type="radio" name="ctype" id="ctype_tournament" />
			<span class="cb-label">Tournament</span>
		</div>
		<div class="fixer"></div>
		<span class="label" style="width: 120px;">Active:</span>
		<input type="radio" name="active" id="active_yes" />
		<span class="cb-label">Yes</span>
		<input type="radio" name="active" id="active_no" checked="checked" />
		<span class="cb-label">No</span>
		<div class="fixer"></div>
		<span class="label" style="width: 120px;">Challenge Rules:</span>
		<a class="button button-mini col-left" id="add-new-rule" href="#" style="width: 60px; position: relative; top: 7px; margin-left: 5px;">Add New</a>
		<div class="fixer"></div>
		<div id="rule-list" style="font-size: 9pt;"></div>
		<div class="fixer"></div>
		<div id="rule-edit" style="display:none; width: 575px; font-size: 9pt;">
			<div class="fixer"></div>
			<div class="col-left">
				<input type="hidden" id="rule-id" value="-1" />
				<input type="hidden" id="rule-dependency" value="-1" />
				<input type="hidden" id="rule-order" value="0" />
				<a class="button button-mini col-left" href="#" id="save-rule" style="width: 40px; position: relative; top: 3px; margin: 0 1em 0 3em;" >Add</a>
				<input class="rule-input" id="rule-amount" maxlength="3" style="width: 2em; position: relative;" type="text" />
				percent at machine of type
				<select id="rule-machine">
					<?php
					foreach($machineTypeList as $machineType) {
						echo
							'<option value="' . $machineType['type'] . '">' .
							htmlentities($machineType['name'], ENT_QUOTES, 'UTF-8') .
							'</option>';
					}
					?>
				</select>
				within
				<input class="rule-input" id="rule-timespan" maxlength="3" style="width: 2em;" type="text" />
				hours
			</div>
		</div>
		<div class="fixer"></div>
		<div class="col-right" style="margin: 20px 10px 0px 0px;">
			<a class="button button-red col-left" id="save" href="#" style="width: 80px; margin-right: 5px;">Save</a>
			<a class="button button-red col-left" id="cancel" href="#" style="width: 80px;">Cancel</a>
		</div>
		<div class="fixer"></div>
		<div class="errors center"></div>
		<div class="fixer" style="height: 20px;"></div>
	</div>
	<script type="text/javascript">
		var idIn = $("#challenge-id");
		var nameIn = $("#challenge-name");
		var amountIn = $("#challenge-amount");
		var timeIn = $("#challenge-time");
		var ruleList = $("#rule-list");
		
		var btnAddNew;

		//rules
		var ruleEdit;
		var ruleEditId = $("#rule-id");
		var ruleEditAmount = $("#rule-amount");
		var ruleEditMachine = $("#rule-machine");
		var ruleEditTimespan = $("#rule-timespan");
		var ruleEditDependency = $("#rule-dependency");
		var ruleEditOrder = $("#rule-order");

		var btnAddRule;
		var btnSaveRule;

		function reload(substring) {
			var redirect = "challenges.php";
			if(typeof substring != 'undefined') {
				redirect += substring;
			}
			window.location = redirect;
		}

		function showRule(rule, index) {
            console.log(rule);
			var el = $(
				'<div class="challenge-rule" id="' + rule.id + '" dependency="' + rule.dependency + '">' +
					(parseInt(rule.orderNum)+1) + '. &nbsp;&nbsp; ' +
					'<b><span class="rule-amount">' + rule.amount + '</span></b>' +
					'% at machine of type ' +
					'"<b>' + rule.machine + '</b>" ' +
					'within ' +
					'<b>' + rule.timespan + '</b> ' +
					'hours' +
					'<div class="controls">' +
						'<a href="#" class="edit" id="' + rule.id + '">edit</a>' +
						'&nbsp;' +
						'<a href="#" class="delete" id="' + rule.id + '">delete</a>' +
					'</div>' +
				'</div>'
			);
			ruleList.append(el);
		}

		function edit_challenge(challenge) {
			// btnAddNew = $("#add-new");
			var formAddNew = $("#add-new-form");
			var addNewTitle = $("#add-new-form .section-title");
			addNewTitle.text('Edit Challenge');

			var idIn = $("#challenge-id");
			var nameIn = $("#challenge-name");
			var amountIn = $("#challenge-amount");
			var timeIn = $("#challenge-time");
			if (challenge.active == "1") {
				$("#active_yes").attr("checked", "true");
			} else {
				$("#active_no").attr("checked", "true");
			}

			idIn.val(challenge.id);
			nameIn.val(challenge.name);
			
			//TODO: set hours/days

			//display rules
			ruleList.children().remove();
			var idx = 0;
			var total = challenge.rules.length;

			// sort the rules based on rule ordering
			challenge.rules.sort(function(a,b) {
				return (a.orderNum - b.orderNum);
			});

			for(var r in challenge.rules) {
				var rule = challenge.rules[r];
				showRule(rule,r);
			}
			formAddNew.removeClass("hidden");
		}

		function editChallengeRule(rule) {
			ruleEdit.show();
			if(rule != null) {
				ruleEditId.val(rule.id);
				ruleEditAmount.val(rule.amount);
				ruleEditMachine.val(rule.machine);
				ruleEditTimespan.val(rule.timespan);
				ruleEditDependency.val(rule.dependency);
				ruleEditOrder.val(rule.orderNum);
				btnSaveRule.text('Save');
			} else {
				// Find previous dependency
				ruleEditOrder.val(0);
				ruleEditTimespan.val('');
				var previousRuleDiv = ruleList.children().last();
				if(previousRuleDiv.length != 0) {
					var previousRule = getChallengeRule(previousRuleDiv.attr('id'));
					ruleEditOrder.val(parseInt(previousRule.orderNum) + 1);
					console.log("SET ORDER: " + ruleEditOrder.val());
				}
				btnSaveRule.text('Add');
			}
		}

		$(document).ready(function() {
			btnAddNew = $("#add-new");
			btnAddRule = $("#add-new-rule");
			btnSaveRule = $("#save-rule");
			ruleEdit = $("#rule-edit");
			
			var formAddNew = $("#add-new-form");
			var btnCancel = $("#cancel");
			var btnSave = $("#save");
			var deleteBtns = $(".delete");
			var editBtns = $(".edit");
			var addNewTitle = $("#add-new-form .section-title");
			var showCompType = $(".show_comp_type");
			var editCompType = $(".edit_comp_type");

			$(".challenge-rule .controls .edit").live('click', function(e) {
				e.preventDefault();
				var id = $(this).attr('id');
				var rule = getChallengeRule(id);
				editChallengeRule(rule);
			});

			$(".challenge-rule .controls .delete").live('click', function(e) {
				e.preventDefault();
				var id = $(this).attr('id');
				if(confirm('Are you sure you want to delete this rule?')) {
					deleteChallengeRule(id);
				}
			});

			var errors = $(".errors");

			btnAddRule.click(function(oEvent) {
				oEvent.preventDefault();
				
				editChallengeRule(null);
			});

			btnSaveRule.click(function(oEvent) {
				oEvent.preventDefault();
				
				//TODO: get challenge id

				var cId = idIn.val();
				var ruleId = ruleEditId.val();
				var amount = ruleEditAmount.val();
				var machine = ruleEditMachine.val();
				var timespan = ruleEditTimespan.val();
				var sortNum = ruleEditOrder.val();
				console.log("SAVE, sort: " + sortNum);

				fbExecuteAction({
					sAction : 'saveChallengeRule',
					oAjaxSettings : {
						data : {
							challengeId : cId,
							ruleId : ruleId,
							amount : amount,
							machine : machine,
							timespan : timespan,
							orderNum : sortNum,
							dependency : ruleEditDependency.val()
						},
						success : function(sResponse) {
							var rule = jQuery.parseJSON(sResponse);
							console.log(rule);
							updateChallengeRule(
								rule.id,
								cId,
								rule.orderNum,
								amount,
								machine,
								timespan,
								rule.dependency,
								(ruleId == -1 ? true : false)
							);
							edit_challenge(get_challenge(cId));
						}
					}
				});

				//TODO: send request to save rule and show in list
				ruleEdit.hide();
			});

			btnAddNew.click(function(oEvent) {
				oEvent.preventDefault();
				
				//TODO: send request to add new challenge. request returns the challenge object, put challenge object at end of 'challenges' array.
				var data = "action=saveChallenge&challengeId=-1&name=Untitled&active=0&type=1";
				App.Service.request({
					data: data,
					callback: function(response) {
						//set id in the edit form
						var challenge = jQuery.parseJSON(response);
						challenges.push(challenge);
						idIn.val(challenge.id);
						window.reload("?challengeId=" + challenge.id);
					}
				});

				idIn.val('-1');
				nameIn.val('Untitled');
				amountIn.val('');
				timeIn.val('');

				ruleList.children().remove();
				$("#active_no").attr('checked', 'true');
				addNewTitle.text('Add New Challenge');
				formAddNew.removeClass("hidden");

				showCompType.hide();
				editCompType.show();
			})

			btnCancel.click(function(oEvent) {
				oEvent.preventDefault();
				
				formAddNew.addClass("hidden");

				ruleEditAmount.val('');
				ruleEditMachine.val('');
				ruleEditTimespan.val('');
				ruleEdit.hide();
			});

			btnSave.click(function(oEvent) {
				oEvent.preventDefault();

				// Validation of rules:
				var totalAmount = 0;
				ruleList.children().each(function() {
					totalAmount += parseInt($(this).find('.rule-amount').text(), 10);
				});
				if(totalAmount != 100) {
					alert("The rule totals must add to 100.");
					return;
				}
				var name = nameIn.val();
				if (name == '') {
					errors.text('You must enter a name.');
					return;
				}
				
				var id = idIn.val();
				
				// 0=regular, 1=scavenger, 2=tournament
				var type;
				$('#add-new-form > input[name="ctype"]').each(function() {
					if(this.checked === true) {
						type = this.value.toString();
					}
				});
				var active = $("#active_no").attr("checked") ? '1' : '2';
				
				fbExecuteAction({
					sAction : 'saveChallenge',
					oAjaxSettings : {
						data : {
							challengeId : id,
							name : name,
							type : type,
							active : active
						},
						success : function() {
							window.location.reload();
						}
					}
				});
			});

			//delete challenge
			deleteBtns.click(function(oEvent) {
				oEvent.preventDefault();
				
				var id = $(this).attr('id');

				if (confirm("Are you sure you want to delete this challenge?")) {
					var data = "action=deleteChallenge&challengeId=" + id;
					App.Service.request({
							data: data,
							callback: function(result){
								reload();
							}
					});
				}
			});

			//edit challenge
			editBtns.click(function(oEvent) {
				oEvent.preventDefault();
				
				showCompType.show();
				editCompType.hide();

				var id = $(this).attr('id');
				var challenge = get_challenge(id);
				edit_challenge(challenge);
			});

			deleteBtns.hover(function() {
				$(this).css('background-image', 'url(../images/delete_hover.png)');
			}, function() {
				$(this).css('background-image', 'url(../images/delete.png)');
			});

			editBtns.hover(function() {
				$(this).css('background-image', 'url(../images/page_edit_hover.png)');
			}, function() {
				$(this).css('background-image', 'url(../images/page_edit.png)');
			});

		});
	</script>
</div>
<?php
include('footer.php');
?>