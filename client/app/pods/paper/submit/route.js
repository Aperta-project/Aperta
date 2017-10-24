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

  // After loading the paper and the associated tasks
  // find the Preprint Posting custom card.
  // Load the answers on that card and locate the preprintOptOut
  // field. Set the paper.preprintOptOut field.
  // FYI - the preprintOptOut field is defined on paper in the
  // backend data model but is never set by any component. Its set
  // here in the UI only on load and is not persisted to the backend.
  //


  afterModel(model) {
    let prePrintTask = model.tasks.findBy('title', 'Preprint Posting');

    // set the model based on the located preprint posting task
    // if there is no preprint posting task do nothing and use the
    // default value which is false
    if(prePrintTask) {
      prePrintTask.get('answers').then((answers) => {
        let value = answers.get('firstObject').get('value');
        model.paper.set('preprintOptOut', (value === '2'));
      });
    }
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
