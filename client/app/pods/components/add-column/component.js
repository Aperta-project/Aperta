import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'span',
  classNameBindings: [':add-column', 'bonusClass'],
  attributeBindings: ['toggle:data-toggle', 'placement:data-placement', 'title'],

  toggle: 'tooltip',
  placement: 'auto right',
  title: 'Add Phase',

  click() {
    this.sendAction('action', this.get('position'));
  },

  setupTooltip: Ember.on('didInsertElement', function() {
    this.$().tooltip();
  })
});
