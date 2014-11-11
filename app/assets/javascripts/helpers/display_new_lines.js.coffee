Ember.Handlebars.helper 'displayLineBreaks', (text) ->
  new Em.Handlebars.SafeString text.replace(/\n/g, "<br>")
