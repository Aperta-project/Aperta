`import Ember from 'ember'`

DisplayLineBreaks = Ember.Handlebars.makeBoundHelper (text) ->
  new Em.Handlebars.SafeString text.replace(/\n/g, "<br>")

`export default DisplayLineBreaks`
