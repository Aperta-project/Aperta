`import Ember from 'ember'`

formatDate = (date, options) ->
  moment(date).format(options.hash.format || "LL")

FormatDateHelper = Ember.Handlebars.makeBoundHelper formatDate

`export { formatDate }`

`export default FormatDateHelper`
