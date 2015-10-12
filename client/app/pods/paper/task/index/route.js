import Ember from 'ember';

export default Ember.Route.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  model(params) {
    // Force the reload of the task when visiting the tasks' route.
    let task = this.store.findTask(params.task_id);
    if (task) {
      task.reload();
    } else {
      task = this.store.find('task', params.task_id);
    }
    return task;
  },

  setupController(controller, model) {
    // TODO: Rename AdHocTask to Task (here, in views, and in templates)
    let redirectOptions = this.get('cardOverlayService.previousRouteOptions');
    let currentType     = model.get('type') === 'Task' ? 'AdHocTask' : model.get('type');
    let baseObjectName  = (currentType || 'AdHocTask').replace('Task', '');
    let taskController  = this.controllerFor('overlays/' + baseObjectName);

    this.set('baseObjectName', baseObjectName);
    this.set('taskController', taskController);

    taskController.setProperties({
      model: model,
      comments: model.get('comments'),
      participations: model.get('participations'),
      onClose: Ember.isEmpty(redirectOptions) ? 'redirectToDashboard' : 'redirect'
    });

    taskController.trigger('didSetupController');
  },

  resetController(controller, isExiting) {
    if (isExiting) { controller.set('isNewTask', false); }
  },

  renderTemplate() {
    this.render('overlays/' + this.get('baseObjectName'), {
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
