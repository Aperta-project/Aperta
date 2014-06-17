Ember.Handlebars.helper 'formatNumber', (number) ->
  if number
    number.toString().replace /(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"
  else
    0
