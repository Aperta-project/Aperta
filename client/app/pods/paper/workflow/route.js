import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';
import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';

export default AuthorizedRoute.extend({
  afterModel(paper) {
    // Ping manuscript_manager url for authorization.
    //
    // TODO: you shouldn't need to make a call to the server to decide
    // to render this page. Fix tasks#index to only return authorized
    // tasks, and then get this information off of user and paper
    // locally.
    let auth = new Ember.RSVP.Promise(function(resolve, reject) {
      return Ember.$.ajax({
        method: 'GET',
        url: '/api/papers/' + paper.get('id') + '/manuscript_manager',
        success(json) { return Ember.run(null, resolve, json); },
        error(xhr)    { return Ember.run(null, reject, xhr); }
      });
    });

    // We need tasks for this view, but we'll access them via phases;
    // fetching tasks *then* phases reduces the total number of requests.

    return Ember.RSVP.all([auth, paper.get('tasks'), paper.get('phases')]);
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
