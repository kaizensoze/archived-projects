<?php
$page = 'login';
$loggedin = false;

include('header.php');
?>

<div class="page col-center center" style="width: 300px;">

<span style="padding-bottom:10px; display: block;">Login:</span>
<div class="fixer"></div>
<span class="label" style="width: 100px;">Username:</span><input type="text" class="col-left"></input>
<div class="fixer"></div>
<span class="label" style="width: 100px;">Password:</span><input type="text" class="col-left"></input>
<div class="fixer" style="height: 5px;"></div>
<a class="button button-blue" href="reports.php" style="float: right; margin-right: 40px; width: 70px;">Login</a>

</div>

<?php
include('footer.php');

?>