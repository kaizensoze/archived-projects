<?php
class Group {
	public $casino_id;
	public $challengeDetails; //reward/challenge instance
	public $date_start; //group creation
	public $group_size;
	public $id;
	public $initial_group_size;
	public $players; //player objects
	public $previousChallenges;
}

class Player { //legacy, TODO: update
	public $card_id;
	public $casino_id;
	public $facebook_id;
	public $group_id;
	public $id;
	public $name;
	public $redemption;
	public $sum;
	public $username;
	public $user_id;
}

class GroupManager {
    //tries to create a group based on two usernames
    function tryJoinGroup($userA, $userB) {
        global $mysqli;
        global $facebookHelper;
        global $challengeMgr;
        
        $query = <<<'SQL'
            SELECT
                pg.pgroup_id
            FROM
                user u
                JOIN player p ON (u.id = p.user_id)
                JOIN pgroup_players pg ON (p.id = pg.player_id)
            WHERE
                u.username = ?
SQL;
        $pstmt = $mysqli->prepare($query);
        
        $pstmt->bind_param('s', $userA);
        $pstmt->execute();
        $pstmt->bind_result($aGroup);
        $pstmt->fetch();
        
        $pstmt->bind_param('s', $userB);
        $pstmt->execute();
        $pstmt->bind_result($bGroup);
        $pstmt->fetch();
        $pstmt->close();
		
        $groupId = -1;
        
        // if neither are in group, create one
        if ($aGroup == null && $bGroup == null) {
			// FIXME: hardcoded casino for now
            $createGroupQuery = <<<'SQL'
			INSERT INTO pgroup(
				casino_id,
				time_created
			)
			VALUES(
				(SELECT id FROM casino WHERE name = 'Mohegan Sun'),
				CURRENT_TIMESTAMP()
			);
SQL;

            $mysqli->query($createGroupQuery);
            $groupId = $mysqli->insert_id;
            
            $createSessionQuery = "INSERT INTO pgroup_session (pgroup_id) VALUES (?)";
            $pstmt = $mysqli->prepare($createSessionQuery);
            $pstmt->bind_param("s", $groupId);
            $pstmt->execute();
            $pstmt->close();
        } else {
            $groupId = $aGroup | $bGroup;
        }
        
        // associate players with new group if necessary
        $query = "
            INSERT INTO pgroup_players (pgroup_id, player_id, status) VALUES (
                ?,
                (SELECT p.id FROM player p JOIN user u ON (p.user_id = u.id) WHERE u.username = ?),
                'active'
            ) ON DUPLICATE KEY UPDATE status = 'active'
        ";
        $pstmt = $mysqli->prepare($query);
        
        
        $group_size_changed = FALSE;
        if ($aGroup == null) {
            $pstmt->bind_param("ss", $groupId, $userA);
            $pstmt->execute();
            $group_size_changed = TRUE;
            
            // postToWall
            $wall_textA = "I just grouped up with " . $userB . ". #GroupSlots";
            $fbid = $facebookHelper->getFacebookId($userA);
            $facebookHelper->postToWall($fbid, $wall_textA);
        }
        if ($bGroup == null) {
            $pstmt->bind_param("ss", $groupId, $userB);
            $pstmt->execute();
            $group_size_changed = TRUE;
            
            // postToWall
            $wall_textB = "I just grouped up with " . $userA . ". #GroupSlots";
            $fbid = $facebookHelper->getFacebookId($userB);
            $facebookHelper->postToWall($fbid, $wall_textB);
        }
        $pstmt->close();
        
        if ($group_size_changed) {
            $challengeMgr->recalculateGroupChallenge($groupId);
        }
        
        return $groupId;        
    }

    function tryJoinGroupFromFacebook($fbUserA, $fbUserB, $appRequest) {
        global $mysqli;
        global $facebookHelper;
		
        // get usernames given facebook ids
        
        $query = "SELECT username FROM user WHERE facebook_id = ?";
        $pstmt = $mysqli->prepare($query);
        
        $pstmt->bind_param("s", $fbUserA);
        $pstmt->execute();
        $pstmt->bind_result($userA);
        $pstmt->fetch();
        
        $pstmt->bind_param("s", $fbUserB);
        $pstmt->execute();
        $pstmt->bind_result($userB);
        $pstmt->fetch();
        
        $pstmt->close();
        
        $groupId = $this->tryJoinGroup($userA, $userB);
        
		echo 'tryJoinGroup: ' . $userA . ' ' . $userB . ' ' . $groupId;
		
        // remove the facebook app request
		$request;
		try {
			$request = $facebookHelper->api($appRequest);
			$from_id = $request["from"]["id"];
			$from_name = $request["from"]["name"];
        } catch (Exception $e) {
			echo 'Error sending facebook request: ' . $e->getMessage();
			//return;
        }
        // remove app request
        try {
            $delete_success = $facebookHelper->api($appRequest, "DELETE");
        } catch (Exception $e) {
			echo 'Error deleting request: ' . $e->getMessage();
        }
        
        // just in case anything got stuck, clear all facebook app requests
        try {
            $requests = $facebookHelper->api('/me/apprequests');
            foreach($requests['data'] as $request) {
                $delete_success = $facebookHelper->api($request["id"], "DELETE");
            }
        } catch (Exception $e) {
			echo 'Error deleting request: ' . $e->getMessage();
        }
        
        return $groupId;
    }

