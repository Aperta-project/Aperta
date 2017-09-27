import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  beforeModel(transition){
    this.set('previousTransition', transition);
  },

  model(params) {
    return this.store.findRecord('task', params.task_id)
      .catch(() => {
        this.handleUnauthorizedRequest(this.get('previousTransition'));
      });
  },

  afterModel(task) {
    let assignedUser = task.get('assignedUser');
    if (assignedUser) this.store.pushPayload({'user': assignedUser});
  },
  actions: {
    willTransition(transition) {
      this.controllerFor('paper.task').send('routeWillTransition', transition);
    }
  }
});
