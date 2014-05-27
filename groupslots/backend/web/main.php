<?php

function getNameInfo($card_id) {
	global $mysqli;

	$query = "
		SELECT
			u.name,
			u.username
		FROM
			player p
			JOIN user u ON (p.user_id = u.id)
		WHERE
			p.card_id = ?
	";

	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $card_id);
	$pstmt->execute();
	$pstmt->bind_result($name, $username);
	$pstmt->fetch();
	$pstmt->close();
	
	$result = array();
	$result["name"] = $name;
	$result["username"] = $username;
	return $result;
}

function setFbId($card_id, $fb_id) {
	global $mysqli;
	
	$query = "UPDATE user SET facebook_id = ? WHERE id = (SELECT user_id FROM player where card_id = ?)";
	
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("ss", $fb_id, $card_id);
	$pstmt->execute();
	$pstmt->close();
}
function setFbIdForUser($userid, $fbid) {
    global $mysqli;
	
	$query = "UPDATE user SET facebook_id =".$fbid." WHERE id = ".$userid;
    $result = $mysqli->query($query);
}

function setCompRedeemCodes($group_id) {
    global $mysqli;
    
    $group = get_group($group_id);
    $players = getPlayersInGroup($group_id);
    
    foreach($players as $player) {
        //create a redemption code for this unique group/player/comp
        $code = hash("crc32", (string)$group->id + (string)$player->id + (string)$group->comp->id, false);
        
        $query = "INSERT INTO redeem_codes (player_id, pgroup_id, comp_id, code, redeemed)
                VALUES (?,?,?,?,0)";
                echo $query;
        $pstmt = $mysqli->prepare($query);
        $pstmt->bind_param("iiis", $player->id, $group_id, $group->comp->id, $code);
        $pstmt->execute();
        $pstmt->close();
    }
    
    print_r($players);
}

function getUpdate($group_id) {
	global $mysqli;
	
	$query = "SELECT amount FROM pgroup_session WHERE pgroup_id = ?";
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $group_id);
	$pstmt->execute();
	$pstmt->bind_result($amount);
	$pstmt->fetch();
	$pstmt->close();
	
	$query = "
		SELECT
			c.id,
			c.name,
			c.challenge_type,
			gc.challenge_quantity,
			(gc.tier_num+1),
			(SELECT COUNT(*) FROM challenge_rules cr2 WHERE cr2.challenge_id = cr.challenge_id),
			gc.balance,
			gc.target,
			(select timediff( (select addtime(gc.time_created, cr.timespan)), CURRENT_TIMESTAMP )),
			mt.name,
			r.name
		FROM
			group_challenges gc
			JOIN challenge c ON (gc.challenge_id = c.id)
			JOIN challenge_rules cr ON (gc.challenge_id = cr.challenge_id AND gc.tier_num = cr.order_num)
			JOIN machine_type mt ON (cr.machine = mt.type)
			JOIN reward r ON (gc.reward_id = r.id)
		WHERE
			group_id = ?
		ORDER BY
			gc.tier_num DESC
		LIMIT 1
	";
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $group_id);
	$pstmt->execute();
	$pstmt->bind_result(
		$challengeId,
		$challengeName, 
		$challengeType,
		$challengeShareType, 
		$challengeStage, 
		$challengeNumStages,
		$challengeBalance, 
		$challengeTarget,
		$challengeTimeRemaining,
		$machineName,
		$rewardName
	);
	$pstmt->fetch();
	$pstmt->close();
	
	$fbIdsInGroup = getFacebookIdsInGroup($group_id);
	
	$result = array();
	$result["challenge_id"] = $challengeId;
	$result["challenge_name"] = $challengeName;
	$result["challenge_type"] = $challengeType;
	$result["challenge_share_type"] = $challengeShareType;
	$result["challenge_stage"] = $challengeStage;
	$result["challenge_num_stages"] = $challengeNumStages;
	$result["challenge_balance"] = $challengeBalance;
	$result["challenge_target"] = $challengeTarget;
	$result["challenge_time_remaining"] = $challengeTimeRemaining;
	$result["machine_name"] = $machineName;
	$result["reward_name"] = $rewardName;
	$result["fb_ids"] = $fbIdsInGroup;
	
	return $result;
}

function getComps() {
	global $mysqli;

	$comps = array();
	
	$query = "SELECT name FROM comp";
	
	$result = $mysqli->query($query);
	if ($result) {
		while ($obj = $result->fetch_object()) {
			array_push($comps, $obj->name);
		}
	}
	$result->close();
	
	return $comps;
}

