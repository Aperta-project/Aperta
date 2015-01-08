ETahi.TextAreaComponent = Ember.TextArea.extend
  attributeBindings: ["name", "type", "value"]
  focusOut: ->
    @sendAction()
