/* From http://www.nitinh.com/2010/01/vertical-align-middle-using-javascript-jquery-mootools/ */

vAlign = new Class({

    initialize: function(element){
        this.element = $(element);

        var div = new Element('div', {
                    'class': 'nitinh-vAlign',
                    'styles': {
                        'position': 'relative'
                    }
                });

        div.set({ 'html': this.element.get('html') })
        this.element.set({'html':''})
        div.inject(this.element);

        var ph = this.element.getSize().y;
        var dh = div.getSize().y;
        var mh = (ph - dh) / 2;
        div.set('styles',{
            'top':mh
        });
    }
});

window.addEvent('domready', function() {
    if ($('login-box')) {
        var login_modal = new FloatBoxLogin($('login-box'), {
            size: {
                x: 600,
                y: 300
            }
        });

        $$('.login').addEvent('click', function(evt) {
            evt.preventDefault();
            showLoginModal();
        });

        function showLoginModal() {
            $$('.overlay').removeClass('hide');
            login_modal.show();
            document.getElementById("id_username").focus();
        }
    }

    var FormValidator = new Form.Validator.Tips($('theform'));
    $('id_address').set('value', 'Enter Your Email');
    $('id_address').addEvent('focus', function(event) {
        if (this.value == 'Enter Your Email') {
            this.value = '';
        }
        advices = $('theform').retrieve('validator').advices;
        for (i = 0; i < advices.length; i++) {
            advices[i].hide();
        }
    });

    $('id_query').addEvent('click', function(){
        this.value = '';
        this.removeEvents('click');
    });

    new Autocompleter.Request.JSON('id_query', '/search/autocomplete/', {
        'postVar': 'q',
        minLength: 2,
        maxChoices: 15,
        autoSubmit: false,
        cache: true,
        delay: 0,
        onRequest: function() {
          $('id_query').setStyles({
            'background-position':'350px 7px',
            'background-repeat':'no-repeat'
          });
        },
        onSelect: function()
        {
            var selected = this.selected.get('text')
            $$('.autocompleter-choices').getElements('li')[0].each(function(el, i){
                if($$('.autocompleter-choices').getChildren()[0][i].get('text') == selected)
                {
                    $$('.autocompleter-choices').getElements('li')[0][i].setStyle('background', 'gray');
                }
                else{
                    $$('.autocompleter-choices').getElements('li')[0][i].setStyle('background', '');
                }
            });
        },
        onComplete: function() {
          $('id_query').setStyle('background','');
        }
    });

    if ($('compose-modal')) {
        compose_modal = new FloatBoxCompose($('compose-modal'), {
            size:{x:460,y:'380'}
        });


        if($('compose-new-message')) {
            $('compose-new-message').addEvent('click', function(event){
                event.preventDefault();

                compose_modal.show();
                $$('.token-input-list').setStyle('background-image', 'url(\'/media/images/input-help.png?e74f75003a0f\') no-repeat 6px 5px');
            });
        }

        if($('compose-container')) {
            $('compose-container').addEvent('click', function(event){
                event.preventDefault();
                compose_modal.show();
                $$('.token-input-list').setStyle('background', 'url(\'/media/images/input-help.png?e74f75003a0f\') no-repeat 6px 5px');
            });
        }

        if($$('.reply-to-message')) {
            $$('.reply-to-message').addEvent('click', function(event){
                event.preventDefault();
                compose_modal.show();
                $$('.token-input-list').setStyle('background-image', 'none');
                $('id_recipient').addClass('is-reply');
            });
        }
    }

    $$('.social-auth-link').addEvent('click', function(evt) {
        $$('body').set('styles', {
            'overflow': 'hidden'
        });
        $('please-wait-overlay').show();
        $('please-wait-overlay-inner-wrapper').show();
        /* Center vertically, remove scrollbar. It's really display logic, but
           it's easier to do in JS than CSS. */
        new vAlign($('please-wait-overlay'));
        new vAlign($('please-wait-overlay-inner-wrapper'));
        new vAlign($('please-wait-overlay-inner'));
        // insert current auth backend name:
        $('please-wait-overlay-auth-service-name').innerHTML = evt.target.get('data-auth');
    });
});


/* Custom styled pseudo-SELECT */
function DropDown(el) {
    this.dd = el;
    this.placeholder = this.dd.children('span');
    this.opts = this.dd.find('ul.dropdown > li');
    this.val = '';
    this.index = -1;
    this.initEvents();
}
function go_to_site(domain) {
    if (domain != location.host) {
        location.href = location.protocol + '//' + domain;
    }
}
DropDown.prototype = {
    initEvents : function() {
        var obj = this;

        obj.dd.on('click', function(event){
            jQuery(this).toggleClass('active');
            return false;
        });

        obj.opts.on('click', function(){
            var opt = jQuery(this);
            obj.val = opt.text();
            obj.index = opt.index();
            obj.placeholder.text(obj.val);
            go_to_site(jQuery(opt).data('value'));
        });
    },
    getValue : function() {
        return this.val;
    },
    getIndex : function() {
        return this.index;
    }
}

jQuery(document).ready(function($) {
    var dd = new DropDown($('#city-select-dropdown'));
    $(document).click(function() {
        // all dropdowns
        $('.wrapper-dropdown').removeClass('active');
    });
    $('#city-select img').click(function() {
        $('#city-select-dropdown').toggleClass('active');
        return false;
    });
});
