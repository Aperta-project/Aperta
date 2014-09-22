Ember.Handlebars.helper('badge', (count, classString) ->
  console.log count
  if count > 0
    new Handlebars.SafeString("<span class='badge #{classString}'>#{count}</span>")
  else
    new Handlebars.SafeString("<span>OOPS</span>")
)
