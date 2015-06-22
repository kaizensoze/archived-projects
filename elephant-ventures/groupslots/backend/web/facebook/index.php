<html>
<head>
  <link type="text/css" href="css/blitzer/jquery-ui-1.8.16.custom.css" rel="stylesheet" />    
  <script type="text/javascript" src="js/jquery-1.6.2.min.js"></script>
  <script type="text/javascript" src="js/jquery-ui-1.8.16.custom.min.js"></script>
  <script type="text/javascript" src="../js/slot.js"></script>
</head>
<body>

<?php

require '../FacebookPHP/facebook.php';
require '../admin/helper.php';

$log = new log();

try {

$signed_request = $_REQUEST["signed_request"];
list($encoded_sig, $payload) = explode('.', $signed_request, 2);
$data = json_decode(base64_decode(strtr($payload, '-_', '+/')), true);
$to = $data["user_id"];

$facebook = new Facebook(array(
  'appId' => '161380047292117',
  'secret' => '964d0b7f497ec5b2c8bbbb627b28e693',
));

$request_ids = $_REQUEST["request_ids"];
$request_id_array = explode(",", $request_ids);
$request_id_to_choose = end($request_id_array);

$full_app_request_id = $request_id_to_choose . "_" . $to;

$request = $facebook->api($full_app_request_id);

//$log->general(print_r($request));

$from_id = $request["from"]["id"];
$from_name = $request["from"]["name"];

}
catch (Exception $ex) {
  $log->general("Exception: " . $ex->getMessage());
}

?>

<h1 id="msg" style="display: none;">You are now in <?= $from_name ?>'s group.</h1>
<div id="dialog">
  <p>Join <?= $from_name ?>'s group?</p>
</div>
<script type="text/javascript">
  $(function(){
      $('#dialog').dialog({
          autoOpen: false,
          width: 300,
          draggable: true,
          buttons: {
              "NO": function() { 
                  $(this).dialog("close"); 
              },
              "YES": function() {
                var data = {
                  userA : '<?= $from_id ?>',
                  userB : '<?= $to ?>',
                  appRequest : '<?= $full_app_request_id ?>'
                };
                console.log(data);
                fbExecuteAction({
                  sAction : 'tryJoinGroupFromFacebook',
                  oAjaxSettings : {
                    data : data,
                    success : function() {
                       $('#msg').show();
                    }
                  }
                });
                $(this).dialog("close"); 
              }
          }
      });
      $('#dialog').dialog('open');
  });
</script>
*/

<img src="/images/groupslots.jpg"><br>

</body>
</html>
