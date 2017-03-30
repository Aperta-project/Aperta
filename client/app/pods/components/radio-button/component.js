import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'input',
  type: 'radio',
  attributeBindings: ['name', 'type', 'value', 'checked:checked', 'disabled', 'data-test-selector:data-test-selector'],

  value: null,
  selection: null,

  init() {
    this._super(...arguments);
    Ember.assert(
      'You must pass a value property to the RadioButtonComponent',
      this.get('value') !== null && this.get('value') !== undefined
    );
    Ember.assert(
      'You must pass a selection property to the RadioButtonComponent',
      this.attrs.hasOwnProperty('selection')
    );
  },

  checked: Ember.computed('selection', 'value', function() {
    return Ember.isEqual(this.get('selection'), this.get('value'));
  }),

  change() {
    this.get('action')(this.get('value'));
  }
});
