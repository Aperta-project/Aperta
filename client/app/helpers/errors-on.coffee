`import Ember from 'ember'`

ErrorsOn = Ember.Handlebars.makeBoundHelper((model, field) ->
  errors = model.get("errors.#{field}")
  if Ember.isEmpty(errors)
    new Handlebars.SafeString("")
  else
    msg = "#{field.capitalize()} #{errors.mapProperty('message').join("; ")}"
    new Handlebars.SafeString("<span class='error-message'>#{msg}</span>")
, 'errors.length')

`export default ErrorsOn`
