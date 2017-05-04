import Ember from 'ember';

export default Ember.Route.extend({
  setupController() {
    this.controllerFor('application').set('minimalChrome', true);
  }
});
