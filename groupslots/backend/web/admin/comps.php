<?php
$page = 'comps';
include('header.php');

$rewards = $rewardMgr->getRewards();
?>

<script type="text/javascript">
    var rewards = [
            <?php
                $i = 0;
                $total = count($rewards);
            foreach($rewards as $c) {
                $i++; ?>
                { id: <?php echo $c->id ?>, name: '<?php echo $c->name ?>', amount: <?php echo $c->amount ?>, active: <?php echo $c->active ?>, timespan: '<?php echo $c->timespan ?>',
                    inv_controlled: <?php echo $c->inv_controlled ?>, inv_amount: <?php echo $c->inv_amount ?>, time_created: '<?php echo $c->time_created ?>' }
                <?php
                if ($i != $total) { echo ','; }
            } ?>
        ];
    
    function get_reward(id) {
        for(var c in rewards) {
            var reward = rewards[c];
            if(reward.id == id)
                return reward;            
        }        
        return null;
    }
</script>

<div class="page">

<div class="col-left section">
	<div class="section-title">
		Available Rewards
		<a class="button button-red col-right" id="add-new-comp" href="#">
			Add New Reward
			<img src="../images/plus.png" alt="Plus sign" width="8" height="8" />
		</a>
	</div>
	<table class="table" style="width: 100%">
		<thead>
			<tr class="head">
				<th>Name</th>
				<th>Win/User</th>
				<th>Inventory</th>
				<th>Active?</th>
				<th>&nbsp;</th>
			</tr>
		</thead>
		<tbody>
			<?php foreach($rewards as $c) { ?>
			<tr>
				<td><?= $c->name ?></td>
				<td class="winuser"><?= number_format($c->amount) ?></td>
				<td class="inv"><?= $c->inv_controlled == true ? $c->inv_amount : '-' ?></td>
				<td class="active"><?= $c->active == true ? 'active' : '' ?></td>
				<td>
					<div class="buttons">
						<a href="#" class="edit button" id="<?= $c->id ?>"></a>
						<a href="#" class="delete button"></a>
					</div>
				</td>
			</tr>
			<?php } ?>
		</tbody>
	</table>
</div>

