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

  actions: {
    setPage(page) {
      this.set('page', page); // triggers route reload
    },

    sort(orderBy, orderDir) {
      this.set('orderBy',  orderBy);
      this.set('orderDir', orderDir);
      this.set('page',     page); // triggers route reload
    }
  }
});
