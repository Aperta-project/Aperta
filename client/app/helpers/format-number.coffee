`import Ember from 'ember'`

FormatNumber = Ember.Handlebars.makeBoundHelper (number) ->
  if number
    number.toString().replace /(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"
  else
    0

`export default FormatNumber`
