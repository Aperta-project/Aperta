import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  model() {
    return this.store.createRecord('correspondence', {
      paper: this.modelFor('paper')
    });
  },

  actions: {
    removeCorrespondenceOverlay() {
      // this.modelFor('paper.correspondence.new').deleteRecord();
      this.transitionTo('paper.correspondence', this.modelFor('paper'));
    }
  }
});
