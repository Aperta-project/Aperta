import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  beforeModel(transition){
    this.set('previousTransition', transition);
  },

  model(params) {
    // Force the reload of the task when visiting the tasks' route.
    let task = this.store.findTask(params.task_id);
    if (task) {
      return task.reload();
    } else {
      return this.store.find('task', params.task_id).then(
        (task) => { return task; },
        () => {
          this.handleUnauthorizedRequest(this.get('previousTransition'));
        }
      );
    }
  },

  actions: {
    willTransition(transition) {
      this.controllerFor('paper.task').send('routeWillTransition', transition);
    }
  }
});
