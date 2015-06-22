var FloatBoxPlus = new Class({
    Extends: FloatBox,
    initialize: function (elem, options) {
        this.tmp = new Element('div');
        this.elem = elem;
        elem.getChildren().inject(this.tmp);
        this.setOptions(options);
        this.createBox(this.tmp);
        this.attachEvents();
    },
    createBox: function (elem) {
        var save = new Element('div', {
            'class': 'save save-box'
        });
        var screen_size = Window.getSize();
        var top = (screen_size.y - this.options.size.y) / 4;
        var side = (this.options.rtl) ? 'right' : 'left';
        var side_p = (screen_size.x - this.options.size.x) / 2;
        elem.addClass('box-contained');
        this.box = new Element('div', {
            'class': 'box-container'
        });
        elem.setStyles({
            height: this.options.size.y,
            width: this.options.size.x
        });
        elem.adopt(save);
        this.box.adopt(elem).setStyles({
            'padding-top': top,
            'padding-right': side_p,
            'padding-left': side_p
        });
    },
    save: function () {
        this.elem.empty();
        var content = this.tmp.clone();
        content.inject(this.elem);
        this.fireEvent('save');
        this.hide();
    },
    attachEvents: function () {
        this.box.getElements('.save').addEvent('click', this.save.bind(this));
    },
    resize: function (x, y) {
        var screen_size = Window.getSize(),
            side = this.options.rtl ? 'right' : 'left',
            padd = (screen_size.x - x) / 2,
            top = (screen_size.y - y) / 2,
            new_padd = {
                'padding-top': top
            },
            new_close = {
                top: top + 10
            };
        new_padd['padding-' + side] = padd;
        this.box.morph(new_padd);
        new_close[side] = padd + 10;
        this.box.getElement('.close-box').morph(new_close);
        this.box.getElement('.box-contained').morph({
            height: y,
            width: x
        });
    }
});

window.addEvent('domready', function () {
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

    var neighborhood_modal = new FloatBoxPlus($('neighborhood-content'), {
        size: {
            x: neighborhood_width,
            y: neighborhood_height
        }
    });
    $('neighborhood-box').addEvent('click', function (event) {
    	this.blur();
        event.preventDefault();
        modalDelay1 = setTimeout(function(){
            clearTimeout(modalDelay1);
            neighborhood_modal.show();
            // masonry_box('neighborhood');  // Don't masonize this! Instead:
            floatify(jQuery('.controls.neighborhood'));
        }, 600);
    });
    neighborhood_modal.addEvent('save', function () {
        var selected = $('neighborhood-content').getElements('input:checked');
        var neighborhoods = '';
        selected.each(function (el, index) {
            if (el.get('class') != 'select-all-checkbox') {
                value = el.getParent().get('text').trim();
                if (selected.getLast() == el) {
                    neighborhoods = neighborhoods + value;
                } else {
                    neighborhoods = neighborhoods + value + ', ';
                }
            }
        });
        if (neighborhoods) {
            if (neighborhoods.length > 35) {
                neighborhoods = neighborhoods.slice(0, 35) + '...';
            }
            $('neighborhood-box').set('value', neighborhoods);
        }
        if (neighborhoods == '') {
            $('neighborhood-box').set('value', 'Neighborhood');
        }
    });


    var w_and_h = {w: 435, h: 435}  // We set this manually, as packing failed.

    var cuisine_width = w_and_h['w'];
    var cuisine_height = w_and_h['h'];

    var cuisine_modal = new FloatBoxPlus($('cuisine-content'), {
        size: {
            x: cuisine_width,
            y: cuisine_height
        }
    });
    $('cuisine-box').addEvent('click', function (event) {
        this.blur();
        event.preventDefault();
        modalDelay2 = setTimeout(function(){
            clearTimeout(modalDelay2);
            cuisine_modal.show();
            // masonry_box('cuisine');  // Don't masonize this! Instead:
            floatify(jQuery('.controls.cuisine'));
        }, 600);
    });
    cuisine_modal.addEvent('save', function () {
        var selected = $('cuisine-content').getElements('input:checked');
        var cuisines = '';
        selected.each(function (el, index) {
            if (el.get('class') != 'select-all-checkbox') {
                value = el.getParent().get('text').trim();
                if (selected.getLast() == el) {
                    cuisines = cuisines + value;
                } else {
                    cuisines = cuisines + value + ', ';
                }
            }
        });
        if (cuisines) {
            if (cuisines.length > 35) {
                cuisines = cuisines.slice(0, 35) + '...';
            }
            $('cuisine-box').set('value', cuisines);
        }
        if (cuisines == '') {
            $('cuisine-box').set('value', 'Cuisine');
        }
    });

    var w_and_h = pack_box('#occasion-content', 'ul');  // From FloatBox.js

    var occasion_width = w_and_h['w'];
    var occasion_height = w_and_h['h'];

    var occasion_modal = new FloatBoxPlus($('occasion-content'), {
        size: {
            x: occasion_width,
            y: occasion_height
        }
    });
    $('occasion-box').addEvent('click', function (event) {
        this.blur();
        event.preventDefault();
        modalDelay3 = setTimeout(function(){
            clearTimeout(modalDelay3);
            occasion_modal.show();
        }, 600);
    });
    occasion_modal.addEvent('save', function () {
        var selected = $('occasion-content').getElements('input:checked');
        var occasions = '';
        selected.each(function (el, index) {
            value = el.getParent().get('text').trim();
            if (selected.getLast() == el) {
                occasions = occasions + value;
            } else {
                occasions = occasions + value + ', ';
            }
        });
        if (occasions) {
            if (occasions.length > 35) {
                occasions = occasions.slice(0, 35) + '...';
            }
            $('occasion-box').set('value', occasions);
        }
        if (occasions == '') {
            $('occasion-box').set('value', 'Occasion');
        }
    });

    //price click event
    $('priceContainer').getElements('li').addEvent('click', function () {
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
	});

	//on mouseleave remove class to make unclicked white rather then hover state
	$('priceContainer').getElements('li').addEvent('mouseleave', function (){
		this.removeClass('unselected');
	});

    /* Make the Who to Follow box a scrollable carousel, if it exists. */
    if (Boolean($('follow_suggestions'))) {
        suggestions_carousel = new Fx.Scroll.Carousel('follow-suggestions-carousel', {
            mode: 'horizontal',
            childSelector: 'div.follow-suggestions-element'
        });
        $('follow_suggestions_left_arrow').addEvent('click', function(event) {
            event.preventDefault();
            event.stop();
            suggestions_carousel.toPrevious();
        });
        $('follow_suggestions_right_arrow').addEvent('click', function(event) {
            event.preventDefault();
            event.stop();
            suggestions_carousel.toNext();
        });
    }
});
