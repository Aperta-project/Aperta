import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  store: Ember.inject.service(),
  model() {
    let paper = this.modelFor('paper');
    return this.store.createRecord('external-correspondence', {
      paper: paper
    });
  },
  actions: {
    removeCorrespondenceOverlay() {
      this.transitionTo('paper.correspondence', this.modelFor('paper'));
    }
  }
});
