import Ember from 'ember';

export default Ember.Controller.extend({
  correspondence: Ember.computed.alias('model'),
  showCorrespondenceOverlay: true,
  actions: {
    showCorrespondenceOverlay() {
      this.set('showCorrespondenceOverlay', true);
    },
    hideCorrespondenceOverlay() {
      this.set('showCorrespondenceOverlay', false);
    }
  }
});
