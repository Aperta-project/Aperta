Ember.Handlebars.helper 'formatNumber', (number) ->
  number.toString().replace /(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"
