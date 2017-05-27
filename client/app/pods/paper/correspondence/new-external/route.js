import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  model() {
    // return this.store.peekRecord('correspondence', params.id);
  },
  actions: {
    removeCorrespondenceOverlay() {
      this.transitionTo('paper.correspondence', this.modelFor('paper'));
    }
  }
});
