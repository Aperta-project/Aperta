import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'input',
  type: 'radio',
  attributeBindings: ['name', 'type', 'value', 'checked:checked', 'disabled'],

  value: null,

  _propertiesCheck: Ember.on('init', function() {
    Ember.assert('You must pass a value property to the RadioButtonComponent', this.get('value'));
    Ember.assert('You must pass a selection property to the RadioButtonComponent', this.attrs.hasOwnProperty('selection'));
  }),

  checked: Ember.computed('selection', 'value', function() {
    return Ember.isEqual(this.get('selection'), this.get('value'));
  }),

  change() {
    this.attrs.action(this.get('value'));
  }
});
