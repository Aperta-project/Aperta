import Ember from 'ember';
import TaskComparisonDiff from 'tahi/models/task-comparison-diff';

export default Ember.Route.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  model(params) {
    return TaskComparisonDiff.create();
  },

  setupController(controller, model) {
    let redirectOptions = this.get('cardOverlayService.previousRouteOptions');
    let taskController  = this.controllerFor('overlays/versioned-task');

    this.set('taskController', taskController);

    taskController.setProperties({
      model: model,
      onClose: Ember.isEmpty(redirectOptions) ? 'redirectToDashboard' : 'redirect'
    });

    taskController.trigger('didSetupController');
  },

  renderTemplate() {
    this.render('overlays/versioned-task', {
      into: 'application',
      outlet: 'overlay',
      controller: this.get('taskController')
    });

    this.render(this.get('cardOverlayService').get('overlayBackground'));
    // TODO: meh:
    this.controllerFor('application').set('showOverlay', true);
  },

  deactivate() {
    this.send('closeOverlay');
    this.get('cardOverlayService').setProperties({
      previousRouteOptions: null,
      overlayBackground: null
    });
  },

  actions: {
    willTransition(transition) {
      this.get('taskController').send('routeWillTransition', transition);
    }
  }
});
