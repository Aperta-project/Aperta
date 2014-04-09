Ember.Handlebars.helper 'formattedTime', (time) ->
  time ||= new Date()
  new Handlebars.SafeString $.timeago(time)
