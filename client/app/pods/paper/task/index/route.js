import AuthorizedRoute from 'tahi/pods/authorized/route';

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

  actions: {
    willTransition(transition) {
      this.controllerFor('paper.task').send('routeWillTransition', transition);
    }
  }
});
