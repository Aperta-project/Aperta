import Ember from 'ember';

export default Ember.Route.extend({
  can: Ember.inject.service('can'),

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
      const firstJournal = model.journals.get('firstObject');

      return this.get('can').can('administer', firstJournal).then( (value)=> {
        const route = 'admin.journals.' + (value ? 'workflows' : 'users');
        return this.transitionTo(route, firstJournal.id);
      });
    }
  }
});
