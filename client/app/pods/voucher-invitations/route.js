import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findRecord('voucher-invitation', params.token);
  },
  setupController(controller, model) {
    this._super(...arguments);

    controller.set('invitations', [model]);
  },

});
