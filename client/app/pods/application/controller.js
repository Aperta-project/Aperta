import Ember from 'ember';
import ENV from 'tahi/config/environment';

export default Ember.Controller.extend({
  delayedSave: false,
  isLoading: false,
  isLoggedIn: Ember.computed.notEmpty('currentUser'),
  canViewAdminLinks: false,
  canViewFlowManagerLink: false,

  clearError: function() {
    this.set('error', null);
  }.observes('currentPath'),

  resetScrollPosition: function() {
    window.scrollTo(0, 0);
  }.observes('currentPath'),

  overlayBackground: Ember.computed.oneWay('defaultBackground'),
  overlayRedirect: [],
  defaultBackground: 'overlay-background',

  testing: function() {
    return Ember.testing || ENV.environment === 'test';
  }.property(),

  showSaveStatusDiv: Ember.computed.and('testing', 'delayedSave'),

  navigationVisible: false,
  toggleNavigation: function() {
    $('html')[this.get('navigationVisible') ? 'addClass' : 'removeClass']('navigation-visible');
  }.observes('navigationVisible'),

  actions: {
    showNavigation() { this.set('navigationVisible', true); },
    hideNavigation() { this.set('navigationVisible', false); }
  }
});