function setComp($group_id, $comp_name) {
    echo 'setComp' . $group_id . ', ' . $comp_name;
	global $mysqli;
	
    //INSERT INTO pgroup_comps (pgroup_id, comp_id, initial_group_size, increment_amount, amount) VALUES (
		//	?,
		//	(SELECT id FROM comp WHERE name = ?),
		//	(SELECT COUNT(*) FROM pgroup_players WHERE pgroup_id = ?),
		//	(SELECT (SELECT amount FROM comp WHERE name = ?) / (SELECT COUNT(*) FROM pgroup_players WHERE pgroup_id = ?)),
		//	(SELECT amount FROM comp WHERE name = ?)
		//)
        
    $gid = $group_id;
	$query = "
        INSERT INTO pgroup_comps (pgroup_id, comp_id, initial_group_size, increment_amount, amount) VALUES (
			" . $gid . ",
			(SELECT id FROM comp WHERE name = '" . $comp_name . "'),
			(SELECT COUNT(*) FROM pgroup_players WHERE pgroup_id = " . $gid . "),
			(SELECT amount FROM comp WHERE name = '" . $comp_name . "'),
            (SELECT (SELECT amount FROM comp WHERE name = '" . $comp_name . "') * (SELECT COUNT(*) FROM pgroup_players WHERE pgroup_id = " . $gid . "))
		)
	";
	
    echo $query;
	//$pstmt = $mysqli->prepare($query);
	//$pstmt->bind_param("ssssss", $group_id, $comp_name, $group_id, $comp_name, $group_id, $comp_name);
	//$pstmt->execute();
	//$pstmt->close();
	$mysqli->query($query);
	
    echo 'here3';
	$query ="UPDATE pgroup_session SET amount = 0 WHERE pgroup_id = ?";
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $group_id);
	$pstmt->execute();
	$pstmt->close();
    echo 'here4';
	
	// postToWall of members of group
	$wall_text = "My group has selected " . $comp_name . ". #GroupSlots";
	$facebook_ids = getFacebookIdsInGroup($group_id);
	foreach($facebook_ids as $facebook_id) {
		postToWall($facebook_id, $wall_text);
	}
}


function getPlayerRewards($card_id) {
	global $mysqli;
	
	$query = "
		SELECT
			rw.name,
			r.id,
			r.code,
			r.redeemed
		FROM
			redeem_codes r
            JOIN reward rw ON (r.reward_id = rw.id)
		WHERE
			r.player_id = (SELECT id FROM player WHERE card_id = ?)
	";
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $card_id);
	$pstmt->execute();
	$pstmt->bind_result($reward_name, $redeem_id, $redeem_code, $redeemed);
	$result_string = "";
	while ($pstmt->fetch()) {
		$result_string .= $reward_name . ":" . $redeem_id . ":" . $redeem_code . ":" . $redeemed . ";";
	}
	$result_string = rtrim($result_string, ";");
	$pstmt->close();

	return $result_string;
}

function resetAmount($group_id) {
	global $mysqli;

	$query = "UPDATE pgroup_session SET amount = 0 WHERE pgroup_id = ?";

	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $group_id);
	$pstmt->execute();
	$pstmt->close();
}


function getFbUsers() {
	global $mysqli;
	
	$fb_ids = array();
	
	$query = "SELECT DISTINCT facebook_id FROM user WHERE facebook_id IS NOT NULL";
	
	$result = $mysqli->query($query);
	if ($result) {
		while ($obj = $result->fetch_object()) {
			array_push($fb_ids, $obj->facebook_id);
		}
	}
	$result->close();
	
	return $fb_ids;
}

function getPlayerName($card_id) {
	global $mysqli;
	
	$query = "
		SELECT
			u.name
	    FROM
	    	user u
	    	JOIN player p on (u.id = p.user_id)
		WHERE
			p.card_id = ?
	";
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $card_id);
	$pstmt->execute();
	$pstmt->bind_result($name);
	$pstmt->fetch();
	$pstmt->close();
	
	return $name;
}

