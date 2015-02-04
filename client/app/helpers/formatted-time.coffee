`import Ember from 'ember'`

FormattedTime = Ember.Handlebars.makeBoundHelper (time) ->
  time ||= new Date()
  new Handlebars.SafeString $.timeago(time)

`export default FormattedTime`
