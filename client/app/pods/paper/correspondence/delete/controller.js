import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    hideCorrespondenceOverlay() {
      this.transitionToRoute('paper.correspondence.viewcorrespondence', this.get('model.id'));
    }
  }
});