function getDeviceTokensInGroup($group_id, $card_id_to_exclude) {
	global $mysqli;
	
	$device_tokens = array();
	
	$query = "
		SELECT DISTINCT
			device_token
	    FROM
	    	pgroup_players pg
	        JOIN player p ON (pg.player_id = p.id)
			JOIN user u ON (p.user_id = u.id)
		WHERE
			pg.pgroup_id = ?
			AND u.device_token IS NOT NULL
			AND p.card_id != ?
	";
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("ss", $group_id, $card_id_to_exclude);
	$pstmt->execute();
	$pstmt->bind_result($token);

	while ($pstmt->fetch()) {
		array_push($device_tokens, $token);
	}
	$pstmt->close();

	return $device_tokens;
}

function getAllDeviceTokens() {
    global $mysqli;
	
	$device_tokens = array();
	
	$query = "
		SELECT DISTINCT
			device_token
	    FROM
	    	pgroup_players pg
	        JOIN player p ON (pg.player_id = p.id)
			JOIN user u ON (p.user_id = u.id)
		WHERE
            u.device_token IS NOT NULL
			AND p.card_id != -1 AND p.card_id IS NOT NULL
	";
	$pstmt = $mysqli->prepare($query);
	$pstmt->execute();
	$pstmt->bind_result($token);

	while ($pstmt->fetch()) {
		array_push($device_tokens, $token);
	}
	$pstmt->close();

	return $device_tokens;
}

function getFacebookIdsInGroup($group_id) {
	global $mysqli;
	
	$facebook_ids = array();
	
	$query = "
			SELECT DISTINCT
				u.facebook_id
		    FROM
		    	pgroup_players pg
		        JOIN player p ON (pg.player_id = p.id)
				JOIN user u ON (p.user_id = u.id)
			WHERE
				pg.pgroup_id = ?
		";
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $group_id);
	$pstmt->execute();
	$pstmt->bind_result($facebook_id);
	
	while ($pstmt->fetch()) {
		array_push($facebook_ids, $facebook_id);
	}
	$pstmt->close();
	
	return $facebook_ids;
}

function pushRuleWin($group_id) {
    error_log("Pushing rule win");
    $device_tokens = getDeviceTokensInGroup($group_id, -1);
    if (!empty($device_tokens)) {
	$push = initPush();
	$message = createMessage($device_tokens, "rule-win", "Stage completed!");
	pushMessage($push, $message);
    }
}

function pushGroupWin($group_id) {
    error_log("Pushing group win");
	$device_tokens = getDeviceTokensInGroup($group_id, -1);
	if (!empty($device_tokens)) {
		$push = initPush();
		$message = createMessage($device_tokens, "group-win", "Goal reached!");
		pushMessage($push, $message);
	}
	
	$wall_text = "My group just won! #GroupSlots";
	
	$facebook_ids = getFacebookIdsInGroup($group_id);
	foreach ($facebook_ids as $facebook_id) {
// 		postToWall($facebook_id, $wall_text);  //TODO: uncomment
	}
}

function pushPlayerWin($card_id, $group_id, $amount) {
    error_log("Pushing player win");
	global $mysqli;
	
	$name = getPlayerName($card_id);
	$text = $name . " won $" . $amount . "!";
	
	$device_tokens = getDeviceTokensInGroup($group_id, $card_id);
	if (!empty($device_tokens)) {
	    error_log("Init'ing push and sending...");
		$push = initPush();
		error_log("Done");
		error_log("Creating message");
		$message = createMessage($device_tokens, "player-win", $text);
		error_log("Pushing message");
		pushMessage($push, $message);
		error_log("Done.");
	}
	
	// get facebook_id from card_id
	$query = "
		SELECT
			u.facebook_id
		FROM
			user u
			JOIN player p ON (u.id = p.user_id)
		WHERE
			p.card_id = ?
	";
	
	$pstmt = $mysqli->prepare($query);
	
	$pstmt->bind_param("s", $card_id);
	$pstmt->execute();
	$pstmt->bind_result($facebook_id);
	$pstmt->fetch();
	$pstmt->close();
	
// 	$wall_text = "I just won $" . $amount . "! #GroupSlots";
// 	postToWall($facebook_id, $wall_text);
}

function initPush() {
	date_default_timezone_set('America/New_York');

	$push = new ApnsPHP_Push(
		ApnsPHP_Abstract::ENVIRONMENT_SANDBOX,
		dirname(__FILE__) . '/certs/Certificates.pem'
	);
	$push->setRootCertificationAuthority(dirname(__FILE__) . '/certs/entrust_2048_ca.pem');
	return $push;
}

