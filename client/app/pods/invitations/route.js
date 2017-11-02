import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord('token-invitation', {token: params.token});
  }
});
