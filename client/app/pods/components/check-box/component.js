import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'input',
  type: 'checkbox',
  classNameBindings: [':ember-checkbox', 'class'],
  attributeBindings: 'type checked indeterminate disabled tabindex name autofocus form value'.w(),
  checked: false,
  disabled: false,
  indeterminate: false,

  _setupOnChange: function() {
    this.on('change', this, this._updateElementValue);
  }.on('init'),

  _setupIndeterminate: function() {
    this.get('element').indeterminate = !!this.get('indeterminate');
  }.on('didInsertElement'),

  _updateElementValue() {
    this.set('checked', this.$().prop('checked'));
  },

  change() {
    this.sendAction('action', this);
  }
});
