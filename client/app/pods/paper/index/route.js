import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';
import RESTless from 'tahi/services/rest-less';

export default AuthorizedRoute.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  afterModel(model) {
    if (model.get('editable')) {
      return this.replaceWith('paper.edit', model);
    }
  },

  setupController(controller, model, transition) {
    model.set('versioningMode', !!transition.queryParams.showVersions);

    controller.set('model', model);
    controller.set('commentLooks', this.store.all('commentLook'));

    controller.set('versionsVisible', !!transition.queryParams.showVersions);
    controller.set('subNavVisible', !!transition.queryParams.showVersions);

    if (this.currentUser) {
      RESTless.authorize(controller, '/api/papers/' + (model.get('id')) + '/manuscript_manager', 'canViewManuscriptManager');
    }
  },

  actions: {
    viewCard(task) {
      this.get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.index', this.modelFor('paper')],
        overlayBackground: 'paper/index'
      });

      this.transitionTo('paper.task', this.modelFor('paper'), task.id);
    },

    editableDidChange() {
      this.replaceWith('paper.edit', this.modelFor('paper'));
    }
  }
});
