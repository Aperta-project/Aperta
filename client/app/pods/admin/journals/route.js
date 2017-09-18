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

  afterModel(model, transition) {
    if (transition && this._nonAdminRoute(transition)) { return; }
    const journal = this._determineSubject(model);

    if (journal) {
      return this.get('can').can('administer', journal).then( (value)=> {
        // allow any transition if permissions exits
        if (value) { return; }

        const route = 'admin.journals.' + (value ? 'workflows' : 'users');
        if (!transition || !(transition.targetName === route)){
          return this.transitionTo(route, journal.id);
        }
      });
    }
  },

  _nonAdminRoute(transition) {
    return this.get('_manage_users_routes').some((name) => {
      return transition.targetName.match(name);
    });
  },

  _determineSubject(model) {
    // For users with one journal, transition to that journal rather than 'all journals'.
    if (model.journal) {
      return model.journal;
    }
    else if (model.journals.get('length') === 1) {
      return model.journals.get('firstObject');
    }
  },

  _manage_users_routes: [/users$/,  /mailtemplates$/]
});
