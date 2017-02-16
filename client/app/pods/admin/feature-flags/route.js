import Ember from 'ember';

export default Ember.Route.extend({
  restless: Ember.inject.service(),

  model() {
    if (!this.get('currentUser.siteAdmin')) {
      this.transitionTo('dashboard').then(()=> {
        this.flash.displayRouteLevelMessage(
          'error',
          'Only site admins may edit feature flags.'
        );
      });
    }

    return this.get('restless').get('/api/feature_flags').then(
      it => new Ember.Object(it)
    );
  }
});
