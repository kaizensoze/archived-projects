<?php
$page = 'rewards';
include('header.php');

if(isset($_GET['cardid']) === true) {
	$cardid = $_GET['cardid'];
	$rewards = $GLOBALS['rewardMgr']->getRewardsByCardID($cardid);
	// debug($rewards); exit;
	$player = get_player_by_card_id($cardid);
} else {
	$rewards = $rewardMgr->getRewards();
	$cardid = '';
}
?>
<div class="help-blurb">
	<div class="controls"><a href="#" id="hide">hide</a></div>
	<span class="bold"></span> Use this screen to see which rewards players have redeemed or are currently playing for.
</div>


<div class="page">
		<div class="col-left section">
			<div class="section-title" style="width: 800px;">Rewards</div>
			<div class="fixer"></div>
			<form action="rewards.php" method="get">
				<div class="search">
					<span class="label">Search for Player:</span>
					<input type="text" name="cardid" placeholder="Card ID"/>
					<input type="submit" class="button-red submit" value="Search" />
				</div>
			</form>
		</div>
		<div class="fixer"></div>
		<div class="results" style="margin-top: 15px;">
			<?php if(isset($player)) { ?>
			<span class="label2 bold">Player:</span>
			<?= $cardid ?>
			<br/>
			<span class="label2 bold">Name:</span>
			<?= $player->name ?>
			<div class="fixer" style="height: 7px;"></div>
			<span class="label2 bold">Available Awards</span>
			<ul>
				<?php
				if(count($rewards['pending']) === 0) {
					echo '<li>None</li>';
				} else {
					foreach($rewards['pending'] as $r) { ?>
				<li>
					<span class="reward-name" style="font-weight: bold"><?= $r['name'] ?></span>
					<span style="font-size: 10pt">
						(Redemption Code: <?= $r['redemption_code'] ?>)
					</span>
					<a
						class="button button-red redeem"
						href="#"
						id="<?= $r['redemption_id'] ?>"
						style="width: 80px; position: relative; top: -1px;"
					>Redeem</a>
				</li>
				<?php } } ?>
			</ul>
			<div class="fixer" style="height: 10px;"></div>
			<span class="label2 bold">Redeemed Awards</span>
			<ul>
				<?php
				if(count($rewards['redeemed']) === 0) {
					echo '<li>None</li>';
				} else {
					foreach($rewards['redeemed'] as $r) { ?>
				<li>
					<span class="reward-name" style="font-weight: bold"><?= $r['name'] ?></span>
					<span style="font-size: 10pt">
						(Redemption Code: <?= $r['redemption_code'] ?>)
					</span>
				</li>
				<?php } } ?>
			</ul>
			<?php
			} else {
				if(isset($_GET['cardid']) === true) {
					echo 'Player not found.';
				}
			}
			?>
		</div>
		<script type="text/javascript">
			$(document).ready(function() {
				$('.redeem').click(function(oEvent) {
					oEvent.preventDefault();
					
					var jThis = $(this);
					if(confirm('Are you sure you want to redeem "' + jThis.prev().prev().text() + '"?')) {
						fbExecuteAction({
							sAction : 'redeem-reward',
							oAjaxSettings : {
								data : 'rid=' + jThis.attr('id'),
								success : function(data) {
									window.location.reload();
								}
							}
						});
					}
				});
			});
		</script>
	<?php include('footer.php'); ?>