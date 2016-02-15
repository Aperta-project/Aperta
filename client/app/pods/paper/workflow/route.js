import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';
import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';

export default AuthorizedRoute.extend({
  afterModel(model) {
    return model.get('tasks');
  },

  actions: {
    addTaskTypeToPhase(phase, taskTypeList) {
      if (!taskTypeList) { return; }

      let promises = [];

      taskTypeList.forEach((task) => {
        let unNamespacedKind = deNamespaceTaskType(task.get('kind'));
        let newTaskPromise = this.store.createRecord(unNamespacedKind, {
          phase: phase,
          oldRole: task.get('oldRole'),
          type: task.get('kind'),
          paper: this.modelFor('paper'),
          title: task.get('title')
        }).save();

        promises.push(newTaskPromise);
      });

      Ember.RSVP.all(promises);
    },

    // Required until Ember has routable components.
    // We need to cleanup because controllers are singletons
    // and are not torn down:

    willTransition() {
      this.controllerFor('paper.workflow').setProperties({
        taskToDisplay: null,
        showTaskOverlay: false
      });
    }
  }
});
