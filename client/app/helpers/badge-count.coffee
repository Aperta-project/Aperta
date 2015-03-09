`import Ember from 'ember'`

BadgeCount = Ember.Handlebars.makeBoundHelper (count, classString) ->
  if count > 0
    new Ember.Handlebars.SafeString("<span class='badge #{classString}'>#{count}</span>")
  else
    new Ember.Handlebars.SafeString("")

`export default BadgeCount`
