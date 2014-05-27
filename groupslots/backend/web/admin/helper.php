<?php

global $debug;
$debug_to_error_log = false;
$debug = true;


function dlog($msg) {
	global $debug;
	global $debug_to_error_log;

	if ($debug == true) {
		echo $msg;
	}

	if ($debug_to_error_log) {
		error_log("Group Slots:[DEBUG] ".$msg);
	}
}

function gs_error_log($msg) {
	echo $msg;
	error_log($msg);
}

function get_post($key) {
    $val = null;
    if(isset($_POST[$key])) {
        $val = $_POST[$key];
    } else if (isset($_GET[$key])) {
        $val = $_GET[$key];
    }
    return $val;
}

// Dump all contents of a variable, recursively
function debug($mVariable, $bUseVarDump=false) {
	// Capture variable details
	if($bUseVarDump === true) {
		ob_start();
		var_dump($mVariable);
		$sVariableDetails = ob_get_contents();
		ob_end_clean();
	} else {
		$sVariableDetails = print_r($mVariable, true);
	}

	// Output them to the screen
	echo
		'<pre style="background: #D1FDD0; border: 1px solid #32CD32; display: table; padding: 0.5em;">' .
			htmlentities($sVariableDetails, ENT_QUOTES, 'UTF-8') .
		'</pre>';
}

Class log { 
  // 
  const USER_ERROR_DIR = '../logs/errors.log';
  const GENERAL_ERROR_DIR = '../logs/errors.log';

  /* 
   User Errors... 
  */ 
    public function user($msg,$username) 
    { 
		$date = date('d.m.Y h:i:s'); 
		$log = $msg."   |  Date:  ".$date."  |  User:  ".$username."\n"; 
		error_log($log, 3, self::USER_ERROR_DIR); 
    } 
    /* 
   General Errors... 
  */ 
    public function general($msg) 
    { 
		$date = date('d.m.Y h:i:s'); 
		$log = $msg."   |  Date:  ".$date."\n"; 
		error_log($msg, 3, self::GENERAL_ERROR_DIR); 
    } 

} 