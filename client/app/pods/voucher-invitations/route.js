import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findRecord('voucher-invitation', params.token);
  },
  setupController(controller, model) {
    this._super(...arguments);

    if (model.get('invited')) {
      model.setDeclined();
      model.set('pendingFeedback', true);
    } else if (model.get('declined') || model.get('rescinded')) {
      controller.set('inactive', true);
    }

    controller.set('invitations', [model]);
  },

});
