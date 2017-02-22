import Ember from 'ember';

export default Ember.Component.extend({
  journals: [],
  journalSort: ['name:asc'],
  sortedJournals: Ember.computed.sort('journals', 'journalSort'),

  classNames: ['admin-page'],

  multipleJournals: Ember.computed('journals.[]', function() {
    return this.get('journals.length') > 1;
  })
});
