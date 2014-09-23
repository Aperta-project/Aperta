Ember.Handlebars.helper('badge', (count, classString) ->
  if count > 0
    new Handlebars.SafeString("<span class='badge #{classString}'>#{count}</span>")
  else
    new Handlebars.SafeString("")
)
