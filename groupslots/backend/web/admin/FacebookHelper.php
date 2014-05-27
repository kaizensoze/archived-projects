<?php

require_once '../ApnsPHP/Autoload.php';
require '../FacebookPHP/facebook.php';

$facebook = new Facebook(array(
    	  'appId' => '161380047292117',
    	  'secret' => '964d0b7f497ec5b2c8bbbb627b28e693',
));

class FacebookHelper {    
    
    function api($request, $action) {
        global $facebook;
        
        $facebook->api($request, $action);
    }
    
    function getFacebookId($username) {
        global $mysqli;
    
        $query = "SELECT facebook_id FROM user WHERE username = ? AND facebook_id IS NOT NULL";
        $pstmt = $mysqli->prepare($query);
        $pstmt->bind_param("s", $username);
        $pstmt->execute();
        $pstmt->bind_result($facebook_id);
        $pstmt->fetch();
        $pstmt->close();
        
        return $facebook_id;
    }

    function postToWall($facebook_id, $text) {
        global $facebook;
        
        if (isset($facebook_id) && strcmp($facebook_id, "9101508") != 0) { // FIXME: avoiding app spamming my (Joe) own facebook wall
            $params = array(
                'message' => $text
            );
            try {
                $publish_feed = $facebook->api("/$facebook_id/feed", "post", $params);
            } catch (Exception $e) {
                //echo $e->getMessage() . "<br />";
            }
        }
    }
}

?>