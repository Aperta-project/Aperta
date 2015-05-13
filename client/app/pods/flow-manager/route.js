import AuthorizedRoute from 'tahi/routes/authorized';
import RESTless from 'tahi/services/rest-less';

export default AuthorizedRoute.extend({
  beforeModel(transition) {
    if (!this.currentUser) {
      return this.handleUnauthorizedRequest(transition);
    }
  },

  model() {
    let cachedModel = this.controllerFor('application').get('cachedModel');
    if (cachedModel) {
      this.controllerFor('application').set('cachedModel', null);
      return cachedModel;
    } else {
      return this.store.find('userFlow');
    }
  },

  afterModel() {
    return this.store.find('comment-look');
  },

  setupController(controller, model) {
    controller.setProperties({
      model: model,
      commentLooks: this.store.all('commentLook'),
      journalTaskType: this.store.all('journalTaskType')
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

      this.render('overlays/chooseNewFlowManagerColumn', {
        into: 'application',
        outlet: 'overlay',
        controller: controller
      });
    },

    removeFlow(flow) { flow.destroyRecord(); },
    saveFlow(flow)   { flow.save(); },

    viewCard(task) {
      let paperId = task.get('paper.id');
      let redirectParams = ['flow_manager'];
      this.controllerFor('application').get('overlayRedirect').pushObject(redirectParams);
      this.controllerFor('application').set('cachedModel', this.modelFor('flow_manager'));
      this.controllerFor('application').set('overlayBackground', 'flow_manager');
      this.transitionTo('paper.task', paperId, task.get('id'));
    }
  }
});
