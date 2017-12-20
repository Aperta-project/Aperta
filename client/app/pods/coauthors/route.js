import Ember from 'ember';

export default Ember.Route.extend({
  beforeModel(){
    if (this.currentUser) { this.transitionTo('dashboard'); }
  },

  model(params) {
    return this.store.queryRecord('token-coauthor', {token: params.token});
  }
});
