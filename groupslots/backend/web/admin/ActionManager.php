<?php

// Receives calls from service layer, directs them to appropriate classes

class ActionManager {
    function handleAction($action) {
        global $challengeMgr, $groupMgr, $rewardMgr, $userMgr;

        if(isset($action)) {
            switch($action) {
				case 'setBrand':
					$brand = get_post('brand');
					$_SESSION['brand'] = $brand;
					break;
				
                case 'getActiveGroup': //legacy
                    $cardId = get_post('card_id');
                    $groupId = $groupMgr->getActiveGroup($cardId);
                    echo json_encode($groupId);
                    break;
				
                case 'login': //legacy
                    $card_id = get_post('card_id');
                    $password = get_post('password');
                    $token = get_post('token');
					$result = $userMgr->login($card_id, $password, $token);
					echo json_encode($result);
					break;
				
                case 'logout': //legacy
                    $card_id = get_post('card_id');
                    $userMgr->logout($card_id);
                    break;
                case 'register': //legacy
                    $name = get_post('name');
                    $casino = get_post('casino');
                    $card_id = get_post('card_id');
                    $result = $userMgr->register($name, $casino, $card_id);
                    echo json_encode($result);
                    break;
                case 'getGroups':
                    $groups = $groupMgr->getGroups();
                    echo json_encode($groups);
                    break;
                case 'tryJoinGroup':
                    $userA = get_post('userA');
                    $userB = get_post('userB');
                    $groupId = $groupMgr->tryJoinGroup($userA, $userB);
                    echo $groupId;
                    break;
                case 'tryJoinGroupFromFacebook':
                    $fbUserA = get_post('userA');
                    $fbUserB = get_post('userB');
                    $appRequest = get_post('appRequest');
                    $groupId = $groupMgr->tryJoinGroupFromFacebook($fbUserA, $fbUserB, $appRequest);
					echo $groupId;
                    break;
                case 'deleteGroup':
					$cardId = get_post('cardId');
					$group = $groupMgr->getGroupFromCardId($cardId);
					$groupMgr->deleteGroup($group->id);
					break;
				case 'deleteGroupByID':
					$groupMgr->deleteGroup($_REQUEST['group_id']);
					break;
                case 'startChallenge':
                    $groupId = get_post('group_id');
                    $challengeQty = get_post('challenge_qty');
                    $rewardId = get_post('reward_id');
                    $challengeType = get_post('challenge_type');
                    $challengeId = get_post('challenge_id');
                    $challengeMgr->tryStartChallenge($groupId, $challengeQty, $rewardId, $challengeType, $challengeId);
                    break;
                case 'saveChallenge':
					$challengeId = get_post('challengeId');
					$name = get_post('name');
					$active = get_post('active');
					$challengeType = get_post('type');
					$challenge = $challengeMgr->saveChallenge($challengeId, $name, $active, $challengeType);
					echo json_encode($challenge);
					break;
				case 'saveChallengeInstance':
					$instanceId = get_post('id');
					$name = get_post('name');
					$challengeId = get_post('challengeId');
					$rewardId = get_post('rewardId');
					$challengeQuantity = get_post('challengeQuantity');
					$active = get_post('active');
					$instance = $challengeMgr->saveChallengeInstance($instanceId, $name, $challengeId, $rewardId, $challengeQuantity, $active);
					echo json_encode($instance);
					break;
				case 'deleteChallengeInstance':
					$id = get_post('id');
					$challengeMgr->deleteChallengeInstance($id);
					break;
                case 'deleteChallenge':
                    $challengeId = get_post('challengeId');
                    $challengeMgr->deleteChallenge($challengeId);
                    break;
                case 'saveChallengeRule':
                    $challengeId = get_post('challengeId');
                    $ruleId = get_post('ruleId');
                    $amount = get_post('amount');
                    $machine = get_post('machine');
                    $timespan = get_post('timespan');
                    $orderNum = get_post('orderNum');
                    $dependencyId = get_post('dependency');
                    $rule = $challengeMgr->saveChallengeRule($ruleId, $challengeId, $amount, $machine, $timespan, $orderNum, $dependencyId);
                    echo json_encode($rule);
                    break;
                case 'deleteChallengeRule':
                    $ruleId = get_post('ruleId');
                    $challengeMgr->deleteChallengeRule($ruleId);
                    break;
	        	case 'getRewards':
		            echo json_encode($rewardMgr->getRewards());
                    break;
                case 'saveReward':
                    $rewardId = get_post('id');
                    $name = get_post('name');
                    $user_amount = get_post('user_amount');
                    $active = get_post('active');
                    $invControlled = get_post('inv');
                    $invAmount = get_post('invAmount');
                    $time = get_post('time');
                    $reward = $rewardMgr->saveReward($rewardId, $name, $user_amount, $active, $invControlled, $invAmount, $time);
                    echo json_encode($reward);
                    break;
                case 'registerPoints':
                    $cardId = get_post('cardId');
                    $amount = get_post('amount');
					$machine_id = get_post('machine_id');
                    $challengeMgr->registerPoints($cardId, $amount, $machine_id);
                    break;
                case 'save-comp':
                    save_comp();
                    break;
                case 'delete-comp':
                    delete_comp();
                    break;
                case 'get-group':
                    $id = get_post("groupId");
                    $group = get_group($id);
                    echo json_encode($group);
                    break;
                case 'get-groups':
                    $groups = get_groups();
                    echo json_encode($groups);
                    break;
                case 'get-events':
                    $events = get_events();
                    echo json_encode($events);
                    break;
                case 'get-active-users':
                    $numUsers = get_active_users();
                    echo json_encode($numUsers);
                    break;
                case 'reset-data':
                    reset_data();
                    break;
                case 'invite-email':
                    $email = get_post("email");
                    $userId = get_post("userId");
                    invite_email($email, $userId);
                    break;
                case 'join-email':
                    echo 'join email';
                    $email = get_post("invitee_email");
                    $token = get_post("invitee_token");
                    join_email($email, $token);
                    break;
                case 'register-to-group':
                    $email = get_post("email");
                    $token = get_post("token");
                    $username = get_post("username");
                    $cardid = get_post("cardid");
                    $fbid = get_post("fbid");
                    register_to_group($email, $token, $username, $cardid, $fbid);
                    break;
                case 'redeem-reward':
                    $rid = get_post("rid");
                    redeem_reward($rid);
                    break;
                case 'submit-app-message':
                    $msg = get_post("message");
                    $isNotification = get_post("notification");
                    $isScrollMessage = get_post("scrollMessage");
                    submit_app_message($msg, $isNotification, $isScrollMessage);
                    break;
                case 'activate-message':
                    $mid = get_post("mid");
                    activate_message($mid);
                    break;
                case 'deactivate-message':
                    $mid = get_post("mid");
                    deactivate_message($mid);
                    break;
                case 'delete-message':
                    $mid = get_post("mid");
                    delete_message($mid);
					break;
				case 'getNameInfo':
					$card_id = get_post('card_id');
					$result = getNameInfo($card_id);
					echo json_encode($result);
					break;
				case 'setFbId':
					$card_id = get_post('card_id');
					$fb_id = get_post('fb_id');
					setFbId($card_id, $fb_id);
					break;
				case 'getFbUsers':
					$fb_ids = getFbUsers();
					echo json_encode($fb_ids);
					break;
				case 'getMessages':
					$messages_str = getMessages();
					echo json_encode($messages_str);
					break;
				case 'getPlayerRewards':
					error_log("Fetching player rewards");
					$card_id = get_post('card_id');
					$user_rewards_result_str = getPlayerRewards($card_id);
					echo json_encode(array("val"=>$user_rewards_result_str));
					break;
				case 'getUpdate':
					$group_id = get_post('group_id');
					$result = getUpdate($group_id);
					echo json_encode($result);
					break;
				case 'getChallengeRewardSummary':
					$result = $challengeMgr->getChallengeRewardSummary();
					echo json_encode($result);
					break;
				default:
					echo 'Action not supported.';
            }
        }
    }
}

//TODO: package up actions?

?>
