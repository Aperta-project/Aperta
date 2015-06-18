import Ember from 'ember';

export default Ember.Component.extend({
  _didUpdateAttrs: Ember.on('didUpdateAttrs', function() {
  }),

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
