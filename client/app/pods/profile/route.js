import Ember from 'ember';

export default Ember.Route.extend({
  model: function() { return this.currentUser; },

  afterModel: function(model) {
    return Ember.$.getJSON('/api/affiliations', function(data) {
      if(!data) { return; }
      model.set('institutions', data.institutions);
    });
  }
});
