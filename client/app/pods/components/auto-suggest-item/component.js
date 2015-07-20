import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':auto-suggest-item', 'highlighted:auto-suggest-item--highlight'],

  highlighted: Ember.computed('item', 'highlightedItem', function() {
    return Ember.isEqual(this.get('highlightedItem'), this.get('item'));
  }),

  mouseEnter() {
    this.set('highlightedItem', this.get('item'));
  }
});
