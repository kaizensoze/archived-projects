<?php
// Start a session if it hasn't been started already
session_start();

// Includes
require_once '../mysql.php';
require_once 'service.php';

if(isset($page) === false) {
	$page = '';
}
if(isset($loggedin) === false) {
    $loggedin = isset($_SESSION['user']);
}
?>
<!DOCTYPE html>
<html>
    <head>
	<meta charset="UTF-8" />
	
	<title>GroupSlots.com Administrative Control</title>

	<link rel="stylesheet" type="text/css" href="../css/slot.css" />
	<link rel="stylesheet" type="text/css" href="admin.css" />
	<link rel="stylesheet" type="text/css" href="../css/jquery-ui-1.8.16.custom.css" />
	
	<?php
	if(isset($_SESSION['brand'])) {
	    $casinoName = $_SESSION['brand'];
	} else {
	    $casinoName = "mohegansun";
	}
	
	switch ($casinoName) {
	 case 'mohegansun':
	    $casinoNameText = 'Mohegan Sun';
	    break;
	 case 'pechanga':
	    $casinoNameText = 'Pechanga';
	    break;
	 case 'sanmanuel':
	    $casinoNameText = 'San Manuel';
	    break;
	 case 'fantasysprings':
	    $casinoNameText = 'Fantasy Springs';
	    break;
	}
	?>
	
	<link rel="stylesheet" type="text/css" href="brands/<?= $casinoName ?>.css" />

	<script src="../js/jquery-1.7.min.js" type="text/javascript"></script>
        <script src="../js/jquery-ui-1.8.16.custom.min.js" type="text/javascript"></script>
        <script src="../js/date.js" type="text/javascript"></script>
        <script src="../js/slot.js" type="text/javascript"></script>
        <script src="../js/admin.js" type="text/javascript"></script>
        <script src="../js/knockout.js" type="text/javascript"></script>
        <script src="../js/jquery.scrollTo-min.js" type="text/javascript"></script>
    </head>
	<body>
		<div id="admin">
			<div class="header">
				<img class="logo" src="../images/app-icon-114x114.png" alt="Logo" style="height: 57px; width: 57px;" />
				<span class="title">GroupSlots.com Administrative Control</span>
				<span class="login">
				<?php if ($loggedin == true) { ?>
					You are logged in as: <span class="user"><?= $_SESSION['user']['name'] ?></span>
				<a href="#" id="logout" class="logout">Logout</a>
				<?php } ?>
				</span>
				
				<div class="brand" id="brand">
				    <div class="col-left details">
					<span class="name"><?= $casinoNameText ?></span><br/>
					<a href="#" id="change_casino">Change</a>
				    </div>
				    <img class="col-left" src="../images/casino_<?= $casinoName ?>.png"/>
				    
				    <div class="change-brand">
					Choose:
					<select id="brands">
					    <option value="mohegansun" <?= $casinoName == 'mohegansun' ? 'selected' : '' ?>>Mohegan Sun</option>
					    <option value="pechanga" <?= $casinoName == 'pechanga' ? 'selected' : '' ?>>Pechanga</option>
					    <option value="sanmanuel" <?= $casinoName == 'sanmanuel' ? 'selected' : '' ?>>San Manuel</option>
					    <option value="fantasysprings" <?= $casinoName == 'fantasysprings' ? 'selected' : '' ?>>Fantasy Springs</option>
					</select>
					<div class="fixer"></div>
					<div class="button-blue button cancel-btn">Cancel</div>
					<div class="button-blue button change-btn">Change</div>
				    </div>
				</div>
			</div>
			<div class="fixer"></div>
			<ul class="nav">
				<li class="<? if($page == 'comps') echo 'active' ?>"><a href="comps.php">COMPS</a></li>
				<li class="<? if($page == 'challenges') echo 'active' ?>"><a href="challenges.php">CHALLENGES</a></li>
				<li class="<? if($page == 'challenge_instances') echo 'active' ?>"><a href="challenge_instances.php">CHALLENGE INSTANCES</a></li>
				<li class="<? if($page == 'groups') echo 'active' ?>"><a href="groups.php">GROUPS</a></li>
				<li class="<? if($page == 'reports') echo 'active' ?>"><a href="reports.php">REPORTS</a></li>
				<li class="<? if($page == 'rewards') echo 'active' ?>"><a href="rewards.php">REWARDS</a></li>
				<li class="<? if($page == 'messages') echo 'active' ?>"><a href="messages.php">MESSAGES</a></li>
			</ul>
			
			<div class="fixer"></div>