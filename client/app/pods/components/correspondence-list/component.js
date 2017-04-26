import Ember from 'ember';

export default Ember.Component.extend({
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
