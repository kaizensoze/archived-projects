<?php

class ChallengeManager {
    
    // boxcar request for all challenges, challenge types and rewards
    function getChallengeRewardSummary() {
	global $rewardMgr;
	global $mysqli;
	
	$result = array();
	$result['challengeTypes'] = $this->getChallengeSummaries();
	$result['rewards'] = $rewardMgr->getRewards();

	return $result;
    }

    function getChallengeSummaries() {
	global $mysqli;
	$challenges = array();
	
        $query = "SELECT id, name, active, amount, time_created FROM challenge";
       	$result = $mysqli->query($query);

        if ($result) {
            while ($row = $result->fetch_assoc()) {
				$c = new ChallengeSummary();
				$c->id = $row['id'];
				$c->name = $row['name'];
				$c->description = "description"; //FIXME: add description to challenge
			
				array_push($challenges, $c);
			}
	    $result->close();
	}
	return $challenges;
    }


	//TODO: challengeType not implemented
    function getChallengesByType($challengeType = null) {
        global $mysqli;
        $challenges = array();

        $query = "SELECT id, name, active, amount, time_created FROM challenge";
       	$result = $mysqli->query($query);

        if ($result) {
            while ($row = $result->fetch_assoc()) {
                $c = new Challenge();
                $c->id = $row['id'];
                $c->name = $row['name'];
                $c->active = $row['active'];
                $c->amount = $row['amount'];
                $c->time_created = $row['time_created'];

                 //get rules for this challenge (if it's a scavenger hunt)
                $c->rules = array();
                $query = "SELECT id, name, machine, order_num, amount, active, timespan, dependency
                            FROM challenge_rules WHERE challenge_id=" . $c->id . "
                            ORDER BY order_num desc";
                $result2 = $mysqli->query($query);

                if ($result2) {
                    while ($row2 = $result2->fetch_assoc()) {
                        $cr = new ChallengeRule();
                        $cr->id = $row2['id'];
                        $cr->challengeId = $c->id;
                        $cr->name = $row2['name'];
                        $cr->active = $row2['active'];
                        $cr->machine = $row2['machine'];
                        $cr->orderNum = $row2['order_num'];
                        $cr->amount = $row2['amount'];
                        $cr->timespan = $row2['timespan'];
                        $cr->dependencyId = $row2['dependency'];
                        array_push($c->rules, $cr);
                    }
                }

                array_push($challenges, $c);
            }

            $result->close();
        }

        return $challenges;
    }

	//gets the single-click challenge instances
	function getChallengeInstances() {
		global $mysqli;
        $challenges = array();

        $query = "SELECT id, name, active, challenge_id, challenge_quantity, reward_id, time_created FROM challenge_instances";
       	$result = $mysqli->query($query);

        if ($result) {
            while ($row = $result->fetch_assoc()) {
                $c = new ChallengeInstance();
                $c->id = $row['id'];
                $c->name = $row['name'];
                $c->active = $row['active'];
                $c->challengeId = $row['challenge_id'];
                $c->challengeQuantity = $row['challenge_quantity'];
                $c->rewardId = $row['reward_id'];
                $c->timeCreated = $row['time_created'];

                array_push($challenges, $c);
            }

            $result->close();
        }

        return $challenges;
	}
	
    // Returns a challenge object, generally used for scavenger hunts
    function getChallenge($id) {
		global $mysqli;
		
		$c = null;
		$query = 'SELECT name, active, time_created, challenge_type FROM challenge WHERE id = ' . $id;
		$result = $mysqli->query($query);
		
        if ($result) {
            if ($row = $result->fetch_assoc()) {
								$result->close();
                $c = new Challenge();
                $c->id = $id;
                $c->name = $row['name'];
                $c->active = $row['active'];
                $c->time_created = $row['time_created'];
                $c->challengeType = $row['challenge_type'];

                //get rules for this challenge (if it's a scavenger hunt)
                $c->rules = array();
                $query = "SELECT id, name, machine, order_num, amount, active
                            FROM challenge_rules WHERE challenge_id=" . $id . "
                            ORDER BY order_num asc";
                $result = $mysqli->query($query);
                if ($result) {
                    while ($row = $result->fetch_assoc()) {
                        $cr = new ChallengeRule();
                        $cr->id = $row['id'];
                        $cr->challengeId = $id;
                        $cr->name = $row['name'];
                        $cr->active = $row['active'];
                        $cr->machine = $row['machine'];
                        $cr->orderNum = $row['order_num'];
                        $cr->amount = $row['amount'];
                        array_push($c->rules, $cr);
                    }
					$result->close();
                }
            }
        }

        return $c;
    }

