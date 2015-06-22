<?php
$mysqli = new mysqli("localhost", "root", "root", "groupslots");
if (mysqli_connect_errno()) {
  exit('Failure connecting to MySQL due to the following error:' . "\n\n" . mysqli_connect_error());
}
