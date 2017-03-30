import Ember from 'ember';

export default Ember.Component.extend({
  journals: [],
  persistedJournals: Ember.computed.filterBy('journals', 'isNew', false),

  journalSort: ['name:asc'],
  sortedJournals: Ember.computed.sort('persistedJournals', 'journalSort'),
  newJournalOverlayVisible: false,

  classNames: ['admin-page'],

  multipleJournals: Ember.computed('persistedJournals.[]', function() {
    return this.get('persistedJournals.length') > 1;
  }),

  actions: {
    showNewJournalOverlay() {
      this.set('newJournalOverlayVisible', true);
    },

    hideNewJournalOverlay() {
      this.set('newJournalOverlayVisible', false);
    }
  }
});
