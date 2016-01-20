import Ember from 'ember';
import { CanMixin } from 'ember-can';
import AuthorizedRoute from 'tahi/routes/authorized'

export default AuthorizedRoute.extend(CanMixin, {
  model() { return this.currentUser; },

  beforeModel(transition){
    if (!this.can('view_profile', this.currentUser)){
      return this.handleUnauthorizedRequest(transition);
    }
  },

  afterModel(model) {
    return Ember.$.getJSON('/api/affiliations', function(data) {
      if(!data) { return; }
      model.set('institutions', data.institutions);
    });
  }
});
