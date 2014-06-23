ETahi.RadioButton = Ember.View.extend
  tagName: 'input'
  type: 'radio'
  attributeBindings: ['name', 'type', 'value', 'checked:checked:']

  checked: (->
    @get('selection') == @get('value')
  ).property('selection')

  change: ->
    @set('selection', @$().val())
