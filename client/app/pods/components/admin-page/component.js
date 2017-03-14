import Ember from 'ember';

export default Ember.Component.extend({
  journals: [],
  journalSort: ['name:asc'],
  sortedJournals: Ember.computed.sort('journals', 'journalSort'),
  newJournalOverlayVisible: false,

  classNames: ['admin-page'],

  multipleJournals: Ember.computed('journals.[]', function() {
    return this.get('journals.length') > 1;
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
