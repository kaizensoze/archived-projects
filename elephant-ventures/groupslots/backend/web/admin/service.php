<?php
error_reporting(E_ERROR);

require_once 'helper.php';
require_once '../mysql.php';
require_once '../email.php';
require_once '../main.php';

require_once 'ActionManager.php';
require_once 'UserManager.php';
require_once 'GroupManager.php';
require_once 'RewardManager.php';
require_once 'ChallengeManager.php';
require_once 'FacebookHelper.php';
require_once 'MachineManager.php';

function last_insert_id($table) {
    global $mysqli;
    $id = null;
    $res = $mysqli->query("SELECT MAX(ID) as id from " . $table);
    if($res) {
        if ($row = $res->fetch_assoc()) {
            $id = $row['id'];
        }
    } 
    return $id;
}

global $actionMgr;
global $userMgr;
global $groupMgr;
global $rewardMgr;
global $challengeMgr;
global $facebookHelper;

$actionMgr = new ActionManager();
$userMgr = new UserManager();
$groupMgr = new GroupManager();
$rewardMgr = new RewardManager();
$challengeMgr = new ChallengeManager();
$facebookHelper = new FacebookHelper();

if(isset($_REQUEST['action']) === true) {
	$actionMgr->handleAction($_REQUEST['action']);
}