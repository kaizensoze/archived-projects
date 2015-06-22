var Entry = Backbone.Model.extend({
  defaults: {
    name: "New restaurant",
    restaurant: null,
    entry: '',
    offset: 0
  }
});

var Entries = Backbone.Collection.extend({
  model: Entry
});

var List = Backbone.Model.extend({
  defaults: {
    title: "New list",
    entries: [],
    firstVisibleListIndex: 0,
    addOffset: 0
  },
  pageCount: function () {
    return Math.ceil(this.entries.length / 11);
  },
  pages: function () {
    return _.compact(this.entries.toArray().concat([1]).map(function (elt, i) {
      if (i % 11 === 0) {
        return i + 1;  // Otherwise the zero is too "falsy" and gets compacted.
      }
    }));
  },
  pagesLinks: function () {
    var ret = [];
    var pages = this.pages();
    for (var i = 0; i < pages.length; i++) {
      ret.push(i + 1);  // For human consumption!
    }
    return ret;
  },
  currentPageNumber: function () {
    return Math.ceil(this.get('firstVisibleListIndex') / 11) + 1;
  },
  maxPage: function () {
    return Math.ceil((this.entries.length + 1) / 11);
  },
  closePage: function (elt) {
    return (Math.abs(this.currentPageNumber() - elt) < 3);  // Pagination boundary
  },
  firstOrLast: function (elt) {
    return (elt == 1 || elt == this.pagesLinks().length);
  },
  justOutsideBounds: function (elt) {
    var val = Math.abs(this.currentPageNumber() - elt);
    return (3 <= val && val < 4);  // Pagination boundary
  },
  atFirstPage: function () {
    return this.currentPageNumber() === 1;
  },
  atLastPage: function () {
    return this.currentPageNumber() === this.maxPage();
  }
});

var ListCollection = Backbone.Collection.extend({
  model: List
});

var ListView = Backbone.View.extend({
  el: jQuery('#blackbooks'),
  model: ListCollection,
  template: _.template(jQuery('#listTemplate').html()),
  events: {
    /* More sauce */
    'click .list-entry-x': 'removeElement',
    'click .prev': 'previous',
    'click .next': 'next',
    'click .list-controls-edit': 'editList',
    'click .list-controls-delete': 'deleteList',
    'click .add-list-entry-show': 'showAddList',
    'click .edit-list-okay': 'editListConfirm',
    'click .edit-list-cancel': 'editListCancel',
    'click .pagination': 'pagination'
  },
  initialize: function() {
    this.listenTo(this.model, "change", this.render);
  },
  render: function() {
    this.$el.html(this.template(this.model.attributes));
    activate_select2(jQuery);
    return this;
  },
  removeElement: function (evt) {
    evt.preventDefault();
    var id = jQuery(evt.currentTarget).data("id");
    var listId = jQuery(evt.currentTarget).data("listid");
    var collection = this.model.get(listId).entries
    var item = collection.get(id);
    var that = this;
    if (!confirm("Are you sure you want to remove " + item.get('name') + " from this list?")) {
      return;
    }
    // @todo: sanitize listId and id
    jQuery.ajax('/api/1/blackbook/' + listId + '/entries/' + id + '/', {
      type: 'DELETE',
      success: function () {
        // @todo: we should probably do these, and undo them in an error callback, for latency-compensation.
        collection.remove(item);
      },
      complete: function () {
        // We do this manually, as the ListCollection hasn't changed.
        that.render();
      }
    });
  },
  changeListPage: function (list, increment) {
    if (list.get('firstVisibleListIndex') - increment < 0 || list.get('firstVisibleListIndex') - increment > list.entries.length) {
      return;
    }
    list.set('firstVisibleListIndex', list.get('firstVisibleListIndex') - increment);
    var change_by = (29 * increment);
    list.entries.each(function (elt) {
      var current_offset = elt.get('offset');
      elt.set('offset', current_offset + change_by);
    });
    var current_add_offset = list.get('addOffset');
    list.set('addOffset', current_add_offset + change_by);
    this.render();
  },
  previous: function (evt) {
    var listId = jQuery(evt.currentTarget).data("listid");
    var list = this.model.get(listId);
    var increment = 11;
    this.changeListPage(list, increment);
  },
  next: function (evt) {
    var listId = jQuery(evt.currentTarget).data("listid");
    var list = this.model.get(listId);
    var increment = -11;
    this.changeListPage(list, increment);
  },
  editList: function (evt) {
    evt.preventDefault();
    var listId = jQuery(evt.currentTarget).data("listid");
    var list = this.model.get(listId);
    var form = jQuery(evt.currentTarget).parent().siblings('form'); // THIS IS SUPER FRAGILE UH OH.
    var spans = form.siblings('span');
    spans.hide();
    // Reset form
    form.children('input').val(list.get('title'));
    form.show();
    form.children('input').focus();
  },
  editListConfirm: function (evt) {
    evt.preventDefault();
    var listId = jQuery(evt.currentTarget).data("listid");
    var list = this.model.get(listId);
    var form = jQuery(evt.currentTarget).parent(); // THIS IS SUPER FRAGILE UH OH.
    var spans = form.siblings('span');
    form.hide()
    spans.show();
    var form_value = form.children('input').val();
    var that = this;
    jQuery.ajax('/api/1/blackbook/' + listId + '/', {
      type: 'PUT',
      data: {
        title: form_value
      },
      success: function (data) {
        list.set('title', data.title);
      },
      complete: function () {
        that.render();
      }
    });
  },
  editListCancel: function (evt) {
    evt.preventDefault();
    var listId = jQuery(evt.currentTarget).data("listid");
    var list = this.model.get(listId);
    var form = jQuery(evt.currentTarget).parent(); // THIS IS SUPER FRAGILE UH OH.
    var spans = form.siblings('span');
    form.hide();
    spans.show();
  },
  deleteList: function (evt) {
    var that = this;
    if (confirm("Do you really want to delete this list?")) {
      var list_id = jQuery(evt.currentTarget).data("listid");
      jQuery.ajax('/api/1/blackbook/' + list_id + '/', {
        type: 'DELETE',
        success: function (data) {
          window.list_collection.remove(list_collection.get(list_id));
        },
        complete: function () {
          that.render();
        }
      });
    }
  },
  showAddList: function (evt) {
    evt.preventDefault();
    var form = jQuery(evt.currentTarget).children('form'); // THIS IS SUPER FRAGILE UH OH.
    form.show();
    form.children('.new-restaurant-name').first().select2('open');
  },
  addToList: function (list, restaurant_api_uri) {
    var that = this;
    jQuery.ajax('/api/1/blackbook/' + list.id + '/entries/', {
      type: "POST",
      data: {
        entry: 'Added from restaurant page',
        restaurant: restaurant_api_uri
      },
      success: function (data) {
        console.log(data);
        var first = list.entries.at(0);
        if (first) {
          var offset = first.get('offset');
        } else {
          var offset = 0;
        }
        data['offset'] = offset;
        entry = new Entry(data);
        list.entries.add(entry);
      },
      complete: function (jqXHR) {
        that.render();
      }
    });
  },
  pagination: function (evt) {
    evt.preventDefault();
    evt.stopPropagation();
    var listId = jQuery(evt.currentTarget).data("listid");
    var list = this.model.get(listId);
    var pageId = jQuery(evt.currentTarget).data("pageid");
    var currentPage = Math.ceil(list.get('firstVisibleListIndex') / 11) + 1;
    var number_of_times = 11 * (currentPage - pageId);
    this.changeListPage(list, number_of_times);
  }
});

