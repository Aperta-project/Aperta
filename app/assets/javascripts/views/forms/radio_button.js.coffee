ETahi.RadioButton = Ember.View.extend
  tagName: 'input'
  type: 'radio'
  attributeBindings: ['name', 'type', 'value', 'checked:checked:']
