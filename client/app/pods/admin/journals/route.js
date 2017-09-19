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
    if (this._transitionRoutable(model, transition)) { return; }

    if (this._needsRedirection(model)) {
      const journal = this._determineSubject(model, transition);

      return this.get('can').can('administer', journal).then( (value)=> {
        if (model.journal && value) { return; }

        const route = 'admin.journals.' + (value ? 'workflows' : 'users');
        if (!transition || !(transition.targetName === route) || this._invalidAllTransition(model, transition)) {
          return this.transitionTo(route, journal.id);
        }
      });
    }
  },

  _transitionRoutable(model, transition) {
    if (!transition || this._invalidAllTransition(model, transition)) { return false; }

    return this.get('_manageUsersRoutes').some((name) => {
      return transition.targetName.match(name);
    });
  },

  _determineSubject(model) {
    if (model.journal) {
      return model.journal;
    }
    else {
      return model.journals.get('firstObject');
    }
  },

  _needsRedirection(model) {
    return (!model.journal && model.journals.get('length') === 1) ||
      model.journal;
  },

  _invalidAllTransition(model, transition) {
    // avoids going to `journals/all` routes with only one journal
    return transition.params['admin.journals'].journal_id === 'all' &&
      model.journals.get('length') === 1;
  },

  _manageUsersRoutes: [/users$/,  /mailtemplates$/]
});
