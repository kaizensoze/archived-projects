<?php
$page = 'links';
include('header.php');
?>
<style type="text/css">
	.page > .section > ol > li {
		margin-bottom: 1em;
		list-style-type: decimal;
	}
</style>
<div class="page">
	<div class="section">
		<h1>Steps to prep this environment</h1>
		<ol>
			<li>
				Start a group:
				<a href="service.php?action=tryJoinGroup&userA=Joe&userB=Donna">service.php?action=tryJoinGroup&userA=Joe&userB=Donna</a>
			</li>
			<li>
				Start a challenge for the group:
				<a href="service.php?action=startChallenge&group_id=1&challenge_qty=1&reward_id=1&challenge_type=1&challenge_id=2">service.php?action=startChallenge&group_id=1&challenge_qty=1&reward_id=1&challenge_type=1&challenge_id=2</a>
			</li>
		</ol>
		<h1>Other actions</h1>
		<ol>
			<li>
				Register points for player with card ID 13001300 (Joe):
				<a href="service.php?action=registerPoints&cardId=13001300&amount=100&machine_id=1">service.php?action=registerPoints&cardId=13001300&amount=100&machine_id=1</a>
			</li>
			<li>
				Add another player to the group:
				<a href="service.php?action=tryJoinGroup&userA=Joe&userB=Mark">service.php?action=tryJoinGroup&userA=Joe&userB=Mark</a>
			</li>
			<li>
				Delete the group:
				<a href="service.php?action=deleteGroupByID&group_id=1">service.php?action=deleteGroupByID&group_id=1</a>
			</li>
		</ol>
	</div>
</div>
<?php
include('footer.php');
?>