<?php
require_once 'mysql.php';

$success = false;
$error = false;
$email = '';
$token = '';
if(isset($_GET["email"])) {
    $email = $_GET["email"];
}
if(isset($_GET["token"])) {
    $token = $_GET["token"];
}
if(isset($_GET["success"])) {
    $success = true;
}
if(isset($_GET["error"])) {
    $error = true;
}
?>

<html>
<head>
  <link rel="stylesheet" type="text/css" href="css/slot.css" />
  <script src="js/jquery-1.7.min.js"></script>
  <script src="js/jquery.easing.1.3.js"></script>
  <script src="js/slot.js"></script>
  
  <style>
  body { background: -webkit-radial-gradient(rgba(127, 127, 127, 0.5), rgba(127, 127, 127, 0.5) 35%, #899); }
  </style>
</head>

<body>
      
<div class="header">
    <img class="logo col-left" src="./images/app-icon-114x114.png" width="57" height="57" />
    <div class="col-left title">GroupSlots.com - Virtual Slot Machine</div>
</div>
<div class="col-left section" style="padding: 20px; width: 600px;margin-top:10px;">
    <?php if ($error == true) { ?>
        <span style="color: #845;">The given token did not match your email or no longer exists.</span><br/><br/>
    <?php } ?>
    
    <?php if ($success == false) { ?>
    <div class="section-title bold">Register</div>
    <form method="POST" action="admin/service.php" style="margin-top: 10px;">
        <input type="hidden" name="action" value="register-to-group"></input>
        <input type="hidden" name="email" value="<?= $email ?>"></input> 
        <input type="hidden" name="token" value="<?= $token ?>"></input>    
        <span class="label2">Enter a username (required):</span>
        <input type="text" name="username" id="username"></input><br/>
        <span class="label2">Enter your players club card id (optional):</span>
        <input type="text" name="cardid" id="cardid"></input><br/>
        <span class="label2">Enter your facebook id (optional):</span>
        <input type="text" name="fbid" id="fbid"></input><br/>
        
        <div class="fixer" style="height: 10px;"></div>
        <input class="button button-blue" style="padding: 1px 5px 1px 5px; height: 20px; width: 80px;" type="submit" value="Register"></input>
    </form>
    <?php } else { ?>
        <h3> Thank you for registering. You have been placed in a group. </h3>    
    <?php } ?>

</div>