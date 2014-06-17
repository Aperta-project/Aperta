ETahi.RadioButtonActionComponent = Ember.Component.extend
  tagName: 'input'
  type: 'radio'
  attributeBindings: ['name', 'type', 'value', 'checked']

  click: ->
    @sendAction()
