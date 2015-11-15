import Ember from 'ember';
import ENV from 'tahi/config/environment';

const { computed, observer } = Ember;

export default Ember.Controller.extend({
  delayedSave: false,
  isLoading: false,
  isLoggedIn: computed.notEmpty('currentUser'),
  canViewAdminLinks: false,
  canViewFlowManagerLink: false,
  showOverlay: false,
  showFeedbackOverlay: false,

  clearError: observer('currentPath', function() {
    this.set('error', null);
  }),

  resetScrollPosition: observer('currentPath', function() {
    window.scrollTo(0, 0);
  }),

  testing: computed(function() {
    return Ember.testing || ENV.environment === 'test';
  }),

  showSaveStatusDiv: computed.and('testing', 'delayedSave'),

  specifiedAppName: window.appName,

  actions: {
    showFeedbackOverlay() { this.set('showFeedbackOverlay', true); },
    hideFeedbackOverlay() { this.set('showFeedbackOverlay', false); }
  }
});
