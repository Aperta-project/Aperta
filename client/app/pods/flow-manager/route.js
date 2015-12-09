import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  beforeModel(transition) {
    if (!this.currentUser) {
      return this.handleUnauthorizedRequest(transition);
    }
  },

  model() {
    return this.store.find('user-flow');
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
    saveFlow(flow)   { flow.save(); }
  }
});