function format(state) {
  return state.text;
}

function activate_select2 ($) {
  $('.new-restaurant-name').select2({
    formatNoMatches: function () {
        return '';
    },
    formatSearching: function () {
      return '';
    },
    id: function (e) {
      return e;
    },
    width: "207px",
    ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
      url: "/api/1/restaurant-autocomplete/",
      data: function (term, page) {
        return {
          s: term,
          city: 'all'
        };
      },
      results: function (data, page) { // parse the results into the format expected by Select2.
        // since we are using custom formatting functions we do not need to alter remote JSON data
        window.restaurant_data = {};
        jQuery.each(data, function (i, elt) {
          window.restaurant_data[elt.name] = elt.api_uri;
        });
        return {
          results: data.map(function (elt) { return {text: elt.name}; })
        };
      },
      formatResult: format,
      formatSelection: format
    },
  }).unbind('change')
  .on('change', function (evt) {
    // @todo firing twice again.
    evt.preventDefault();
    evt.stopPropagation();
    var api_uri = window.restaurant_data[evt.added.text];
    var listId = jQuery(evt.currentTarget).data('listid');
    var list = window.list_view.model.get(listId);
    window.list_view.addToList(list, api_uri)
    this.destroy();
  }).on('select2-blur', function (evt) {
    evt.preventDefault();
    evt.stopPropagation();
    jQuery(evt.currentTarget).parent().hide();
  });
}

jQuery(document).ready(function ($) {
  $.ajax('/api/1/blackbook/', {
    data: {
      user: $('#username').val()
    },
    success: function (data) {
      window.list_collection = list_collection = new ListCollection();
      window.list_view = new ListView({model: list_collection});
      _.each(data, function (api_list) {
        var list = new List(api_list);
        var entries = new Entries();
        _.each(api_list.entries, function (api_entry) {
          var entry = new Entry(api_entry);
          entries.push(entry);
        });
        list.entries = entries;
        list_collection.push(list);
      });
      window.list_view.render();
      // Bind delegated events!
      $('#body').on("click", ".new-list-button-link", function (evt) {
        evt.preventDefault();
        // reset form
        $('.new-list-button-form').children('input').val('');
        // swap to form.
        $('.new-list-button-form').show();
        $('.new-list-button-form input').focus();
      });
      $('#body').on("click", ".new-list-okay", function (evt) {
        evt.stopPropagation();
        evt.preventDefault();
        $('.new-list-button-form').hide();
        // get form value
        var form_value = $('.new-list-button-form').children('input').val();
        // post to server
        $.ajax('/api/1/blackbook/', {
          type: 'POST',
          data: {
            title: form_value
          },
          success: function (data) {
            // update list list with return value
            var list = new List(data);
            var entries = new Entries();
            list.entries = entries;
            list_collection.push(list);
            // re-render
            window.list_view.render();
          },
          complete: function () {
            window.list_view.render();
          }
        });
      });
      $('#body').on("click", ".new-list-cancel", function (evt) {
        evt.stopPropagation();
        evt.preventDefault();
        $('.new-list-button-form').hide();
      });
      activate_select2($);
    },
    error: function () {
      //pass
    }
  });
});
