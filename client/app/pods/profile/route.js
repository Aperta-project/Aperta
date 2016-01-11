import Ember from 'ember';
import { CanMixin } from 'ember-can';

export default Ember.Route.extend(CanMixin, {
  model() { return this.currentUser; },

  beforeModel(){
    if (!this.can('view_profile', this.currentUser)){
      this.transitionTo('dashboard');
    }
  },

  afterModel(model) {
    return Ember.$.getJSON('/api/affiliations', function(data) {
      if(!data) { return; }
      model.set('institutions', data.institutions);
    });
  }
});
