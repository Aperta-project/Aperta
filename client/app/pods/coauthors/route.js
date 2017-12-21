import Ember from 'ember';

export default Ember.Route.extend({
  beforeModel(){
    if (this.currentUser) { this.transitionTo('dashboard'); }
  },

  model(params) {
    return this.store.findRecord('token-coauthor', params.token);
  },

  setupController(controller, model) {
    this.controllerFor('application').set('minimalChrome', true);
    controller.set('model', model);
  },

  actions: {
    save() {
      this.set('model.confirmationState', 'confirmed');
      this.get('controller.model').save();
    }
  }
});
