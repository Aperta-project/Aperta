`import Ember from 'ember'`

Pluralize = Ember.Handlebars.makeBoundHelper (number, single, plural) ->
  if number == 1 then single else plural

`export default Pluralize`