	function getChallengeInstance($id) {
		global $mysqli;
		
		$c = null;
		$query = 'SELECT name, active, time_created, challenge_id, reward_id, challenge_quantity FROM challenge_instances WHERE id = ' . $id;
		$result = $mysqli->query($query);
		
        if ($result) {
            if ($row = $result->fetch_assoc()) {
				$result->close();
                $c = new ChallengeInstance();
                $c->id = $id;
                $c->name = $row['name'];
                $c->active = $row['active'];
                $c->time_created = $row['time_created'];
                $c->challengeId = $row['challenge_id'];
                $c->rewardId = $row['reward_id'];
                $c->challengeQuantity = $row['challenge_quantity'];
            }
        }

        return $c;
    }
	
    function getChallengeRule($challengeId, $order) {
        global $mysqli;
		
		$c = null;
		$query = "SELECT id, challenge_id, name, machine, order_num, amount, active, timespan, dependency FROM challenge_rules WHERE challenge_id=" .
					$challengeId . " AND order_num= " . $order;
		$result = $mysqli->query($query);
		
        if ($result) {
            if ($row = $result->fetch_assoc()) {
                $c = new ChallengeRule();
                $c->id = $row['id'];
                $c->challengeId = $row['challenge_id'];
                $c->name = $row['name'];
                $c->machine = $row['machine'];
                $c->orderNum = $row['order_num'];
                $c->amount = $row['amount'];
                $c->active = $row['active'];
                $c->timespan = $row['timespan'];
                $c->dependencyId = $row['dependency'];
                $c->dependencyId = -1; //TODO
            }
            $result->close();
        }

        return $c;
    }

    function getChallengeRuleById($ruleId) {
        global $mysqli;
        $c = null;
        $query = "SELECT id, challenge_id, name, machine, order_num, amount, active, timespan, dependency FROM challenge_rules WHERE id=" . $ruleId;
       	$result = $mysqli->query($query);

        if ($result) {
            if ($row = $result->fetch_assoc()) {
                $c = new ChallengeRule();
                $c->id = $row['id'];
                $c->challengeId = $row['challenge_id'];
                $c->name = $row['name'];
                $c->machine = $row['machine'];
                $c->orderNum = $row['order_num'];
                $c->amount = $row['amount'];
                $c->active = $row['active'];
                $c->timespan = $row['timespan'];
                $c->dependencyId = $row['dependency'];
                $c->dependencyId = -1; //TODO
            }
            $result->close();
        }

        return $c;
    }

    //gets the latest challenge for the group, including rules
    function getChallengeDetailsForGroup($group, $getAll = false) {
        global $mysqli; global $rewardMgr; global $groupMgr;
        $details = null;

		$id_group = $group->id;
        $query = <<<SQL
SELECT
	id,
	challenge_id,
	challenge_quantity,
	reward_id,
	rematch_num,
	tier_num,
	balance,
	target,
	time_created,
	(SELECT sum(gc.balance) from group_challenges gc where group_id = $id_group) as sum
FROM
	group_challenges
WHERE
	group_id = $id_group
ORDER BY
	id DESC
SQL;
        $result = $mysqli->query($query);
        if ($result) {
            //get the latest group challenge for this group
            if($getAll == false) {
                if ($row = $result->fetch_assoc()) {
                    $details = new GroupChallengeDetails();
                    $details->id = $row['id'];
                    $details->groupid = $group->id;
                    $details->challenge = $this->getChallenge($row['challenge_id']);
                    $details->challengeQuantity = $row['challenge_quantity'];
                    $details->rewardId = $row['reward_id'];
                    $details->balance = $row['balance'];
                    $details->target = $row['target'];
                    $details->tierNum = $row['tier_num'];
                    $details->rematchNum = $row['rematch_num'];
                    $details->timeCreated = $row['time_created'];
                    $details->reward = $rewardMgr->getRewardDetails($row['reward_id']);
                    $details->balanceSum = $row['sum'];
                    $details->totalRewardTarget = ($details->reward->amount * $group->group_size);
                }
            } else {
                //get each and every group challenge this group is in and has been in
                $details = array();
                while ($row = $result->fetch_assoc()) {
                    $dtl = new GroupChallengeDetails();
                    $dtl->id = $row['id'];
                    $dtl->groupId = $group->id;
                    $dtl->challenge = $this->getChallenge($row['challenge_id']);
                    $dtl->challengeQuantity = $row['challenge_quantity'];
                    $dtl->reward = $rewardMgr->getRewardDetails($row['reward_id']);
                    $dtl->balance = $row['balance'];
                    $dtl->target = $row['target'];
                    $dtl->tierNum = $row['tier_num'];
                    $dtl->rematchNum = $row['rematch_num'];
                    $dtl->timeCreated = $row['time_created'];
                    $dtl->totalRewardTarget = ($dtl->reward->amount * $group->group_size);

                    array_push($details, $dtl);
                }
            }
            $result->close();
        }

        return $details;
    }

