import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';
import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';

export default AuthorizedRoute.extend({
  afterModel(model, transition) {
    return this.get('can').can('manage_workflow', model).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      } else {
        return model.get('tasks');
      }
    });
  },

  actions: {
    addTaskTypeToPhase(phase, taskTypeList) {
      if (!taskTypeList) { return; }

      let promises = [];

      // TODO: We need to do this via another method/route so that we can
      // use a hook to create the queue for a PaperEditor task
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
