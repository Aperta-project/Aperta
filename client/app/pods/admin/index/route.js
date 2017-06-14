import Ember from 'ember';

export default Ember.Route.extend({
  featureFlag: Ember.inject.service(),

  beforeModel() {
    this.transitionTo('admin.journals'); 
  }
});
