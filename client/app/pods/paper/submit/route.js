import Ember from 'ember';

export default Ember.Route.extend({
  actions: {

    exitVersions() {
      this.transitionTo('paper.index', this.modelFor('paper'));
    },
    // Required until Ember has routable components.
    // We need to cleanup because controllers are singletons
    // and are not torn down:

    willTransition() {
      this.controllerFor('paper.submit').setProperties({
        taskToDisplay: null,
        showTaskOverlay: false
      });
    }
  }
});
