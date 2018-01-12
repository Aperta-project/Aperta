import Ember from 'ember';
import AuthorizedRoute from 'tahi/pods/authorized/route';

export default AuthorizedRoute.extend( {
  model() { return this.currentUser; },

  beforeModel(transition){
    this.get('can').can('view', this.currentUser).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
    });
  },

  afterModel(model) {
    return Ember.$.getJSON('/api/affiliations', function(data) {
      if(!data) { return; }
      model.set('institutions', data.institutions);
    });
  }
});
