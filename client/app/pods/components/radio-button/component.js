import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'input',
  type: 'radio',
  attributeBindings: ['name', 'type', 'value', 'checked:checked:', 'disabled'],

  checked: function() {
    return this.get('selection') === this.get('value');
  }.property('selection'),

  change() {
    this.set('selection', this.$().val());
  }
});
