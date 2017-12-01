import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  model() {
    let paper = this.modelFor('paper');
    paper.reload();
    return Ember.RSVP.hash({
      paper : paper,
      tasks: paper.get('tasks')
    });
  },

  actions: {

    // Required until Ember has routable components.
    // We need to cleanup because controllers are singletons
    // and are not torn do
    willTransition() {
      this.controllerFor('paper.submit').setProperties({
        taskToDisplay: null,
        showTaskOverlay: false
      });
    }
  }
});
