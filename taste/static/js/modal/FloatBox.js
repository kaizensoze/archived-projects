var FloatBox = this.FloatBox = new Class({
    Implements: [Options, Events],
    options: {
        size: {
            x: 400,
            y: 400
        },
        target: '',
        rtl: false,
        showOnStart: true
    },
    box: null,
    initialize: function (elem, options) {
        this.setOptions(options);
        this.createBox(elem);
        this.attachEvents();
        this.show();
    },
    createBox: function (elem) {
        var border = new Element('div', {
            'class': 'box-border'
        }),
            close = new Element('span', {
                'class': 'close close-box'
            }),
            screen_size = Window.getSize(),
            top = (screen_size.y - this.options.size.y - 60) / 2,
            side = (this.options.rtl) ? 'right' : 'left',
            side_p = (screen_size.x - this.options.size.x - 60) / 2;
        elem.addClass('box-contained');
        this.box = new Element('div', {
            'class': 'box-container'
        });
        this.box.adopt(close, border, elem).setStyles({
            'padding-top': top,
            'padding-right': side_p,
            'padding-left': side_p
        });
        border.setStyles({
            height: this.options.size.y + 60,
            width: this.options.size.x + 60
        });
        elem.setStyles({
            height: this.options.size.y,
            width: this.options.size.x
        });
        close.setStyle('top', top + 5).setStyle(side, side_p + 5);
    },
    attachEvents: function () {
        var closeBox = this.close.bind(this),
            box = this.box;
        this.box.getElements('.close').addEvent('click', function () {
            closeBox();
        });
        document.addEvents({
            'click': function close_box(e) {
                if (e.target == box) {
                    closeBox();
                    document.removeEvent('click', close_box);
                }
            },
            'keydown': function esc(e) {
                if (e.code == 27) {
                    closeBox();
                    document.removeEvent('keydown', esc);
                }
            }
        });
    },
    show: function () {
        if (!this.options.target) {
            this.box.inject($(document.body));
        } else {
            this.box.inject(this.options.target);
        }
        this.fireEvent('show');
    },
    hide: function () {
        this.box.dispose();
        this.fireEvent('hide');
    },
    close: function () {
        this.box.destroy();
        this.fireEvent('close');
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
        this.box.getElement('.box-border').morph({
            height: y + 60,
            width: x + 60
        });
        this.box.getElement('.box-contained').morph({
            height: y,
            width: x
        });
    }
});

function QueryStringBuilder() {
    var nameValues = [];

    this.add = function(name, value) {
        nameValues.push( {name: name, value: value} );
    };

    this.toQueryString = function() {
        var segments = [], nameValue;
        for (var i = 0, len = nameValues.length; i < len; i++) {
            nameValue = nameValues[i];
            segments[i] = encodeURIComponent(nameValue.name) + "=" + encodeURIComponent(nameValue.value);
        }
        return segments.join("&");
    };
}

function CheckboxQueryString(content) {
    var checked = $(content).getElements('input[type=checkbox]:not(input[name=select-all]):checked');
    if (checked.length != 0) {
        var name = checked[0].get('name');
        var values = checked.map(function(e) { return e.value; });
        var txt = $(document.body).getElement('input[name='+name+'_qs]');
        var qs = new QueryStringBuilder();

        Array.each(values, function(val, index) {
            qs.add(name, val);
        });

        var querystr = qs.toQueryString();
        txt.set('value', querystr);
    }
    else {
        var checkbox = $(content).getElements('input[type=checkbox]:not(input[name=select-all])');
        var name = checkbox[0].get('name');
        var txt = $(document.body).getElement('input[name='+name+'_qs]');
        txt.set('value', '');
    }
}

