import Ember from 'ember';

export default Ember.Controller.extend({
  queryParams: ['page', 'query', 'orderBy', 'orderDir'],

  // are set in route when in url
  // are reset on user page events
  page:     null,
  query:    null,
  orderBy:  null,
  orderDir: null,

  // are set in route w server meta data
  perPage:    null,
  totalCount: null,

  //on-page props
  queryInput: null,

  // true when naming a new saved query
  newQueryState: false,
  newQueryTitle: '',

  actions: {
    setPage(page) {
      this.set('page', page);
    },

    sort(orderBy, orderDir) {
      this.set('orderBy',  orderBy);
      this.set('orderDir', orderDir);
      this.set('page',     1);
    },

    search() {
      this.set('orderBy',  null);
      this.set('orderDir', null);
      this.set('page',     null);
      this.set('query', this.get('queryInput'));
    },

    clearSearch() {
      console.log('clearSearch');
      this.set('orderBy',  null);
      this.set('orderDir', null);
      this.set('page',     null);
      this.set('query',    null);
    },

    saveQuery() {
      this.store.createRecord('paper-tracker-query', {
        title: this.get('newQueryTitle'),
        query: this.get('queryInput')
      }).save();
      this.set('newQueryState', false);
    },

    startNewSavedQuery() {
      this.set('newQueryState', true);
    }
  }
});
