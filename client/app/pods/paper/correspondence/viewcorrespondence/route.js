import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  model(params) {
    return this.store.findRecord('correspondence', params.id, { reload: true });
  },
  actions: {
    removeCorrespondenceOverlay() {
      this.transitionTo('paper.correspondence', this.modelFor('paper'));
    }
  }
});
