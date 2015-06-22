from itertools import chain
from django.contrib import admin
from django.conf import settings
from django.utils.safestring import mark_safe
from django.forms.widgets import CheckboxSelectMultiple, CheckboxInput, Select, SelectMultiple
from django.utils.encoding import force_unicode
from django.utils.html import conditional_escape
from django.utils.translation import ugettext as _
from django.db.models import Count

class SmartSizeCheckboxSelectMultipleTree(SelectMultiple):
    def build_tree_from_roots(self, roots):
        """ a totally hack solution, but getting mptt to sort nicely was
        taking too long"""

        flat = []
        for r in roots:
            flat.append(r)
            for x in r.get_children().order_by('name'):
                flat.append(x)
        return flat

    # @todo: Decompose this into well-named methods. --kit
    def render(self, name, value, attrs=None, choices=()):
        if value is None: value = []
        has_id = attrs and 'id' in attrs
        final_attrs = self.build_attrs(attrs, name=name)
        output = [u'<ul>']
        str_values = set([force_unicode(v) for v in value])

        choices = [c for c in enumerate(chain(
                    self.build_tree_from_roots(self.choices.queryset.filter(level = 1).annotate(
                            count=Count('children')).order_by('-count')), choices))]
        for i, choice in choices:
            option_value = choice.id
            option_label = choice.name
            option_level = choice.level - 1

            # if option level is 0, create new parent node/nested list.
            if option_level == 0:
                # if this is not the first parent node being created,
                # close the previous nested list.
                if i != 0:
                    output.append('</ul></li>')
                # create new nested list
                output.append('<li class="parent-group"><ul>')

            if has_id:
                final_attrs = dict(final_attrs, id='%s_%s' % (attrs['id'], i))
                label_for = u' for="%s"' % final_attrs['id']
            else:
                label_for = ''

            cb = CheckboxInput(final_attrs, check_test=lambda value: value in str_values)
            option_value = force_unicode(option_value)
            rendered_cb = cb.render(name, option_value)
            option_label = conditional_escape(force_unicode(option_label))

            if option_level == 0:
                output.append(u'<li class="parent-checkbox">')
            else:
                output.append(u'<li>')

            output.append(u'<label%s>%s %s</label></li>' % (label_for, rendered_cb, option_label))
        output.append(u'</ul></ul>')
        return mark_safe(u'\n'.join(output))

    class Media:
        css = {
            'all': ('css/checkbox-tree.css')
            }

        js = ('js/checkbox-tree.js')

class CheckboxSelectMultipleTree(SelectMultiple):
    # @todo: Decompose this into well-named methods. --kit
    def render(self, name, value, attrs=None, choices=()):
        if type(self.choices.queryset) is list:
            pass
        if value is None: value = []
        has_id = attrs and 'id' in attrs
        final_attrs = self.build_attrs(attrs, name=name)
        output = [u'<ul>']
        str_values = set([force_unicode(v) for v in value])
        choices = [c for c in enumerate(chain(self.choices.queryset, choices))]
        for i, choice in choices:
            option_value = choice.id
            option_label = choice.name
            option_level = choice.level - 1

            # if option level is 0, create new parent node/nested list.
            if option_level == 0:
                # if this is not the first parent node being created,
                # close the previous nested list.
                if i != 0:
                    output.append('</ul></li>')
                # create new nested list
                output.append('<li class="parent-group"><ul>')

            if has_id:
                final_attrs = dict(final_attrs, id='%s_%s' % (attrs['id'], i))
                label_for = u' for="%s"' % final_attrs['id']
            else:
                label_for = ''

            cb = CheckboxInput(final_attrs, check_test=lambda value: value in str_values)
            option_value = force_unicode(option_value)
            rendered_cb = cb.render(name, option_value)
            option_label = conditional_escape(force_unicode(option_label))

            if option_level == 0:
                output.append(u'<li class="parent-checkbox">')
            else:
                output.append(u'<li>')

            output.append(u'<label%s>%s %s</label></li>' % (label_for, rendered_cb, option_label))
        output.append(u'</ul></ul>')
        return mark_safe(u'\n'.join(output))

    class Media:
        css = {
            'all': ('css/checkbox-tree.css')
            }

        js = ('js/checkbox-tree.js')

class CheckboxColumnSelectMultiple(CheckboxSelectMultiple):
    # @todo: Decompose this into well-named methods. --kit
    def render(self, name, value, attrs=None, choices=(), columns=3):
        if value is None: value = []
        has_id = attrs and 'id' in attrs
        final_attrs = self.build_attrs(attrs, name=name)
        total_items = self.choices.queryset.count()
        items_per_column = total_items/columns
        remainder = total_items%columns
        if remainder != 0:
            items_per_column = items_per_column + 1
        column_count = 0
        items_in_column = 0
        output = [u'<ul>']
        # Normalize to strings
        str_values = set([force_unicode(v) for v in value])
        for i, (option_value, option_label) in enumerate(chain(self.choices, choices)):
            items_in_column += 1
            # If an ID attribute was given, add a numeric index as a suffix,
            # so that the checkboxes don't all have the same ID attribute.
            if has_id:
                final_attrs = dict(final_attrs, id='%s_%s' % (attrs['id'], i))
                label_for = u' for="%s"' % final_attrs['id']
            else:
                label_for = ''

            cb = CheckboxInput(final_attrs, check_test=lambda value: value in str_values)
            option_value = force_unicode(option_value)
            rendered_cb = cb.render(name, option_value)
            option_label = conditional_escape(force_unicode(option_label))
            output.append(u'<li><label%s>%s %s</label></li>' % (label_for, rendered_cb, option_label))
            if items_in_column == items_per_column and (total_items - 1) != i:
                output.append(u'</ul>')
                items_in_column = 0
                column_count += 1
                if column_count == columns:
                    output.append('<ul class="last">')
                else:
                    output.append('<ul>')
        output.append(u'</ul>')
        return mark_safe(u'\n'.join(output))


