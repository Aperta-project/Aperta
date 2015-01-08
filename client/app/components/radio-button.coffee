`import Ember from 'ember'`

RadioButtonComponent = Ember.Component.extend
  tagName: 'input'
  type: 'radio'
  attributeBindings: ['name', 'type', 'value', 'checked:checked:']

  checked: (->
    @get('selection') == @get('value')
  ).property('selection')

  change: ->
    @set('selection', @$().val())

`export default RadioButtonComponent`
