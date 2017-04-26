import Ember from 'ember';

export default Ember.Component.extend({
  showCorrespondenceOverlay: false,
  actions: {
    showCorrespondenceOverlay() {
      this.set('showCorrespondenceOverlay', true);
    },
    hideCorrespondenceOverlay() {
      this.set('showCorrespondenceOverlay', false);
    }
  }
});
