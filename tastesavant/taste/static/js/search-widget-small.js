function isIE() {
  return /msie/i.test(navigator.userAgent) && !/opera/i.test(navigator.userAgent);
}

base_url = window.location.protocol + '//' + window.location.host + '/search/advanced/';

function populateQueryString(field) {
    values = $(document.body).getElements('input[name='+field+']:checked');
    var txt = $(document.body).getElement('input[name='+field+'_qs]');
    if (values.length != 0) {
        values = values.map(function(e) { return e.value; });
        var qs = new QueryStringBuilder();
        var name = field

        Array.each(values, function(val, index) {
            qs.add(name, val);
        });

        var querystr = qs.toQueryString();
        txt.set('value', querystr);
    }
    else {
        txt.set('value', '');
    }
}

window.addEvent('load', function() {
    populateQueryString('price');
    populateQueryString('neighborhood');
    populateQueryString('cuisine');
    populateQueryString('occasion');
    var populateText = function(content, elem) {
        var selected = content.getElements('input:checked');
        var cuisines = '';
        selected.each(function(el, index) {
            if(el.get('class') != 'select-all-checkbox') {
                value = el.getParent().get('text').trim();
                if (selected.getLast() == el) {
                    cuisines = cuisines + value
                } else {
                    cuisines = cuisines + value + ', '
                }
            }
        });

        if (cuisines) {
            if (cuisines.length > 28) {
                cuisines = cuisines.slice(0, 28) + "...";
            }
            elem.set('value', cuisines);
        } else {
            if (content == $('neighborhood-content')) {
                elem.set('value', 'Neighborhood');
            } else if (content == $('cuisine-content')) {
                elem.set('value', 'Cuisine');
            } else if (content == $('occasion-content')) {
                elem.set('value', 'Occasion');
            }
        }
    };

    populateText($('occasion-content'), $('occasion-box'));
    populateText($('neighborhood-content'), $('neighborhood-box'));
    populateText($('cuisine-content'), $('cuisine-box'));

    var top_offset = 200;

    /* If there's an image carousel, then the modals have to be set lower. */
    if (Boolean($('image-carousel'))) {
        top_offset = top_offset + 220;
    }

    // Can we pack the neighborhoods here and now, and size accordingly?
    var w_and_h = ({
        'Chicago':     {w: 400, h: 397},
        'New York':    {w: 540, h: 373},
        'London':      {w: 1, h: 1},
        'Los Angeles': {w: 540, h: 373},
        'Boston':      {w: 540, h: 330},
        'Brooklyn':    {w: 365, h: 340}
    })[$('city-select-dropdown').getChildren('span').get('html')[0]];

    var neighborhood_width = w_and_h['w'];
    var neighborhood_height = w_and_h['h'];

    var neighborhood_modal = new FloatBoxSmallWidget($('neighborhood-content'), {
        size: {
            x: neighborhood_width,
            y: neighborhood_height
        },
        top: top_offset,
        left: 267
    });
    $('neighborhood-box').addEvent('click',
        function(event){
        	this.blur();
            event.preventDefault();
            neighborhood_modal.show();
            $('neighborhood-arrow').show();
            // masonry_box('neighborhood');  // Don't masonize this! Instead:
            floatify(jQuery('.controls.neighborhood'));
    });

    neighborhood_modal.addEvent('save', function(){
        populateText($('neighborhood-content'), $('neighborhood-box'));
    });

    var w_and_h = {w: 435, h: 435}  // We set this manually, as packing failed.

    var cuisine_width = w_and_h['w'];
    var cuisine_height = w_and_h['h'];

    var cuisine_modal = new FloatBoxSmallWidget($('cuisine-content'), {
        size: {
            x: cuisine_width,
            y: cuisine_height
        },
        top: top_offset,
        left: 267
    });
    $('cuisine-box').addEvent('click',
        function(event){
            this.blur();
            event.preventDefault();
            cuisine_modal.show();
            $('cuisine-arrow').show();
            // masonry_box('cuisine');  // Don't masonize this! Instead:
            floatify(jQuery('.controls.cuisine'));
    });

    cuisine_modal.addEvent('save', function(){
        populateText($('cuisine-content'), $('cuisine-box'));
    });

    var w_and_h = pack_box('#occasion-content', 'ul');  // From FloatBox.js

    var occasion_width = w_and_h['w'];
    var occasion_height = w_and_h['h'];

    var occasion_modal = new FloatBoxSmallWidget($('occasion-content'), {
        size: {
            x: occasion_width,
            y: occasion_height
        },
        top: top_offset,
        left: 267
    });
    $('occasion-box').addEvent('click',
        function(event){
            this.blur();
            event.preventDefault();
            occasion_modal.show();
            $('occasion-arrow').show();
    });

    occasion_modal.addEvent('save', function(){
        populateText($('occasion-content'), $('occasion-box'));
    });

	//set price search
	var numberArray = ['one','two','three','four','five'];
	for(var z = 0; z<5; z++){
		if($('id_price_'+z).checked == true){
			$(numberArray[z]).addClass('on');
		}
	}

	//price click event
    $('priceContainer-small').getElements('li').addEvent('click', function () {
    	//temp clicked id
    	var tempID = this.id;

		if(this.hasClass('on')){
			this.removeClass('on');
			this.addClass('unselected');

			//uncheck unclicked
			if(tempID == 'one'){
				$('id_price_0').checked = false;
			}else if(tempID == 'two'){
				$('id_price_1').checked = false;
			}else if(tempID == 'three'){
				$('id_price_2').checked = false;
			}else if(tempID == 'four'){
				$('id_price_3').checked = false;
			}else{
				$('id_price_4').checked = false;
			}

		}else{
			this.addClass('on');
			this.removeClass('unselected');

			//check clicked
			if(tempID == 'one'){
				$('id_price_0').checked = true;
			}else if(tempID == 'two'){
				$('id_price_1').checked = true;
			}else if(tempID == 'three'){
				$('id_price_2').checked = true;
			}else if(tempID == 'four'){
				$('id_price_3').checked = true;
			}else{
				$('id_price_4').checked = true;
			}
		}
        populateQueryString('price');
	});

	//on mouseleave remove class to make unclicked white rather then hover state
	$('priceContainer-small').getElements('li').addEvent('mouseleave', function (){
		this.removeClass('unselected');
	});

    if ($('search-widget-form')) {
        var form = $('search-widget-form');
        form.getElement('input[type=submit]').addEvent('click', function(e){
            e.stop();
            querystring = '?sort=critic'
            values = $(document.body).getElements('input[name$=_qs]').map(function(e) { return e.value; });
            Array.each(values, function(val, index) {
                if (val != '') {
                    querystring = querystring.concat('&' + val)
                }
            });
            window.location=base_url + querystring;
        });
    }
});

