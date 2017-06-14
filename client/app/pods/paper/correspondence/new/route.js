import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  actions: {
    removeCorrespondenceOverlay() {
      this.transitionTo('paper.correspondence', this.modelFor('paper'));
    }
  }
});
