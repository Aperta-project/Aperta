import Ember from 'ember';

export default Ember.Route.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  model(params) {
    this.set('params', params)
    return this.store.find('task', params.task_id);
  },

  afterModel(model) {
    return Ember.RSVP.all([model.get('snapshots')]);
  },

  setupController(controller, model) {
    let redirectOptions = this.get('cardOverlayService.previousRouteOptions');
    let taskController = this.controllerFor('overlays/versioned_metadata');
    this.set('taskController', taskController);
    taskController.setProperties({
      model: model,
      majorVersion: this.get('params.majorVersion'),
      minorVersion: this.get('params.minorVersion'),
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
