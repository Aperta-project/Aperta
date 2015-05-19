import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.find('task', params.task_id);
  },

  setupController: function(controller, model) {
    // TODO: Rename AdHocTask to Task (here, in views, and in templates)
    let overlayRedirect = this.controllerFor('application').get('overlayRedirect');
    let currentType     = model.get('type') === 'Task' ? 'AdHocTask' : model.get('type');
    let baseObjectName  = (currentType || 'AdHocTask').replace('Task', '');
    let taskController  = this.controllerFor('overlays/' + baseObjectName);

    this.set('baseObjectName', baseObjectName);
    this.set('taskController', taskController);

    taskController.setProperties({
      model: model,
      comments: this.store.filter('comment', function(part) {
        return part.get('task') === model;
      }),
      participations: this.store.filter('participation', function(part) {
        return part.get('task') === model;
      }),
      onClose: Ember.isEmpty(overlayRedirect) ? 'redirectToDashboard' : 'redirect'
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

    this.render(this.controllerFor('application').get('overlayBackground'));
  },

  deactivate() {
    this.send('closeOverlay');
    this.controllerFor('application').setProperties({
      overlayRedirect: [],
      overlayBackground: null
    });
  },

  actions: {
    willTransition(transition) {
      this.get('taskController').send('routeWillTransition', transition);
    }
  }
});
