ETahi.RadioButton = Ember.View.extend
  tagName: "input"
  type: "radio"
  attributeBindings: [ "name", "type", "value", "checked:checked:", "model"]

  click: ->
    paper = @get('model')
    decision = @get('value')
    @get('controller').send('setDecisionTemplate', paper, decision)

  checked: (->
    @get("value") == @get("selection")
  ).property()
