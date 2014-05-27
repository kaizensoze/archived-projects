<?php
$page = 'messages';
include('header.php');

$messages = get_app_messages();
?>

<div class="help-blurb">
	<div class="controls"><a href="#" id="hide">hide</a></div>
	<span class="bold">Messages</span> come in two flavors: those sent to the mobile device as a one-time notification to all players,
    and those which can be setup to be continuously scrolled along the bottom of the mobile app.
</div>

<div class="page">

 
<div class="col-left section">
    <div class="section-title" style="width: 800px;">Messages</div>
    <div class="search">
        <span class="label2">Enter a New Message:</span><div class="fixer"></div>
        <input type="text" id="message" style="width: 400px;"></input><br/>
        <input class="col-left" type="checkbox" id="send_immediately"></input><span class="label2">Send to all players now, as a notification</span>
        <div class="fixer"></div>
        <input class="col-left" type="checkbox" id="scroll_message"></input><span class="label2">Save to messaging queue</span>
        <div class="fixer" style="height: 10px;"></div>
        <a class="button button-red col-left" id="submit" href="#" style="width: 140px; position: relative; top: -1px;">Submit Message</a>
    </div>
</div>

<div class="results">
    <div class="fixer" style="height: 30px;"></div>
    <div class="section-title" style="width: 680px;">
        Current Messages
        <a class="button button-red col-right" id="delete" href="#" style="width: 80px; position: relative; top: -1px; margin-left: 4px;">Delete</a>
        <a class="button button-red col-right" id="activate" href="#" style="width: 80px; position: relative; top: -1px; margin-left: 4px;">Activate</a>
        <a class="button button-red col-right" id="deactivate" href="#" style="width: 80px; position: relative; top: -1px;">Deactivate</a>
        <span class="col-right" style="font-weight: normal; margin: 0px 8px 2px 0px; color: #665; text-transform: lowercase; font-size: 7pt;">selected:</span>
    </div>
    
    <table class="table" cellpadding="0" cellspacing="0" id="group-table">
        <thead>
            <tr>
                <th style="max-width: 40px;"></th>
                <th style="width: 400px;">Message</td>
                <th style="width: 80px;">Active</td>
                <th style="width: 140px;">Created</td>
            </tr>
        </thead>
        <?php foreach($messages as $m) { ?>
            <tr class="row">
                <td style="padding: 0px 4px 0px 4px; text-align: center; max-with: 20px;"><input type="checkbox" class="cb" id="<?= $m->id ?>"></input></td>
                <td class="label2">"<?= $m->message ?>"</td>
                <td class="label2 active" style="text-align: center;" ><?php if($m->is_active == true) { echo 'yes'; } else { echo '-'; } ?></td>
                <td class="label2"><?= $m->time_created ?></td>
            </tr>
        <?php } ?>
    </table>
    
    <div class="fixer" style="height: 10px;"></div>
</div>

<script type="text/javascript">
$("document").ready(function() {
    var submit = $("#submit");
    var activate = $("#activate");
    var deactivate = $("#deactivate");
    var deletes = $("#delete");
    var trs = $(".table tr.row");
    
    trs.click(function() {
        var cb = $(this).find(".cb");
        if(cb.is(":checked")) {
            cb.removeAttr("checked");
        } else {
            cb.attr("checked", "true");
        }
    });
    
    submit.click(function() {
        var message = $("#message").val();
        
        var isNotification = typeof $("#send_immediately").attr("checked") != 'undefined';
        var isScrollMessage = typeof $("#scroll_message").attr("checked") != 'undefined';
        
        var data = "action=submit-app-message&message=" + message + "&notification=" + isNotification + "&scrollMessage=" + isScrollMessage;
        App.Service.request({
            data: data,
            callback: function(result){
                window.location.reload();
            }
        });
    });
    
    activate.click(function() {
        $(".table .cb").each(function() {
            var el = $(this);
            var tr = el.parents("tr");
            if(el.is(":checked")) {
                var id = el.attr('id');
                var data = "action=activate-message&mid=" + id;
                App.Service.request({
                    data: data,
                    callback: function(result){
                        tr.find(".active").text('active');
                    }
                });
            }
        })
    });
    
    deactivate.click(function() {
        var isLast = false;
        $(".table .cb").each(function(i, e) {
            var el = $(this);
            var tr = el.parents("tr");
            if(el.is(":checked")) {
                var id = el.attr('id');
                var data = "action=deactivate-message&mid=" + id;
                App.Service.request({
                    data: data,
                    callback: function(result){
                        tr.find(".active").text('-');
                    }
                });
            }
        })
    });
    
    deletes.click(function() {
        var isLast = false;
        $(".table .cb").each(function(e, i) {
            var el = $(this);
            var tr = el.parents("tr");
            if(el.is(":checked")) {
                var id = el.attr('id');
                var data = "action=delete-message&mid=" + id;
                App.Service.request({
                    data: data,
                    callback: function(result){
                        tr.remove();
                    }
                });
            }
        })
    })
});
</script>
 
<?php
include('footer.php');
?>