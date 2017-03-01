import Ember from 'ember';

export default Ember.Component.extend({
  cards: [],
  journal: null,
  newCardOverlayVisible: false,

  cardsSorting: ['name'],
  sortedCards: Ember.computed.sort('filteredCards', 'cardsSorting'),
  filteredCards: Ember.computed('cards.@each.isNew', function () {
    return this.get('cards').filterBy('isNew', false);
  }),

  actions: {
    showNewCardOverlay() {
      this.set('newCardOverlayVisible', true);
    },

    hideNewCardOverlay() {
      this.set('newCardOverlayVisible', false);
    }
  }
});
