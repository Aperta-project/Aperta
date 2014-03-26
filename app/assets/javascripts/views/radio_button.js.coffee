ETahi.RadioButton = Ember.View.extend
  tagName: "input"
  type: "radio"
  attributeBindings: [ "name", "type", "value", "checked:checked:", "model"]
  click: ->
    paper = @get('model')
    paper.set("decision", @get('value'))
    paper.save()

  checked: (->
    @get("value") == @get("selection")
  ).property()
