var initial_step = 10;
var steps = 10;
var offset = 5;
var default_step = 5;

function get_bg_offset(position) {
    var p = position * 10;
    return (p * -1);
}

window.addEvent('domready', function () {
    var tips = $('more-tips');
    var expander_label = $('tips-label');

    $('tips-expander').addEvent('click', function () {
        if (tips.hasClass('expanded')) {
            tips.removeClass('expanded');
            jQuery('#tips-label').empty().text('Show more');
        } else {
            tips.addClass('expanded');
            jQuery('#tips-label').empty().text('Show less');
        }
    });

    var overall_slider_default = $('id_overall_score').value != 0 ? $('id_overall_score').value : default_step;

    var overall_slider = new Slider($('slider-overall'), $('slider-overall-knob'), {
        initialStep: initial_step,
        range: [1,10],
        steps: steps,
        offset: offset,
        onChange: function (pos) {
            $('slider-overall-value').set('html', '<span class="score-' + pos + '">' + pos + '/10</span>');
            bg = get_bg_offset(pos);
            $('id_overall_score').set('value', pos);
            $('slider-overall').setStyle('background-position', '0 ' + bg + 'px');
        }
    }).set(overall_slider_default);

    var food_slider_default = $('id_food_score').value != 0 ? $('id_food_score').value : default_step;

    var food_slider = new Slider($('slider-food'), $('slider-food-knob'), {
        initialStep: initial_step,
        range: [1,10],
        steps: steps,
        offset: offset,
        onChange: function (pos) {
            $('slider-food-value').set('html', '<span class="score-' + pos + '">' + pos + '/10</span>');
            $('id_food_score').set('value', pos);
            bg = get_bg_offset(pos);
            $('slider-food').setStyle('background-position', '0 ' + bg + 'px');
        }
    }).set(food_slider_default);

    var ambience_slider_default = $('id_ambience_score').value != 0 ? $('id_ambience_score').value : default_step;

    var ambience_slider = new Slider($('slider-ambience'), $('slider-ambience-knob'), {
        initialStep: initial_step,
        range: [1,10],
        steps: steps,
        offset: offset,
        onChange: function (pos) {
            $('slider-ambience-value').set('html', '<span class="score-' + pos + '">' + pos + '/10</span>');
            $('id_ambience_score').set('value', pos);
            bg = get_bg_offset(pos);
            $('slider-ambience').setStyle('background-position', '0 ' + bg + 'px');
        }
    }).set(ambience_slider_default);

    var service_slider_default = $('id_service_score').value != 0 ? $('id_service_score').value : default_step;

    var service_slider = new Slider($('slider-service'), $('slider-service-knob'), {
        initialStep: initial_step,
        range: [1,10],
        steps: steps,
        offset: offset,
        onChange: function (pos) {
            $('slider-service-value').set('html', '<span class="score-' + pos + '">' + pos + '/10</span>');
            $('id_service_score').set('value', pos);
            bg = get_bg_offset(pos);
            $('slider-service').setStyle('background-position', '0 ' + bg + 'px');
        }
    }).set(service_slider_default);

    // Show share-on-Twitter/FB modal if successfully posted
    if ($('share-modal')) {
        var share_modal = new FloatBoxPlus($('share-modal'), {disable_save: true, size: {x:465,y:200},top: 100});
        share_modal.show();
        $$('.close-button').addEvent('click', function(evt) {
            share_modal.hide();
        });
    }
});

$$('.new-modal-window').addEvent('click', function(evt) {
    var url = evt.target.href;
    var score = $('slider-overall-value').children[0].innerHTML; // Super-brittle, but Mootools leaves me little choice.
    var summary = $('id_review').value;
    var preview_length = 100;
    if (summary.length > preview_length) {
        summary = summary.substr(0, preview_length - 1) + "…";
    }
    url = url.replace('javascript-score', score);
    url = url.replace('javascript-description', summary);
    window.open(url)//, '_blank', 'height=300,width=600');
    return false;
});
