import Ember from 'ember';

export default Ember.Route.extend({
  model() { return this.currentUser; },

  afterModel(model) {
    return Ember.$.getJSON('/api/affiliations', function(data) {
      if(!data) { return; }
      model.set('institutions', data.institutions);
    });
  }
});
