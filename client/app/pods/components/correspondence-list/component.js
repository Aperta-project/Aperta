import Ember from 'ember';

export default Ember.Component.extend({
  showCorrespondenceOverlay: false,
  actions: {
    showCorrespondenceOverlay(message) {
      this.set('showCorrespondenceOverlay', true);
      this.set('message', message);
    },
    hideCorrespondenceOverlay() {
      this.set('showCorrespondenceOverlay', false);
    }
  }
});
