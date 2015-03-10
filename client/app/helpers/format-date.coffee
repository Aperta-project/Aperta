`import Ember from 'ember'`

FormatDate = Ember.Handlebars.makeBoundHelper (date, options) ->

  moment(date).format(options.hash.format || "LL")

`export default FormatDate`
