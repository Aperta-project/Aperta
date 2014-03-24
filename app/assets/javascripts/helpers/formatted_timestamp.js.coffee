Ember.Handlebars.helper 'formattedTime', (time) ->
  new Handlebars.SafeString $.timeago(time)
