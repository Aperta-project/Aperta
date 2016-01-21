import Ember from 'ember';

export default Ember.Controller.extend({
  queryParams: ['page'],
  page: null,
  perPage: null,
  totalCount: null,

  actions: {
    setPage(page) {
      this.set('page', page); // triggers route reload
    }
  }
});
