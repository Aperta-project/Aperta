import Ember from 'ember';

export default Ember.Route.extend({
  featureFlag: Ember.inject.service(),

  setupController(controller, model) {
    const flagValue = this.get('featureFlag').value('PREPRINT');
    controller.set('preprintsEnabled', flagValue);
    return this._super(controller, model);
  },

  actions: {
    willTransition(transition) {
      if (this.controller.get('pendingChanges')) {
        alert("There are changes in this template please save first");
        transition.abort();
      }
    }
  }
});
