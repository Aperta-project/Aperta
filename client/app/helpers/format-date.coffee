`import Ember from "ember"`

formatDate = (date, options) ->
  dateObj = moment(date)
  return date unless dateObj.isValid()
  dateObj.format(options.hash.format || "LL")

`export { formatDate }`
`export default Ember.Handlebars.makeBoundHelper(formatDate)`
