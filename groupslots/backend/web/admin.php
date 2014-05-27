<?php

require_once 'mysql.php';

function main() {
    $action = $_GET['action'];
    if (!isset($action)) {
        return;
    }

    switch ($action) {
      case 'groups':
        echo groups();
        break;
      case 'group_details':
      	$group_id = $_GET['group_id'];
      	echo group_details($group_id);
        default:
            echo 'invalid action';
    }
}
main();
$mysqli->close();

function groups() {
	global $mysqli;
	
	$table_html = 
// 		"<table id='groups_table'>
		   "<thead>
		   <tr>
		     <th>group_id</th>
		     <th>casino</th>
		     <th>progress</th>
		     <th>goal</th>
		     <th>reward</th>
			 <th>&nbsp;</th>
		   </tr>
		   </thead>
		   <tbody>
	";
	
	$query = "
		SELECT
			pg.id group_id,
			c.name casino,
			s.amount progress,
			5000 goal,
			'free_brunch' reward
		FROM
			pgroup pg
			JOIN casino c ON (pg.casino_id = c.id)
			JOIN pgroup_session s ON (s.pgroup_id = pg.id)
	";
	$result = $mysqli->query($query);
	if ($result) {
	    while ($row = $result->fetch_assoc()) {
	    	$table_html .=
	    		"<tr>"
	    			. "<td>" . $row['group_id'] . "</td>"
	    			. "<td>" . $row['casino'] . "</td>"
	    			. "<td>" . $row['progress'] . "</td>"
	    			. "<td>" . $row['goal'] . "</td>"
	    			. "<td>" . $row['reward'] . "</td>"
	    			. "<td><a href='' id='".$row['group_id']."_details_link' class='details_link'>details</a></td>"
	    	  . "</tr>";
	    }
	    $result->close();
	}
	
	$table_html .= "</tbody>"; //</table>";
	
	return $table_html;
}

function group_details($group_id) {
  global $mysqli;
	
	$table_html = 
// 		"<table id='groups_table'>
		   "<thead>
		   <tr>
		     <th>player_id</th>
		     <th>user_id</th>
		     <th>name</th>
		     <th>card_id</th>
		     <th>facebook_id</th>
		   </tr>
		   </thead>
		   <tbody>
	";
	
	$query = "
		SELECT
			p.id player_id,
			u.id user_id,
			u.name name,
			p.card_id card_id,
			u.facebook_id
		FROM
			pgroup_players pgp
			JOIN player p ON (pgp.player_id = p.id)
			JOIN user u ON (p.user_id = u.id)
		WHERE
			pgp.pgroup_id = ?
	";
	$pstmt = $mysqli->prepare($query);
	$pstmt->bind_param("s", $group_id);
	$pstmt->execute();
	$pstmt->bind_result($player_id, $user_id, $name, $card_id, $facebook_id);
	
	while ($pstmt->fetch()) {
    	$table_html .=
    		"<tr>"
    			. "<td>" . $player_id . "</td>"
    			. "<td>" . $user_id . "</td>"
    			. "<td>" . $name . "</td>"
    			. "<td>" . $card_id . "</td>"
    			. "<td>" . $facebook_id . "</td>"
    	  . "</tr>";
    }
    $pstmt->close();
	
	$table_html .= "</tbody>"; //</table>";
	
	return $table_html;
}

?>
