                            window.addEvent("domready", function() {
                                var autocomplete = new CwAutocompleter( 'id_auto_%s', '',
                                 {
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
                                                   values.append([[value, key]])
                                                }
                                            }.bind(this));
                                        return values;
                                        }
                                    }
                                 });
                            });