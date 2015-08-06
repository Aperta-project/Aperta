import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    hideNavigation() {
      this.attrs.hideNavigation();
    },

    showNavigation() {
      this.attrs.showNavigation();
    },

    showFeedbackOverlay() {
      this.attrs.showFeedbackOverlay();
    }
  }
});
