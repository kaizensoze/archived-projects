<?php
class UserManager {
    
    //returns userId
    function login($cardId, $password, $token) {
        global $mysqli;
        
        $query = "
            SELECT
                p.user_id,
                pp.pgroup_id,
                u.name,
                u.username
            FROM
                player p
                LEFT OUTER JOIN pgroup_players pp ON p.id = pp.player_id
                JOIN user u ON p.user_id = u.id
            WHERE
                card_id = ?";
        $pstmt = $mysqli->prepare($query);
        $pstmt->bind_param('s', $cardId);
        $pstmt->execute();
        $pstmt->bind_result($user_id, $group_id, $name, $username);
        $pstmt->fetch();
        $pstmt->close();
        
        if ($user_id > 0) {
            error_log("Updating player ".$cardId." to active");
            $query = "UPDATE player SET status = 'active' WHERE card_id = ?";
            $pstmt = $mysqli->prepare($query);
            $pstmt->bind_param('s', $cardId);
            if(!$pstmt->execute()) {
                error_log("Mysql error ".$mysqli->error);
            }
            $pstmt->close();
            error_log("Affected rows = ".$mysqli->affected_rows);

            if (strlen($token) == 64) {
                error_log("Setting device token to ".$token);
                $query = "UPDATE user SET device_token = ? WHERE id = (SELECT user_id FROM player WHERE card_id = ?)";
                $pstmt2 = $mysqli->prepare($query);
                $pstmt2->bind_param("ss", $token, $cardId);
                if(!$pstmt2->execute()) {
                    error_log("Mysql error ".$mysqli->error);
                }
                $pstmt2->close();
            } else {
                error_log("Received invalid device token '".$token."'");
            }
            
            $result = array();
            $result["response_code"] = $user_id;
            
            // Cache the current user's data in the session
            $_SESSION['user'] = array(
                'card_id' => $cardId,
                'id' => $user_id,
                'name' => $name,
                'group_id' => $group_id,
                'username' => $username
            );
        } else {
            $result["response_code"] = 0;
        }
        
        return $result;
    }
    
    function logout($card_id) {
        global $mysqli;
    
        $query = "UPDATE player SET status = 'inactive' WHERE card_id = ?";
        $pstmt = $mysqli->prepare($query);
        $pstmt->bind_param("s", $card_id);
        $pstmt->execute();
        $pstmt->close();
        
        // Destroy the user's session cache
        unset($_SESSION['user']);
    }
    
    function getPlayerFromCardId($cardId) {
        global $mysqli;
        $player = null;
        $query = "
            SELECT DISTINCT p.id, u.facebook_id, u.name, u.username, p.card_id, 
            (SELECT SUM(win_amount) FROM player_session ps WHERE ps.player_id=p.id) as sum
            FROM pgroup_players pp INNER JOIN
            player p ON p.id = pp.player_id INNER JOIN
            user u ON u.id = p.user_id
            WHERE p.card_id=" . $cardId;
    
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
            }
        }
        
        return $player;
    }
    
    function register($name, $casino, $card_id) {
        global $mysqli;
        $user_id;
        
        $query = "SELECT COUNT(*) FROM player WHERE card_id = ?";
        $pstmt = $mysqli->prepare($query);
        $pstmt->bind_param("s", $card_id);
        $pstmt->execute();
        $pstmt->bind_result($player_count);
        $pstmt->fetch();
        $pstmt->close();
        
        $result = array();
        
        if ($player_count > 0) {
            $result["val"] = 0;
        } else {
            $query = "INSERT INTO user (name, username) VALUES (?,?)";
            $pstmt = $mysqli->prepare($query);
            $pstmt->bind_param("ss", $name, $name);
            $pstmt->execute();
            $user_id = $mysqli->insert_id;
            
            $query = "
                INSERT INTO player (casino_id, user_id, card_id) VALUES (
                    (SELECT id FROM casino WHERE name = ?),
                    ?,
                    ?
                )";
            
            $pstmt = $mysqli->prepare($query);
            $pstmt->bind_param("sss", $casino, $user_id, $card_id);
            $pstmt->execute();
            $pstmt->close();
            
            $result["val"] = 1;
        }
        
        return $result;
    }
}