function createMessage($device_tokens, $message_id, $text) {
	$message = new ApnsPHP_Message();
	
	foreach ($device_tokens as $token) {
		$message->addRecipient($token);
	}
	
	$message->setCustomIdentifier($message_id);
	$message->setBadge(1);
	$message->setSound($message_id);
	$message->setText($text);
	$message->setExpiry(30);
	
	return $message;
}

function pushMessage($push, $message) {
    try {
	$push->connect();
	$push->add($message);
	$push->send();
	$push->disconnect();
    } catch (Exception $e) {
	error_log("Error pushing message: ".$e);
    }
}

function getPlayersInGroup($group_id) {
    global $mysqli;
    $players = array();
    
	$query = <<<SQL
SELECT
	p.id,
	p.user_id,
	p.casino_id,
	p.card_id,
	u.username,
	u.name,
	u.facebook_id,
	(SELECT SUM(win_amount) FROM player_session ps WHERE ps.player_id=p.id) as sum
FROM
	pgroup_players pp 
	JOIN player p ON pp.player_id = p.id
	JOIN user u ON p.user_id = u.id
WHERE
	pp.pgroup_id = $group_id
SQL;
    $result = $mysqli->query($query);

	if ($result) { 
        while ($row = $result->fetch_assoc()) {
            $player = new Player();
            $player->id = $row['id'];
            $player->card_id = $row['card_id'];
            $player->casino_id = $row['casino_id'];
            $player->facebook_id = $row['facebook_id'];
			$player->group_id = $group_id;
            $player->name = $row['name'];
            $player->sum = $row['sum'];
            $player->username = $row['username'];
            $player->user_id = $row['user_id'];
            array_push($players, $player);
        }
    }
    
    return $players;
}

function register_to_group($email, $token, $username, $cardid, $fbid) {
    global $url;
    global $mysqli;
    
    //echo 'register: ' . $username . ' token: ' . $token;
    
    $query = "SELECT * FROM invite_tokens WHERE token='" . $token . "'";
    $result = $mysqli->query($query);
    
	if ($result) { 
        if ($row = $result->fetch_assoc()) {
            $dbEmail = $row['email'];
            $inviter_id = $row['inviter_id'];
            $token = $row['token'];
            $time_created = $row['time_created'];
            
            if($dbEmail != $email) {
                echo 'Invalid email';
                return;
            }
            
            //same casino as the inviter
            $inviter = get_player($inviter_id);
            $casino = get_casino($inviter->casino_id);
            
            $card_id = '';
            $userId = register($username, $casino, $cardid);
            setFbIdForUser($userId, $fbid);
            
            $newUser = get_player($userId);
            //echo 'new username: ' . $newUser->username;
            
            findGroup($inviter->username, $newUser->username);
            
            //findGroup();
            
            //join up this new email guy with inviter_ids group
            //$groupId = $this->find_user_group($inviter_id);
        
            //token consumed
            $query = "DELETE FROM invite_tokens WHERE token='" . $token . "'";
            $result = $mysqli->query($query);
            
            header('Location: ' . $url . 'register.php?success=true');
        } else {
            header('Location: ' . $url . 'register.php?token=' . $token . '&email=' . $email . '&error=true');
        }
    }
}

function get_app_messages() {
    global $mysqli;
    $messages = array();
    
    $query= "SELECT * FROM app_messages";
    $result = $mysqli->query($query);

	if ($result) {
        while ($row = $result->fetch_assoc()) {
            $msg = new AppMessage();
            $msg->id = $row['id'];
            $msg->message = $row['message'];
            $msg->is_active = $row['is_active'];
            $msg->time_created = $row['time_created'];
            array_push($messages, $msg);
        }
    }
    $result->close();
    
    return $messages;
}

function getMessages() {
	global $mysqli;
	
	$query = "SELECT * FROM app_messages WHERE is_active = 1";
	$result = $mysqli->query($query);
	$messages = array();
	if ($result) {
		while ($row = $result->fetch_assoc()) {
			$msg = $row['message'];
			array_push($messages, $msg);
		}
	}
	$result->close();
	
	$msg_result = array();
	$msg_result["messages"] = $messages;
	
	return $msg_result;
}

