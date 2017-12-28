import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findRecord('token-coauthor', params.token);
  },

  setupController(controller, model) {
    this.controllerFor('application').set('minimalChrome', true);
    controller.set('model', model);
  }
});