class FKNoEdit(admin.widgets.ForeignKeyRawIdWidget):
    # @todo: Decompose this into well-named methods. --kit
    def render(self, name, value, attrs=None):
        if attrs is None:
            attrs = {}
        related_url = '../../../%s/%s/add/' % (self.rel.to._meta.app_label, self.rel.to._meta.object_name.lower())
        if not attrs.has_key('class'):
            attrs['class'] = 'vForeignKeyRawIdAdminField nodisplay' # The JavaScript looks for this hook.

        if value:
            output = [self.label_for_value(value)]
        else:
            output = ['<strong>Click the Button to add hours</strong>']
        output.append(super(admin.widgets.ForeignKeyRawIdWidget, self).render(name, value, attrs))
        # TODO: "id_" is hard-coded here. This should instead use the correct
        # API to determine the ID dynamically.
        if not value:
            output.append('<a href="%s" class="add-another" id="add_id_%s" onclick="return showAddAnotherPopup(this);"> ' % \
                (related_url, name))
            output.append(u'<img src="%simg/admin/icon_addlink.gif" width="10" height="10" alt="%s"/></a>' % (settings.ADMIN_MEDIA_PREFIX, _('Add Another')))

        return mark_safe(u''.join(output))

class SelectWidget(Select):
    # @todo: Decompose this into well-named methods. --kit
    def render(self, name, value, attrs=None):
        output = super(SelectWidget, self).render(name, value, attrs)
        choices = dict(self.choices)
        if value:
            value = choices[value]
        else:
            value = ''
        output = output + """<input id="id_auto_%s" type="text" class="vTextField" value="%s" maxlength="255">""" % (name, value)
        output = output + """<script>
                            window.addEvent("domready", function() {
                                var autocomplete = new CwAutocompleter( 'id_auto_%s', '',
                                 {
                                 inputMinLength:2,
                                 targetfieldForKey: 'id_%s',
                                 targetfieldForValue: 'id_auto_%s',
                                 doRetrieveValues: function(input) {
                                    if (input){
                                        var values = []
                                        var elements = $('id_%s').getChildren();
                                            elements.each(function(el){
                                                var value = el.get('value')
                                                var key = el.get('html')
                                                if (key.contains(input)){
                                                   values.append([[String(value), key]])
                                                }
                                            }.bind(this));
                                        return values;
                                        }
                                    return [];
                                    }
                                 });
                            });
                            </script>""" % (name, name, name, name)
        return mark_safe(output)

    class Media:
        css = {
            'all': ('css/select-widget.css', 'css/mootools.complete.css')
        }
        js = (
            'js/mootools.core.js',
            'js/mootools.more.js',
            'js/mootools.complete.js',
            )

class FilterWidget(CheckboxSelectMultiple):
    def __init__(self, *args, **kwargs):
        self.app_name = kwargs['app_name']
        kwargs.pop('app_name')
        super(FilterWidget, self).__init__(*args, **kwargs)

    # @todo: Decompose this into well-named methods. --kit
    def render(self, name, value, attrs=None, choices=()):
        if value is None: value = []
        has_id = attrs and 'id' in attrs
        final_attrs = self.build_attrs(attrs, name=name)
        output = [u"""<a onclick="return showAddAnotherPopup(this);" id="add_id_%s" class="add-another" href="/admin/%s/%s/add/">
                    <img height="10" width="10" alt="Add Another" src="%simg/admin/icon_addlink.gif">
                    Add new filter</a>""" % (name, self.app_name, name, settings.ADMIN_MEDIA_PREFIX)]
        output.append(u'<ul class = "filter-widget-list" id="id_%s">' % name)
        # Normalize to strings
        str_values = set([force_unicode(v) for v in value])
        for i, (option_value, option_label) in enumerate(chain(self.choices, choices)):
            # If an ID attribute was given, add a numeric index as a suffix,
            # so that the checkboxes don't all have the same ID attribute.
            if has_id:
                final_attrs = dict(final_attrs, id='%s_%s' % (attrs['id'], i))
            final_attrs['extra'] = option_label
            cb = CheckboxInput(final_attrs, check_test=lambda value: value in str_values)
            option_value = force_unicode(option_value)
            rendered_cb = cb.render(name, option_value)
            option_label = conditional_escape(force_unicode(option_label))
            if option_value in str_values:
                li_class = 'checked-item'
            else:
                li_class = 'unchecked-item'
            output.append(u'<li class = "%s"><div>%s %s</div></li>' % (li_class, rendered_cb, option_label))
        output.append(u'</ul>')
        output.append(u'<script>jQuery(document).ready(function($) {filterwidget("%s")});</script>'% name)
        return mark_safe(u'\n'.join(output))

    class Media:
        css = {
            'all': ('css/filter-widget.css', 'css/jquery.autocomplete.css')
        }
        js = (
            'js/jquery-1.3.2.js',
            'js/jquery.autocomplete.js',
            'js/jquery.livequery.js',
            'js/filter-widget.js',
            )