function submit_app_message($msg, $notification, $scroll) {
    global $mysqli;
    
    $time = gmdate("Y-m-d H:i:s", time());
    //store in database if it's a scroll message
    if($scroll == true) {
        $query = "INSERT INTO app_messages (message, is_active, time_created)
                VALUES ('".$msg."', 1, '".$time."')";
        
        $result = $mysqli->query($query);
    }
	
    //send notification to everyone with this message
    if($notification == true) {
        $device_tokens = getAllDeviceTokens();
        echo 'sending to devices: ';
        echo print_r($device_tokens);
        if (!empty($device_tokens)) {
	   $push = initPush();
           $message = createMessage($device_tokens, "general-notification", $msg);
	    pushMessage($push, $message);
        }
    }
}

function activate_message($mid) {
    global $mysqli;
    
    $query = "UPDATE app_messages SET is_active=1 WHERE id=" . $mid;        
    $result = $mysqli->query($query);
}

function deactivate_message($mid) {
    global $mysqli;
    
    $query = "UPDATE app_messages SET is_active=0 WHERE id=" . $mid;
    $result = $mysqli->query($query);
}

function delete_message($mid) {
    global $mysqli;
    
    $query = "DELETE FROM app_messages WHERE id=" . $mid;
    $result = $mysqli->query($query);
}


function get_player($userid) { //just returns the user id 
    global $mysqli;
    $player = null;
    
    $query = "SELECT p.id, p.user_id, p.casino_id, p.card_id, u.username ".
                "FROM player p " .
                "JOIN user u ON u.id=p.user_id ".
                "WHERE user_id=" . $userid;
    $result = $mysqli->query($query);

	if ($result) { 
        if ($row = $result->fetch_assoc()) {
            $player = new Player();
            $player->id = $row['id'];
            $player->user_id = $row['user_id'];
            $player->casino_id = $row['casino_id'];
            $player->card_id = $row['card_id'];
            $player->username = $row['username'];
        }
    }
    
    return $player;
}

function invite_email($email, $userId) {
    global $url;
    global $mysqli;
    
    //echo $email . ": " . $userId;
    
    $time = gmdate("Y-m-d H:i:s", time());
    $md5 = md5($time . $email . $userId);
    //echo $md5;
    
    $query= "INSERT INTO invite_tokens (email, inviter_id, token, time_created) " .
            "VALUES (?,?,?,?)";
            //echo $query;
    
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("siss", $email, $userId, $md5, $time);
	$pstmt->execute();

	$pstmt->close();
    
    $joinUrl = $url . "admin/service.php?action=join-email%26invitee_email=" . $email . "%26invitee_token=" . $md5;
    //echo $joinUrl;
    
    $data = "recipient_email=" . $email . "&template=groupslots_trigger" . "&organization=Groupslots" . 
            "&actor_name=GroupSlots&actor_email=noreply@groupslots.com" . "&url=" . $joinUrl;
    echo $data;
    
    $serviceUrl = "http://lists.groundwavemailer.com/components/insert/send_to_friend/";
    $response = do_post_request($serviceUrl, $data);
    echo $response;
    
    echo '<a href="' . $joinUrl . '">' . $joinUrl . '</a>';
    
    //echo print_r($result);
}

function join_email($email, $token) {
    echo 'join email';
    global $url;
    global $mysqli;
    
    $query = "SELECT email, token FROM invite_tokens WHERE token='" . $token . "'";
    $result = $mysqli->query($query);

	if ($result) {
        if ($row = $result->fetch_assoc()) {
            $dbEmail = $row['email'];
            if($dbEmail != $email) {
                echo 'Emails do not match';
                return;
            }
            header('Location: ' . $url . 'register.php?email='.$email .'&token=' . $token);
            return;
        } else {
            echo 'token doesn\'t exist';
            return false;
        }
    } else {
        //ERROR: token didn't exist (already used)
        return false;
    }
    return true;
}

function reset_data() {
    chdir('../../db');
    exec("php migrate.php root -1", $response, $returnVal);
    exec("php migrate.php root", $response, $returnVal);
}

function get_active_users() {
    global $mysqli;
    $activeUsers = 0;
    
    $events = array();
    
    $query = "SELECT count(*) as count FROM pgroup_players";
    $result = $mysqli->query($query);

	if ($result) {
	    if ($row = $result->fetch_assoc()) {
            $activeUsers = $row['count'];
        }
    }
    
    return $activeUsers;
}