    function updateChallengeDetails($id, $balance, $target) {
        global $mysqli;
        $query = "UPDATE group_challenges SET balance=" . $balance . ", target=" . $target . " WHERE id=" . $id;
        $mysqli->query($query);
    }

    //when a group initialy chooses a challenge
    function tryStartChallenge($groupId, $challengeQty, $rewardId, $challengeType, $challengeId) {
        global $mysqli;

        //check if this group already has a challenge going
        $query = "SELECT * from group_challenges where group_id=" . $groupId;
		
        $result = $mysqli->query($query);
        if($result) {
            if ($row = $result->fetch_assoc()) {
                echo 'Group already has a challenge';
                //group already has a challenge going
                return false;
            }
        }

        $challenge = $this->getChallenge($challengeId);
        if($challenge == null) {
            echo 'Challenge does not exist.';
            return;
        }
        $rule = null;

        //TODO: see if this is a rematch (do we have past group_challenges with the same parameters)
        $rematchNum = 0;
        $tierNum = 0;
        $balance = 0;

        //tierNum is the rule number, or Tournament tier number (for the... future?)
        if($challenge->challengeType == ChallengeType::Scavenger) {
            $rule = $this->getNextRule($challenge->rules, -1);

            if($rule != null) {
                $tierNum = $rule->orderNum;
            }
	}

        //calculate the cost based on group structure (and other things, in the... future?)
        $targetAmount = $this->calculateChallengeCost($groupId, $challengeQty, $rewardId, $rematchNum, $challenge->challengeType, $challengeId, $rule);

        $query = "INSERT INTO group_challenges (group_id, challenge_id, challenge_quantity, reward_id,
            rematch_num, tier_num, balance, target, time_created) VALUES " .
            "(" . $groupId . ", " . $challengeId . ", " . $challengeQty . ", " . $rewardId . ", " .
            $rematchNum . ", " . $tierNum . ", " . $balance . ", " . $targetAmount . ", CURRENT_TIMESTAMP())";
        $mysqli->query($query);
    }

    //assumes the current challenge is finished, proceed to the next
    //returns false if there are no more rules for the challenge
    function tryStartNextChallengeRule($groupId) {
        global $mysqli, $groupMgr;

        $group = $groupMgr->getGroup($groupId);
        $details = $group->challengeDetails;
        $challenge = $this->getChallenge($details->challenge->id);
        $challengeRule = $this->getChallengeRule($details->challenge->id, $details->tierNum); //current rule
        $nextRule = $this->getNextRule($challenge->rules, $challengeRule->orderNum);
        if($nextRule == null) {
            return false; //out of rule, end of challenge
		}
        $tierNum = $nextRule->orderNum;
        $balance = 0; //start with a balance of 0 for the new rule. if there was overflow, it will be added in addPointsToGroup
		$targetAmount = $this->calculateChallengeCost(
			$groupId,
			$details->challengeQuantity,
			$details->reward->id,
			$details->rematchNum,
			$challenge->challengeType,
			$details->challenge->id,
			$nextRule
		);

        $query = "INSERT INTO group_challenges (group_id, challenge_id, challenge_quantity, reward_id,
            rematch_num, tier_num, balance, target, time_created) VALUES " .
            "(" . $groupId . ", " . $challenge->id . ", " . $details->challengeQuantity . ", " . $details->reward->id . ", " .
            $details->rematchNum . ", " . $tierNum . ", " . $balance . ", " . $targetAmount . ", CURRENT_TIMESTAMP())";
		if(!$mysqli->query($query)) {
			gs_error_log('Mysql error: ' . $mysqli->error);
		}

        return true;
    }

    //calculate the next amount for the current challenge (be it a normal challenge or a specific rule)
    function calculateChallengeCost($groupId, $challengeQty, $rewardId, $rematchNum, $playType, $challengeId, $rule) {
        global $groupMgr; global $rewardMgr;

        $group = $groupMgr->getGroup($groupId);
        $reward = $rewardMgr->getRewardDetails($rewardId);
        $challenge = $this->getChallenge($challengeId); //only exists if its a scavenger hunt (for now)

        //TODO: some logic for $rematchNum

        //COST LOGIC: the reward stores both a win/user amount (ie. how much the reward would cost for a single user),
        //and also a timespan (ie. how long it would take one user to win). If we're in a scavenger hunt, we break this logic up as follows:
        // -the total reward target (trt) = (num players in group) * reward amount
        // -each rule's target is the (trt)/(rule's point %)

        switch($challengeQty) {
            case ChallengeQuantity::Single:
                $target = $reward->amount;
                break;
            case ChallengeQuantity::Group:
                $target = ($reward->amount * $group->group_size);
                break;
        }

        switch($playType) {
            case ChallengeType::Regular:
                break; //target stays the same
            case ChallengeType::Scavenger:
                //set up the first tier
                //TODO: get rules from challenge, use amount
                break;
            case ChallengeType::Tournament:
                //TODO
                break;
        }

        //if a rule is supplied, we want to only return a % of the total reward target, based on the rule's %.
        if ($rule != null) {
            //TODO: have to go through all the previous rules that have been completed for this group, and deduct their
            //targets (which have been met already) from this current target. we also have to subtract their % amounts from the 100% total,
            //and then recalculate this current target to be that %/100, so: $newTarget = ($target)*(remaining %)/100
            $totalPerc = 100;

            //TODO: need to pass the current challenge id, in case theyve started a new challenge, in the... future?
            $previousChallenges = $this->getChallengeDetailsForGroup($group, true);
            //for each previous: if target==balance (ie. complete), subtract that rule's % from 100, and subtract the balance from this new $target
            foreach ($previousChallenges as $prev) {
                if($prev->target == $prev->balance) {
                    $target = $target - $prev->target;
                    $prevRule = $this->getChallengeRule($prev->challenge->id, $prev->tierNum);
                    $totalPerc = $totalPerc - $prevRule->amount;
                }
            }

            //new targets weighted percentage, as a result of the above histories
            if($totalPerc != 0) {
				$target = ($target) * ($rule->amount / $totalPerc);
			}
        }

        return $target;
    }

    //TODO: need to check sortNum logic, not ID
    function getNextRule($ruleArray, $previousOrder) {
        $next = null;
        foreach($ruleArray as $rule) {
            if($rule->orderNum > $previousOrder) {
                if($next != null) {
                    if($rule->orderNum < $next->orderNum) {
                        $next = $rule;
                    }
                } else {
                    $next = $rule;
                }
            }
        }
		
        return $next;
    }

    //takes a point input, checks if the groups current challenge is complete, and does all that fancy logic
    function registerPoints($cardId, $amount, $machine_id) {
        global $mysqli, $groupMgr, $userMgr;

		// Check for errors
        $group = $groupMgr->getGroupFromCardId($cardId);
		
		if($group == null) {
			echo 'Can\'t find group';
			gs_error_log('Unable to find group for card id '.$cardId);
			return;
		}
		if($group->challengeDetails == null) {
			echo 'No challenge details for this group';
			gs_error_log('No challenge details found for group '.$group->id);
			return;
		}
		if(isset($machine_id) === false) {
			echo 'No machine id was supplied';
			gs_error_log('No machine ID was passed into registerPoints()');
			return;
		}
		
        //TODO: here is the hook where you can add modifiers to the point input
		pushPlayerWin($cardId,$group->id,$amount);
		
        // Log the win amount for this player's session
        $player = $userMgr->getPlayerFromCardId($cardId);
        $query = 'INSERT INTO player_session (player_id, win_amount, time_created, machine_id) ' .
					'VALUES(' . $player->id . ', ' . $amount . ', CURRENT_TIMESTAMP(), ' . $machine_id . ')';
        $mysqli->query($query);
		
		// Conditionally exit depending on the current challenge state
		$challenge = $group->challengeDetails->challenge;
		switch($challenge->challengeType) {
			case ChallengeType::Scavenger:
				// Return if this machine's type does not match that of the current challenge
				$oMachineManager = new MachineManager();
				$machine_type = $oMachineManager->getTypeFromMachineID($machine_id);
				
				$machineLog = "id:".$machine_id." rule type:".$challenge->rules[$group->challengeDetails->tierNum]->machine . " machine type:" . $machine_type[0]['type'];
				gs_error_log($machineLog);
				
				if(array_key_exists(0, $machine_type) === false) {
					gs_error_log('Machine ID "' . $machine_id . '" does not exist or has no associated type');
					return;
				} elseif($challenge->rules[$group->challengeDetails->tierNum]->machine !== $machine_type[0]['type']) {				
					echo print_r($challenge->rules);
					echo 'tier: ' . $group->challengeDetails->tierNum;
					gs_error_log(
						'Machine ID #' . $machine_id . ' is of type "' . $machine_type[0]['type'] .
						'"; the expected machine type for the current challenge is "' .
						$challenge->rules[$group->challengeDetails->tierNum]->machine . '"'
					);
					return;
				}
				// FALL THROUGH TO THE NEXT "CASE" STATEMENT
			case ChallengeType::Regular:
				// Return if the current time does not fall within the current challenge/rule's timespan
				if($this->isChallengeRuleExpired($challenge->rules[$group->challengeDetails->tierNum]->id) === true) {
					gs_error_log(
						'[CARD ID ' . $cardId . '] Challenge rule #' .
						$challenge->rules[$group->challengeDetails->tierNum]->id .
						' has expired, so no points will be registered'
					);
					return;
				}
				break;
			case ChallengeType::Tournament:
				gs_error_log(
					'User is in TOURNAMENT challenge; ' . $amount .
					' points awarded to the individual not the group'
				);
				return;
		}
		
		// Award points to the group
		$this->addPointsToGroup($group, $amount);
    }

    function addPointsToGroup($group, $amount) {
        global $mysqli, $groupMgr;

		// Calculate point values
        $target = $group->challengeDetails->target;
        $balance = $group->challengeDetails->balance;
        $newBalance = $balance + $amount;
        $overflow = 0;
        if ($newBalance > $target) {
            $overflow = $newBalance - $target;
            $newBalance = $target;
        }
		
		// update the balance for this challenge or individual rule
		$this->updateChallengeDetails($group->challengeDetails->id, $newBalance, $target);
		
		// Perform actions if this challenge or challenge step are now complete
        if($newBalance == $target) {
			switch($group->challengeDetails->challenge->challengeType) {
				case ChallengeType::Regular:
					// Completed this challenge
					$this->awardPrize($group->id);
					pushGroupWin($group->id);
			
					//now we remove the group challenge details, since its finished
					$query = "DELETE FROM group_challenges WHERE group_id=" . $group->id;
					$mysqli->query($query);
					return;
				case ChallengeType::Scavenger:
					
				    if($this->tryStartNextChallengeRule($group->id) !== true) {
						// Completed all challenge rules
						$this->awardPrize($group->id);
						pushGroupWin($group->id);
						
			
						//now we remove the group challenge details, since its finished
						$query = "DELETE FROM group_challenges WHERE group_id=" . $group->id;
						$mysqli->query($query);
						return;
					} elseif($overflow > 0) {
					        // rule/stage completed
					
						// apply the overflow to the next challenge rule, ie. recurse
						$group = $groupMgr->getGroup($group->id); //refresh the group
						$this->addPointsToGroup($group, $overflow);
					}
					pushRuleWin($group->id);
					break;
				default:
					gs_error_log(
						'Unexpected challenge type "' .
						$group->challengeDetails->challenge->challengeType .
						'" encountered in addPointsToGroup()'
					);
					return;
			}
        }
    }

    function saveChallenge($id, $name, $active, $challengeType) {
        global $mysqli;
        $newId = $id;
        $activeVal = $active == true ? '1' : '0';

        if($id == -1) {
            $query = "INSERT INTO challenge (name, active, amount, challenge_type, time_created) " .
					"VALUES ('" . $name . "', " . $activeVal . ", 0, ". $challengeType. ", CURRENT_TIME())";
			if(!$mysqli->query($query)) {
				gs_error_log("Mysql error ".$mysqli->error);
			}
            $newId = last_insert_id('challenge');
        } else {
            $query = "UPDATE challenge SET name='" . $name . "', active=" . $activeVal . ", challenge_type=" . $challengeType. " WHERE id=" . $id;
            $mysqli->query($query);
        }

        $challenge = $this->getChallenge($newId);
        return $challenge;
    }
	
	function saveChallengeInstance($id, $name, $challengeId, $rewardId, $challengeQuantity, $active) {
		global $mysqli;
        $newId = $id;
        $activeVal = $active == true ? '1' : '0';
	
        if($id == -1) {
            $query = "INSERT INTO challenge_instances (name, active, challenge_id, reward_id, challenge_quantity) " .
					"VALUES ('" . $name . "', " . $activeVal . ", " . $challengeId . ", ". $rewardId. ", " . $challengeQuantity . ")";
			if(!$mysqli->query($query)) {
				gs_error_log("Mysql error ".$mysqli->error);
			}
            $newId = last_insert_id('challenge');
        } else {
            $query = "UPDATE challenge_instances SET name='" . $name . "', active=" . $activeVal . ", challenge_id=" . $challengeId. ",
					reward_id=" . $rewardId . ", challenge_quantity=" . $challengeQuantity . " WHERE id=" . $id;
            $mysqli->query($query);
        }
		
        $challenge = $this->getChallengeInstance($newId);
		
        return $challenge;
	}
	
	function deleteChallengeInstance($id) {
		global $mysqli;
		$sql = "DELETE FROM challenge_instances WHERE id=" . $id;
		if(!$mysqli->query($sql)) {
			gs_error_log("Mysql error ".$mysqli->error);
		}
	}

    function deleteChallenge($id) {
         global $mysqli;

        $query = "DELETE FROM challenge where id=" . $id;
        $mysqli->query($query);

        $query = "DELETE FROM challenge_rules where challenge_id=" . $id;
        $mysqli->query($query);

        $query = "DELETE FROM group_challenges where challenge_id=" . $id;
        $mysqli->query($query);
    }

    function saveChallengeRule($ruleId, $challengeId, $amount, $machine, $timespan, $orderNum, $dependencyId) {
        global $mysqli;
        $newId = $ruleId;
        $name = '';

        if($ruleId == -1) {
            //TODO: for now we don't support active or or names
            $query = "INSERT INTO challenge_rules (challenge_id, name, machine, order_num, amount, active, timespan, dependency) VALUES" .
                    " (" . $challengeId . ", '" . $name . "', '" . $machine . "', " . $orderNum . ", " . $amount . ", 0, " . $timespan . ", " . $dependencyId . ")";

            $mysqli->query($query);
            $newId = last_insert_id('challenge_rules');
        } else {
            $query = "UPDATE challenge_rules SET challenge_id=" . $challengeId . ", name='" . $name . "', machine='" . $machine .
                       "', order_num=" . $orderNum . ", amount=" . $amount . ", timespan='" . $timespan . "', dependency=" . $dependencyId . " WHERE id=" . $ruleId;
            $mysqli->query($query);
        }

        $rule = $this->getChallengeRuleById($newId);
        return $rule;
    }

    function deleteChallengeRule($ruleId) {
        global $mysqli;
        $query = "DELETE from challenge_rules where ID=" . $ruleId;
        $mysqli->query($query);
    }

    //called when a group adds or removes players
    //TODO: if we eventually store all rules upon group inception, need to change this to update them
    //all, not just the current rule/challenge
    function recalculateGroupChallenge($groupId) {
        global $mysqli;
		global $groupMgr;

        //get current challenge
        $group = $groupMgr->getGroup($groupId);
        $details = $group->challengeDetails;
        if($details == null)
            return;

        $rule = $this->getChallengeRule($details->challenge->id, $details->tierNum);

        //if the current rule has already met its target, do nothing
        if($details->target == $details->balance)
            return;

        //new challenge total:
        $newTargetAmount = $this->calculateChallengeCost($groupId, $details->challengeQuantity, $details->reward->id,
                $details->rematchNum, $details->challenge->challengeType, $details->challenge->id, $rule);

        $this->updateChallengeDetails($details->id, $details->balance, $newTargetAmount);
    }
	
	// Return whether or not the current challenge rule's timespan has expired
	function isChallengeRuleExpired($challenge_rule_id) {
		$query = <<<'SQL'
SELECT
	timestampadd(HOUR, cr.timespan, c.time_created) <= CURRENT_TIMESTAMP
FROM
	challenge c
	JOIN challenge_rules cr ON c.id = cr.challenge_id
WHERE
	c.active = 1
	AND cr.id = ?
SQL;
		$stmt = $GLOBALS['mysqli']->prepare($query);
		$stmt->bind_param('i', $challenge_rule_id);
		$stmt->execute();
		$stmt->bind_result($expired);
		$stmt->fetch();
		$stmt->close();
		
		if($expired === 1) {
			return true;
		}
		return false;
	}
	
	// Award a group prize(s) (triggered when completing a challenge)
	function awardPrize($group_id) {
		$players = getPlayersInGroup($group_id);
		$reward_id = $GLOBALS['groupMgr']->getRewardID($group_id);
		
		foreach($players as $player) {
			$hashCode = hash(
				'crc32',
				(string)$group_id + (string)$player->id + (string)$reward_id,
				false
			);
			
			// Check if this prize has been awarded already; if not, do so
			$query = <<<'SQL'
SELECT
	count(*)
FROM
	redeem_codes
WHERE
	code = ?
SQL;
			$stmt = $GLOBALS['mysqli']->prepare($query);
			$stmt->bind_param('s', $hashCode);
			$stmt->execute();
			$stmt->bind_result($alreadyAwarded);
			$stmt->fetch();
			$stmt->close();
			if($alreadyAwarded === 0) {
				$query = <<<'SQL'
INSERT INTO redeem_codes (player_id, pgroup_id, code, redeemed, reward_id)
VALUES (?, ?, ?, 0, ?)
SQL;
				$stmt = $GLOBALS['mysqli']->prepare($query);
				$stmt->bind_param('iisi', $player->id, $group_id, $hashCode, $reward_id);
				$stmt->execute();
				$stmt->close();
			} else {
				gs_error_log('Player #' . $player->id . ' has already been awarded reward #' . $reward_id);
			}
		}
	}
}

