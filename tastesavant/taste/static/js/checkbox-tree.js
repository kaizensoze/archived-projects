window.addEvent('domready', function() {
    var parents = $$('.parent-checkbox > label > input[type=checkbox]');
    $$(parents).addEvent('click', function() {
        var children = $$(this).getParent('.parent-group').getElements("li:not([class='parent-checkbox'])");
        var parent_state = this.checked;
        $$(children).each(function(li) {
            var checkbox = li.getElement('input[type=checkbox]');
            checkbox.checked = parent_state;
        });
    });

    var toggle_all_checkbox = $$('.select-all-checkbox');
    $$(toggle_all_checkbox).addEvent('click', function(event) {
        var state = this.checked;
        var all = $$(this).getParent('.box-wrap').getElements('input[type=checkbox]:not([class="select-all-checkbox"])');
        $$(all).each(function(input) {
            input.checked = state;
        });
    });
});
