`import Ember from 'ember'`

DisplayLineBreaks = Ember.Handlebars.makeBoundHelper (text) ->
  new Ember.Handlebars.SafeString text.replace(/\n/g, "<br>")

`export default DisplayLineBreaks`