    //TODO: Should we also delete group_challenges instances for this group? We are for now.
    function deleteGroup($id) {
		global $mysqli;

		$query = "DELETE from pgroup_session where pgroup_id=" . $id;
		$mysqli->query($query);

		$query = "DELETE from pgroup_comps where pgroup_id=" . $id;
		$mysqli->query($query);

		$query = "DELETE from pgroup_players where pgroup_id=" . $id;
		$mysqli->query($query);

		$query = "DELETE from pgroup WHERE id=" . $id;
		if(!$mysqli->query($query)) {
			error_log("Error deleting pgroup with id ".$id);
			error_log("Mysqli error:".$mysqli->error);
		}

		$query = "DELETE from group_challenges WHERE group_id=" . $id;
		if(!$mysqli->query($query)) {
			error_log("Error deleting group challenge with group id ".$id);
			error_log("Mysqli error:".$mysqli->error);
		}
    }

	function getGroupFromCardId($cardId) {
		global $mysqli;

		$query = <<<SQL
SELECT
	pp.pgroup_id
FROM
	pgroup_players pp
INNER JOIN
	player p ON p.id = pp.player_id
WHERE
	p.card_id = $cardId
SQL;
		$result = $mysqli->query($query);
		if($result && ($row = $result->fetch_assoc())) {
			return $this->getGroup($row['pgroup_id']);
		}

		return null; 
	}

    //returns Group object with current challenge details
    function getGroup($id) {
        global $mysqli;
        global $challengeMgr;
        
        $group = null;
        
        $query = "SELECT casino_id from pgroup where id=" . $id;
        $result = $mysqli->query($query);
    
        if ($result) {
            if ($row = $result->fetch_assoc()) {
                $group = new Group();
                $group->id = $id;
                $group->casino_id = $row['casino_id'];
                
                $group->players = $this->getPlayersForGroup($id);
                $group->group_size = count($group->players);
                
                $group->challengeDetails = $challengeMgr->getChallengeDetailsForGroup($group, false);
            }
            $result->close();
        }
        
        return $group;
    }

    function getPlayersForGroup($groupId) {
        global $mysqli;
        
        $players = array();
        
        $query = "
            SELECT DISTINCT p.id, u.facebook_id, u.name, u.username, p.card_id, 
            (SELECT SUM(win_amount) FROM player_session ps WHERE ps.player_id=p.id) as sum
            FROM pgroup_players pp INNER JOIN
            player p ON p.id = pp.player_id INNER JOIN
            user u ON u.id = p.user_id
            WHERE pp.pgroup_id=" . $groupId;
    
        $result = $mysqli->query($query);

        if ($result) {
            while ($row = $result->fetch_assoc()) {
                $player = new Player();
                $player->id = $row['id'];
                $player->facebook_id = $row['facebook_id'];
                $player->sum = $row['sum'];
                $player->card_id = $row['card_id'];
                $player->name = $row['name'];
                $player->username = $row['username'];
                array_push($players, $player);
            }
        }
        
        return $players;
    }

    function getActiveGroup($card_id) {
        global $mysqli;
        $query = "
            SELECT
                gp.pgroup_id
            FROM
                player p
                JOIN pgroup_players gp ON (p.id = gp.player_id)
            WHERE
                p.card_id = ?
                AND gp.status = 'active'
        ";
        
        $pstmt = $mysqli->prepare($query);
        $pstmt->bind_param("s", $card_id);
        $pstmt->execute();
        $pstmt->bind_result($group_id);
        $pstmt->fetch();
        $pstmt->close();
        
        $result = array();
        $result["val"] = $group_id;
        return $result;
    }

	function getRewardID($group_id) {
		$query = <<<'SQL'
SELECT
	gc.reward_id
FROM
	group_challenges gc
	INNER JOIN pgroup_players pp ON gc.group_id = pp.pgroup_id
WHERE
	gc.group_id = ?
	AND pp.status = 'active'
SQL;
		$stmt = $GLOBALS['mysqli']->prepare($query);
		$stmt->bind_param('i', $group_id);
		$stmt->execute();
		$stmt->bind_result($reward_id);
		$stmt->fetch();
		$stmt->close();
		
		return $reward_id;
	}

    //returns all active groups and their challenge details
    //TODO: get challenge details for each group? (not really necessary)
    function getGroups() {
        global $mysqli; global $challengeMgr;
        $groups = array();
        
        $query = "SELECT id, casino_id, time_created, (SELECT COUNT(*) from pgroup_players pp where pp.pgroup_id=pg.id) as groupSize
                    FROM pgroup pg";
    
        $result = $mysqli->query($query);    
        if ($result) {
            while ($row = $result->fetch_assoc()) {
                $group = new Group();
                $group->id = $row['id'];
                $group->casino_id = $row['casino_id'];
                $group->time_created = $row['time_created'];
                
                $group->players = $this->getPlayersForGroup($group->id);
                $group->group_size = $row['groupSize'];
                
                $group->challengeDetails = $challengeMgr->getChallengeDetailsForGroup($group, false);
                $group->previousChallenges = $challengeMgr->getChallengeDetailsForGroup($group, true);
				
                array_push($groups, $group);
            }
            $result->close();
        }
		
        return $groups;	
    }    

    function removeMemberFromGroup($groupId, $playerId) {
        //TODO
    }

    function updateGroupComp($group_id) {
        global $mysqli;
        
        $query = "
            SELECT
                (SELECT COUNT(*) FROM pgroup_players WHERE pgroup_id = ?)
                *
                (SELECT increment_amount FROM pgroup_comps WHERE pgroup_id = ?)
        ";
        $pstmt = $mysqli->prepare($query);
        $pstmt->bind_param("ss", $group_id, $group_id);
        $pstmt->execute();
        $pstmt->bind_result($new_comp_amount);
        $pstmt->fetch();
        $pstmt->close();
        
        $query = "UPDATE pgroup_comps SET amount = ? WHERE pgroup_id = ?";
        $pstmt = $mysqli->prepare($query);
        $pstmt->bind_param("ss", $new_comp_amount, $group_id);
        $pstmt->execute();
        $pstmt->close();
    }
}