function get_events() {
    global $mysqli;
    
    $events = array();
    
    $query = "
		SELECT ps.id, ps.player_id as playerId, ps.win_amount, ps.time_created, u.name as player_name, u.username, pp.pgroup_id
        FROM player_session ps
        INNER JOIN player p ON p.id = ps.player_id
        INNER JOIN user u ON u.id = p.user_id
        INNER JOIN pgroup_players pp ON pp.player_id = ps.player_id
        ORDER BY time_created desc";

	$result = $mysqli->query($query);

	if ($result) {
	    while ($row = $result->fetch_assoc()) {
            $event = new Event();
            $event->id = $row['id'];
            $event->player_id = $row['playerId'];
            $event->win_amount = $row['win_amount'];
            $event->time_created = $row['time_created'];
            $event->player_name = $row['player_name'];
            $event->username = $row['username'];
            $event->group_id = $row['pgroup_id'];
            
	    	array_push($events, $event);
	    }
	    $result->close();
	}
    
    return $events;	
}

function get_rewards() {
    global $mysqli;
    
    $comps = array();
    $query = "
		SELECT
			c.id, c.name, c.description, c.amount, c.time_limit, ps.amount as earned
        FROM comp c INNER JOIN pgroup_comps pc ON pc.comp_id=c.id
        INNER JOIN pgroup_session ps ON ps.pgroup_id=pc.pgroup_id
	";
    
	$result = $mysqli->query($query);
    
	if ($result) {
	    while ($row = $result->fetch_assoc()) {
            $comp = new Comp();
            $comp->id = $row['id'];
            $comp->name = $row['name'];
            $comp->description = $row['description'];
            $comp->user_amount = $row['amount'];
            $comp->timespan = $row['time_limit'];
            if($comp->timespan == null || $comp->timespan == '')
                $comp->timespan = 0;
            $earned = $row['earned'];
            
            $comp->reached = false;
            if($comp->user_amount - $earned <= 0)
                $comp->reached = true;
            
	    	array_push($comps, $comp);
	    }
	    $result->close();
	}
    
    return $comps;	
}

function get_comps() {
    global $mysqli;
    
    $comps = array();
    $query = "
		SELECT
			c.id, c.name, c.description, c.amount, c.time_limit
        FROM comp c
	";
    

	$result = $mysqli->query($query);


	if ($result) {
	    while ($row = $result->fetch_assoc()) {
            $comp = new Comp();
            $comp->id = $row['id'];
            $comp->name = $row['name'];
            $comp->description = $row['description'];
            $comp->user_amount = $row['amount'];
            $comp->timespan = $row['time_limit'];
            if($comp->timespan == null || $comp->timespan == '')
                $comp->timespan = 0;
            
	    	array_push($comps, $comp);
	    }
	    $result->close();
	}
    
    return $comps;	
}

function get_comp($id) {
    global $mysqli;
    
    $comp = null;
    $query = "
		SELECT
			id, name, description, amount, time_limit
        FROM comp where id = " . $id;

	$result = $mysqli->query($query);

	if ($result) {
	    while ($row = $result->fetch_assoc()) {
            $comp = new Comp();
            $comp->id = $row['id'];
            $comp->name = $row['name'];
            $comp->description = $row['description'];
            $comp->user_amount = $row['amount'];
            $comp->timespan = $row['time_limit'];
            if($comp->timespan == null || $comp->timespan == '')
                $comp->timespan = 0;
	    }
	    $result->close();
	}
    
    return $comp;	
}
    
function save_comp() {
    global $mysqli;
	
	try {
		$id = $_POST["id"];
		$name = $_POST["name"];
		$description = "";
		$user_amount = $_POST["user_amount"];
		$timespan = $_POST["timespan"];
		$isDays = $_POST["is_days"];
		$invControlled = $_POST["inv"];
		$invAmount = $_POST["invAmount"];
	} catch(Exception $ex) {
		echo 'exc: ' . $ex->getMessage();
	}

    $query = '';
    if ($id == '-1') {
        $query = "INSERT INTO comp (name, description, amount, time_limit, inv_controlled, inv_amount) VALUES
                ('" . $name . "', '" . $description . "', " . $user_amount . ", " . $timespan . ", " . $invControlled . ", " . $invAmount . ")";
    } else {
        $query = "UPDATE comp SET name='" . $name . "', description='" . $description . "', amount=" . $user_amount . ", time_limit=" . $timespan .
            ", inv_controlled=" . $invControlled . ", inv_amount=" . $invAmount .
            " WHERE id=" . $id;
    }
    
    $result = $mysqli->query($query);   
}

