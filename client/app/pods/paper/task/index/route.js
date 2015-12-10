import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    // Force the reload of the task when visiting the tasks' route.
    let task = this.store.findTask(params.task_id);
    if (task) {
      return task.reload();
    } else {
      return this.store.find('task', params.task_id);
    }
  },

  actions: {
    willTransition(transition) {
      this.controllerFor('paper.task').send('routeWillTransition', transition);
    }
  }
});
