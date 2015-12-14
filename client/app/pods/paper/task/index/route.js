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

  // renderTemplate() {
  //   this.render('overlays/' + this.get('baseObjectName'), {
  //     into: 'application',
  //     outlet: 'overlay',
  //     controller: this.get('taskController')
  //   });

  //   this.render(this.get('cardOverlayService').get('overlayBackground'));
  //
  //   this.controllerFor('application').set('showOverlay', true);
  // },

  deactivate() {
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
