`import Ember from 'ember'`

formatDate = (date, format) ->
  return date unless moment(date).isValid()
  moment(date).format(format || "LL")

# FormatDateHelper = Ember.Handlebars.makeBoundHelper formatDate
FormatDateHelper = Ember.Handlebars.registerBoundHelper 'formatDate', formatDate

`export { formatDate }`

`export default FormatDateHelper`
