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
    let assignedUserId = task.get('assignedUserId');
    if (!assignedUserId) return;
    this.store.findRecord('user', assignedUserId).then(function(user) {
      task.set('assignedUser', user);
    });
  },
  actions: {
    willTransition(transition) {
      this.controllerFor('paper.task').send('routeWillTransition', transition);
    }
  }
});
