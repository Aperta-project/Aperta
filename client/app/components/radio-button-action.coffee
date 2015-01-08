`import Ember from 'ember'`

RadioButtonActionComponent = Ember.Component.extend
  tagName: 'input'
  type: 'radio'
  attributeBindings: ['name', 'type', 'value', 'checked']

  click: ->
    @sendAction()

`export default RadioButtonActionComponent`