function delete_comp() {
    global $mysqli;
    
    $id = $_POST["id"];
    $query = "DELETE FROM comp WHERE ID=" . $id;
    $result = $mysqli->query($query);
}

function get_group($id) {
   global $mysqli;
    
    $group = null;
	$query = <<<SQL
SELECT
	pg.id,
	pg.comp_id,
	pg.initial_group_size,
	pg.increment_amount,
	pg.amount AS target,
	pg.time_created,
	(SELECT COUNT(*) FROM pgroup_players WHERE pgroup_id=pg.id) AS curr_group_size,
	c.name,
	c.description,
	c.amount,
	c.time_limit,
	ps.amount AS balance
FROM
	pgroup_comps pg
	INNER JOIN comp c ON c.id = pg.comp_id
	INNER JOIN pgroup_session ps ON ps.pgroup_id = pg.pgroup_id
WHERE
	pg.id = $id
SQL;

	$result = $mysqli->query($query);

	if ($result) {
	    if ($row = $result->fetch_assoc()) {
            $group = new Group();
            $group->id = $row['id'];
            $group->comp_id = $row['comp_id'];
            $group->initial_group_size = $row['initial_group_size'];
            $group->curr_group_size = $row['curr_group_size'];
            $group->increment_amount = $row['increment_amount'];
            $group->balance = $row['balance'];
            $group->target = $row['target'];
            $group->date_start = new DateTime($row['time_created']);
            $group->date_end = new DateTime($row['time_created']);
            
            $group->comp = get_comp($group->comp_id);
            
            $group->player_ids = get_players_for_group($group->id);
	    }
	    $result->close();
	}
    
    return $group;
}

function get_casino($id) {
    global $mysqli;
    
    $query = "SELECT name from casino where id=" . $id;
	$result = $mysqli->query($query);
    $name;
    
	if ($result) {
	    if ($row = $result->fetch_assoc()) {
            $name = $row['name'];
        }
    }
    
    return $name;
}



function get_player_by_card_id($cardid) {
    global $mysqli;
    $player = null;
    
    $query = "SELECT p.id, p.user_id, p.casino_id, p.card_id, u.username, u.name
                FROM pgroup_players pp 
                JOIN player p ON pp.player_id=p.id
                JOIN user u ON u.id=p.user_id 
                WHERE p.card_id=" . $cardid;
                
    $result = $mysqli->query($query);

	if ($result) { 
        if ($row = $result->fetch_assoc()) {
            $player = new Player();
            $player->id = $row['id'];
            $player->user_id = $row['user_id'];
            $player->casino_id = $row['casino_id'];
            $player->card_id = $row['card_id'];
            $player->username = $row['username'];
            $player->name = $row['name'];
        }
    }
    
    return $player;
}

function redeem_reward($rid) {
    global $mysqli;
    $query = "UPDATE redeem_codes SET redeemed=1 WHERE id=" . $rid;
    
    $result = $mysqli->query($query);
}

function get_players_for_group($id) {
    global $mysqli;
    
    $players = array();
    
    $query = "
		SELECT DISTINCT u.facebook_id,
        (SELECT SUM(win_amount) FROM player_session ps WHERE ps.player_id=p.id) as sum
        FROM pgroup_players pp INNER JOIN
        player p ON p.id = pp.player_id INNER JOIN
        user u ON u.id = p.user_id INNER JOIN
        pgroup_comps pc ON pc.pgroup_id = pp.pgroup_id
        WHERE pp.pgroup_id=" . $id;

	$result = $mysqli->query($query);

	if ($result) {
	    while ($row = $result->fetch_assoc()) {
            $fbid = $row['facebook_id'];
            $sum = $row['sum'];
            $players[$fbid] = $sum;
        }
    }
    
    return $players;
}

function find_user_group($userId) {
    global $mysqli;
    $query = "SELECT pgroup_id FROM pgroup_players pp " .
                "JOIN player p ON p.id=pp.player_id " .
                "JOIN user u ON u.id=p.user_id " .
                "WHERE u.id=" . $userId;
    
	$result = $mysqli->query($query);

	if ($result) {
	    if ($row = $result->fetch_assoc()) {
            $groupId = $row['pgroup_id'];
            return $groupId;
        }
    }
    
    return null;
}

