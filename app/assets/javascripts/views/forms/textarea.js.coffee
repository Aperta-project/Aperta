ETahi.TextArea = Ember.TextArea.extend
  attributeBindings: ["name", "type", "value"]
  focusOut: ->
    @sendAction()