class GroupChallengeDetails {
    public $id;
    public $groupId;
    public $challengeId; //the challenge 'template' instance, TODO: remove, redundant from #challenge
    public $challenge; //challenge instance
    public $challengeQuantity; //single or group
    public $reward;
    public $totalRewardTarget;
    public $balance; //earnings toward this instance
    public $balanceSum; //total across all challenge instances/rules
    public $target; //goal to complete this instance
    public $tierNum; //rule number for scavenger, tier for tournaments
    public $rematchNum; //if it's a scavenger hunt rematch
}

class ChallengeSummary {
    public $id;
    public $name;
    public $description;
}

//templates
class Challenge {
    public $id;
    public $name;
    public $challengeType; //scavenger or tournament
    public $active;
    public $rules; //array of ChallengeRule
}

//for single-click instances
class ChallengeInstance {
	public $id;
	public $active;
	public $name;
	public $challengeId;
	public $challengeQuantity;
	public $rewardId;
	public $timeCreated;
}

class ChallengeRule {
    public $id;
    public $challengeId;
    public $amount;
    public $active;
    public $machine; //name or id
    public $orderNum; //sorting
    public $timespan;
    public $depedencyId; //id for previous or other dependency
}


//enums
class ChallengeQuantity
{
    const Single = 0;
    const Group = 1;
}

class ChallengeType
{
    const Regular = 0;
    const Scavenger = 1;
    const Tournament = 2;
}
?>