function get_reward_details($cardid) {
    global $mysqli;
    $results = array();
    
    $query = "SELECT r.id, r.player_id, r.pgroup_id, r.comp_id, r.code, r.redeemed, p.card_id, c.name
            FROM redeem_codes r
            JOIN player p ON p.id=r.player_id
            JOIN comp c ON c.id=r.comp_id
            WHERE p.card_id=" . $cardid;
    
	$result = $mysqli->query($query);
    if ($result) {
	    while ($row = $result->fetch_assoc()) {
            $r = new Redemption();
            $r->id = $row['id'];
            $r->player_id = $row['player_id'];
            $r->group_id = $row['pgroup_id'];
            $r->comp_id = $row['comp_id'];
            $r->code = $row['code'];
            $r->redeemed = $row['redeemed'];
            $r->comp = get_comp($r->comp_id);
            
            array_push($results, $r);
        }
    }
    
    return $results;
}

function get_groups_for_reward_page() {
    global $mysqli;
    
    $groups = array();
    $query = "
		SELECT pg.pgroup_id as id, pg.comp_id, pg.initial_group_size, pg.increment_amount, pg.amount as target, pg.time_created,
            (SELECT COUNT(*) FROM pgroup_players WHERE pgroup_id=pg.pgroup_id) as curr_group_size,
            c.name, c.description, c.amount, c.time_limit, ps.amount as balance
            
        FROM pgroup_comps pg inner join
        comp c on c.id=pg.comp_id inner join
        pgroup_session ps on ps.pgroup_id=pg.pgroup_id
	";

	$result = $mysqli->query($query);


	if ($result) {
	    while ($row = $result->fetch_assoc()) {
            $group = new Group();
            $group->id = $row['id'];
            $group->comp_id = $row['comp_id'];
            $group->initial_group_size = $row['initial_group_size'];
            $group->curr_group_size = $row['curr_group_size'];
            $group->increment_amount = $row['increment_amount'];
            $group->balance = $row['balance'];
            $group->target = $row['target'];
            $group->date_start = new DateTime($row['time_created']);
            $group->date_end = new DateTime($row['time_created']);
            
            if($group->target - $group->balance <= 0)
                $group->achieved = true;
                
            $group->comp = get_comp($group->comp_id);
            
            $group->player_ids = get_players_for_group($group->id);
            
	    	array_push($groups, $group);
	    }
	    $result->close();
	}
    
    //for each group, see if they achieved their goal
    foreach($groups as $g) {
        echo 'GROUP: ' . $g->id;
        echo 'A: ' . $g->achieved;
        if($g->achieved == true) {
            //get player redemption info
            foreach($player_ids as $pid) {
                $player = get_player($pid);
                $player->redemption = get_redemption_for_player($g->id, $player->id);
            }
        }
    }
    
    return $groups;	
}

function get_redemption_for_player($groupId, $playerId) {
    $query = "SELECT id, comp_id, code, redeemed FROM redeem_codes
                WHERE player_id=".$playerId." AND group_id=".$groupId;
    $r;
	$result = $mysqli->query($query);
    if ($result) {
        if ($row = $result->fetch_assoc()) {
            $r = new Recemption();
            $r->id = $row['id'];
            $r->player_id = $playerId;
            $r->group_id = $groupId;
            $r->comp_id = $row['comp_id'];
            $r->code = $row['code'];
            $r->redeemed = $row['redeemed'];
        }
    }
    
    return $r;
}



function do_post_request($url, $data, $optional_headers = null) {
    $params = array('http' => array( 
    'method' => 'POST', 
    'content' => $data 
    )); 
    if ($optional_headers!== null) { 
    $params['http']['header'] = $optional_headers; 
    } 
    $ctx = stream_context_create($params); 
    $fp = @fopen($url, 'rb', false, $ctx); 
    if (!$fp) { 
    throw new Exception("Problem with $url, $php_errormsg"); 
    } 
    $response = @stream_get_contents($fp); 
    if ($response === false) { 
    throw new Exception("Problem reading data from $url, $php_errormsg"); 
    } 
    return $response; 
}


class Casino {
    public $id;
    public $name;
}

class Comp {
    public $id;
    public $name;
    public $description;
    public $user_amount;
    public $timespan;
    public $reached;
}

class Event {
    public $id;
    public $player_id;
    public $win_amount;
    public $time_created;
    public $player_name;
    public $username;
    public $group_id;
}

class Redemption {
    public $id;
    public $player_id;
    public $pgroup_id;
    public $comp_id;
    public $code;
    public $redemeed;
}
class AppMessage {
    public $id;
    public $message;
    public $is_active;
    public $time_created;
}