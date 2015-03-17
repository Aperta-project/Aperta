`import Ember from "ember"`

FormatDateHelper = Ember.Handlebars.makeBoundHelper (date, options) ->
  moment(date).format(options.hash.format || "LL")

`export default FormatDateHelper`
