import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),
  cardOverlayService: Ember.inject.service('card-overlay'),

  afterModel(model) {
    if (model.get('editable')) {
      return this.replaceWith('paper.edit', model);
    }
  },

  setupController(controller, model) {
    controller.set('model', model);
    controller.set('commentLooks', this.store.all('commentLook'));

    if (this.currentUser) {
      let url = '/api/papers/' + (model.get('id')) + '/manuscript_manager';
      this.get('restless').authorize(controller, url, 'canViewManuscriptManager');
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
