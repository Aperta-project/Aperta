import Ember from 'ember';

export default Ember.Controller.extend({
  queryParams: ['page'],
  page: null,       // is set in route w server meta data
  perPage: null,    // is set in route w server meta data
  totalCount: null, // is set in route w server meta data

  actions: {
    setPage(page) {
      this.set('page', page); // triggers route reload
    }
  }
});
