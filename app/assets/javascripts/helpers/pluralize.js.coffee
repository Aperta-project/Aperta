Ember.Handlebars.helper 'pluralize', (number, single, plural) ->
  if number == 1 then single else plural
