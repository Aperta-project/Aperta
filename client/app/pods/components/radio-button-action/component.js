import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'input',
  type: 'radio',
  attributeBindings: ['name', 'type', 'value', 'checked:checked', 'disabled'],

  _throwDeprecationWarning: Ember.on('init', function() {
    Ember.deprecate(
      'TAHI DEPRECATION: RadioButtonAction is deprecated in favor of RadioButton.',
      false,
      { url: 'https://github.com/Tahi-project/tahi/wiki/Tahi-Ember-1.13-Transition-Guide#radiobuttonaction' }
    );
  }),

  checked: Ember.computed('selection', 'value', function() {
    return Ember.isEqual(this.get('selection'), this.get('value'));
  }),

  change() {
    this.set('selection', this.get('value'));
    this.sendAction('action', this.get('value'));
  }
});
