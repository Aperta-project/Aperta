import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    hideNavigation: function() {
      this.attrs.hideNavigation();
    },

    showNavigation: function() {
      this.sendAction.showNavigation();
    },

    showFeedbackOverlay: function() {
      this.sendAction('showFeedbackOverlay');
    }
  }
});
