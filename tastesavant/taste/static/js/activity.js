function pagination(direction, _prefix) {
    var prefix = typeof _prefix !== 'undefined' ? _prefix + "-" : "";

    var curr = $(prefix + 'pagination-curr');
    var next = $(prefix + 'pagination-next');
    var prev = $(prefix + 'pagination-prev');
    var current = parseInt(curr.get('value'));
    var pages = parseInt($(prefix + 'num-pages').get('value'));
    var updated = false;

    if (direction == 'next' && current < pages) {
        current++;
        updated = true;
    }
    if (direction == 'prev' && current > 1) {
        current--;
        updated = true;
    }
    if (updated == true) {
        curr.set('value', current);
        if (current < pages) {
            next.set('value', current + 1);
        }
        if (current > 1) {
            prev.set('value', current - 1);
        }
    }
}

if ($('activity-next-page')) {
    $('activity-next-page').addEvent('click', function(event){
        event.stop();
        var pg_next = $('pagination-next').get('value');
        var HTMLRequest = new Request.HTML({
            url:'/activity/',
            async: false,
            noCache: true,
            onSuccess: function(tree, elements, html) {
                pagination('next');
                $('ajax_stream').set('html', html);
            }
        }).get({'page': pg_next});
    });

    $('activity-prev-page').addEvent('click', function(event){
        event.stop();
        var pg_prev = $('pagination-prev').get('value');
        var HTMLRequest = new Request.HTML({
            url:'/activity/',
            async: false,
            noCache: true,
            onSuccess: function(tree, elements, html) {
                pagination('prev');
                $('ajax_stream').set('html', html);
            }
        }).get({'page': pg_prev});
    });
}

if ($('following-next-page')) {
    $('following-next-page').addEvent('click', function(event){
        event.stop();
        var pg_next = $('following-pagination-next').get('value');
        var HTMLRequest = new Request.HTML({
            async: false,
            noCache: true,
            url:'/profiles/' + username + '/friends',
            onSuccess: function(tree, elements, html) {
                pagination('next', 'following');
                $('following_ajax_stream').set('html', html);
            }
        }).get({'page': pg_next});
    });

    $('following-prev-page').addEvent('click', function(event){
        event.stop();
        var pg_prev = $('following-pagination-prev').get('value');
        var HTMLRequest = new Request.HTML({
            url:'/profiles/' + username + '/friends',
            async: false,
            noCache: true,
            onSuccess: function(tree, elements, html) {
                pagination('prev', 'following');
                $('following_ajax_stream').set('html', html);
            }
        }).get({'page': pg_prev});
    });
}

if ($('followers-next-page')) {
    $('followers-next-page').addEvent('click', function(event){
        event.stop();
        var pg_next = $('followers-pagination-next').get('value');
        var HTMLRequest = new Request.HTML({
            async: false,
            noCache: true,
            url: '/profiles/' + username + '/followers',
            onSuccess: function(tree, elements, html) {
                pagination('next', 'followers');
                $('followers_ajax_stream').set('html', html);
            }
        }).get({'page': pg_next});
    });

    $('followers-prev-page').addEvent('click', function(event){
        event.stop();
        var pg_prev = $('followers-pagination-prev').get('value');
        var HTMLRequest = new Request.HTML({
            url:'/profiles/' + username + '/followers',
            async: false,
            noCache: true,
            onSuccess: function(tree, elements, html) {
                pagination('prev', 'followers');
                $('followers_ajax_stream').set('html', html);
            }
        }).get({'page': pg_prev});
    });
}
