import Ember from 'ember';

export default Ember.Route.extend({
  queryParams: {
    journalID: { refreshModel: true }
  },

  model(params) {
    return this.store.findAll('admin-journal').then((journals) => {
      return {
        journals: journals,
        journal: journals.find(j => j.id === params.journalID)
      };
    });
  }
});
