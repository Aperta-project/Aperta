import AuthorizedRoute from 'tahi/routes/authorized';
import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

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
      return this.store.findAll('user-flow');
    }
  },

  afterModel() {
    return this.store.findAll('comment-look');
  },

  setupController(controller, model) {
    controller.setProperties({
      model: model,
      commentLooks: this.store.peekAll('comment-look'),
      journalTaskType: this.store.peekAll('journal-task-type')
    });
  },

  actions: {
    chooseNewFlowManagerColumn() {
      let controller = this.controllerFor('overlays/chooseNewFlowManagerColumn');
      controller.set('isLoading', true);

      RESTless.get('/api/user_flows/potential_flows').then(function(data) {
        controller.set('isLoading', false);
        controller.set('flows', data.flows);
      });

      this.send('openOverlay', {
        template: 'overlays/chooseNewFlowManagerColumn',
        controller: controller
      });
    },

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
