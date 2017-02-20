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
  },

  afterModel(models) {
    //
    // for users with only one journal, transition to a route that
    // specifies a specific journal rather than behaving like
    // 'all journals'.
    //
    if (!models.journal && models.journals.get('length') === 1) {
      const defaultJournalID = models.journals.get('firstObject.id');
      this.transitionTo('admin.cc.journals',
        { queryParams: { journalID: defaultJournalID }}
      );
    }
  }
});
