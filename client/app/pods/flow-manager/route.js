import AuthorizedRoute from 'tahi/routes/authorized';
import Ember from 'ember';

export default AuthorizedRoute.extend({
  cardOverlayService: Ember.inject.service('card-overlay'),

  beforeModel(transition) {
    if (!this.currentUser) {
      return this.handleUnauthorizedRequest(transition);
    }
  },

  model() {
    let cachedModel = this.get('cardOverlayService').get('cachedModel');
    if (cachedModel) {
      this.get('cardOverlayService').set('cachedModel', null);
      return cachedModel;
    } else {
      return this.store.find('user-flow');
    }
  },

  afterModel() {
    return this.store.find('comment-look');
  },

  setupController(controller, model) {
    controller.setProperties({
      model: model,
      commentLooks: this.store.all('comment-look'),
      journalTaskType: this.store.all('journal-task-type')
    });
  },

  actions: {
    removeFlow(flow) { flow.destroyRecord(); },
    saveFlow(flow)   { flow.save(); },

    viewCard(task) {
      this.get('cardOverlayService').setProperties({
        previousRouteOptions: ['flow_manager'],
        cachedModel: this.modelFor('flow_manager'),
        overlayBackground: 'flow_manager'
      });

      this.transitionTo('paper.task', task.get('paper.id'), task.get('id'));
    }
  }
});
