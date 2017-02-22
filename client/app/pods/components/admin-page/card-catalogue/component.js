import Ember from 'ember';

export default Ember.Component.extend({
  cards: [],
  journal: null,
  newCardOverlayVisible: false,
  saving: [],

  allCards: Ember.computed.union('cards', 'saving'),
  cardsSorting: ['name'],
  sortedCards: Ember.computed.sort('allCards', 'cardsSorting'),

  actions: {
    showNewCardOverlay() {
      this.set('newCardOverlayVisible', true);
    },

    hideNewCardOverlay() {
      this.set('newCardOverlayVisible', false);
    },

    createCard(card) {
      this.set('saving', [card]);
      this.get('cards').update().then(() => {
        this.set('saving', []);
      });
    }
  }
});
