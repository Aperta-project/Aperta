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
      if (taskTypeList.length == 0) { 
        this.flash.displayRouteLevelMessage('error', "you didn't select");
        return;
      }

      let promises = [];

      taskTypeList.forEach((task) => {
        let unNamespacedKind = deNamespaceTaskType(task.get('kind'));
        let newTaskPromise = this.store.createRecord(unNamespacedKind, {
          phase: phase,
          type: task.get('kind'),
          paper: this.modelFor('paper'),
          title: task.get('title')
        }).save().catch((errors, errors2) => {
          debugger;
          this.flash.displayRouteLevelMessage('error', 'sorry someting went wrong.');
        });

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
