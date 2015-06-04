`import Ember from 'ember'`

TahiNavComponent = Ember.Component.extend
  actions:
    hideNavigation: ->
      @sendAction("hideNavigation")
    showNavigation: ->
      @sendAction("showNavigation")
    feedback: ->
      @sendAction("feedback")

`export default TahiNavComponent`
