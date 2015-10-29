import Ember from 'ember';

export default Ember.Route.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  model(params) {
    // Force the reload of the task when visiting the tasks' route.
    let task = this.store.findTask(params.task_id);
    if (task) {
      return task.reload();
    } else {
      return this.store.find('task', params.task_id);
    }
  },

  afterModel(model) {
    return Ember.RSVP.all([model.get('nestedQuestions'),
                           model.get('nestedQuestionAnswers')]);
  },

  setupController(controller, model) {
    let redirectOptions = this.get('cardOverlayService.previousRouteOptions');
    let taskController  = this.controllerFor('overlays/versioned_metadata');
    this.set('taskController', taskController);
    taskController.setProperties({
      model: model,
      comments: model.get('comments'),
      participations: model.get('participations'),
      onClose: Ember.isEmpty(redirectOptions) ? 'redirectToDashboard' : 'redirect'
    });
  },

  renderTemplate() {
    this.render('overlays/versioned_metadata', {
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