<div class="section col-left" style="width: 400px; margin-left: 20px;">
	<div id="add-new-comp-form" class="hidden">
		<div class="section-title">Add New Reward</div>
		<div class="fixer" style="height: 10px;"></div>
		<input type="hidden" value="-1" id="comp-id" />
		<span class="label" style="width: 120px;">Reward Name:</span>
		<input type="text" style="width: 200px;" id="comp-name" />
		<div class="fixer"></div>
		<span class="label" style="width: 120px;">Win/User:</span>
		<input type="text" style="width: 60px;" id="comp-amount" />
		<div class="fixer"></div>
		<span class="label" style="width: 120px;">Time to Complete:</span>
		<input class="col-left" type="text" id="comp-time" style="width: 60px;" />
		<div class="col-left" style="padding: 2px 0px 0px 5px;">
			<input type="radio" name="time" checked="checked" id="hours" />
			<span class="cb-label">Hours</span>
			<input type="radio" name="time" id="days" />
			<span class="cb-label">Days</span>
		</div>
		<div class="fixer"></div>
		<span class="label" style="width: 120px;">Inventory Controlled:</span>
		<div class="col-left" style="padding: 2px 0px 0px 5px;">
			<input type="radio" name="invControl" id="inv_yes" />
			<span class="cb-label">Yes</span>
			<input type="radio" name="invControl" id="inv_no" checked="checked" />
			<span class="cb-label">No</span>
		</div>
		<div class="fixer"></div>         
		<div id="invQuantity" style="display: none;">
			<span class="label" style="width: 120px;">Quantity:</span>
			<input class="col-left" type="text" id="inv-amount" style="width: 40px;" />
		</div>
		<div class="fixer"></div>
		<span class="label" style="width: 120px;">Active:</span> 
		<input type="radio" name="active" id="active_yes" />
		<span class="cb-label">Yes</span>
		<input type="radio" name="active" id="active_no" checked="checked" />
		<span class="cb-label">No</span>
		<div class="fixer"></div>
		<div class="col-right" style="margin: 8px 10px 0px 0px;">
			<a class="button button-red col-left" id="save" href="#" style="width: 80px; margin-right: 5px;">Save</a>
			<a class="button button-red col-left" id="cancel" href="#" style="width: 80px;">Cancel</a>
		</div>
		<div class="fixer"></div>
		<div class="errors center"></div>
		<div class="fixer" style="height: 20px;"></div>
	</div>

	<script type="text/javascript">
		var btnAddNew;
		
		function reload() {
			window.location.reload();
		}
		
		function edit_reward(reward) {
			btnAddNew = $("#add-new-comp");
			var formAddNew = $("#add-new-comp-form");
			var addNewTitle = $("#add-new-comp-form .section-title");
			addNewTitle.text('Edit Comp');
			
			var idIn = $("#comp-id");
			var nameIn = $("#comp-name");
			var amountIn = $("#comp-amount");
			var timeIn = $("#comp-time");
			
			idIn.val(reward.id);
			nameIn.val(reward.name);
			amountIn.val(reward.amount);
			timeIn.val(reward.timespan);
			if(reward.active) {
				$("#active_yes").attr('checked', true);
			} else {
				$("#active_no").attr('checked', true);
			}
			if(reward.inv_controlled) {
				$("#inv_yes").attr('checked', true);
				$("#invQuantity").show();
				$("#inv-amount").val(reward.inv_amount);
			} else {
				$("#inv_no").attr('checked', true);
				$("#invQuantity").hide();
			}
			//TODO: set hours/days
			
			formAddNew.removeClass("hidden");
		}
		
		$("document").ready(function() {
			btnAddNew = $("#add-new-comp");
			var formAddNew = $("#add-new-comp-form");
			var btnCancel = $("#cancel");
			var btnSave = $("#save");
			var deleteBtns = $(".delete");
			var editBtns = $(".edit");
			var addNewTitle = $("#add-new-comp-form .section-title");
			var showCompType = $(".show_comp_type");
			var editCompType = $(".edit_comp_type");
			var invControlled = $("#inv_yes");
			var invControlledNo = $("#inv_no");
			var invQuantityContainer = $("#invQuantity");
			var invQuantity = $("#inv-amount");
			
			var idIn = $("#comp-id");
			var nameIn = $("#comp-name");
			var amountIn = $("#comp-amount");
			var timeIn = $("#comp-time");
			
			var errors = $(".errors");
			
			btnAddNew.click(function(oEvent) {
				oEvent.preventDefault();
				
				//TODO: clear input fields
				idIn.val('-1');
				nameIn.val('');
				amountIn.val('');
				timeIn.val('');
				
				addNewTitle.text('Add New Comp');
				formAddNew.removeClass("hidden");
				
				showCompType.hide();
				editCompType.show();
			})
			
			btnCancel.click(function(oEvent) {
				oEvent.preventDefault();
				formAddNew.addClass("hidden");
			});
			
			btnSave.click(function(oEvent) {
				oEvent.preventDefault();
				
				var id = idIn.val();
				var name = nameIn.val();
				var amount = amountIn.val();
				var time = timeIn.val();
				var isDays = $("#days").attr("checked") != null;
				var invControlled = $("#inv_yes").attr("checked") != null;
				var invAmount = invQuantity.val();
				if(invAmount == '') invAmount = 0;
				var isActive = $("#active_yes").attr("checked") != null;
				if (name == '' || amount == '' || time == '') {
					errors.text('You must fill in all fields.');
					return;
				}
				
				var data = "action=saveReward&id=" + id + "&name=" + name + "&user_amount=" + amount + "&time=" + time
					+ "&inv=" + invControlled + "&invAmount=" + invAmount + "&active=" + isActive;
				
				App.Service.request({
						data: data,
						callback: function(response){
							window.location.reload();
						}
				});
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
			
			deleteBtns.click(function(oEvent) {
				oEvent.preventDefault();
				
				var li = $(this).parents('li');
				var id = li.attr('id');
				
				if (confirm("Are you sure you want to delete this comp?")) {
					var data = "action=delete-comp&id=" + id;
					App.Service.request({
							data: data,
							callback: function(result){
								reload();
							}
					});
				}
			});
			
			editBtns.click(function(oEvent) {
				oEvent.preventDefault();
				
				showCompType.show();
				editCompType.hide();
				
				var id = $(this).attr('id');
				var reward = get_reward(id);
				edit_reward(reward);
			});
			
			
			invControlled.change(function() {
				invQuantityContainer.show();
			});
			
			invControlledNo.change(function() {
				invQuantityContainer.hide();
			});
		});
	</script>
</div>
<?php
include('footer.php');
?>