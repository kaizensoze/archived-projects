<?php
class RewardManager {
    function getRewardDetails($id) {
        global $mysqli;
        $reward = null;

        $query = "SELECT name, active, amount, time_created, inv_controlled, inv_amount, timespan FROM reward WHERE id = " . $id;
       	$result = $mysqli->query($query);

        if ($result) {
            while ($row = $result->fetch_assoc()) {
                $reward = new Reward();
                $reward->id = $id;
                $reward->name = $row['name'];
                $reward->amount = $row['amount'];
                $reward->active = $row['active'];
                $reward->inv_controlled = $row['inv_controlled'];
                $reward->inv_amount = $row['inv_amount'];
                $reward->time_created = $row['time_created'];
                $reward->timespan = $row['timespan'];
                if($reward->timespan == null)
                    $reward->timespan = 0;
            }
            $result->close();
        }

        return $reward;
    }

    function saveReward($id, $name, $amount, $active, $invControlled, $invAmount, $timespan) {
        global $mysqli;
        $activeVal = $active == 'true' ? '1' : '0';
        $invVal = $invControlled == 'true' ? '1' : '0';
        $newId = $id;

        if($id == -1) {
            $query = "INSERT INTO reward (amount, name, active, time_created, inv_controlled, inv_amount, timespan)
                    VALUES (" . $amount . ", '" . $name . "', " . $activeVal . ", CURRENT_TIMESTAMP(), " . $invVal . ", " . $invAmount . ", '" . $timespan . "')";
            $mysqli->query($query);
            echo $query;
            $newId = last_insert_id('reward');
        } else {
            $query = "UPDATE reward SET amount=" . $amount . ", name='" . $name . "', active=" . $activeVal . ", inv_controlled="
                    . $invControlled . ", inv_amount=" . $invAmount . ", timespan='" . $timespab ."' WHERE id=" . $id;
            $mysqli->query($query);
        }

        return $this->getRewardDetails($newId);
    }

    function deleteReward($id) {
        global $mysqli;
        $query = "DELETE from reward where id=" . $id;
        $mysqli->query($query);
    }

    function getRewards() {
        global $mysqli;

		$rewards = array();

		$query = "SELECT id, amount, name, active, inv_controlled, inv_amount, time_created, timespan FROM reward";
		$result = $mysqli->query($query);
        if ($result) {
            while ($row = $result->fetch_assoc()) {
                $reward = new Reward();
                $reward->id = $row['id'];
                $reward->amount = $row['amount'];
                $reward->name = $row['name'];
                $reward->active = $row['active'];
                $reward->inv_controlled = $row['inv_controlled'];
                $reward->inv_amount = $row['inv_amount'];
                $reward->timespan = $row['timespan'];
                if($reward->timespan == null) {
                    $reward->timespan = 0;
				}
                $reward->time_created = $row['time_created'];
                array_push($rewards, $reward);
            }
            $result->close();
        }
		
        return $rewards;
    }

	function getRewardsByCardID($card_id) {
		$query = <<<'SQL'
SELECT
	r.name,
	rc.code,
	rc.id,
	rc.redeemed
FROM
	player p
	INNER JOIN redeem_codes rc ON p.id = rc.player_id
	INNER JOIN reward r ON rc.reward_id = r.id
WHERE
	p.card_id = ?
SQL;
		$stmt = $GLOBALS['mysqli']->prepare($query);
		$stmt->bind_param('i', $card_id);
		$stmt->execute();
		$stmt->bind_result($reward_name, $redemption_code, $redemption_id, $reward_redeemed);
		$rewards = array(
			'pending' => array(),
			'redeemed' => array()
		);
		while($stmt->fetch() === true) {
			if($reward_redeemed === 0) {
				array_push(
					$rewards['pending'],
					array(
						'name' => $reward_name,
						'redemption_code' => $redemption_code,
						'redemption_id' => $redemption_id
					)
				);
			} else {
				array_push(
					$rewards['redeemed'],
					array(
						'name' => $reward_name,
						'redemption_code' => $redemption_code,
						'redemption_id' => $redemption_id
					)
				);
			}
			
		}

		return $rewards;
	}
}

class Reward {
    public $id;
    public $name;
    public $description; //FIXME: add description to reward
    public $amount;
    public $active;
    public $timespan;
    public $inv_controlled;
    public $inv_amount;
    public $time_created;
}