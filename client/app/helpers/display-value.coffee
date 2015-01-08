`import Ember from 'ember'`

DisplayValue = Ember.Handlebars.makeBoundHelper (value, options) ->
  if Em.isEmpty(value) then options.hash.or else value

`export default DisplayValue`
