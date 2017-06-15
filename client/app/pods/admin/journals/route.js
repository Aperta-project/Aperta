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
    //
    // for users with only one journal, transition to a route that
    // specifies a specific journal rather than behaving like
    // 'all journals'.
    //
    var defaultJournalID = 'all';
    if (!model.journal && model.journals.get('length') === 1) {
      defaultJournalID = model.journals.get('firstObject.id');
    }
    this.transitionTo('admin.journal.workflows', defaultJournalID);
  }
});
