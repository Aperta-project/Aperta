ETahi.TextArea = Ember.TextArea.extend
  attributeBindings: [ "name", "type", "value", "model"]
  focusOut: ->
    @get('model').save()