var FloatBoxSmallWidget = new Class({
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
        var top = (screen_size.y - this.options.size.y) / 2;
        var side = (this.options.rtl) ? 'right' : 'left';
        if (this.options.left) {
            var side_p = this.options.left;
        } else {
            var side_p = (screen_size.x - this.options.size.x) / 2;
        }
        elem.addClass('box-contained');
        this.box = new Element('div', {
            'class': 'box-container'
        });
        elem.setStyles({
            height: this.options.size.y,
            width: this.options.size.x
        });
        elem.adopt(save);
        elem.setStyles({
            'position': 'relative',
            'top': this.options.top,
            'left': side_p
        });
        this.box.adopt(elem).setStyles({
            'width': 960,
            'margin': '0 auto'
        });
    },
    save: function () {
        this.elem.empty();
        CheckboxQueryString(this.tmp);
        var content = this.tmp.clone();
        content.inject(this.elem);
        this.fireEvent('save');
        this.hide();
        $$('span[class=input-arrow]').hide();
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
        if (!this.options.disable_save) {
            var class_ = 'save save-box';
        } else {
            var class_ = 'save no-thanks-box';
        }
        var save = new Element('div', {
            'class': class_
        });
        var screen_size = Window.getSize();
        var top = (screen_size.y - this.options.size.y) / 2;
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
        if (!this.options.disable_save) {
            this.elem.empty();
            var content = this.tmp.clone();
            content.inject(this.elem);
        }
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

var FloatBoxLogin = new Class({
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
        var screen_size = Window.getSize();
        var top = (screen_size.y - this.options.size.y) / 2;
        var side = (this.options.rtl) ? 'right' : 'left';
        var side_p = (screen_size.x - this.options.size.x) / 2;
        elem.addClass('box-contained');
        this.box = new Element('div', {
            'class': 'box-container'
        });
        elem.setStyles({
            width: this.options.size.x
        });
        this.box.adopt(elem).setStyles({
            'padding-top': top,
            'padding-right': side_p,
            'padding-left': side_p
        });
    },
    save: function () {
        $$('.overlay').addClass('hide');
        document.documentElement.style.overflow = 'auto';
        document.body.scroll = "yes";
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

var FloatBoxCompose = new Class({
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
        var screen_size = Window.getSize();
        var top = (screen_size.y - this.options.size.y) / 2;
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
        this.box.adopt(elem).setStyles({
            'padding-top': top,
            'padding-right': side_p,
            'padding-left': side_p
        });
    },
    save: function () {
        $$('.overlay').addClass('hide');
        document.documentElement.style.overflow = 'auto';
        document.body.scroll = "yes";
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

function pack_box(css_identifier, child_identifier) {
    /**
     * Expects to be passed a CSS identifier
     */
    if (css_identifier === '#cuisine-content') {
        return {
            h: 'auto',
            w: 140 * 4
        };
    }

    if (typeof child_identifier === "undefined") {
        child_identifier = '.parent-group';
    }
    jQuery(css_identifier).show();
    var blocks = [];
    jQuery(css_identifier + ' ' + child_identifier).each(function (i, e) {
        blocks.push({
            w: jQuery(e).width(),
            h: jQuery(e).height()
        });
    });
    jQuery(css_identifier).hide();
    var packer = new GrowingPacker();

    packer.fit(blocks);

    var height = 30 + 55;  // Allow for header + footer
    var width = 15; // Allow for padding

    for (var i = 0; i < blocks.length; i++) {
      var block = blocks[i];
      if (block.fit) {
        if (block.fit.x === 0) {
          // Let's make height!
          height += block.fit.h;
        }
        if (block.fit.y === 0) {
          // let's make width!
          width += block.fit.w;
        }
      }
    }
    return {w: width, h: height};
}

function masonry_box(css_identifier) {
    var container = document.querySelector('.box-contained div.controls.' + css_identifier + ' > ul');
    var msnry = new Masonry(container, {
        itemSelector: '.parent-group'
    });
    msnry.layout();  // Apparently only IE needs this?
}

// Since IE doens't support CSS3 columns, we have to hand-roll them. The
// following code is very specific to our needs, and makes plenty of
// assumptions about what elements we have, what we want to break between, and
// what should be unbreakable.
// Because MooTools makes me sad, it expects to be passed a jQuery object.
function floatify(float_area) {
  if (!window.floatified) {
    window.floatified = {};
  }
  if (float_area[0].className in window.floatified) {
    return;
  }
  var max_height = float_area.height();
  var total_height_so_far = 0;
  var boxes = new Array();
  var box = jQuery('<div class="floatifier-column">');
  float_area.children().children().each(function(i, elt) {
    var height = jQuery(elt).height();
    if (height + total_height_so_far > max_height) {
      boxes.push(box);
      box = jQuery('<div class="floatifier-column">');
      total_height_so_far = 0;
    }
    box.append(elt);
    total_height_so_far += height;
  });
  boxes.push(box);
  float_area.html(boxes);
  window.floatified[float_area[0].className] = true;
}
