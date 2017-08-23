import Ember from 'ember';
import ENV from 'tahi/config/environment';
import pusherConcerns from 'tahi/mixins/controllers/pusher-concerns';

export default Ember.Controller.extend(pusherConcerns, {
  can: Ember.inject.service('can'),
  delayedSave: false,
  isLoggedIn: Ember.computed.notEmpty('currentUser'),
  canViewAdminLinks: false,
  showOverlay: false,
  showFeedbackOverlay: false,
  journals: null,
  canViewPaperTracker: false,
  healthCheck: Ember.inject.service('health-check'),
  minimalChrome: false,

  init: function() {
    this._super(...arguments);
    this.get('healthCheck').start();
  },

  setCanViewPaperTracker: function() {
    if (this.journals === null) {
      return false;
    }
    var that = this;
    this.journals.toArray().forEach(function(journal) {
      that.get('can').can('view_paper_tracker', journal).then( (value) =>
        Ember.run(function() {
          if (value) {
            that.set('canViewPaperTracker', true);
          }
        })
      );
    });
  },

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

  actions: {
    showFeedbackOverlay() { this.set('showFeedbackOverlay', true); },
    hideFeedbackOverlay() { this.set('showFeedbackOverlay', false); }
  }
});
