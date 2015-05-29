`import Ember from 'ember'`

TahiNavComponent = Ember.Component.extend
  actions:
    hideNavigation: ->
      @sendAction("hideNavigation")
    showNavigation: ->
      @send("showNavigation")

`export default TahiNavComponent`
