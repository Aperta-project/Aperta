import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findAll('admin-journal').then((journals) => {
      return {
        journals: journals,
        journal: journals.find(j => j.id === params.journal_id)
      };
    });
  },

  afterModel(model) {
    // For users with one journal, transition to that journal rather than 'all journals'.
    if (!model.journal && model.journals.get('length') === 1) {
      this.transitionTo('admin.journals.workflows', model.journals.get('firstObject.id'));
    }
  }
});
