Ember.Handlebars.helper 'display', (value, options) ->
  if Em.isEmpty(value) then options.hash.or else value.htmlSafe()
