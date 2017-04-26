import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  model() {
    let paper = this.modelFor('paper');
    return paper.get('correspondence');
  },

  setupController(controller, model) {
    this._super(...arguments);
    controller.set('paper', this.modelFor('paper'));
  },
});
