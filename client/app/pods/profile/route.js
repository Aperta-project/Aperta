import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized'

export default AuthorizedRoute.extend( {
  can: Ember.inject.service('can'),
  model() { return this.currentUser; },

  beforeModel(transition){
    this.get('can').can('view_profile', this.currentUser).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
    })
  },

  afterModel(model) {
    return Ember.$.getJSON('/api/affiliations', function(data) {
      if(!data) { return; }
      model.set('institutions', data.institutions);
    });
  }
});
