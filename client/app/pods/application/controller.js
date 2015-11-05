import Ember from 'ember';
import ENV from 'tahi/config/environment';

export default Ember.Controller.extend({
  delayedSave: false,
  isLoading: false,
  isLoggedIn: Ember.computed.notEmpty('currentUser'),
  canViewAdminLinks: false,
  canViewFlowManagerLink: false,
  showOverlay: false,

  clearError: Ember.observer('currentPath', function() {
    this.set('error', null);
  }),

  resetScrollPosition: Ember.observer('currentPath', function() {
    window.scrollTo(0, 0);
  }),

  testing: Ember.computed(function() {
    return Ember.testing || ENV.environment === 'test';
  }),

  showSaveStatusDiv: Ember.computed.and('testing', 'delayedSave'),

  specifiedAppName: window.appName,
});
