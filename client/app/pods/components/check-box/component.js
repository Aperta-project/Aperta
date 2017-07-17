import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'input',
  type: 'checkbox',
  classNameBindings: [':ember-checkbox', 'class'],
  attributeBindings: 'type checked indeterminate disabled tabindex name autofocus form value content.isRequired:required aria-required'.w(),
  checked: false,
  disabled: false,
  indeterminate: false,
  'aria-required': Ember.computed.reads('content.isRequiredString'),

  _setupOnChange: Ember.on('init', function() {
    this.on('change', this, this._updateElementValue);
  }),

  _setupIndeterminate: Ember.on('didInsertElement', function() {
    this.get('element').indeterminate = !!this.get('indeterminate');
  }),

  _updateElementValue() {
    this.set('checked', this.$().prop('checked'));
  },

  change() {
    this.sendAction('action', this);
  }
});
