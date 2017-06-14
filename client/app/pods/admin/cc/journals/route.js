import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.findAll('admin-journal').then((journals) => {
      return {
        journals: journals,
        journal: journals.get('firstObject')
      };
    });
  },

  afterModel(model) {
    this.transitionTo('admin.cc.journal.workflows', model.journal.id);
  }
});
