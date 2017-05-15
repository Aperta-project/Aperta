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
