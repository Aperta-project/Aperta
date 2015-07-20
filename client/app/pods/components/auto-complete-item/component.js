import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':auto-complete-item', 'highlighted:auto-complete-item--highlight'],

  highlighted: Ember.computed('item', 'highlightedItem', function() {
    return Ember.isEqual(this.get('highlightedItem'), this.get('item'));
  }),

  mouseEnter() {
    this.set('highlightedItem', this.get('item'));
  }
});
